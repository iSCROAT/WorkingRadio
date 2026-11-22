import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/neumorphic_theme.dart';
import '../../core/widgets/neumorphic.dart';
import '../radio/radio_service.dart';
import '../weather/weather_service.dart';
import 'settings_provider.dart';

/// TELA 3 — Configurações (neumorfismo).
/// Campos físicos para URL do stream e cidade — estrutura real,
/// persistida em SharedPreferences.
class SettingsScreen extends StatefulWidget {
  final VoidCallback onOpenWeather;
  final VoidCallback onOpenStations;
  final VoidCallback onOpenGlobe;

  const SettingsScreen({
    super.key,
    required this.onOpenWeather,
    required this.onOpenStations,
    required this.onOpenGlobe,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final TextEditingController _streamController;
  late final TextEditingController _cityController;

  @override
  void initState() {
    super.initState();
    final settings = context.read<SettingsProvider>();
    _streamController = TextEditingController(text: settings.streamUrl);
    _cityController = TextEditingController(text: settings.city);
  }

  @override
  void dispose() {
    _streamController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final settings = context.read<SettingsProvider>();
    final radio = context.read<RadioService>();
    final weather = context.read<WeatherService>();
    await settings.saveStreamUrl(_streamController.text);
    await settings.saveCity(_cityController.text);
    await radio.setStream(settings.streamUrl);
    await weather.fetch(settings.city);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Configurações salvas'),
          backgroundColor: NeuColors.accent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      backgroundColor: NeuColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabeçalho (aba — sem botão voltar redundante)
              const Text('Configurações',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: NeuColors.textPrimary,
                      height: 1.25)),
              const SizedBox(height: 2),
              const Text('Stream, local do tempo e preferências',
                  style: TextStyle(fontSize: 12, color: NeuColors.textMuted)),

              const SizedBox(height: 22),
              const _SectionLabel('RÁDIO'),
              const SizedBox(height: 8),
              const Text('URL do stream',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: NeuColors.textSecondary)),
              const SizedBox(height: 8),
              NeumorphicTextField(
                controller: _streamController,
                hint: 'https://.../stream.mp3',
                icon: Icons.radio,
              ),
              const SizedBox(height: 6),
              const Text(
                'Padrão: stream público SomaFM. Substitua pela URL oficial da sua rádio.',
                style: TextStyle(
                    fontSize: 11, height: 1.4, color: NeuColors.textMuted),
              ),

              const SizedBox(height: 22),
              const _SectionLabel('PREVISÃO DO TEMPO'),
              const SizedBox(height: 8),
              const Text('Cidade padrão',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: NeuColors.textSecondary)),
              const SizedBox(height: 8),
              NeumorphicTextField(
                controller: _cityController,
                hint: 'Ex.: Paraúna',
                icon: Icons.location_on,
              ),
              const SizedBox(height: 6),
              const Text(
                'Para usar país ou GPS, abra a tela Previsão e toque no local.',
                style: TextStyle(
                    fontSize: 11, height: 1.4, color: NeuColors.textMuted),
              ),

              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: NeumorphicButton(
                  icon: Icons.save,
                  size: 56,
                  active: true,
                  onTap: _save,
                ),
              ),
              const SizedBox(height: 6),
              const Center(
                child: Text('Salvar alterações',
                    style: TextStyle(
                        fontSize: 12, color: NeuColors.textSecondary)),
              ),

              const SizedBox(height: 24),
              const _SectionLabel('ATALHOS'),
              const SizedBox(height: 8),
              // Cada atalho leva a uma aba DIFERENTE (sem duplicar função)
              _Item(
                icon: Icons.cloud,
                title: 'Previsão do tempo',
                subtitle: 'wttr.in — dados reais',
                onTap: widget.onOpenWeather,
              ),
              _Item(
                icon: Icons.public,
                title: 'Estações do mundo',
                subtitle: 'Radio Browser — 60 mil+ estações',
                onTap: widget.onOpenStations,
              ),
              _Item(
                icon: Icons.language,
                title: 'Globo de estações',
                subtitle: 'Mapa-múndi interativo',
                onTap: widget.onOpenGlobe,
              ),

              const SizedBox(height: 16),
              const _SectionLabel('PREFERÊNCIAS'),
              const SizedBox(height: 8),
              _Item(
                icon: Icons.notifications,
                title: 'Notificações',
                subtitle: settings.notifications ? 'Ativadas' : 'Desativadas',
                trailing: NeumorphicToggle(
                  value: settings.notifications,
                  onChanged: settings.setNotifications,
                ),
                onTap: () => settings.setNotifications(!settings.notifications),
              ),
              _Item(
                icon: Icons.info,
                title: 'Sobre',
                subtitle: 'Working Radio v4.0.0 — Flutter + Neumorfismo',
                onTap: () => showAboutDialog(
                  context: context,
                  applicationName: 'Working Radio',
                  applicationVersion: 'v4.0.0',
                  applicationLegalese:
                      'Rádios globais via Radio Browser · tempo via wttr.in',
                ),
              ),
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  'Working Radio • v4.0.0',
                  style: TextStyle(fontSize: 11, color: NeuColors.textMuted),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 12,
          decoration: BoxDecoration(
            color: NeuColors.accent,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 7),
        Text(
          text,
          style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.4,
              color: NeuColors.textMuted),
        ),
      ],
    );
  }
}

class _Item extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback onTap;

  const _Item({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: onTap,
        child: NeumorphicContainer(
          borderRadius: 18,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, size: 22, color: NeuColors.accent),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: NeuColors.textPrimary)),
                    Text(subtitle,
                        style: const TextStyle(
                            fontSize: 12, color: NeuColors.textSecondary)),
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }
}
