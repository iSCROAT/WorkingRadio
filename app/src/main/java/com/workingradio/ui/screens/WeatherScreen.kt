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
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material.icons.filled.Cloud
import androidx.compose.material.icons.filled.LocationOn
import androidx.compose.material.icons.filled.Notifications
import androidx.compose.material.icons.filled.Refresh
import androidx.compose.material.icons.filled.Thunderstorm
import androidx.compose.material.icons.filled.WaterDrop
import androidx.compose.material.icons.filled.WbSunny
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.Slider
import androidx.compose.material3.SliderDefaults
import androidx.compose.material3.Switch
import androidx.compose.material3.SwitchDefaults
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
import com.workingradio.ui.theme.WrAccent
import com.workingradio.ui.theme.WrSurface
import com.workingradio.ui.theme.WrSurfaceElevated
import com.workingradio.ui.theme.WrTextMuted
import com.workingradio.ui.theme.WrTextPrimary
import com.workingradio.ui.theme.WrTextSecondary
import com.workingradio.ui.viewmodel.RadioViewModel
import com.workingradio.ui.viewmodel.WeatherViewModel

/**
 * TELA 2 — Previsão do Tempo (adaptada de "Heart Limit" do protótipo).
 * Card grande com temperatura, abas Hoje/Semana, notificações e volume.
 */
@Composable
fun WeatherScreen(
    weatherViewModel: WeatherViewModel,
    radioViewModel: RadioViewModel,
    onBack: () -> Unit,
    modifier: Modifier = Modifier
) {
    val report by weatherViewModel.report.collectAsState()
    val loading by weatherViewModel.loading.collectAsState()
    val volume by radioViewModel.volume.collectAsState()
    var selectedTab by remember { mutableStateOf(0) } // 0 = Hoje, 1 = Semana
    var notificationsOn by remember { mutableStateOf(true) }

    Column(
        modifier = modifier
            .fillMaxSize()
            .background(Color(0xFF0B0C0F))
            .padding(horizontal = 20.dp, vertical = 16.dp)
    ) {
        // Voltar para configurações
        Row(verticalAlignment = Alignment.CenterVertically) {
            IconButton(onClick = onBack) {
                Icon(Icons.Filled.ArrowBack, contentDescription = "Voltar", tint = WrTextPrimary)
            }
            Text("Voltar para configurações", fontSize = 13.sp, color = WrTextSecondary)
            Spacer(Modifier.weight(1f))
            if (loading) {
                CircularProgressIndicator(modifier = Modifier.size(18.dp), color = WrAccent, strokeWidth = 2.dp)
            } else {
                IconButton(onClick = { weatherViewModel.refresh() }) {
                    Icon(Icons.Filled.Refresh, contentDescription = "Atualizar", tint = WrTextSecondary)
                }
            }
        }

        Spacer(Modifier.height(8.dp))

        Text("Previsão do\nTempo", fontSize = 34.sp, fontWeight = FontWeight.Bold, color = WrTextPrimary, lineHeight = 38.sp)
        Spacer(Modifier.height(6.dp))
        Text(
            "Veja a previsão para sua cidade\ncom dados ao vivo (wttr.in)",
            fontSize = 13.sp,
            color = WrTextSecondary
        )

        Spacer(Modifier.height(20.dp))

        // Card grande — temperatura atual (adaptado de "140 bpm")
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .clip(RoundedCornerShape(28.dp))
                .background(WrSurface)
                .padding(24.dp)
        ) {
            Column {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Icon(Icons.Filled.LocationOn, contentDescription = null, tint = WrAccent, modifier = Modifier.size(18.dp))
                    Spacer(Modifier.size(4.dp))
                    Text(
                        "${report.city}, ${report.region} — ${report.country}",
                        fontSize = 13.sp,
                        fontWeight = FontWeight.SemiBold,
                        color = WrTextPrimary
                    )
                }
                Spacer(Modifier.height(8.dp))
                Row(verticalAlignment = Alignment.Bottom) {
                    Text(
                        text = "${report.tempC}°",
                        fontSize = 64.sp,
                        fontWeight = FontWeight.Light,
                        color = WrTextPrimary
                    )
                    Spacer(Modifier.size(8.dp))
                    Column(modifier = Modifier.padding(bottom = 10.dp)) {
                        Text("°C", fontSize = 16.sp, color = WrTextSecondary)
                        Text(report.condition, fontSize = 12.sp, color = WrTextSecondary)
                    }
                    Spacer(Modifier.weight(1f))
                    Icon(
                        imageVector = weatherIcon(report.conditionCode),
                        contentDescription = report.condition,
                        tint = WrAccent,
                        modifier = Modifier.size(44.dp).padding(bottom = 8.dp)
                    )
                }
                Spacer(Modifier.height(12.dp))
                Row(horizontalArrangement = Arrangement.spacedBy(16.dp)) {
                    WeatherStat(Icons.Filled.WaterDrop, "Umidade", "${report.humidity}%")
                    WeatherStat(Icons.Filled.Cloud, "Vento", "${report.windKmh} km/h ${report.windDir}")
                    WeatherStat(Icons.Filled.WbSunny, "UV", "${report.uvIndex}")
                }
                if (report.isMock) {
                    Spacer(Modifier.height(8.dp))
                    Text("Modo offline — dados de demonstração", fontSize = 11.sp, color = WrTextMuted)
                }
            }
        }

        Spacer(Modifier.height(20.dp))

        // Abas Hoje / Semana (adaptado de Resting / Gym)
        Row(horizontalArrangement = Arrangement.spacedBy(28.dp)) {
            TabLabel("Hoje", selected = selectedTab == 0) { selectedTab = 0 }
            TabLabel("Semana", selected = selectedTab == 1) { selectedTab = 1 }
        }

        Spacer(Modifier.height(12.dp))

        if (selectedTab == 0) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                report.hourly.forEach { hour ->
                    Column(horizontalAlignment = Alignment.CenterHorizontally) {
                        Text(hour.time, fontSize = 11.sp, color = WrTextMuted)
                        Spacer(Modifier.height(4.dp))
                        Icon(
                            imageVector = weatherIconForText(hour.condition),
                            contentDescription = hour.condition,
                            tint = WrTextSecondary,
                            modifier = Modifier.size(22.dp)
                        )
                        Spacer(Modifier.height(4.dp))
                        Text("${hour.tempC}°", fontSize = 13.sp, fontWeight = FontWeight.SemiBold, color = WrTextPrimary)
                    }
                }
            }
        } else {
            Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                report.daily.forEach { day ->
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .clip(RoundedCornerShape(14.dp))
                            .background(WrSurfaceElevated)
                            .padding(horizontal = 14.dp, vertical = 10.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Text(day.weekday, fontSize = 13.sp, fontWeight = FontWeight.SemiBold, color = WrTextPrimary, modifier = Modifier.size(44.dp))
                        Icon(
                            imageVector = weatherIconForText(day.condition),
                            contentDescription = day.condition,
                            tint = WrTextSecondary,
                            modifier = Modifier.size(20.dp)
                        )
                        Spacer(Modifier.size(8.dp))
                        Text(day.condition, fontSize = 12.sp, color = WrTextSecondary, modifier = Modifier.weight(1f))
                        Text("${day.minC}°  ${day.maxC}°", fontSize = 13.sp, color = WrTextPrimary)
                    }
                }
            }
        }

        Spacer(Modifier.weight(1f))

        // Volume (adaptado de "140 bpm" → slider) + Notificações
        Text("Volume da rádio", fontSize = 12.sp, color = WrTextMuted)
        Slider(
            value = volume,
            onValueChange = { radioViewModel.setVolume(it) },
            modifier = Modifier.fillMaxWidth(),
            colors = SliderDefaults.colors(
                thumbColor = WrAccent,
                activeTrackColor = WrAccent,
                inactiveTrackColor = WrSurfaceElevated
            )
        )

        Row(
            modifier = Modifier.fillMaxWidth(),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Icon(Icons.Filled.Notifications, contentDescription = null, tint = WrTextSecondary, modifier = Modifier.size(20.dp))
            Spacer(Modifier.size(8.dp))
            Text("Notificações", fontSize = 14.sp, color = WrTextPrimary)
            Spacer(Modifier.weight(1f))
            Switch(
                checked = notificationsOn,
                onCheckedChange = { notificationsOn = it },
                colors = SwitchDefaults.colors(
                    checkedTrackColor = WrAccent,
                    checkedThumbColor = Color.White
                )
            )
        }
    }
}

@Composable
private fun TabLabel(text: String, selected: Boolean, onClick: () -> Unit) {
    Column(
        modifier = Modifier.clickable(onClick = onClick),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Text(
            text = text,
            fontSize = 15.sp,
            fontWeight = if (selected) FontWeight.SemiBold else FontWeight.Normal,
            color = if (selected) WrTextPrimary else WrTextMuted
        )
        Spacer(Modifier.height(4.dp))
        Box(
            modifier = Modifier
                .height(2.dp)
                .fillMaxWidth()
                .background(if (selected) WrAccent else Color.Transparent)
        )
    }
}

@Composable
private fun WeatherStat(icon: androidx.compose.ui.graphics.vector.ImageVector, label: String, value: String) {
    Row(verticalAlignment = Alignment.CenterVertically) {
        Icon(icon, contentDescription = null, tint = WrAccent, modifier = Modifier.size(16.dp))
        Spacer(Modifier.size(4.dp))
        Column {
            Text(label, fontSize = 10.sp, color = WrTextMuted)
            Text(value, fontSize = 12.sp, fontWeight = FontWeight.SemiBold, color = WrTextPrimary)
        }
    }
}

private fun weatherIcon(code: Int) = when (code) {
    113 -> Icons.Filled.WbSunny
    116, 119, 122 -> Icons.Filled.Cloud
    143, 176, 179, 182, 185, 200, 386, 389 -> Icons.Filled.Thunderstorm
    else -> Icons.Filled.Cloud
}

private fun weatherIconForText(condition: String) = when {
    condition.contains("sol", ignoreCase = true) || condition.contains("limpo", ignoreCase = true) -> Icons.Filled.WbSunny
    condition.contains("chuva", ignoreCase = true) || condition.contains("tempestade", ignoreCase = true) -> Icons.Filled.Thunderstorm
    else -> Icons.Filled.Cloud
}
