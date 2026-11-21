# Changelog — Working Radio

Formato baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.0.0/).
Versionamento: `version` semântico em `pubspec.yaml` (v2+) / `versionName`+`versionCode` (v1).

## [2.0.0] — 2026-11-21

### Adicionado
- **Migração de stack: Kotlin → Flutter (Dart)** — 1 código para Android + iOS futuro
- **Neumorfismo dark**: botões convexos/côncavos, cards elevados, campos físicos,
  ícones em relevo, slider e toggle táteis, hexágono com sombra dupla
- **CI/CD GitHub Actions** (`.github/workflows/android.yml`): APK debug como artefato
  a cada push + Release por tag `v*`
- Stream real configurável (just_audio) — URL editável nas Configurações, persistida
- Previsão do tempo real (wttr.in) com estados de erro reais (sem mock)
- Gráfico de temperatura real por hora (substitui o gráfico fake da v1)
- Navegação por abas com bottom bar neumórfica e transições
- Ícones reais (Material Icons + launcher vetorial/PNG) — sem emojis

### Removido
- Demonstrações falsas (estações mock, programação fake, fallback mock de tempo)
- CI/CD Codemagic (migrado para GitHub Actions)
- App Kotlin v1 movido para `legacy/v1-kotlin/` (arquivo histórico)

## [1.0.0] — 2026-11-21

### Adicionado
- MVP completo em **Kotlin nativo + Jetpack Compose** (Android API 26+)
- Tela **Radio Ao Vivo**: hexágono do protótipo, círculo central play/pause + frequência,
  gráfico de programação do dia, bottom bar premium
- Tela **Previsão do Tempo**: dados reais via wttr.in (sem chave), abas Hoje/Semana,
  slider de volume, toggle de notificações
- Tela **Configurações** com lista de estações e atalhos
- Player **Media3/ExoPlayer** com 3 streams de demonstração (SomaFM)
- Ícones vetoriais reais (Material Icons) — sem emojis
- CI/CD **Codemagic** (`codemagic.yaml`) — APK debug como artefato baixável
- Instalação do **REA** (`rea@6.7.0`) + documentação de engenharia reversa
- README premium, Design System e guia REA

### Notas
- Streams são de demonstração — substituir pela URL oficial da rádio em produção
- Previsão usa `wttr.in/Parauna?format=j1` com fallback offline (mock)
