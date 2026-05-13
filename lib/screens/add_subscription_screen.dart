import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/subscription.dart';
import '../providers/subscription_provider.dart';
import '../providers/payment_method_provider.dart';
import 'add_payment_method_screen.dart';

/// サブスクリプション登録・編集画面
class AddSubscriptionScreen extends ConsumerStatefulWidget {
  const AddSubscriptionScreen({super.key, this.subscription});

  /// 編集対象のサブスクリプション（新規登録の場合は null）
  final Subscription? subscription;

  @override
  ConsumerState<AddSubscriptionScreen> createState() => _AddSubscriptionScreenState();
}

class _AddSubscriptionScreenState extends ConsumerState<AddSubscriptionScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // 入力項目のためのコントローラー
  late final TextEditingController _nameController;
  late final TextEditingController _amountController;
  
  late BillingCycle _cycle;
  late DateTime _nextPaymentDate;
  late String _selectedPaymentMethodId;

  @override
  void initState() {
    super.initState();
    // 編集モードの場合は初期値をセット、新規の場合はデフォルト値をセット
    _nameController = TextEditingController(text: widget.subscription?.name);
    _amountController = TextEditingController(text: widget.subscription?.amount.toString());
    _cycle = widget.subscription?.cycle ?? BillingCycle.monthly;
    _nextPaymentDate = widget.subscription?.nextPaymentDate ?? DateTime.now();
    _selectedPaymentMethodId = widget.subscription?.paymentMethod ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  /// データの保存処理
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final repository = ref.read(subscriptionRepositoryProvider);
    
    if (widget.subscription == null) {
      // 新規登録
      final subscription = Subscription(
        id: '',
        name: _nameController.text,
        amount: int.parse(_amountController.text),
        cycle: _cycle,
        nextPaymentDate: _nextPaymentDate,
        paymentMethod: _selectedPaymentMethodId,
      );
      await repository.addSubscription(subscription);
    } else {
      // 更新
      final subscription = widget.subscription!.copyWith(
        name: _nameController.text,
        amount: int.parse(_amountController.text),
        cycle: _cycle,
        nextPaymentDate: _nextPaymentDate,
        paymentMethod: _selectedPaymentMethodId,
      );
      await repository.updateSubscription(subscription);
    }

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    // 支払い方法一覧を取得
    final paymentMethodsAsync = ref.watch(paymentMethodsProvider);
    final isEditing = widget.subscription != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'サブスク編集' : 'サブスク登録'),
        actions: [
          IconButton(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              try {
                await _save();
              } catch (e) {
                messenger.showSnackBar(
                  SnackBar(content: Text('保存に失敗しました: $e')),
                );
              }
            },
            icon: const Icon(Icons.check),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // サービス名
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'サービス名',
                hintText: '例: Netflix, Spotifyなど',
              ),
              validator: (value) =>
                  (value == null || value.isEmpty) ? 'サービス名を入力してください' : null,
            ),
            const SizedBox(height: 16),
            
            // 金額
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: '金額',
                suffixText: '円',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) return '金額を入力してください';
                if (int.tryParse(value) == null) return '有効な数値を入力してください';
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // 支払い周期
            ListTile(
              title: const Text('支払い周期'),
              trailing: DropdownButton<BillingCycle>(
                value: _cycle,
                onChanged: (value) {
                  if (value != null) setState(() => _cycle = value);
                },
                items: const [
                  DropdownMenuItem(value: BillingCycle.monthly, child: Text('毎月')),
                  DropdownMenuItem(value: BillingCycle.yearly, child: Text('毎年')),
                ],
              ),
            ),
            
            // 次回支払日
            ListTile(
              title: const Text('次回支払日'),
              subtitle: Text(DateFormat('yyyy/MM/dd').format(_nextPaymentDate)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final selected = await showDatePicker(
                  context: context,
                  initialDate: _nextPaymentDate,
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now().add(const Duration(days: 3650)),
                );
                if (selected != null) {
                  setState(() => _nextPaymentDate = selected);
                }
              },
            ),

            const Divider(),
            
            // 支払い方法の選択
            paymentMethodsAsync.when(
              data: (methods) => ListTile(
                title: const Text('支払い方法'),
                subtitle: Text(
                  methods.any((m) => m.id == _selectedPaymentMethodId)
                      ? methods.firstWhere((m) => m.id == _selectedPaymentMethodId).name
                      : '未設定',
                ),
                trailing: methods.isEmpty
                    ? TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => const AddPaymentMethodScreen()),
                          );
                        },
                        child: const Text('追加'),
                      )
                    : DropdownButton<String>(
                        value: _selectedPaymentMethodId.isEmpty ? null : _selectedPaymentMethodId,
                        hint: const Text('選択してください'),
                        onChanged: (value) {
                          if (value != null) setState(() => _selectedPaymentMethodId = value);
                        },
                        items: methods.map((m) {
                          return DropdownMenuItem(value: m.id, child: Text(m.name));
                        }).toList(),
                      ),
              ),
              loading: () => const Center(child: LinearProgressIndicator()),
              error: (e, _) => Text('支払い方法の読み込みエラー: $e'),
            ),
          ],
        ),
      ),
    );
  }
}
