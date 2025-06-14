import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'download_manager.g.dart';

typedef DownloadManagerTask = ({
  String? name,
  String url,
  String taskId,
  DownloadManagerTaskStatus status,
  // 0 to 1
  double progress,
});

enum DownloadManagerTaskStatus {
  undefined,
  enqueued,
  running,
  complete,
  failed,
  canceled,
  paused,
}

class DownloadManager {
  final _port = ReceivePort();
  late final String _localDir;

  Future<void> init() async {
    await FlutterDownloader.initialize(
      debug: true, // optional: set to false to disable printing logs to console (default: true)
      ignoreSsl: true, // option: set to false to disable working with http links (default: false)
    );
    final downloadsDir = await _getDownloadDir();
    // _localDir = p.join(downloadsDir, '_DM');
    // if (!await Directory(_localDir).exists()) {
    //   await Directory(_localDir).create();
    // }
    _localDir = downloadsDir;

    _bindBackgroundIsolate();

    FlutterDownloader.registerCallback(downloadCallback, step: 1);
  }

  Future<String> _getDownloadDir() async {
    Directory? directory;
    if (defaultTargetPlatform == TargetPlatform.android) {
      directory = Directory('/storage/emulated/0/Download');
    }
    directory ?? await getExternalStorageDirectory();

    return directory!.path;
  }

  Future<Iterable<DownloadManagerTask>> get downloadTask async {
    final tasks = await FlutterDownloader.loadTasks();

    if (tasks == null || tasks.isEmpty) {
      return [];
    }

    return tasks.map(
      (task) => (
        name: task.filename,
        url: task.url,
        taskId: task.taskId,
        status: switch (task.status) {
          DownloadTaskStatus.undefined => DownloadManagerTaskStatus.undefined,
          DownloadTaskStatus.enqueued => DownloadManagerTaskStatus.enqueued,
          DownloadTaskStatus.running => DownloadManagerTaskStatus.running,
          DownloadTaskStatus.complete => DownloadManagerTaskStatus.complete,
          DownloadTaskStatus.failed => DownloadManagerTaskStatus.failed,
          DownloadTaskStatus.canceled => DownloadManagerTaskStatus.canceled,
          DownloadTaskStatus.paused => DownloadManagerTaskStatus.paused,
        },
        progress: task.progress / 100,
      ),
    );
  }

  void _bindBackgroundIsolate() {
    final isSuccess = IsolateNameServer.registerPortWithName(
      _port.sendPort,
      'downloader_send_port',
    );
    if (!isSuccess) {
      _unbindBackgroundIsolate();
      _bindBackgroundIsolate();
      return;
    }
    _port.listen((dynamic data) {
      final taskId = (data as List<dynamic>)[0] as String;
      final status = DownloadTaskStatus.fromInt(data[1] as int);
      final progress = data[2] as int;

      print(
        'Callback on UI isolate: '
        'task ($taskId) is in status ($status) and process ($progress)',
      );

      // if (_tasks != null && _tasks!.isNotEmpty) {
      //   final task = _tasks!.firstWhere((task) => task.taskId == taskId);
      //   setState(() {
      //     task
      //       ..status = status
      //       ..progress = progress;
      //   });
      // }
    });
  }

  void _unbindBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
  }

  @pragma('vm:entry-point')
  static void downloadCallback(
    String id,
    int status,
    int progress,
  ) {
    print(
      'Callback on background isolate: '
      'task ($id) is in status ($status) and process ($progress)',
    );

    IsolateNameServer.lookupPortByName('downloader_send_port')?.send([id, status, progress]);
  }

  Future<void> request(String url) async {
    await FlutterDownloader.enqueue(
      url: url,
      savedDir: _localDir,
      saveInPublicStorage: true,
      allowCellular: false,
    );
  }

  Future<void> pause(DownloadManagerTask task) async {
    await FlutterDownloader.pause(taskId: task.taskId);
  }

  Future<void> resume(DownloadManagerTask task) async {
    final newTaskId = await FlutterDownloader.resume(taskId: task.taskId);
    // task.taskId = newTaskId;
    // trigger new taskId
  }

  Future<void> retry(DownloadManagerTask task) async {
    final newTaskId = await FlutterDownloader.retry(taskId: task.taskId);
    // task.taskId = newTaskId;
    // trigger new taskId
  }

  Future<bool> openDownloadedFile(DownloadManagerTask? task) async {
    final taskId = task?.taskId;
    if (taskId == null) {
      return false;
    }

    return FlutterDownloader.open(taskId: taskId);
  }

  // Future<void> _delete(TaskInfo task) async {
  //   await FlutterDownloader.remove(
  //     taskId: task.taskId!,
  //     shouldDeleteContent: true,
  //   );
  //   await _prepare();
  //   setState(() {});
  // }

  Future<void> deleteAll() async {
    await FlutterDownloader.cancelAll();
    final tasks = (await FlutterDownloader.loadTasks()) ?? [];
    for (final task in tasks) {
      await FlutterDownloader.remove(taskId: task.taskId);
    }
  }
}

@riverpod
DownloadManager downloadManager(Ref ref) => throw StateError('Not initialized');
