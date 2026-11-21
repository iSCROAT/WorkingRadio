package com.workingradio.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.workingradio.data.model.ProgramSlot
import com.workingradio.ui.theme.WrAccent
import com.workingradio.ui.theme.WrBarTrack
import com.workingradio.ui.theme.WrTextMuted
import com.workingradio.ui.theme.WrTextSecondary

/**
 * Gráfico de barras da programação (adaptado de "Average" do protótipo).
 * A barra vermelha = programa atual.
 */
@Composable
fun ProgramBarChart(
    slots: List<ProgramSlot>,
    modifier: Modifier = Modifier
) {
    val max = (slots.maxOfOrNull { it.audience } ?: 1).toFloat()
    Column(modifier = modifier) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.Bottom
        ) {
            slots.forEach { slot ->
                val barHeight = (slot.audience / max * 72f).dp
                Column(
                    horizontalAlignment = Alignment.CenterHorizontally,
                    verticalArrangement = Arrangement.spacedBy(6.dp)
                ) {
                    Text(
                        text = slot.audience.toString(),
                        fontSize = 11.sp,
                        fontWeight = FontWeight.SemiBold,
                        color = if (slot.isCurrent) WrAccent else WrTextSecondary
                    )
                    Box(
                        modifier = Modifier
                            .width(26.dp)
                            .height(barHeight)
                            .clip(RoundedCornerShape(8.dp))
                            .background(if (slot.isCurrent) WrAccent else WrBarTrack)
                    )
                    Text(
                        text = slot.hourLabel,
                        fontSize = 10.sp,
                        color = WrTextMuted
                    )
                }
            }
        }
    }
}
