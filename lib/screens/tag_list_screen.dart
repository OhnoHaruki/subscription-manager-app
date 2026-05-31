import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/tag.dart';
import '../providers/tag_provider.dart';

class TagListScreen extends ConsumerWidget {
  const TagListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tagsAsync = ref.watch(tagsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('タグ管理'),
      ),
      body: tagsAsync.when(
        data: (tags) => tags.isEmpty
            ? const Center(child: Text('タグが登録されていません'))
            : ListView.builder(
                itemCount: tags.length,
                itemBuilder: (context, index) {
                  final tag = tags[index];
                  return ListTile(
                    leading: const Icon(Icons.label),
                    title: Text(tag.name),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _editTag(context, ref, tag),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteTag(context, ref, tag),
                        ),
                      ],
                    ),
                  );
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('エラーが発生しました: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addTag(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showTagDialog({
    required BuildContext context,
    String? initialName,
    required String title,
    required String confirmLabel,
    required Function(String) onConfirm,
  }) async {
    final controller = TextEditingController(text: initialName);
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'タグ名'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );

    if (name != null && name.trim().isNotEmpty) {
      await onConfirm(name.trim());
    }
  }

  Future<void> _addTag(BuildContext context, WidgetRef ref) async {
    await _showTagDialog(
      context: context,
      title: 'タグの追加',
      confirmLabel: '追加',
      onConfirm: (name) => ref.read(tagRepositoryProvider).addTag(name),
    );
  }

  Future<void> _editTag(BuildContext context, WidgetRef ref, Tag tag) async {
    await _showTagDialog(
      context: context,
      initialName: tag.name,
      title: 'タグの編集',
      confirmLabel: '保存',
      onConfirm: (name) => ref.read(tagRepositoryProvider).updateTag(tag.id, name),
    );
  }

  Future<void> _deleteTag(BuildContext context, WidgetRef ref, Tag tag) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('タグの削除'),
        content: Text('${tag.name} を削除しますか？\nこのタグが付いているサブスクリプションからはタグが外れます。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('削除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(tagRepositoryProvider).deleteTag(tag.id);
    }
  }
}
