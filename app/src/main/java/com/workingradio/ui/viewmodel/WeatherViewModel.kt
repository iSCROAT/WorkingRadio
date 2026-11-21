package com.workingradio.ui.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import com.workingradio.data.WeatherRepository
import com.workingradio.data.model.MockWeather
import com.workingradio.data.model.WeatherReport
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

class WeatherViewModel(private val repository: WeatherRepository) : ViewModel() {

    private val _report = MutableStateFlow(MockWeather.report())
    val report: StateFlow<WeatherReport> = _report.asStateFlow()

    private val _loading = MutableStateFlow(false)
    val loading: StateFlow<Boolean> = _loading.asStateFlow()

    init {
        refresh()
    }

    fun refresh(city: String = "Parauna") {
        viewModelScope.launch {
            _loading.value = true
            _report.value = repository.fetchWeather(city)
            _loading.value = false
        }
    }

    companion object {
        fun factory(repository: WeatherRepository): ViewModelProvider.Factory =
            object : ViewModelProvider.Factory {
                @Suppress("UNCHECKED_CAST")
                override fun <T : ViewModel> create(modelClass: Class<T>): T {
                    return WeatherViewModel(repository) as T
                }
            }
    }
}
