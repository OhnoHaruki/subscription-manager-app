import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/profile.dart';
import '../repositories/profile_repository.dart';
import 'subscription_provider.dart';

/// ProfileRepositoryのインスタンスを提供するProvider
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(ref.watch(supabaseProvider));
});

/// 現在のユーザープロフィールを取得するProvider
final profileProvider = FutureProvider<Profile?>((ref) {
  return ref.watch(profileRepositoryProvider).getProfile();
});
