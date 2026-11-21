package com.workingradio.ui.theme

import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.runtime.Composable

private val DarkColorScheme = darkColorScheme(
    primary = WrAccent,
    onPrimary = WrTextPrimary,
    background = WrBackground,
    onBackground = WrTextPrimary,
    surface = WrSurface,
    onSurface = WrTextPrimary,
    surfaceVariant = WrSurfaceElevated,
    onSurfaceVariant = WrTextSecondary
)

@Composable
fun WorkingRadioTheme(
    darkTheme: Boolean = true,
    content: @Composable () -> Unit
) {
    MaterialTheme(
        colorScheme = DarkColorScheme,
        typography = WorkingRadioTypography,
        content = content
    )
}
