package com.workingradio.ui.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import com.workingradio.data.RadioRepository
import com.workingradio.data.model.MockStations
import com.workingradio.data.model.RadioStation
import kotlinx.coroutines.flow.StateFlow

class RadioViewModel(private val repository: RadioRepository) : ViewModel() {

    val isPlaying: StateFlow<Boolean> = repository.isPlaying
    val isBuffering: StateFlow<Boolean> = repository.isBuffering
    val currentStation: StateFlow<RadioStation> = repository.currentStation
    val volume: StateFlow<Float> = repository.volume
    val stations: List<RadioStation> = MockStations.stations

    fun toggle() = repository.toggle()
    fun play(station: RadioStation) = repository.play(station)
    fun setVolume(value: Float) = repository.setVolume(value)

    companion object {
        fun factory(repository: RadioRepository): ViewModelProvider.Factory =
            object : ViewModelProvider.Factory {
                @Suppress("UNCHECKED_CAST")
                override fun <T : ViewModel> create(modelClass: Class<T>): T {
                    return RadioViewModel(repository) as T
                }
            }
    }
}
