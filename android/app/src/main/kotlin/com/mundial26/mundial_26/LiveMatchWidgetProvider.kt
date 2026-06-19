package com.mundial26.mundial_26

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.widget.RemoteViews
import android.app.PendingIntent
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import es.antonborri.home_widget.HomeWidgetProvider
import java.net.URL
import java.util.concurrent.Executors

class LiveMatchWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        val executor = Executors.newSingleThreadExecutor()

        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_layout).apply {
                val intent = Intent(context, MainActivity::class.java)
                val pendingIntent = PendingIntent.getActivity(
                    context, 0, intent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                setOnClickPendingIntent(R.id.widget_layout_main, pendingIntent)

                val title = widgetData.getString("widget_title", "Mundial 2026")
                val time = widgetData.getString("widget_time", "--")
                val homeTeam = widgetData.getString("widget_home_team", "Local")
                val awayTeam = widgetData.getString("widget_away_team", "Visitante")
                val score = widgetData.getString("widget_score", "-")
                val homeLogo = widgetData.getString("widget_home_logo", null)
                val awayLogo = widgetData.getString("widget_away_logo", null)
                val homeScorers = widgetData.getString("widget_home_scorers", "")
                val awayScorers = widgetData.getString("widget_away_scorers", "")

                setTextViewText(R.id.widget_title, title)
                setTextViewText(R.id.widget_time, time)
                setTextViewText(R.id.widget_home_team, homeTeam)
                setTextViewText(R.id.widget_away_team, awayTeam)
                setTextViewText(R.id.widget_score, score)
                setTextViewText(R.id.widget_home_scorers, homeScorers)
                setTextViewText(R.id.widget_away_scorers, awayScorers)

                // Load images in background
                executor.execute {
                    try {
                        if (!homeLogo.isNullOrEmpty()) {
                            val homeBitmap = BitmapFactory.decodeStream(URL(homeLogo).openStream())
                            setImageViewBitmap(R.id.widget_home_logo, homeBitmap)
                        } else {
                            setImageViewBitmap(R.id.widget_home_logo, null)
                        }
                        
                        if (!awayLogo.isNullOrEmpty()) {
                            val awayBitmap = BitmapFactory.decodeStream(URL(awayLogo).openStream())
                            setImageViewBitmap(R.id.widget_away_logo, awayBitmap)
                        } else {
                            setImageViewBitmap(R.id.widget_away_logo, null)
                        }
                    } catch (e: Exception) {
                        e.printStackTrace()
                    }
                    appWidgetManager.updateAppWidget(widgetId, this)
                }
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
