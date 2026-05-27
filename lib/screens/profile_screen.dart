import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../providers/profile_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _usernameController = TextEditingController();
  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile(String id) async {
    setState(() => _isLoading = true);
    try {
      final repository = ref.read(profileRepositoryProvider);
      final profile = ref.read(profileProvider).value;
      if (profile != null) {
        await repository.updateProfile(
          profile.copyWith(username: _usernameController.text.trim()),
        );
        ref.invalidate(profileProvider);
        if (mounted) {
          setState(() => _isEditing = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('プロフィールを更新しました')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('更新に失敗しました: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final profileAsync = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('プロフィール'),
      ),
      body: profileAsync.when(
        data: (profile) {
          if (profile == null) {
            return const Center(child: Text('プロフィールが見つかりません'));
          }

          if (!_isEditing && _usernameController.text.isEmpty) {
            _usernameController.text = profile.username ?? '';
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Center(
                child: CircleAvatar(
                  radius: 50,
                  child: Icon(Icons.person, size: 50),
                ),
              ),
              const SizedBox(height: 24),
              
              // メールアドレス (読み取り専用)
              ListTile(
                title: const Text('メールアドレス'),
                subtitle: Text(user?.email ?? '不明'),
                leading: const Icon(Icons.email),
              ),
              const Divider(),

              // ユーザー名
              ListTile(
                leading: const Icon(Icons.badge),
                title: const Text('ユーザー名'),
                subtitle: _isEditing
                    ? TextField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          hintText: 'ユーザー名を入力',
                        ),
                        autofocus: true,
                      )
                    : Text(profile.username ?? '未設定'),
                trailing: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : IconButton(
                        icon: Icon(_isEditing ? Icons.check : Icons.edit),
                        onPressed: () {
                          if (_isEditing) {
                            _updateProfile(profile.id);
                          } else {
                            setState(() => _isEditing = true);
                          }
                        },
                      ),
              ),
              if (_isEditing)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _isEditing = false;
                            _usernameController.text = profile.username ?? '';
                          });
                        },
                        child: const Text('キャンセル'),
                      ),
                    ],
                  ),
                ),
              
              const SizedBox(height: 40),
              
              // ログアウトボタン
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('ログアウト'),
                        content: const Text('ログアウトしてもよろしいですか？'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('キャンセル'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('ログアウト', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      final navigator = Navigator.of(context);
                      await ref.read(authRepositoryProvider).signOut();
                      if (mounted) {
                        navigator.popUntil((route) => route.isFirst);
                      }
                    }
                  },
                  icon: const Icon(Icons.logout, color: Colors.red),
                  label: const Text('ログアウト', style: TextStyle(color: Colors.red)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('エラーが発生しました: $e')),
      ),
    );
  }
}
