import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/tag_provider.dart';
import '../models/tag.dart';

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
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () => _editTag(context, ref, tag),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
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

  Future<void> _addTag(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('タグの追加'),
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
            child: const Text('追加'),
          ),
        ],
      ),
    );

    if (name != null && name.trim().isNotEmpty) {
      await ref.read(tagRepositoryProvider).addTag(name.trim());
    }
  }

  Future<void> _editTag(BuildContext context, WidgetRef ref, Tag tag) async {
    final controller = TextEditingController(text: tag.name);
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('タグの編集'),
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
            child: const Text('保存'),
          ),
        ],
      ),
    );

    if (name != null && name.trim().isNotEmpty && name.trim() != tag.name) {
      await ref.read(tagRepositoryProvider).updateTag(tag.id, name.trim());
    }
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
