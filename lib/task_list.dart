import 'package:flutter/material.dart';
import 'package:what_was_i_just_doing/simple_recorder.dart';
import 'app_state.dart';
import 'task.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TaskListWidget extends StatefulWidget {
  const TaskListWidget({
    super.key,
    required this.appState,
  });

  final AppState appState;

  @override
  State<TaskListWidget> createState() => _TaskListWidgetState();
}

class _TaskListWidgetState extends State<TaskListWidget> {
  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context)?.localeName ?? "en";

    return 
    Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children:[
        ElevatedButton(
          onPressed: () { 
            widget.appState.closeTaskList();
          }, 
          style: ElevatedButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.primary,
            backgroundColor: Theme.of(context).colorScheme.background,
          ),
          child: Text("close task list")
        ),

        FutureBuilder(future: widget.appState.getTasks(),
          builder: (context, AsyncSnapshot<List<Task>>tasks) {
            if (tasks.hasData) {
              NumberFormat timeFormat = NumberFormat("#,##0.0", locale);
              const visualDensity = VisualDensity(horizontal: -4, vertical: -4);
              return Column(
                children: [
                  for (var task in tasks.data!) 
                    ListTile(
                      leading: Text(task.isFinished ? "Done ✅" : "WIP 🏃‍♀️"), // TODO: use icons instead
                      title: Text(task.localizedName(context: context), 
                        style: TextStyle(color: task.isFinished ? Colors.black : Colors.blue), 
                      ),
                      trailing: Text("${timeFormat.format(task.timeSpent.inSeconds / 60.0)} min"),
                      visualDensity: visualDensity,
                      onTap: () {
                        widget.appState.confirmTask(task: task);
                      },
                    ),
                ],
              );
            } else {
              return const CircularProgressIndicator();
            }
          },
        ),
        if (widget.appState.modalDialogType == ModalDialogType.confirmRecord)
          ConfirmRecordingWidget(appState: widget.appState),
      ],
    );

  }
}

