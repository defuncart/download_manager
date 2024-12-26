import 'package:download_manager/download/download_manager.dart';
import 'package:download_manager/home/add_item_dialog.dart';
import 'package:download_manager/home/home_state.dart';
import 'package:download_manager/home/string_extensions.dart';
import 'package:download_manager/l10n/l10n_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum PopupMenuOption {
  deleteAll,
}

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({
    super.key,
    this.deepLinkUrl,
  });

  final String? deepLinkUrl;

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();

    if (widget.deepLinkUrl != null && widget.deepLinkUrl!.isValidUrl) {
      ref.read(taskControllerProvider.notifier).addTask(widget.deepLinkUrl!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(taskControllerProvider);
    print('HomeScreen state ${state.runtimeType}');
    if (state is AsyncData) {
      print('HomeScreen ${state.value?.length}');
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.appTitle),
        actions: [
          PopupMenuButton<PopupMenuOption>(
            initialValue: null,
            onSelected: (PopupMenuOption option) {
              switch (option) {
                case PopupMenuOption.deleteAll:
                  ref.read(taskControllerProvider.notifier).deleteAll();
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<PopupMenuOption>>[
              const PopupMenuItem<PopupMenuOption>(
                value: PopupMenuOption.deleteAll,
                child: Text('Delete All'),
              ),
            ],
          ),
        ],
      ),
      body: switch (state) {
        AsyncLoading() => const Center(
            child: CircularProgressIndicator(),
          ),
        AsyncError(:final error) => Center(
            child: Text(error.toString()),
          ),
        AsyncData(:final value) => TasksList(
            tasks: value,
            onPauseDownload: ref.read(taskControllerProvider.notifier).pause,
            onResumeDownload: ref.read(taskControllerProvider.notifier).resume,
            onRetryDownload: ref.read(taskControllerProvider.notifier).retry,
            onOpenDownloadedFile: ref.read(taskControllerProvider.notifier).openDownloadedFile,
          ),
        // TODO: Remove once migrated to riverpod v3
        _ => const SizedBox.shrink(),
      },
      floatingActionButton: FloatingActionButton.small(
        onPressed: () => showDialog(
          context: context,
          builder: (context) => AddItemDialog(
            onAddUrl: (url) => ref.read(taskControllerProvider.notifier).addTask(url),
          ),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class TasksList extends StatelessWidget {
  const TasksList({
    super.key,
    required this.tasks,
    required this.onPauseDownload,
    required this.onResumeDownload,
    required this.onRetryDownload,
    required this.onOpenDownloadedFile,
  });

  final Iterable<DownloadManagerTask> tasks;
  final void Function(DownloadManagerTask) onPauseDownload;
  final void Function(DownloadManagerTask) onResumeDownload;
  final void Function(DownloadManagerTask) onRetryDownload;
  final void Function(DownloadManagerTask) onOpenDownloadedFile;

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return Center(
        child: Text('No tasks'),
      );
    }

    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks.elementAt(index);

        return ListTile(
          onTap: () {
            if (task.status == DownloadManagerTaskStatus.complete) {
              onOpenDownloadedFile(task);
            } else if (task.status == DownloadManagerTaskStatus.paused) {
              onResumeDownload(task);
            } else if (task.status == DownloadManagerTaskStatus.running) {
              onPauseDownload(task);
            } else if (task.status == DownloadManagerTaskStatus.failed) {
              onRetryDownload(task);
            }
          },
          title: Text(
            task.name ?? task.url,
            style: task.status == DownloadManagerTaskStatus.failed
                ? TextStyle(color: Theme.of(context).colorScheme.error)
                : null,
          ),
          subtitle: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              if (task.status == DownloadManagerTaskStatus.paused ||
                  task.status == DownloadManagerTaskStatus.running) ...[
                LinearProgressIndicator(
                  value: task.progress,
                ),
                const SizedBox(height: 8),
              ],
              Text(task.status.name),
            ],
          ),
          trailing: switch (task.status) {
            DownloadManagerTaskStatus.paused => IconButton(
                onPressed: () => onResumeDownload(task),
                icon: Icon(Icons.play_arrow),
              ),
            DownloadManagerTaskStatus.running => IconButton(
                onPressed: () => onPauseDownload(task),
                icon: Icon(Icons.pause),
              ),
            DownloadManagerTaskStatus.failed => IconButton(
                onPressed: () => onRetryDownload(task),
                icon: Icon(Icons.sync),
              ),
            _ => null,
          },
        );
      },
    );
  }
}
