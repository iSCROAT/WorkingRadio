# Working Radio 📻

**Rádio online premium global — Flutter (Dart) + Neumorfismo**
v4.0.0 • Android (iOS futuro) • CI/CD GitHub Actions

![Flutter](https://img.shields.io/badge/Flutter-3.24-02569B?style=flat-square)
![Dart](https://img.shields.io/badge/Dart-3.5-0175C2?style=flat-square)
![Android](https://img.shields.io/badge/Android-API%2021%2B-3DDC84?style=flat-square)
![Player](https://img.shields.io/badge/just_audio-0.9-FF3B5C?style=flat-square)
![CI](https://img.shields.io/badge/GitHub%20Actions-APK-46E0B0?style=flat-square)

---

## 📱 O que é

O **Working Radio** é um aplicativo mobile de rádio online com visual **neumórfico premium**,
recriado a partir do protótipo de referência via engenharia reversa visual (REA) —
agora em **Flutter** (1 código para Android + iOS futuro).

### Telas da v2

| Tela | Conteúdo real |
|------|---------------|
| **Radio Ao Vivo** | Hexágono neumórfico + botão play convexo, stream configurável (just_audio), gráfico de **temperatura real por hora** |
| **Explorar rádios** | Catálogo ampliado: **Brasil (200 estações)**, **Mundo**, **Perto** (GPS) e **País**; lupa por nome/cidade/estado/tag |
| **Mapa de estações** | Pontos reais das estações ativas (OpenStreetMap), sua posição, card com play e distância |
| **Globo de estações** | Globo em meio-tom recriado do protótipo (ENG. REVERSA): arraste para girar, pinça p/ zoom, tap no ponto abre a estação com **local exato preservado** (coordenadas, país, codec, distância, tags) |
| **Previsão do Tempo** | Card com temperatura real (wttr.in), **local escolhível (GPS, cidade ou país)**, abas Hoje/Semana |
| **Configurações** | Campo físico para URL do stream + cidade, estações, notificações, sobre |

### Princípio da v2: zero demonstrações falsas

- ✅ **Catálogo global real**: [Radio Browser](https://www.radio-browser.info) (sem chave)
- ✅ Stream real configurável (padrão: SomaFM público — substitua pela URL oficial)
- ✅ **Geolocalização real** (`geolocator`) + reverse geocoding OpenStreetMap
- ✅ Tempo real via [wttr.in](https://wttr.in) (sem chave) — erro mostra estado real, nunca dado fake
- ✅ Gráfico com dados reais da API
- ✅ Configurações persistidas (SharedPreferences)

### Neumorfismo

Botões convexos que afundam ao tocar, cards flutuantes, campos côncavos,
ícones em relevo e sliders/toggles táteis — tudo com sombras duplas
(`#2B2E35` / `#0A0B0D`) sobre a superfície `#14161A`. Ver [`docs/DESIGN-SYSTEM.md`](docs/DESIGN-SYSTEM.md).

---

## 🚀 Como rodar

### Pré-requisitos
- Flutter SDK 3.24+ ([flutter.dev](https://flutter.dev))
- Android Studio com JDK 17

### Build local
```bash
flutter pub get
flutter build apk --debug
# APK em: build/app/outputs/flutter-apk/app-debug.apk
```

### CI/CD — GitHub Actions
O workflow [`.github/workflows/android.yml`](.github/workflows/android.yml):
- **A cada push**: compila o APK debug e publica como **artefato** (`app-debug`)
- **A cada tag `v*`**: compila o APK release e publica como **Release** no GitHub

Para baixar: aba **Actions** → build mais recente → **Artifacts** → `app-debug` (APK
debug, ~87 MB — inclui a VM de depuração; o release é bem menor).
Ou em **Releases** (para tags `v*`).

> **Status:** build ✅ verde — APK Flutter v2.0.0 gerado pelo GitHub Actions.

---

## 🏗️ Arquitetura

```
lib/
├── main.dart                  # Entrada
├── app.dart                   # Providers + MaterialApp + bootstrap
├── main_shell.dart            # Bottom nav neumórfica (3 abas)
├── core/
│   ├── theme/                 # Tokens neumórficos
│   ├── geo/                   # Globo (projeção ortográfica + máscara de terra)
│   └── widgets/               # Botões, cards, slider, toggle, hexágono, pílula
└── features/
    ├── radio/                 # just_audio (stream real)
    ├── stations/              # Radio Browser (catálogo global + mapa)
    ├── location/              # GPS + reverse geocoding (OSM)
    ├── weather/               # wttr.in (tempo real)
    ├── settings/              # SharedPreferences (URL, cidade, prefs)
    └── home/                  # Tela principal
```

**Stack:** Flutter 3.24 • Dart 3.5 • just_audio • http • provider • shared_preferences
• geolocator • flutter_map + latlong2 (OpenStreetMap)

> A v1 (Kotlin nativo) está arquivada em [`legacy/v1-kotlin/`](legacy/v1-kotlin/).

---

## 🔧 Engenharia reversa com REA

Protótipo analisado com o [REA](https://github.com/morluto/rea): extração de paleta,
formas e hierarquia — reconstruídos em Flutter com neumorfismo.
Guia completo em [`docs/REA-SETUP.md`](docs/REA-SETUP.md).

---

## 📋 Roadmap

- [x] **v1.0.0** — Kotlin nativo (arquivado em `legacy/`)
- [x] **v2.0.0** — Flutter + Neumorfismo + GitHub CI/CD + dados reais
- [x] **v3.0.0** — Rádios globais (Radio Browser) + geolocalização + mapa de estações
- [x] **v4.0.0** — Auditoria de UI (zero acessos duplicados) + local do tempo (GPS/cidade/país) + catálogo ampliado
- [ ] **v3.1.0** — Favoritos persistentes + histórico de reprodução
- [ ] **v3.2.0** — Filtro por gênero/tag + idioma + ordenação por qualidade
- [ ] **v3.3.0** — Player em segundo plano (notificação) + widget de tela inicial
- [ ] **v4.0.0** — iOS (pasta `ios/`) + Play Store

Ver [`CHANGELOG.md`](CHANGELOG.md) para o histórico de versões.

---

## 📄 Licença

Uso interno / MVP — definir licença antes da publicação na Play Store.
