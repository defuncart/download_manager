import 'package:download_manager/download/download_manager.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_state.g.dart';

@riverpod
class TaskController extends _$TaskController {
  @override
  Future<Iterable<DownloadManagerTask>> build() => ref.read(downloadManagerProvider).downloadTask;

  Future<void> addTask(String url) async {
    await ref.read(downloadManagerProvider).request(url);
    state = AsyncValue.data(await ref.read(downloadManagerProvider).downloadTask);
  }

  Future<void> pause(DownloadManagerTask task) async {
    await ref.read(downloadManagerProvider).pause(task);
    state = AsyncValue.data(await ref.read(downloadManagerProvider).downloadTask);
  }

  Future<void> resume(DownloadManagerTask task) async {
    await ref.read(downloadManagerProvider).resume(task);
    state = AsyncValue.data(await ref.read(downloadManagerProvider).downloadTask);
  }

  Future<void> retry(DownloadManagerTask task) async {
    await ref.read(downloadManagerProvider).retry(task);
    state = AsyncValue.data(await ref.read(downloadManagerProvider).downloadTask);
  }

  Future<void> openDownloadedFile(DownloadManagerTask task) =>
      ref.read(downloadManagerProvider).openDownloadedFile(task);

  Future<void> deleteAll() async {
    await ref.read(downloadManagerProvider).deleteAll();
    state = AsyncValue.data(await ref.read(downloadManagerProvider).downloadTask);
  }
}
