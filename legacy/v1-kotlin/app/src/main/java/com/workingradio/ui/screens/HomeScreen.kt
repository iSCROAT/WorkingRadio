package com.workingradio.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Bolt
import androidx.compose.material.icons.filled.Favorite
import androidx.compose.material.icons.filled.FavoriteBorder
import androidx.compose.material.icons.filled.Home
import androidx.compose.material.icons.filled.MoreVert
import androidx.compose.material.icons.filled.Pause
import androidx.compose.material.icons.filled.PlayArrow
import androidx.compose.material.icons.filled.Radio
import androidx.compose.material.icons.filled.Settings
import androidx.compose.material.icons.filled.WaterDrop
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.workingradio.data.model.MockSchedule
import com.workingradio.ui.components.HexagonSlot
import com.workingradio.ui.components.ProgramBarChart
import com.workingradio.ui.theme.WrAccent
import com.workingradio.ui.theme.WrCircle
import com.workingradio.ui.theme.WrSurface
import com.workingradio.ui.theme.WrTextMuted
import com.workingradio.ui.theme.WrTextPrimary
import com.workingradio.ui.theme.WrTextSecondary
import com.workingradio.ui.viewmodel.RadioViewModel

/**
 * TELA 1 — Radio Ao Vivo (adaptada de "Heart Rate" do protótipo).
 * Hexágono com 3 ícones reais (favorito, tempo, ao vivo),
 * círculo central com play/pause + frequência, gráfico de programação.
 */
@Composable
fun HomeScreen(
    viewModel: RadioViewModel,
    onOpenWeather: () -> Unit,
    onOpenSettings: () -> Unit,
    modifier: Modifier = Modifier
) {
    val isPlaying by viewModel.isPlaying.collectAsState()
    val isBuffering by viewModel.isBuffering.collectAsState()
    val station by viewModel.currentStation.collectAsState()
    var isFavorite by remember { mutableStateOf(false) }

    Column(
        modifier = modifier
            .fillMaxSize()
            .background(Color(0xFF0B0C0F))
            .padding(horizontal = 20.dp, vertical = 16.dp)
    ) {
        // Header — "Radio Ao Vivo" + menu
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Column {
                Text(
                    text = "Radio Ao Vivo",
                    fontSize = 18.sp,
                    fontWeight = FontWeight.SemiBold,
                    color = WrTextPrimary
                )
                Text(
                    text = station.genre,
                    fontSize = 12.sp,
                    color = WrTextMuted
                )
            }
            IconButton(onClick = {}) {
                Icon(Icons.Filled.MoreVert, contentDescription = "Menu", tint = WrTextSecondary)
            }
        }

        Spacer(Modifier.height(12.dp))

        // Hexágono principal com ícones do protótipo
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(300.dp),
            contentAlignment = Alignment.Center
        ) {
            HexagonSlot(modifier = Modifier.size(300.dp)) {
                // Ícone favorito (coração vermelho do protótipo)
                Icon(
                    imageVector = if (isFavorite) Icons.Filled.Favorite else Icons.Filled.FavoriteBorder,
                    contentDescription = "Favoritar",
                    tint = WrAccent,
                    modifier = Modifier
                        .size(28.dp)
                        .align(Alignment.TopCenter)
                        .padding(top = 18.dp)
                        .clickable { isFavorite = !isFavorite }
                )
                // Ícone tempo (gota — abre a previsão)
                Icon(
                    imageVector = Icons.Filled.WaterDrop,
                    contentDescription = "Previsão do tempo",
                    tint = WrTextSecondary,
                    modifier = Modifier
                        .size(24.dp)
                        .align(Alignment.TopEnd)
                        .padding(top = 30.dp, end = 34.dp)
                        .clickable(onClick = onOpenWeather)
                )
                // Ícone ao vivo (raio)
                Icon(
                    imageVector = Icons.Filled.Bolt,
                    contentDescription = "Ao vivo",
                    tint = WrTextSecondary,
                    modifier = Modifier
                        .size(24.dp)
                        .align(Alignment.BottomStart)
                        .padding(bottom = 30.dp, start = 34.dp)
                )
                // Texto lateral "Analyze" do protótipo → "Ao Vivo"
                Text(
                    text = "Ao Vivo",
                    fontSize = 10.sp,
                    color = WrTextMuted,
                    modifier = Modifier
                        .align(Alignment.CenterEnd)
                        .padding(end = 10.dp)
                )
            }

            // Círculo central — play/pause + frequência
            Box(
                modifier = Modifier
                    .size(168.dp)
                    .clip(CircleShape)
                    .background(WrCircle)
                    .clickable { viewModel.toggle() },
                contentAlignment = Alignment.Center
            ) {
                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    if (isBuffering) {
                        CircularProgressIndicator(
                            modifier = Modifier.size(28.dp),
                            color = WrAccent,
                            strokeWidth = 2.5.dp
                        )
                    } else {
                        Icon(
                            imageVector = if (isPlaying) Icons.Filled.Pause else Icons.Filled.PlayArrow,
                            contentDescription = if (isPlaying) "Pausar" else "Tocar",
                            tint = WrTextPrimary,
                            modifier = Modifier.size(34.dp)
                        )
                    }
                    Spacer(Modifier.height(4.dp))
                    Text(
                        text = station.frequency.split(" ").first(),
                        fontSize = 40.sp,
                        fontWeight = FontWeight.Light,
                        color = WrTextPrimary
                    )
                    Text(
                        text = station.frequency.split(" ").last(),
                        fontSize = 12.sp,
                        color = WrTextSecondary
                    )
                    Text(
                        text = station.name,
                        fontSize = 11.sp,
                        fontWeight = FontWeight.SemiBold,
                        color = WrAccent
                    )
                }
            }
        }

        Spacer(Modifier.height(8.dp))

        // Programação do dia (adaptado de "Average")
        Row(verticalAlignment = Alignment.CenterVertically) {
            Icon(Icons.Filled.Radio, contentDescription = null, tint = WrTextMuted, modifier = Modifier.size(16.dp))
            Spacer(Modifier.size(6.dp))
            Text("Programação", fontSize = 13.sp, color = WrTextSecondary)
            Spacer(Modifier.weight(1f))
            Text("Audiência média", fontSize = 11.sp, color = WrTextMuted)
        }
        Spacer(Modifier.height(10.dp))
        ProgramBarChart(slots = MockSchedule.slots)

        Spacer(Modifier.weight(1f))

        // Bottom navigation premium
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .clip(CircleShape)
                .background(WrSurface)
                .padding(horizontal = 28.dp, vertical = 12.dp),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Icon(Icons.Filled.Home, contentDescription = "Início", tint = WrAccent, modifier = Modifier.size(26.dp))
            Icon(
                Icons.Filled.Radio,
                contentDescription = "Estações",
                tint = WrTextMuted,
                modifier = Modifier.size(26.dp)
            )
            Icon(
                Icons.Filled.Settings,
                contentDescription = "Configurações",
                tint = WrTextMuted,
                modifier = Modifier
                    .size(26.dp)
                    .clickable(onClick = onOpenSettings)
            )
        }
    }
}
