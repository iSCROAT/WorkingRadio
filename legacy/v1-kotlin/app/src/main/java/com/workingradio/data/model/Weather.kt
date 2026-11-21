package com.workingradio.data.model

import kotlinx.serialization.Serializable

/** Previsão do tempo (wttr.in — sem chave de API). */
@Serializable
data class WeatherReport(
    val city: String,
    val region: String,
    val country: String,
    val tempC: Int,
    val feelsLikeC: Int,
    val condition: String,
    val conditionCode: Int,
    val humidity: Int,
    val windKmh: Int,
    val windDir: String,
    val uvIndex: Int,
    val hourly: List<HourForecast> = emptyList(),
    val daily: List<DayForecast> = emptyList(),
    val isMock: Boolean = false
)

@Serializable
data class HourForecast(
    val time: String,
    val tempC: Int,
    val condition: String,
    val chanceOfRain: Int
)

@Serializable
data class DayForecast(
    val date: String,
    val weekday: String,
    val maxC: Int,
    val minC: Int,
    val condition: String
)

/** Fallback offline — dados de demonstração. */
object MockWeather {
    fun report(city: String = "Paraúna"): WeatherReport = WeatherReport(
        city = city,
        region = "Goiás",
        country = "Brasil",
        tempC = 28,
        feelsLikeC = 30,
        condition = "Parcialmente nublado",
        conditionCode = 116,
        humidity = 62,
        windKmh = 14,
        windDir = "SE",
        uvIndex = 8,
        hourly = listOf(
            HourForecast("Agora", 28, "Parcialmente nublado", 10),
            HourForecast("15h", 29, "Ensolarado", 5),
            HourForecast("18h", 27, "Parcialmente nublado", 15),
            HourForecast("21h", 24, "Céu limpo", 10),
            HourForecast("00h", 22, "Céu limpo", 5)
        ),
        daily = listOf(
            DayForecast("2026-11-21", "Sex", 31, 19, "Ensolarado"),
            DayForecast("2026-11-22", "Sáb", 30, 18, "Parcialmente nublado"),
            DayForecast("2026-11-23", "Dom", 27, 17, "Chuva leve"),
            DayForecast("2026-11-24", "Seg", 29, 18, "Ensolarado"),
            DayForecast("2026-11-25", "Ter", 32, 20, "Ensolarado")
        ),
        isMock = true
    )
}
