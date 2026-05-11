import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:financeiro/core/constants/app_constants.dart';
import 'package:financeiro/core/theme/app_colors.dart';
import 'package:financeiro/core/theme/app_spacing.dart';
import 'package:financeiro/core/theme/app_typography.dart';
import 'package:financeiro/features/auth/providers/auth_provider.dart';

class PinSetupPage extends ConsumerStatefulWidget {
  const PinSetupPage({super.key, required this.isChange});

  final bool isChange;

  @override
  ConsumerState<PinSetupPage> createState() => _PinSetupPageState();
}

class _PinSetupPageState extends ConsumerState<PinSetupPage> {
  String _pin = '';
  String _confirmPin = '';
  bool _isConfirming = false;
  String? _error;

  void _onDigit(String digit) {
    setState(() {
      _error = null;
      if (!_isConfirming) {
        if (_pin.length < AppConstants.pinLength) {
          _pin += digit;
          if (_pin.length == AppConstants.pinLength) {
            unawaited(
              Future.delayed(const Duration(milliseconds: 200), () {
                setState(() => _isConfirming = true);
              }),
            );
          }
        }
      } else {
        if (_confirmPin.length < AppConstants.pinLength) {
          _confirmPin += digit;
          if (_confirmPin.length == AppConstants.pinLength) {
            _validate();
          }
        }
      }
    });
    HapticFeedback.lightImpact();
  }

  void _onDelete() {
    setState(() {
      _error = null;
      if (!_isConfirming) {
        if (_pin.isNotEmpty) _pin = _pin.substring(0, _pin.length - 1);
      } else {
        if (_confirmPin.isNotEmpty) {
          _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1);
        }
      }
    });
    HapticFeedback.lightImpact();
  }

  void _validate() {
    if (_pin == _confirmPin) {
      ref.read(authStateProvider.notifier).setupPin(_pin);
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.heavyImpact();
      setState(() {
        _error = 'PINs não coincidem. Tente novamente.';
        _pin = '';
        _confirmPin = '';
        _isConfirming = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final current = _isConfirming ? _confirmPin : _pin;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        title: Text(widget.isChange ? 'Alterar PIN' : 'Criar PIN'),
        leading: widget.isChange
            ? IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_rounded),
              )
            : null,
      ),
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.pageInsets,
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.xl4),
              // Icon
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  Icons.lock_rounded,
                  size: 32,
                  color: scheme.primary,
                ),
              )
                  .animate()
                  .scale(
                    begin: const Offset(0.5, 0.5),
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.elasticOut,
                  ),
              const SizedBox(height: AppSpacing.xl2),
              Text(
                _isConfirming ? 'Confirme seu PIN' : 'Crie seu PIN',
                style: AppTypography.h4.copyWith(color: scheme.onSurface),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                _isConfirming
                    ? 'Digite o PIN novamente para confirmar'
                    : 'Escolha um PIN de ${AppConstants.pinLength} dígitos',
                style: AppTypography.bodyMedium.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl3),
              // PIN dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  AppConstants.pinLength,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i < current.length
                          ? scheme.primary
                          : scheme.outlineVariant,
                      boxShadow: i < current.length
                          ? [
                              BoxShadow(
                                color: scheme.primary.withValues(alpha: 0.4),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                  ),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: AppSpacing.lg),
                Text(
                  _error!,
                  style: AppTypography.bodySmall.copyWith(
                    color: scheme.error,
                  ),
                ).animate().shakeX(hz: 3),
              ],
              const Spacer(),
              // Numpad
              _PinPad(
                onDigit: _onDigit,
                onDelete: _onDelete,
              ),
              const SizedBox(height: AppSpacing.xl2),
            ],
          ),
        ),
      ),
    );
  }
}

class PinUnlockPage extends ConsumerStatefulWidget {
  const PinUnlockPage({super.key});

  @override
  ConsumerState<PinUnlockPage> createState() => _PinUnlockPageState();
}

class _PinUnlockPageState extends ConsumerState<PinUnlockPage> {
  String _pin = '';
  bool _isShaking = false;

  void _onDigit(String digit) {
    if (_pin.length >= AppConstants.pinLength) return;
    setState(() => _pin += digit);
    HapticFeedback.lightImpact();
    if (_pin.length == AppConstants.pinLength) {
      _validate();
    }
  }

  void _onDelete() {
    if (_pin.isEmpty) return;
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
    HapticFeedback.lightImpact();
  }

  Future<void> _validate() async {
    final valid =
        await ref.read(authStateProvider.notifier).validatePin(_pin);
    if (!valid) {
      unawaited(HapticFeedback.heavyImpact());
      setState(() {
        _pin = '';
        _isShaking = true;
      });
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) setState(() => _isShaking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.pageInsets,
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.xl4),
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: AppColors.brandGradient,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.lock_rounded,
                  size: 32,
                  color: Colors.white,
                ),
              ).animate().scale(
                    begin: const Offset(0.5, 0.5),
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.elasticOut,
                  ),
              const SizedBox(height: AppSpacing.xl2),
              Text(
                'Digite seu PIN',
                style: AppTypography.h4.copyWith(color: scheme.onSurface),
              ),
              const SizedBox(height: AppSpacing.xl3),
              AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                transform: _isShaking
                    ? Matrix4.translationValues(8, 0, 0)
                    : Matrix4.identity(),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    AppConstants.pinLength,
                    (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i < _pin.length
                            ? scheme.primary
                            : scheme.outlineVariant,
                      ),
                    ),
                  ),
                ),
              ),
              if (authState.error != null) ...[
                const SizedBox(height: AppSpacing.lg),
                Text(
                  authState.error!,
                  style: AppTypography.bodySmall.copyWith(
                    color: scheme.error,
                  ),
                ),
              ],
              const Spacer(),
              if (authState.biometricEnabled)
                TextButton.icon(
                  onPressed: () =>
                      ref.read(authStateProvider.notifier).authenticateWithBiometrics(),
                  icon: const Icon(Icons.fingerprint_rounded),
                  label: const Text('Usar biometria'),
                ),
              const SizedBox(height: AppSpacing.lg),
              _PinPad(
                onDigit: _onDigit,
                onDelete: _onDelete,
              ),
              const SizedBox(height: AppSpacing.xl2),
            ],
          ),
        ),
      ),
    );
  }
}

class _PinPad extends StatelessWidget {
  const _PinPad({required this.onDigit, required this.onDelete});

  final ValueChanged<String> onDigit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final row in [
          ['1', '2', '3'],
          ['4', '5', '6'],
          ['7', '8', '9'],
          ['', '0', 'del'],
        ])
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: row.map((k) => _PinKey(
                  key: ValueKey(k),
                  label: k,
                  onTap: k.isEmpty
                      ? null
                      : k == 'del'
                          ? onDelete
                          : () => onDigit(k),
                ),).toList(),
          ),
      ],
    );
  }
}

class _PinKey extends StatelessWidget {
  const _PinKey({
    super.key,
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    if (label.isEmpty) {
      return const SizedBox(width: 80, height: 80);
    }

    final isDelete = label == 'del';

    return Container(
      width: 80,
      height: 80,
      margin: const EdgeInsets.all(AppSpacing.sm),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(40),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(40),
          child: Center(
            child: isDelete
                ? Icon(
                    Icons.backspace_rounded,
                    color: scheme.onSurfaceVariant,
                    size: 22,
                  )
                : Text(
                    label,
                    style: AppTypography.h3.copyWith(
                      color: scheme.onSurface,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
