# Design System — Working Radio

Tokens extraídos do protótipo via engenharia reversa visual (REA).

## Paleta

| Token | Valor | Uso |
|-------|-------|-----|
| `WrBackground` | `#0B0C0F` | Fundo das telas |
| `WrSurface` | `#1A1B21` | Cards, bottom bar |
| `WrSurfaceElevated` | `#23242C` | Itens elevados, trilhas |
| `WrCircle` | `#2A2B33` | Círculo central do player |
| `WrAccent` | `#FF3B5C` | Destaque premium (coração, barra atual, tabs) |
| `WrTextPrimary` | `#FFFFFF` | Títulos e números |
| `WrTextSecondary` | `#8A8D93` | Subtítulos |
| `WrTextMuted` | `#5C5F66` | Labels e horários |

## Formas

- **Hexágono** (`HexagonShape.kt`): gradiente radial + borda fina `WrAccent 18%` — assinatura da tela principal
- **Círculo central**: 168dp, `WrCircle`, play/pause + frequência FM
- **Barras**: 26dp largura, raio 8dp; barra atual em `WrAccent`
- **Cards**: raio 28dp (temperatura), 16dp (itens de settings)

## Tipografia

- Número principal: 64sp Light (temperatura) / 40sp Light (frequência)
- Títulos: 32–34sp Bold
- Corpo: 14sp; Labels: 11sp Medium

## Ícones (reais — Material Icons Extended, sem emoji)

| Conceito | Ícone |
|----------|-------|
| Favorito | `Favorite` / `FavoriteBorder` |
| Tempo / umidade | `WaterDrop` |
| Ao vivo | `Bolt` |
| Play / Pause | `PlayArrow` / `Pause` |
| Navegação | `Home`, `Radio`, `Settings` |
| Tempo (condição) | `WbSunny`, `Cloud`, `Thunderstorm` |
| Localização | `LocationOn` |
| Notificações | `Notifications` |

## Mapeamento protótipo → app

| Protótipo | Working Radio |
|-----------|---------------|
| Heart Rate / 120 bpm | Radio Ao Vivo / frequência FM + play |
| Average (gráfico) | Programação do dia (audiência por hora) |
| Heart Limit / 140 bpm | Previsão do Tempo / temperatura °C |
| Resting / Gym (abas) | Hoje / Semana |
| Notifications (toggle) | Volume slider + toggle de notificações |
