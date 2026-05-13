import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/payment_method.dart';
import '../providers/payment_method_provider.dart';

/// 支払い方法登録・編集画面
class AddPaymentMethodScreen extends ConsumerStatefulWidget {
  const AddPaymentMethodScreen({super.key, this.paymentMethod});

  final PaymentMethod? paymentMethod;

  @override
  ConsumerState<AddPaymentMethodScreen> createState() => _AddPaymentMethodScreenState();
}

class _AddPaymentMethodScreenState extends ConsumerState<AddPaymentMethodScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late final TextEditingController _nameController;
  late final TextEditingController _last4Controller;
  
  late PaymentMethodType _type;
  DateTime? _expiryDate;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.paymentMethod?.name);
    _last4Controller = TextEditingController(text: widget.paymentMethod?.last4);
    _type = widget.paymentMethod?.type ?? PaymentMethodType.creditCard;
    _expiryDate = widget.paymentMethod?.expiryDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _last4Controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final repository = ref.read(paymentMethodRepositoryProvider);

    if (widget.paymentMethod == null) {
      final method = PaymentMethod(
        id: '',
        name: _nameController.text,
        type: _type,
        last4: _last4Controller.text,
        expiryDate: _expiryDate,
      );
      await repository.addPaymentMethod(method);
    } else {
      final method = widget.paymentMethod!.copyWith(
        name: _nameController.text,
        type: _type,
        last4: _last4Controller.text,
        expiryDate: _expiryDate,
      );
      await repository.updatePaymentMethod(method);
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.paymentMethod != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? '支払い方法編集' : '支払い方法登録'),
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
            // 名前
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '支払い方法の名称',
                hintText: '例: メインカード, 楽天銀行など',
              ),
              validator: (value) => (value == null || value.isEmpty) ? '名前を入力してください' : null,
            ),
            const SizedBox(height: 16),
            
            // 種類
            const Text('種類', style: TextStyle(fontSize: 12, color: Colors.grey)),
            SegmentedButton<PaymentMethodType>(
              segments: const [
                ButtonSegment(value: PaymentMethodType.creditCard, label: Text('カード'), icon: Icon(Icons.credit_card)),
                ButtonSegment(value: PaymentMethodType.bankAccount, label: Text('銀行口座'), icon: Icon(Icons.account_balance)),
              ],
              selected: {_type},
              onSelectionChanged: (newSelection) {
                setState(() => _type = newSelection.first);
              },
            ),
            const SizedBox(height: 16),
            
            // 下4桁（任意）
            TextFormField(
              controller: _last4Controller,
              decoration: const InputDecoration(
                labelText: '番号の下4桁 (任意)',
                hintText: '1234',
              ),
              keyboardType: TextInputType.number,
              maxLength: 4,
            ),
            
            // 有効期限（カードの場合のみ）
            if (_type == PaymentMethodType.creditCard)
              ListTile(
                title: const Text('有効期限 (任意)'),
                subtitle: Text(_expiryDate != null ? DateFormat('yyyy/MM').format(_expiryDate!) : '未設定'),
                trailing: const Icon(Icons.calendar_month),
                onTap: () async {
                  final selected = await showDatePicker(
                    context: context,
                    initialDate: _expiryDate ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 3650)),
                  );
                  if (selected != null) {
                    setState(() => _expiryDate = selected);
                  }
                },
              ),
          ],
        ),
      ),
    );
  }
}
