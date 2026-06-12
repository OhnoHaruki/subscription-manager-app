package co.jp.optim.subscription_manager

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin

class SubscriptionWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        for (appWidgetId in appWidgetIds) {
            val widgetData = HomeWidgetPlugin.getData(context)
            val views = RemoteViews(context.packageName, R.layout.widget_layout).apply {
                setTextViewText(R.id.total_amount, widgetData.getString("total_amount", "¥0"))
                setTextViewText(R.id.next_payment_name, widgetData.getString("next_payment_name", "なし"))
            }
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
