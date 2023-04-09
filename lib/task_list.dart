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
          const visualDensity = VisualDensity(horizontal: -4, vertical: -4);
          return Column(
            children: [
              for (var task in tasks.data!) 
                ListTile(
                  leading: Text(task.isFinished ? "Done ✅" : "WIP 🏃‍♀️"), // TODO: use icons instead
                  title: Text(task.name, 
                    style: TextStyle(color: task.isFinished ? Colors.black : Colors.blue), 
                  ),                  
                  trailing: Text("${timeFormat.format(task.timeSpent.inSeconds / 60.0)} min"),
                  visualDensity: visualDensity,
                  onTap: () {
                    appState.confirmTask(task: task);
                  },
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
