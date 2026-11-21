# REA — Engenharia Reversa (morluto/rea)

**REA** (*Reverse Engineer Anything*) é o MCP/CLI oficial para engenharia reversa
com agentes: inspeciona binários nativos, apps JavaScript/Electron, assemblies .NET,
APKs Android e comportamento em runtime — sempre local, com evidências.

- Repositório: https://github.com/morluto/rea
- Site: https://rea.tools
- Pacote npm: `rea-agents`

## Instalação (já feita neste ambiente)

```bash
npm install --global rea-agents
rea --help        # CLI pronto
rea doctor        # diagnóstico do ambiente
```

Versão instalada: **rea@6.7.0** (Node 22.22.3).

### Conectar ao seu agente (MCP) — na sua máquina

```bash
npx rea-agents setup
```

Escolha seu agente (Claude Code, Cursor, Codex…), aprove o plano e reinicie o agente.
O setup registra o MCP do REA + skill de investigação e faz backup da config existente.
Guia oficial: https://rea.tools/get-started/

### Motores de análise nativa (opcional, desktop)

`rea doctor` mostra o que falta. Para análise de binários nativos, configure um provedor:

| Provedor | Como configurar |
|----------|-----------------|
| Hopper | `rea setup` (instala com aprovação) ou `HOPPER_LAUNCHER_PATH` |
| Ghidra 12.1.x | `GHIDRA_INSTALL_DIR=/caminho/extraido` |
| IDA | `REA_IDA_MCP_CONFIG` (registro MCP do IDA) |
| jadx (Android) | `REA_JADX_MCP_JAR` (jadx-headless-mcp 0.7.1) |

Análise estática de JavaScript/Electron **não** precisa de motor nativo.

## Como o REA foi usado neste projeto

1. **Análise visual do protótipo** — extração de tokens de design:
   - Paleta: fundo `#0B0C0F`, superfície `#1A1B21`, acento `#FF3B5C`
   - Formas: hexágono com gradiente radial + círculo central elevado
   - Hierarquia: número grande (120 bpm → frequência FM), gráfico de barras com destaque vermelho
2. **Reconstrução** — os tokens viraram `ui/theme/Color.kt`, `HexagonShape.kt` e `BarChart.kt`
3. **Adaptação de domínio** — Heart Rate → Radio Ao Vivo; Heart Limit → Previsão do Tempo

## Comandos úteis no dia a dia

```bash
# Inspecionar um APK (ex.: validar o APK gerado pelo Codemagic)
rea inspect-android-package app-debug.apk
rea decode-android-resources app-debug.apk

# Analisar app JS/Electron extraído
rea analyze-javascript-application /caminho/do/app --json

# Capturar tela de dispositivo via ADB
rea capture-adb-screen
```

## Atualizar

```bash
rea update          # instalação global
npx rea-agents@latest setup   # via npx
```
