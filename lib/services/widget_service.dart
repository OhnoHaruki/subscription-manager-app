import 'package:home_widget/home_widget.dart';

/// ウィジェットのデータを管理するサービスクラス
class WidgetService {
  static const String _appGroupId = 'group.jp.co.optim.subscriptionManager'; // iOS用AppGroup ID
  static const String _androidWidgetName = 'SubscriptionWidgetProvider'; // Android用Provider名

  /// ウィジェットデータを保存して更新
  static Future<void> updateWidgetData({
    required double totalAmount,
    required String nextPaymentName,
    required String nextPaymentDate,
  }) async {
    // データを保存
    await HomeWidget.saveWidgetData<String>('total_amount', '¥${totalAmount.toInt()}');
    await HomeWidget.saveWidgetData<String>('next_payment_name', nextPaymentName);
    await HomeWidget.saveWidgetData<String>('next_payment_date', nextPaymentDate);

    // ウィジェットを更新
    await HomeWidget.updateWidget(
      iOSName: 'SubscriptionWidget', // iOSのWidget名
      androidName: _androidWidgetName,
    );
  }
}
