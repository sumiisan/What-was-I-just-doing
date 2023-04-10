
import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter/services.dart' show PlatformAssetBundle, rootBundle;
import 'package:path_provider/path_provider.dart';

const int _tSampleRate = 44100;
const int _tNumChannels = 1;

/// Example app.
class AudioProcessor extends StatefulWidget {
  const AudioProcessor({super.key, required String path}) : mediaPath = path;

  final String mediaPath;

  @override
  _AudioProcessorState createState() => _AudioProcessorState(mediaPath: mediaPath);
}

class _AudioProcessorState extends State<AudioProcessor> {
  _AudioProcessorState({required this.mediaPath});
  FlutterSoundPlayer? _mPlayer = FlutterSoundPlayer(logLevel: Level.error);
  late bool _mPlayerIsInited;
  Uint8List? buffer;
  bool busy = false;

  final String mediaPath;

  Future<Uint8List> getAssetData(String path) async {
    var byteData = await rootBundle.load(path);
    return byteData.buffer.asUint8List();
  }

  Future<Uint8List> getTemporaryData(String path) async {
    var file = File(path);
    return file.readAsBytes();
  }

  Future<void> init() async {
    await _mPlayer!.openPlayer();
  }

  @override
  void initState() {
    super.initState();
    init().then((value) => setState(() {
          _mPlayerIsInited = true;
        }));
  }

  @override
  void dispose() {
    _mPlayer!.stopPlayer();
    _mPlayer!.closePlayer();
    _mPlayer = null;

    super.dispose();
  }

  void play({required String path, void Function()? onPlayEnded}) async {
    if (!busy && _mPlayerIsInited) {
      busy = true;

      if (path.startsWith('temp:')) {
        final directory = await getTemporaryDirectory();
        buffer = FlutterSoundHelper().waveToPCMBuffer(
          inputBuffer: await getTemporaryData("$directory/${path.substring(5)}"),
        );
      }
      if (path.startsWith('assets:')) {
        buffer = FlutterSoundHelper().waveToPCMBuffer(
          inputBuffer: await getAssetData("assets/${path.substring(7)}"),
        );
      }
      await _mPlayer!.startPlayerFromStream(
        codec: Codec.pcm16,
        numChannels: _tNumChannels,
        sampleRate: _tSampleRate,
      );

      var sl = normalizeAndStripSilence(buffer!.buffer.asByteData(0));
      sl = octaveUp(sl);

      await _mPlayer!.feedFromStream(sl.buffer.asUint8List(sl.offsetInBytes, sl.lengthInBytes));
      busy = false;
      if (onPlayEnded != null) { onPlayEnded(); }
    }
  }

  Future<void> playSequence({required List items, void Function()? onPlayEnded}) async {
    var ready = (_mPlayerIsInited && (_mPlayer?.isStopped ?? false));

    if (!ready) {
      return;
    }

    if (items.isEmpty) {
      if (onPlayEnded != null) {
        onPlayEnded();
      }
      return;
    }

    var queue = [...items]; // copy the list
    var currentItem = queue.removeAt(0);
    
    if (currentItem == "*") { // replace "*" by the recorded file
      currentItem = "temp:$mediaPath";
    } else {
      currentItem = "assets:/audio/$mediaPath";
    }

    Logger().log(Level.debug, "Recorder.play() $currentItem");

    _mPlayer!
        .startPlayer(
            fromURI: currentItem,
            whenFinished: () {
              setState(() {
              });
              playSequence(items: queue, onPlayEnded: onPlayEnded);
            })
        .then((value) {
      setState(() {
      });
    });
  }

  ByteData octaveUp(ByteData input) {
    const cycle = 6000;
    const halfCycle = 3000;

    var length = input.lengthInBytes;
    var output = ByteData(length);

    int p = 0;
    while(p < length) {
      int w = 0;
      for (var q = 0; q < cycle; q += 4) {
        if (p + q >= length || p + w + halfCycle >= length) break;
        var v1 = input.getInt16(p + q, Endian.host);
        output.setInt16(p + w, v1, Endian.host);
        var v2 = input.getInt16(p + q + 2, Endian.host);
        output.setInt16(p + w + halfCycle, v2, Endian.host);
        w += 2;
      }
      p += cycle;
    }

    return output;
  }

  ByteData normalizeAndStripSilence(ByteData data) {
    var input = data;
    var length = input.lengthInBytes;
    
    var output = ByteData(length);
    var writePosition = 0;

    double rms = calculateRMS(input);
    
    //  normalizer
    var targetAmp = 0.5;
    var scale = targetAmp / rms;

    amplify(input, scale: scale);

    //  gate
    var p = 0;

    var startMutePosition = 0;
    var endMutePosition = 0;
    var margin = 1024;

    while (p < length) {
      var positions = findNextGap(input, seekStartPosition: p);
      startMutePosition = positions[0];
      if (startMutePosition - margin > endMutePosition) {  // if there is a gap between the previous and the current one
        startMutePosition -= margin;  // move the start of the mute gap back by 1024 samples
      }
      endMutePosition = positions[1];
      if (endMutePosition + margin < length) {  // if there is a gap after the current one
        endMutePosition += margin;  // move the end of the mute gap forward by 1024 samples
      }

      if (startMutePosition == length) {  // no more gaps
        if (writePosition == 0) {   // no gaps found at all
          return input;
        }
        break;
      }

      for (; p < startMutePosition; p += 2) {  // copy buffer until we reach the start of the mute gap
        output.setUint16(writePosition, input.getInt16(p, Endian.host), Endian.host);
        writePosition += 2;
      }
      p = endMutePosition;    // skip the mute gap
    }

    return output.buffer.asByteData(0, writePosition);    // crop tail
  }

  void amplify(ByteData buffer, {required double scale}) {
    var length = buffer.lengthInBytes;
    for (var p = 0; p < length; p += 2) {
      var sample = buffer.getInt16(p, Endian.host).toDouble();
      var scaled = (sample * scale).round();
      buffer.setInt16(p, scaled.clamp(-0x7fff, 0x7fff), Endian.host);
    }
  }

  List<int> findNextGap(ByteData buffer, {int seekStartPosition = 0}) {
    var length = buffer.lengthInBytes;
    var startMutePosition = seekStartPosition;
    var endMutePosition = seekStartPosition;
    var gateThreshold = 0.05 * 0x7fff;   // this is fixed because we assume a normalized input

    var p = seekStartPosition;
    var minimumGap = 0.2 * _tSampleRate;

    while(p < length) {

      for (; p < length; p += 2) {   // seek to the first sample BELOW the gate threshold
        var v = buffer.getInt16(p, Endian.host).toDouble();
        if (v.abs() <= gateThreshold) break;
      }
      startMutePosition = p;

      for (; p < length; p += 2) {  // seek to the first sample ABOVE the gate threshold
        var v = buffer.getInt16(p, Endian.host).toDouble();
        if (v.abs() > gateThreshold) break;
      }
      endMutePosition = p;

      // return gap if it's long enough
      var gapLength = endMutePosition - startMutePosition;
      if (gapLength > minimumGap) {
        return [startMutePosition, endMutePosition];
      }
    }
    return [length, length];
  }

  double calculateRMS(ByteData buffer) {
    var length = (buffer.lengthInBytes / 2).floor();
    double sum = 0;
    for (var p = 0; p < length; p++) {
      var sample = buffer.getInt16(p, Endian.host).toDouble() / 0x7fff;
      sum += pow(sample, 2);
    }
    var rms = sqrt(sum / length);
    return rms;
  }


  // ----------------------------------------------------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(3),
          padding: const EdgeInsets.all(3),
          height: 80,
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Color(0xFFFAF0E6),
            border: Border.all(
              color: Colors.indigo,
              width: 3,
            ),
          ),
          child: Row(children: [
            ElevatedButton(
              onPressed: () {
                play(path: "temp:$mediaPath");
              },
              //color: Colors.white,
              child: Text('Play!'),
            ),
          ]),
        ),
      ],
    );
  }
}