package com.workingradio.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
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
import androidx.compose.material.icons.filled.Info
import androidx.compose.material.icons.filled.Notifications
import androidx.compose.material.icons.filled.Radio
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.workingradio.ui.theme.WrAccent
import com.workingradio.ui.theme.WrSurface
import com.workingradio.ui.theme.WrTextMuted
import com.workingradio.ui.theme.WrTextPrimary
import com.workingradio.ui.theme.WrTextSecondary

/**
 * TELA 3 — Configurações (destino do "Back to settings" do protótipo).
 */
@Composable
fun SettingsScreen(
    onBack: () -> Unit,
    onOpenWeather: () -> Unit,
    modifier: Modifier = Modifier
) {
    Column(
        modifier = modifier
            .fillMaxSize()
            .background(Color(0xFF0B0C0F))
            .padding(horizontal = 20.dp, vertical = 16.dp)
    ) {
        Row(verticalAlignment = Alignment.CenterVertically) {
            IconButton(onClick = onBack) {
                Icon(Icons.Filled.ArrowBack, contentDescription = "Voltar", tint = WrTextPrimary)
            }
            Text("Configurações", fontSize = 20.sp, fontWeight = FontWeight.Bold, color = WrTextPrimary)
        }

        Spacer(Modifier.height(16.dp))

        SettingsItem(Icons.Filled.Radio, "Estações", "3 estações de demonstração", onClick = onBack)
        SettingsItem(Icons.Filled.Cloud, "Previsão do tempo", "wttr.in — dados ao vivo", onClick = onOpenWeather)
        SettingsItem(Icons.Filled.Notifications, "Notificações", "Alertas de programas", onClick = {})
        SettingsItem(Icons.Filled.Info, "Sobre", "Working Radio v1.0.0 — MVP", onClick = {})

        Spacer(Modifier.weight(1f))

        Text(
            "Working Radio • Kotlin + Jetpack Compose • v1.0.0",
            fontSize = 11.sp,
            color = WrTextMuted,
            modifier = Modifier.fillMaxWidth(),
            textAlign = androidx.compose.ui.text.style.TextAlign.Center
        )
    }
}

@Composable
private fun SettingsItem(
    icon: ImageVector,
    title: String,
    subtitle: String,
    onClick: () -> Unit
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(vertical = 6.dp)
            .clip(RoundedCornerShape(16.dp))
            .background(WrSurface)
            .clickable(onClick = onClick)
            .padding(horizontal = 16.dp, vertical = 14.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Icon(icon, contentDescription = null, tint = WrAccent, modifier = Modifier.size(22.dp))
        Spacer(Modifier.size(12.dp))
        Column {
            Text(title, fontSize = 14.sp, fontWeight = FontWeight.SemiBold, color = WrTextPrimary)
            Text(subtitle, fontSize = 12.sp, color = WrTextSecondary)
        }
    }
}
