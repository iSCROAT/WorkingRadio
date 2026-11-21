package com.workingradio.data.model

/**
 * Estação de rádio online (streams públicos de demonstração — SomaFM).
 * Para produção, substitua [streamUrl] pela URL oficial da rádio.
 */
data class RadioStation(
    val id: String,
    val name: String,
    val frequency: String,
    val genre: String,
    val streamUrl: String
)

object MockStations {
    val stations: List<RadioStation> = listOf(
        RadioStation(
            id = "groove-salad",
            name = "Groove Salad",
            frequency = "98.5 FM",
            genre = "Chill / Ambiente",
            streamUrl = "https://ice1.somafm.com/groovesalad-128-mp3"
        ),
        RadioStation(
            id = "secret-agent",
            name = "Secret Agent",
            frequency = "101.1 FM",
            genre = "Spy / Lounge",
            streamUrl = "https://ice1.somafm.com/secretagent-128-mp3"
        ),
        RadioStation(
            id = "drone-zone",
            name = "Drone Zone",
            frequency = "104.7 FM",
            genre = "Drone / Atmosférico",
            streamUrl = "https://ice1.somafm.com/dronezone-128-mp3"
        )
    )
}

/** Programação do dia exibida no gráfico de barras (audiência por hora). */
data class ProgramSlot(
    val hourLabel: String,
    val audience: Int,
    val program: String,
    val isCurrent: Boolean = false
)

object MockSchedule {
    val slots: List<ProgramSlot> = listOf(
        ProgramSlot("2 pm", 86, "Madrugada"),
        ProgramSlot("3 pm", 91, "Manhã"),
        ProgramSlot("4 pm", 84, "Meio-dia"),
        ProgramSlot("5 pm", 124, "Tarde"),
        ProgramSlot("6 pm", 148, "Pico"),
        ProgramSlot("7 pm", 116, "Noite", isCurrent = true)
    )
}
