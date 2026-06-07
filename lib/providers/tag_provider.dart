import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/tag.dart';
import '../repositories/tag_repository.dart';
import 'subscription_provider.dart';

/// TagRepositoryのインスタンスを提供するProvider
final tagRepositoryProvider = Provider<TagRepository>((ref) {
  return TagRepository(ref.watch(supabaseProvider));
});

/// タグ一覧をリアルタイムで監視するProvider
final tagsProvider = StreamProvider<List<Tag>>((ref) {
  return ref.watch(tagRepositoryProvider).watchTags();
});
