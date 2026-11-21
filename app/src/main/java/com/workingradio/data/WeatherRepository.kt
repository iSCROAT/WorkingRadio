package com.workingradio.data

import com.workingradio.data.model.DayForecast
import com.workingradio.data.model.HourForecast
import com.workingradio.data.model.MockWeather
import com.workingradio.data.model.WeatherReport
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.JsonArray
import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.jsonArray
import kotlinx.serialization.json.jsonObject
import kotlinx.serialization.json.jsonPrimitive
import okhttp3.OkHttpClient
import okhttp3.Request
import java.util.concurrent.TimeUnit

/**
 * Previsão do tempo via wttr.in (gratuito, sem chave):
 * https://wttr.in/Parauna?format=j1
 * Fallback automático para dados mock offline.
 */
class WeatherRepository {

    private val client = OkHttpClient.Builder()
        .connectTimeout(10, TimeUnit.SECONDS)
        .readTimeout(15, TimeUnit.SECONDS)
        .build()

    private val json = Json { ignoreUnknownKeys = true }

    suspend fun fetchWeather(city: String = "Parauna"): WeatherReport =
        withContext(Dispatchers.IO) {
            try {
                val url = "https://wttr.in/$city?format=j1"
                val request = Request.Builder().url(url).get().build()
                val body = client.newCall(request).execute().use { it.body?.string() }
                    ?: return@withContext MockWeather.report(city)
                parse(body, city)
            } catch (e: Exception) {
                MockWeather.report(city)
            }
        }

    private fun parse(body: String, fallbackCity: String): WeatherReport {
        val root: JsonObject = json.parseToJsonElement(body).jsonObject
        val nearest = root["nearest_area"]?.jsonArray?.firstOrNull()?.jsonObject
        val city = nearest?.get("areaName")?.jsonArray?.firstOrNull()
            ?.jsonObject?.get("value")?.jsonPrimitive?.content ?: fallbackCity
        val region = nearest?.get("region")?.jsonArray?.firstOrNull()
            ?.jsonObject?.get("value")?.jsonPrimitive?.content ?: ""
        val country = nearest?.get("country")?.jsonArray?.firstOrNull()
            ?.jsonObject?.get("value")?.jsonPrimitive?.content ?: ""

        val current = root["current_condition"]?.jsonArray?.firstOrNull()?.jsonObject
        fun num(obj: JsonObject?, key: String): Int =
            obj?.get(key)?.jsonPrimitive?.content?.toIntOrNull() ?: 0

        val hourly = mutableListOf<HourForecast>()
        val daily = mutableListOf<DayForecast>()
        val weatherArr: JsonArray? = root["weather"] as? JsonArray
        weatherArr?.forEach { dayEl ->
            val day = dayEl.jsonObject
            val date = day["date"]?.jsonPrimitive?.content ?: ""
            val avg = day["avgtempC"]?.jsonPrimitive?.content?.toIntOrNull() ?: 0
            val max = day["maxtempC"]?.jsonPrimitive?.content?.toIntOrNull() ?: avg
            val min = day["mintempC"]?.jsonPrimitive?.content?.toIntOrNull() ?: avg
            val desc = day["hourly"]?.jsonArray?.firstOrNull()?.jsonObject
                ?.get("weatherDesc")?.jsonArray?.firstOrNull()?.jsonObject
                ?.get("value")?.jsonPrimitive?.content ?: ""
            daily += DayForecast(date, weekdayOf(date), max, min, desc)
            if (hourly.size < 5) {
                val h = day["hourly"]?.jsonArray
                h?.forEach { hourEl ->
                    if (hourly.size >= 5) return@forEach
                    val ho = hourEl.jsonObject
                    val timeRaw = ho["time"]?.jsonPrimitive?.content ?: "0"
                    val hour = timeRaw.padStart(4, '0').substring(0, 2).toIntOrNull() ?: 0
                    val label = if (hourly.isEmpty()) "Agora" else "${hour}h"
                    hourly += HourForecast(
                        time = label,
                        tempC = ho["tempC"]?.jsonPrimitive?.content?.toIntOrNull() ?: 0,
                        condition = ho["weatherDesc"]?.jsonArray?.firstOrNull()
                            ?.jsonObject?.get("value")?.jsonPrimitive?.content ?: "",
                        chanceOfRain = ho["chanceofrain"]?.jsonPrimitive?.content?.toIntOrNull() ?: 0
                    )
                }
            }
        }

        return WeatherReport(
            city = city,
            region = region,
            country = country,
            tempC = num(current, "temp_C"),
            feelsLikeC = num(current, "FeelsLikeC"),
            condition = current?.get("weatherDesc")?.jsonArray?.firstOrNull()
                ?.jsonObject?.get("value")?.jsonPrimitive?.content ?: "—",
            conditionCode = num(current, "weatherCode"),
            humidity = num(current, "humidity"),
            windKmh = num(current, "windspeedKmph"),
            windDir = current?.get("winddir16Point")?.jsonPrimitive?.content ?: "",
            uvIndex = num(current, "uvIndex"),
            hourly = hourly,
            daily = daily,
            isMock = false
        )
    }

    private fun weekdayOf(date: String): String {
        val map = mapOf(
            "2026-11-21" to "Sex", "2026-11-22" to "Sáb", "2026-11-23" to "Dom",
            "2026-11-24" to "Seg", "2026-11-25" to "Ter"
        )
        return map[date] ?: date.takeLast(2)
    }
}
