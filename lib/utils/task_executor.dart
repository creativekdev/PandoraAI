import 'package:cartoonizer/utils/array_util.dart';
import 'package:worker_manager/worker_manager.dart';

class TaskExecutor {
  List<Runnable> taskList = [];

  DateTime insert(Cancelable task) {
    var runnable = Runnable(task: task);
    taskList.add(runnable);
    return runnable.createDate;
  }

  cancelOldTask(DateTime time) {
    print('finish task dt: ${time.millisecondsSinceEpoch}');
    var oldList = taskList.filter((t) => t.createDate.isBefore(time));
    for (var value in oldList) {
      try {
        value.task.cancel();
        print('cancel task dt: ${value.createDate.millisecondsSinceEpoch}');
      } on CanceledError catch (e) {
        // print(e);
      }
      taskList.remove(value);
    }
  }

  clear() {
    for (var value in taskList) {
      try {
        value.task.cancel();
      } on CanceledError catch (e) {
        print(e);
      }
    }
    taskList.clear();
  }
}

class Runnable {
  late DateTime createDate;
  Cancelable task;

  Runnable({required this.task}) {
    createDate = DateTime.now();
  }
}
