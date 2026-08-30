package com.subasmk.trackmecomplete

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider
import org.json.JSONArray

/**
 * Multi-goal "at a glance" widget. Unlike [TrackMeGoalWidgetProvider], this
 * one isn't bound to a single goal via a configure step — it always shows
 * the user's top goals (up to 5) plus an overall today's-completion
 * summary, matching the stacked streak-card reference layout.
 *
 * The goal array Flutter writes to [KEY_GOALS_JSON] is already sorted
 * newest-first (see GoalService.goals / HomeWidgetService.syncGoals on the
 * Dart side), so the first up-to-3 entries are exactly the same goals
 * shown at the top of the in-app home screen — no re-sorting needed here.
 */
class TrackMeOverviewWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId, widgetData)
        }
    }

    companion object {
        private const val KEY_GOALS_JSON = "goals_json"
        private const val KEY_COMPLETED_TODAY = "completed_today_count"
        private const val KEY_TOTAL_GOALS = "total_goals_count"

        private val cardContainerIds = intArrayOf(
            R.id.goal_card_1, R.id.goal_card_2, R.id.goal_card_3,
            R.id.goal_card_4, R.id.goal_card_5
        )
        private val cardTitleIds = intArrayOf(
            R.id.goal_1_title, R.id.goal_2_title, R.id.goal_3_title,
            R.id.goal_4_title, R.id.goal_5_title
        )
        private val cardStreakIds = intArrayOf(
            R.id.goal_1_streak, R.id.goal_2_streak, R.id.goal_3_streak,
            R.id.goal_4_streak, R.id.goal_5_streak
        )
        private val cardUnitIds = intArrayOf(
            R.id.goal_1_unit, R.id.goal_2_unit, R.id.goal_3_unit,
            R.id.goal_4_unit, R.id.goal_5_unit
        )
        private val cardChecksIds = intArrayOf(
            R.id.goal_1_checks, R.id.goal_2_checks, R.id.goal_3_checks,
            R.id.goal_4_checks, R.id.goal_5_checks
        )
        private val cardSlothIds = intArrayOf(
            R.id.goal_1_sloth, R.id.goal_2_sloth, R.id.goal_3_sloth,
            R.id.goal_4_sloth, R.id.goal_5_sloth
        )
        private val slothDrawables = intArrayOf(
            R.drawable.sloth_happy,
            R.drawable.sloth_playful,
            R.drawable.sloth_happy,
            R.drawable.sloth_worried,
            R.drawable.sloth_sleepy
        )

        fun updateAppWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int,
            widgetData: SharedPreferences
        ) {
            val views = RemoteViews(context.packageName, R.layout.widget_overview)

            val goals = try {
                JSONArray(widgetData.getString(KEY_GOALS_JSON, null) ?: "[]")
            } catch (e: Exception) {
                JSONArray()
            }

            // Every PendingIntent below carries an explicit Uri (even the
            // "just open the app" ones, via a non-"goal" host) rather than
            // relying on an argument-less overload of getActivity().

            if (goals.length() == 0) {
                views.setViewVisibility(R.id.overview_scroll, View.GONE)
                views.setViewVisibility(R.id.empty_state, View.VISIBLE)
                for (containerId in cardContainerIds) {
                    views.setViewVisibility(containerId, View.GONE)
                }
                val pendingIntent = HomeWidgetLaunchIntent.getActivity(
                    context, MainActivity::class.java, Uri.parse("trackme://open")
                )
                views.setOnClickPendingIntent(R.id.widget_root, pendingIntent)
                appWidgetManager.updateAppWidget(appWidgetId, views)
                return
            }

            views.setViewVisibility(R.id.overview_scroll, View.VISIBLE)
            views.setViewVisibility(R.id.empty_state, View.GONE)

            // Default: tapping empty space anywhere in the widget opens the
            // app to the home screen. Each visible row below overrides this
            // with a deep link straight to that specific goal.
            views.setOnClickPendingIntent(
                R.id.widget_root,
                HomeWidgetLaunchIntent.getActivity(
                    context, MainActivity::class.java, Uri.parse("trackme://open")
                )
            )

            for (i in cardContainerIds.indices) {
                if (i >= goals.length()) {
                    views.setViewVisibility(cardContainerIds[i], View.GONE)
                    continue
                }
                views.setViewVisibility(cardContainerIds[i], View.VISIBLE)
                val goal = goals.getJSONObject(i)
                val streak = goal.optInt("streak", 0)
                val unit = if (streak == 1) "day" else "days"
                val completedToday = goal.optBoolean("completedToday", false)

                views.setTextViewText(cardTitleIds[i], goal.optString("title", "Goal"))
                views.setTextViewText(cardStreakIds[i], streak.toString())
                views.setTextViewText(cardUnitIds[i], unit)
                views.setImageViewResource(
                    cardSlothIds[i],
                    if (completedToday) R.drawable.sloth_happy else slothDrawables[i]
                )

                val week = goal.optJSONArray("week")
                views.setTextViewText(cardChecksIds[i], weekChecks(week))

                val goalId = goal.optString("id", "")
                if (goalId.isNotEmpty()) {
                    val uri = Uri.parse("trackme://goal?id=$goalId")
                    views.setOnClickPendingIntent(
                        cardContainerIds[i],
                        HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java, uri)
                    )
                }
            }

            val completedToday = widgetData.getInt(KEY_COMPLETED_TODAY, 0)
            val totalGoals = widgetData.getInt(KEY_TOTAL_GOALS, goals.length())
            views.setTextViewText(
                R.id.completion_summary,
                "$completedToday/$totalGoals goals completed today"
            )
            val progress = if (totalGoals > 0) (completedToday * 100) / totalGoals else 0
            views.setProgressBar(R.id.completion_progress, 100, progress, false)

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }

        private fun weekChecks(week: JSONArray?): String {
            val checks = StringBuilder()
            for (i in 0 until 7) {
                if (i > 0) checks.append("  ")
                checks.append(if (week?.optBoolean(i, false) == true) "✓" else "○")
            }
            return checks.toString()
        }
    }
}
