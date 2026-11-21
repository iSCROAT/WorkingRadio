package com.workingradio

import android.app.Application
import com.workingradio.data.RadioRepository
import com.workingradio.data.WeatherRepository

/**
 * WorkingRadio — MVP v1.0.0
 * Application com repositórios compartilhados (player + tempo).
 */
class WorkingRadioApp : Application() {

    lateinit var radioRepository: RadioRepository
        private set

    lateinit var weatherRepository: WeatherRepository
        private set

    override fun onCreate() {
        super.onCreate()
        radioRepository = RadioRepository(this)
        weatherRepository = WeatherRepository()
    }
}
