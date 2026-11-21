# Working Radio 📻

**Rádio online premium — Kotlin nativo + Jetpack Compose (Android)**
MVP v1.0.0 • Interface recriada a partir de protótipo via engenharia reversa visual (REA)

![Kotlin](https://img.shields.io/badge/Kotlin-2.0.20-7F52FF?style=flat-square)
![Android](https://img.shields.io/badge/Android-API%2026%2B-3DDC84?style=flat-square)
![Compose](https://img.shields.io/badge/Jetpack%20Compose-Material3-4285F4?style=flat-square)
![Player](https://img.shields.io/badge/Media3-ExoPlayer-FF3B5C?style=flat-square)
![CI](https://img.shields.io/badge/Codemagic-APK%20Debug-46E0B0?style=flat-square)

---

## 📱 O que é

O **Working Radio** é um aplicativo mobile de rádio online com visual premium dark,
recriado fielmente a partir do protótipo de referência (telas "Heart Rate" / "Heart Limit"
adaptadas para o universo de rádio + previsão do tempo).

### Telas do MVP

| Tela | Protótipo original | Adaptada para |
|------|-------------------|---------------|
| **Radio Ao Vivo** | Heart Rate (hexágono + 120 bpm + gráfico) | Player com hexágono, círculo central play/pause + frequência FM, gráfico de programação do dia |
| **Previsão do Tempo** | Heart Limit (140 bpm + abas + notificações) | Card de temperatura ao vivo (wttr.in), abas Hoje/Semana, slider de volume, toggle de notificações |
| **Configurações** | Back to settings | Lista de estações, tempo, notificações e sobre |

### Funções (v1.0.0)

- ▶️ **Player real** com Media3/ExoPlayer — 3 estações de demonstração (streams públicos SomaFM)
- 🌤️ **Previsão do tempo real** via [wttr.in](https://wttr.in) (gratuito, sem chave) — cidade, temperatura, umidade, vento, UV, próximas horas e 5 dias
- 🎨 **Ícones vetoriais reais** (Material Icons) — nenhum emoji como ícone
- 🧭 **Navegação** com bottom bar premium + back stack
- 📦 **CI/CD Codemagic** — APK debug gerado automaticamente a cada push (artefato baixável)

---

## 🚀 Como rodar

### Pré-requisitos
- Android Studio (Hedgehog+) com JDK 17
- Android SDK API 26+ (emulador ou aparelho físico)

### Build local
```bash
# gerar wrapper (uma vez, se ainda não existir)
gradle wrapper --gradle-version 8.7

./gradlew assembleDebug
# APK em: app/build/outputs/apk/debug/app-debug.apk
```

### CI/CD — Codemagic
O workflow [`codemagic.yaml`](codemagic.yaml) (`android-debug-apk`) compila o APK debug
a cada push e publica como **artefato baixável** no Codemagic.
Para ativar: conecte este repositório em [codemagic.io](https://codemagic.io) — nenhum passo extra necessário.

---

## 🏗️ Arquitetura

```
app/src/main/java/com/workingradio/
├── MainActivity.kt            # Activity única + Compose
├── WorkingRadioApp.kt         # Application (repositórios)
├── data/
│   ├── RadioRepository.kt     # Media3/ExoPlayer (streams)
│   ├── WeatherRepository.kt   # wttr.in (OkHttp + JSON)
│   └── model/                 # RadioStation, WeatherReport, mocks
└── ui/
    ├── theme/                 # Paleta extraída do protótipo
    ├── components/            # Hexágono, gráfico de barras
    ├── screens/               # Home, Weather, Settings
    ├── viewmodel/             # RadioViewModel, WeatherViewModel
    └── navigation/            # NavGraph (3 rotas)
```

**Stack:** Kotlin 2.0 • Jetpack Compose (Material3) • Media3 ExoPlayer • OkHttp •
kotlinx.serialization • Navigation Compose • MVVM

---

## 🔧 Engenharia reversa com REA

O protótipo foi analisado com o [REA](https://github.com/morluto/rea) (*Reverse Engineer Anything*):
extração de paleta, formas (hexágono/círculo), hierarquia e densidade visual — depois
reconstruídos em Compose nativo. Guia completo em [`docs/REA-SETUP.md`](docs/REA-SETUP.md)
e sistema de design em [`docs/DESIGN-SYSTEM.md`](docs/DESIGN-SYSTEM.md).

```bash
# REA já instalado neste ambiente (rea@6.7.0)
rea --help
rea doctor
```

---

## 📋 Roadmap

- [x] **v1.0.0** — MVP: player + tempo + 3 telas + CI Codemagic
- [ ] **v1.1.0** — Favoritos persistentes (DataStore) + histórico de estações
- [ ] **v1.2.0** — Stream oficial da rádio (trocar URL mock) + capa da estação
- [ ] **v1.3.0** — Notificações de programas + widget de player
- [ ] **v2.0.0** — iOS (Kotlin Multiplatform) + Play Store

Ver [`CHANGELOG.md`](CHANGELOG.md) para o histórico de versões.

---

## 📄 Licença

Uso interno / MVP — definir licença antes da publicação na Play Store.
