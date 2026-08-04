package com.trackme.app

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider
import org.json.JSONArray
import org.json.JSONObject

/**
 * Shows a compact overview of the user's quests on the Android home screen.
 * Displays: today's completed vs total quest count, the top active quest's
 * name and streak, and difficulty label.
 *
 * Data flow:
 * - Flutter writes quests as JSON to [KEY_QUESTS_JSON] via HomeWidgetService.
 * - This provider reads that data and renders a summary card.
 */
class TrackMeQuestWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        for (appWidgetId in appWidgetIds) {
            updateQuestWidget(context, appWidgetManager, appWidgetId, widgetData)
        }
    }

    companion object {
        private const val KEY_QUESTS_JSON = "quests_json"
        private const val KEY_COMPLETED_COUNT = "quest_completed_today_count"
        private const val KEY_TOTAL_COUNT = "quest_total_count"

        fun updateQuestWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int,
            widgetData: SharedPreferences
        ) {
            val views = RemoteViews(context.packageName, R.layout.widget_quest)

            val completedCount = widgetData.getInt(KEY_COMPLETED_COUNT, 0)
            val totalCount = widgetData.getInt(KEY_TOTAL_COUNT, 0)
            val questsJson = widgetData.getString(KEY_QUESTS_JSON, null)

            // Summary line
            if (totalCount == 0) {
                views.setTextViewText(R.id.quest_summary, "No quests yet")
                views.setTextViewText(R.id.quest_title, "Open app to add quests")
                views.setTextViewText(R.id.quest_streak, "")
                views.setTextViewText(R.id.quest_difficulty, "")
            } else {
                views.setTextViewText(
                    R.id.quest_summary,
                    "$completedCount / $totalCount done today"
                )

                // Find the "top" quest: first not completed today, or first overall
                val topQuest = findTopQuest(questsJson)
                if (topQuest != null) {
                    val title = topQuest.optString("title", "Quest")
                    val emoji = topQuest.optString("emoji", "⚔️")
                    val streak = topQuest.optInt("streak", 0)
                    val difficulty = topQuest.optString("difficulty", "")
                    val done = topQuest.optBoolean("completedToday", false)

                    views.setTextViewText(
                        R.id.quest_title,
                        "$emoji $title${if (done) " ✓" else ""}"
                    )
                    views.setTextViewText(
                        R.id.quest_streak,
                        if (streak > 0) "🔥 $streak day streak" else ""
                    )
                    views.setTextViewText(R.id.quest_difficulty, difficulty)
                } else {
                    views.setTextViewText(R.id.quest_title, "All quests complete!")
                    views.setTextViewText(R.id.quest_streak, "")
                    views.setTextViewText(R.id.quest_difficulty, "")
                }
            }

            // Tap to open app
            val launchIntent = es.antonborri.home_widget.HomeWidgetLaunchIntent.getActivity(
                context,
                MainActivity::class.java,
                android.net.Uri.parse("trackme://quests")
            )
            views.setOnClickPendingIntent(R.id.quest_widget_root, launchIntent)

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }

        private fun findTopQuest(questsJson: String?): JSONObject? {
            if (questsJson.isNullOrEmpty()) return null
            return try {
                val arr = JSONArray(questsJson)
                // Prefer first quest not yet completed today
                for (i in 0 until arr.length()) {
                    val q = arr.getJSONObject(i)
                    if (!q.optBoolean("completedToday", false)) return q
                }
                // All done: return first
                if (arr.length() > 0) arr.getJSONObject(0) else null
            } catch (e: Exception) {
                null
            }
        }
    }
}
