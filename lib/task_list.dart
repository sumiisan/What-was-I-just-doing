import 'package:flutter/material.dart';
import 'app_state.dart';
import 'task.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TaskListWidget extends StatelessWidget {
  const TaskListWidget({
    super.key,
    required this.appState,
  });

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context)?.localeName;
    return FutureBuilder(future: appState.getTasks(),
      builder: (context, AsyncSnapshot<List<Task>>tasks) {
        if (tasks.hasData) {
          NumberFormat timeFormat = NumberFormat("#,##0.0", locale);
          return Column(
            children: [
              for (var task in tasks.data!) 
                ListTile(
                  title: Text("${task.isFinished ? "✅" : "🏃‍♀️"} ${task.description}", 
                  style: TextStyle(color: task.isFinished ? Colors.black : Colors.blue),), 
                  trailing: Text("${timeFormat.format(task.timeSpent.inSeconds / 60.0)} min")
                ),
            ],
          );

        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }
}

