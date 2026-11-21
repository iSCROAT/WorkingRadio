package com.workingradio.ui.components

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.unit.dp
import com.workingradio.ui.theme.WrAccent
import com.workingradio.ui.theme.WrSurface

/**
 * Hexágono do protótipo (fundo da tela principal) com gradiente sutil
 * e borda fina — assinatura visual premium do WorkingRadio.
 */
@Composable
fun HexagonBackground(
    modifier: Modifier = Modifier,
    fill: Color = WrSurface,
    stroke: Color = WrAccent.copy(alpha = 0.18f)
) {
    Canvas(modifier = modifier) {
        val w = size.width
        val h = size.height
        val cx = w / 2f
        val cy = h / 2f
        val r = minOf(w, h) / 2f
        val path = Path().apply {
            for (i in 0 until 6) {
                val angle = Math.toRadians((60 * i - 30).toDouble())
                val x = cx + r * kotlin.math.cos(angle).toFloat()
                val y = cy + r * kotlin.math.sin(angle).toFloat()
                if (i == 0) moveTo(x, y) else lineTo(x, y)
            }
            close()
        }
        drawPath(
            path = path,
            brush = Brush.radialGradient(
                colors = listOf(fill, fill.copy(alpha = 0.55f)),
                center = Offset(cx, cy),
                radius = r
            )
        )
        drawPath(path = path, color = stroke, style = Stroke(width = 1.5.dp.toPx()))
    }
}

/** Hexágono com conteúdo centralizado (ícones do protótipo). */
@Composable
fun HexagonSlot(
    modifier: Modifier = Modifier,
    content: @Composable BoxScope.() -> Unit
) {
    Box(modifier = modifier) {
        HexagonBackground(modifier = Modifier.fillMaxSize())
        Box(modifier = Modifier.fillMaxSize(), contentAlignment = androidx.compose.ui.Alignment.Center) {
            content()
        }
    }
}
