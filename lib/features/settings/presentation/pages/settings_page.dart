import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:financeiro/app/router/route_paths.dart';
import 'package:financeiro/core/theme/app_colors.dart';
import 'package:financeiro/core/theme/app_spacing.dart';
import 'package:financeiro/core/theme/app_typography.dart';
import 'package:financeiro/features/settings/providers/settings_provider.dart';
import 'package:financeiro/features/auth/providers/auth_provider.dart';
import 'package:financeiro/shared/widgets/glass_card.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Profile Card ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(AppSpacing.pageHPadding),
              child: AppCard(
                gradient: AppColors.brandGradient,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      child: Text(
                        settings.userName.isNotEmpty
                            ? settings.userName[0].toUpperCase()
                            : 'U',
                        style: AppTypography.h4.copyWith(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            settings.userName,
                            style: AppTypography.h6.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Perfil local',
                            style: AppTypography.caption.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.edit_rounded, color: Colors.white),
                    ),
                  ],
                ),
              ).animate().fadeIn(),
            ),

            _SectionLabel(label: 'Aparência'),
            _SettingsTile(
              icon: Icons.palette_outlined,
              iconColor: AppColors.accent500,
              title: 'Tema',
              subtitle: switch (settings.themeMode) {
                AppThemeMode.dark => 'Escuro',
                AppThemeMode.amoled => 'AMOLED',
                AppThemeMode.light => 'Claro',
              },
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
              onTap: () => context.push(RoutePaths.settingsTheme),
            ),
            _SettingsTile(
              icon: Icons.visibility_outlined,
              iconColor: AppColors.brand500,
              title: 'Ocultar saldo',
              subtitle: 'Esconde valores financeiros',
              trailing: Switch(
                value: settings.hideBalance,
                onChanged: (_) =>
                    ref.read(settingsProvider.notifier).toggleHideBalance(),
              ),
            ),

            _SectionLabel(label: 'Segurança'),
            _SettingsTile(
              icon: Icons.security_rounded,
              iconColor: AppColors.success500,
              title: 'Segurança',
              subtitle: 'PIN e biometria',
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
              onTap: () => context.push(RoutePaths.settingsSecurity),
            ),

            _SectionLabel(label: 'Dados'),
            _SettingsTile(
              icon: Icons.category_outlined,
              iconColor: AppColors.warning500,
              title: 'Categorias',
              subtitle: 'Gerenciar categorias',
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
              onTap: () => context.push(RoutePaths.categories),
            ),
            _SettingsTile(
              icon: Icons.backup_outlined,
              iconColor: AppColors.info500,
              title: 'Backup e restauração',
              subtitle: 'Exporte e importe seus dados',
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
              onTap: () => context.push(RoutePaths.settingsBackup),
            ),

            _SectionLabel(label: 'Notificações'),
            _SettingsTile(
              icon: Icons.notifications_outlined,
              iconColor: AppColors.accent500,
              title: 'Notificações',
              subtitle: 'Lembretes e alertas',
              trailing: Switch(
                value: settings.notificationsEnabled,
                onChanged: (v) => ref
                    .read(settingsProvider.notifier)
                    .setNotificationsEnabled(v),
              ),
            ),

            _SectionLabel(label: 'Sobre'),
            _SettingsTile(
              icon: Icons.info_outline_rounded,
              iconColor: AppColors.dark300,
              title: 'Versão do app',
              subtitle: '1.0.0',
            ),
            _SettingsTile(
              icon: Icons.code_rounded,
              iconColor: AppColors.dark300,
              title: 'Desenvolvido com Flutter',
              subtitle: 'Local-first • Sem rastreamento',
            ),

            const SizedBox(height: AppSpacing.xl3),

            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pageHPadding),
              child: Center(
                child: Text(
                  'Financeiro v1.0.0 • Dados 100% locais',
                  style: AppTypography.caption.copyWith(
                    color: scheme.onSurfaceVariant.withOpacity(0.5),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageHPadding,
        AppSpacing.xl,
        AppSpacing.pageHPadding,
        AppSpacing.sm,
      ),
      child: Text(
        label.toUpperCase(),
        style: AppTypography.overline.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 18),
      ),
      title: Text(
        title,
        style: AppTypography.bodyMedium.copyWith(
          color: scheme.onBackground,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: AppTypography.caption.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            )
          : null,
      trailing: trailing,
    );
  }
}

// ─── Sub-settings pages ───────────────────────────────────────────────────────
class SettingsSecurityPage extends ConsumerWidget {
  const SettingsSecurityPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Segurança')),
      body: Column(
        children: [
          const SizedBox(height: AppSpacing.lg),
          _SettingsTile(
            icon: Icons.pin_outlined,
            iconColor: AppColors.brand500,
            title: 'PIN de acesso',
            subtitle:
                authState.pinEnabled ? 'Ativado' : 'Desativado',
            trailing: Switch(
              value: authState.pinEnabled,
              onChanged: (v) {
                if (v) {
                  context.push(RoutePaths.pinSetup);
                } else {
                  ref.read(authStateProvider.notifier).removePin();
                }
              },
            ),
          ),
          _SettingsTile(
            icon: Icons.fingerprint_rounded,
            iconColor: AppColors.success500,
            title: 'Biometria',
            subtitle: authState.biometricEnabled
                ? 'Ativada'
                : 'Desativada',
            trailing: Switch(
              value: authState.biometricEnabled,
              onChanged: (v) =>
                  ref.read(authStateProvider.notifier).enableBiometric(v),
            ),
          ),
          _SettingsTile(
            icon: Icons.lock_clock_rounded,
            iconColor: AppColors.warning500,
            title: 'Bloqueio automático',
            subtitle: 'Bloqueia após inatividade',
            trailing: Switch(
              value: false,
              onChanged: (_) {},
            ),
          ),
        ],
      ),
    );
  }
}

class SettingsThemePage extends ConsumerWidget {
  const SettingsThemePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Tema')),
      body: Column(
        children: [
          const SizedBox(height: AppSpacing.lg),
          for (final mode in AppThemeMode.values) ...[
            ListTile(
              leading: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: mode == AppThemeMode.light
                      ? const LinearGradient(
                          colors: [Color(0xFFF8F9FC), Color(0xFFE2E5EC)],
                        )
                      : mode == AppThemeMode.amoled
                          ? const LinearGradient(
                              colors: [Color(0xFF060609), Color(0xFF0C0D12)],
                            )
                          : const LinearGradient(
                              colors: [Color(0xFF1C1F28), Color(0xFF282D3A)],
                            ),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: scheme.outlineVariant,
                    width: 1,
                  ),
                ),
              ),
              title: Text(
                switch (mode) {
                  AppThemeMode.dark => 'Escuro',
                  AppThemeMode.amoled => 'AMOLED (preto puro)',
                  AppThemeMode.light => 'Claro',
                },
                style: AppTypography.bodyMedium.copyWith(
                  color: scheme.onBackground,
                  fontWeight: FontWeight.w500,
                ),
              ),
              trailing: settings.themeMode == mode
                  ? Icon(Icons.check_rounded, color: scheme.primary)
                  : null,
              onTap: () =>
                  ref.read(settingsProvider.notifier).setThemeMode(mode),
            ),
          ],
        ],
      ),
    );
  }
}

class SettingsBackupPage extends StatelessWidget {
  const SettingsBackupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Backup')),
      body: Column(
        children: [
          const SizedBox(height: AppSpacing.lg),
          _SettingsTile(
            icon: Icons.upload_outlined,
            iconColor: AppColors.brand500,
            title: 'Exportar dados',
            subtitle: 'Salvar backup em arquivo',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.download_outlined,
            iconColor: AppColors.success500,
            title: 'Importar dados',
            subtitle: 'Restaurar de backup',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.table_chart_outlined,
            iconColor: AppColors.warning500,
            title: 'Exportar CSV',
            subtitle: 'Exportar transações em planilha',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.picture_as_pdf_outlined,
            iconColor: AppColors.error500,
            title: 'Exportar PDF',
            subtitle: 'Relatório mensal em PDF',
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
