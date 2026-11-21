package com.workingradio.data

import android.content.Context
import androidx.media3.common.C
import androidx.media3.common.MediaItem
import androidx.media3.common.Player
import androidx.media3.common.util.UnstableApi
import androidx.media3.exoplayer.ExoPlayer
import com.workingradio.data.model.MockStations
import com.workingradio.data.model.RadioStation
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow

/**
 * Player de rádio online com Media3/ExoPlayer.
 * Streams de demonstração (SomaFM) — troque por URL oficial em produção.
 */
@OptIn(UnstableApi::class)
class RadioRepository(context: Context) {

    private val player: ExoPlayer = ExoPlayer.Builder(context).build()

    private val _isPlaying = MutableStateFlow(false)
    val isPlaying: StateFlow<Boolean> = _isPlaying.asStateFlow()

    private val _currentStation = MutableStateFlow(MockStations.stations.first())
    val currentStation: StateFlow<RadioStation> = _currentStation.asStateFlow()

    private val _isBuffering = MutableStateFlow(false)
    val isBuffering: StateFlow<Boolean> = _isBuffering.asStateFlow()

    private val _volume = MutableStateFlow(0.8f)
    val volume: StateFlow<Float> = _volume.asStateFlow()

    private var prepared = false

    init {
        player.addListener(object : Player.Listener {
            override fun onIsPlayingChanged(isPlaying: Boolean) {
                _isPlaying.value = isPlaying
            }

            override fun onPlaybackStateChanged(playbackState: Int) {
                _isBuffering.value = playbackState == Player.STATE_BUFFERING
            }
        })
        player.volume = _volume.value
    }

    fun play(station: RadioStation = _currentStation.value) {
        _currentStation.value = station
        if (!prepared || player.currentMediaItem?.mediaId != station.id) {
            player.setMediaItem(
                MediaItem.Builder()
                    .setUri(station.streamUrl)
                    .setMediaId(station.id)
                    .build()
            )
            player.prepare()
            prepared = true
        }
        player.play()
    }

    fun pause() = player.pause()

    fun toggle() {
        if (player.isPlaying) pause() else play()
    }

    fun setVolume(value: Float) {
        _volume.value = value.coerceIn(0f, 1f)
        player.volume = _volume.value
    }

    fun release() = player.release()
}
