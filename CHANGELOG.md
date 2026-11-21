# Changelog — Working Radio

Formato baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.0.0/).
Versionamento: `versionName` (semântico) + `versionCode` (incremental) em `app/build.gradle.kts`.

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
