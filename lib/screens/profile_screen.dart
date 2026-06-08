import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../providers/profile_provider.dart';
import '../providers/theme_provider.dart';
import 'privacy_policy_screen.dart';
import 'terms_of_service_screen.dart';
import 'package:url_launcher/url_launcher.dart';

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
    final messenger = ScaffoldMessenger.of(context);
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
          messenger.showSnackBar(
            const SnackBar(content: Text('プロフィールを更新しました')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
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
    final themeMode = ref.watch(themeProvider);

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

              // テーマ設定
              ListTile(
                leading: const Icon(Icons.palette),
                title: const Text('テーマ設定'),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: SegmentedButton<ThemeMode>(
                    segments: const [
                      ButtonSegment(
                        value: ThemeMode.system,
                        label: Text('自動'),
                        icon: Icon(Icons.brightness_auto),
                      ),
                      ButtonSegment(
                        value: ThemeMode.light,
                        label: Text('ライト'),
                        icon: Icon(Icons.light_mode),
                      ),
                      ButtonSegment(
                        value: ThemeMode.dark,
                        label: Text('ダーク'),
                        icon: Icon(Icons.dark_mode),
                      ),
                    ],
                    selected: {themeMode},
                    onSelectionChanged: (newSelection) {
                      ref.read(themeProvider.notifier).setThemeMode(newSelection.first);
                    },
                  ),
                ),
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
              
              const SizedBox(height: 24),
              
              ListTile(
                leading: const Icon(Icons.description),
                title: const Text('利用規約'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const TermsOfServiceScreen(),
                    ),
                  );
                },
              ),
              const Divider(),
              
              ListTile(
                leading: const Icon(Icons.description),
                title: const Text('プライバシーポリシー'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const PrivacyPolicyScreen(),
                    ),
                  );
                },
              ),
              const Divider(),

              ListTile(
                leading: const Icon(Icons.mail),
                title: const Text('お問い合わせ'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  final context = this.context;
                  // TODO: 実際のサポート用メールアドレスに置き換えてください
                  final Uri emailLaunchUri = Uri(
                    scheme: 'mailto',
                    path: 'support@example.com',
                    queryParameters: {
                      'subject': 'Subscription Manager お問い合わせ',
                    },
                  );
                  try {
                    if (await canLaunchUrl(emailLaunchUri)) {
                      await launchUrl(emailLaunchUri);
                    }
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('メールアプリを開けませんでした')),
                    );
                  }
                },
              ),
              const Divider(),
              
              const SizedBox(height: 40),
              
              // ログアウトボタン
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () async {
                        final navigator = Navigator.of(context);
                        
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
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () async {
                        final navigator = Navigator.of(context);
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('アカウント削除', style: TextStyle(color: Colors.red)),
                            content: const Text('アカウントと全てのデータを削除しますか？この操作は取り消せません。'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('キャンセル'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('削除する', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          await ref.read(profileRepositoryProvider).deleteUser();
                          if (mounted) {
                            navigator.popUntil((route) => route.isFirst);
                          }
                        }
                      },
                      child: const Text('アカウントを削除する', style: TextStyle(color: Colors.red)),
                    ),
                  ],
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
