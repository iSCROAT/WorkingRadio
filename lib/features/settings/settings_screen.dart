import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/neumorphic_theme.dart';
import '../../core/widgets/neumorphic.dart';
import '../radio/radio_service.dart';
import '../stations/stations_screen.dart';
import '../weather/weather_service.dart';
import 'settings_provider.dart';

/// TELA 3 — Configurações (neumorfismo).
/// Campos físicos para URL do stream e cidade — estrutura real,
/// persistida em SharedPreferences.
class SettingsScreen extends StatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onOpenWeather;

  const SettingsScreen({
    super.key,
    required this.onBack,
    required this.onOpenWeather,
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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  NeumorphicButton(
                    icon: Icons.arrow_back,
                    size: 44,
                    onTap: widget.onBack,
                  ),
                  const SizedBox(width: 12),
                  const Text('Configurações',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: NeuColors.textPrimary)),
                ],
              ),
              const SizedBox(height: 24),
              const Text('URL do stream da rádio',
                  style: TextStyle(fontSize: 12, color: NeuColors.textMuted)),
              const SizedBox(height: 8),
              NeumorphicTextField(
                controller: _streamController,
                hint: 'https://.../stream.mp3',
                icon: Icons.radio,
              ),
              const SizedBox(height: 6),
              const Text(
                'Padrão: stream público SomaFM. Substitua pela URL oficial da sua rádio.',
                style: TextStyle(fontSize: 11, color: NeuColors.textMuted),
              ),
              const SizedBox(height: 20),
              const Text('Cidade da previsão do tempo',
                  style: TextStyle(fontSize: 12, color: NeuColors.textMuted)),
              const SizedBox(height: 8),
              NeumorphicTextField(
                controller: _cityController,
                hint: 'Ex.: Parauna',
                icon: Icons.location_on,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: NeumorphicButton(
                  icon: Icons.save,
                  size: 56,
                  active: true,
                  onTap: _save,
                ),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text('Salvar configurações',
                    style: TextStyle(
                        fontSize: 12, color: NeuColors.textSecondary)),
              ),
              const SizedBox(height: 24),
              _Item(
                icon: Icons.cloud,
                title: 'Previsão do tempo',
                subtitle: 'wttr.in — dados reais',
                onTap: widget.onOpenWeather,
              ),
              _Item(
                icon: Icons.public,
                title: 'Estações do mundo',
                subtitle:
                    'Radio Browser · ${settings.city.isEmpty ? 'busca global' : settings.city}',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => StationsScreen(
                      onBack: () => Navigator.of(context).pop(),
                    ),
                  ),
                ),
              ),
              _Item(
                icon: Icons.notifications,
                title: 'Notificações',
                subtitle: settings.notifications ? 'Ativadas' : 'Desativadas',
                trailing: NeumorphicToggle(
                  value: settings.notifications,
                  onChanged: settings.setNotifications,
                ),
                onTap: () {},
              ),
              _Item(
                icon: Icons.info,
                title: 'Sobre',
                subtitle: 'Working Radio v2.0.0 — Flutter + Neumorfismo',
                onTap: () {},
              ),
              const SizedBox(height: 24),
              const Center(
                child: Text(
                  'Working Radio • Flutter • v2.0.0',
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
