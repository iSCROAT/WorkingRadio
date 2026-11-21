# Design System — Working Radio v2 (Neumorfismo)

Tokens extraídos do protótipo via engenharia reversa visual (REA) + especificação
de neumorfismo dark. Implementação em `lib/core/theme/neumorphic_theme.dart` e
`lib/core/widgets/neumorphic.dart`.

## Paleta (neumorfismo dark)

| Token | Valor | Uso |
|-------|-------|-----|
| `background` / `surface` | `#14161A` | Fundo e elementos (mesma cor = relevo por sombra) |
| `lightShadow` | `#2B2E35` | Sombra clara (superior-esquerda) |
| `darkShadow` | `#0A0B0D` | Sombra escura (inferior-direita) |
| `accent` | `#FF3B5C` | Destaque premium (play ativo, barra atual, tabs) |
| `textPrimary` | `#FFFFFF` | Títulos e números |
| `textSecondary` | `#8A8D93` | Subtítulos |
| `textMuted` | `#5C5F66` | Labels e horários |

## Componentes neumórficos

| Componente | Widget | Efeito |
|------------|--------|--------|
| Botões realistas | `NeumorphicButton` | Convexo → côncavo ao pressionar (físico) |
| Cartões elevados | `NeumorphicCard` | Sombra dupla, flutuante |
| Campos físicos | `NeumorphicTextField` | Côncavo (relevo interno) |
| Ícones em relevo | `NeumorphicButton` circular | Sombra dupla + ícone central |
| Slider tátil | `NeumorphicSlider` | Trilha côncava + polegar convexo |
| Toggle tátil | `NeumorphicToggle` | Trilha côncava + botão convexo |
| Hexágono | `NeumorphicHexagon` | `drawShadow` duplo + borda accent |

## Tipografia

- Número principal: 64sp Light (temperatura) / 44sp Light (player)
- Títulos: 32–34sp Bold
- Corpo: 14sp; Labels: 11sp Medium

## Ícones (reais — Material Icons, sem emoji)

| Conceito | Ícone |
|----------|-------|
| Play / Pause | `play_arrow` / `pause` |
| Favorito | `favorite` / `favorite_border` |
| Tempo | `water_drop`, `wb_sunny`, `cloud`, `thunderstorm` |
| Navegação | `home`, `settings`, `arrow_back`, `refresh` |
| Volume | `volume_up` |
| Notificações | `notifications` |

## Mapeamento protótipo → app

| Protótipo | Working Radio v2 |
|-----------|------------------|
| Heart Rate / 120 bpm | Radio Ao Vivo / player neumórfico + stream real |
| Average (gráfico fake) | Temperatura real por hora (wttr.in) |
| Heart Limit / 140 bpm | Previsão do Tempo / temperatura °C real |
| Resting / Gym (abas) | Hoje / Semana |
| Notifications (toggle) | Volume slider + toggle persistido |
