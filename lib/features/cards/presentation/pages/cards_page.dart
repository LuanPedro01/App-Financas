import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:financeiro/app/router/route_paths.dart';
import 'package:financeiro/core/extensions/number_extensions.dart';
import 'package:financeiro/core/theme/app_colors.dart';
import 'package:financeiro/core/theme/app_spacing.dart';
import 'package:financeiro/core/theme/app_typography.dart';
import 'package:financeiro/features/cards/providers/cards_provider.dart';
import 'package:financeiro/features/cards/data/models/credit_card_model.dart';
import 'package:financeiro/shared/widgets/amount_display.dart';
import 'package:financeiro/shared/widgets/glass_card.dart';

class CardsPage extends ConsumerWidget {
  const CardsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardsAsync = ref.watch(cardsProvider);
    final totalInvoice = ref.watch(totalInvoiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cartões'),
        actions: [
          IconButton(
            onPressed: () => context.push(RoutePaths.addCard),
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
      body: cardsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (cards) => CustomScrollView(
          slivers: [
            if (cards.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.pageHPadding),
                  child: AppCard(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1C1F28), Color(0xFF222631)],
                    ),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total em faturas',
                              style: AppTypography.caption.copyWith(
                                color: AppColors.dark200,
                              ),
                            ),
                            const SizedBox(height: 4),
                            AmountDisplay(
                              amount: totalInvoice,
                              style: AppTypography.numericLarge.copyWith(
                                color: AppColors.expense,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Text(
                          '${cards.length} ${cards.length == 1 ? 'cartão' : 'cartões'}',
                          style: AppTypography.labelMedium.copyWith(
                            color: AppColors.dark200,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(),
                ),
              ),

            SliverList.builder(
              itemCount: cards.length,
              itemBuilder: (ctx, i) => Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pageHPadding,
                  vertical: AppSpacing.sm,
                ),
                child: _CreditCardWidget(
                  card: cards[i],
                  index: i,
                ),
              ),
            ),

            if (cards.isEmpty)
              const SliverFillRemaining(
                child: Center(
                  child: Text('Nenhum cartão cadastrado'),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(RoutePaths.addCard),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Novo cartão'),
      ),
    );
  }
}

class _CreditCardWidget extends StatelessWidget {
  const _CreditCardWidget({required this.card, required this.index});

  final CreditCardModel card;
  final int index;

  @override
  Widget build(BuildContext context) {
    final color = Color(card.color);
    final usage = card.limit > 0
        ? (card.currentInvoiceAmount / card.limit).clamp(0.0, 1.0)
        : 0.0;

    return GestureDetector(
      onTap: () => context.push(
        RoutePaths.cardDetailPath(card.id.toString()),
      ),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color,
              color.withValues(alpha: 0.7),
            ],
          ),
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: AppSpacing.cardInsets,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    card.name,
                    style: AppTypography.h6.copyWith(color: Colors.white),
                  ),
                  _BrandIcon(brand: card.brand),
                ],
              ),
              const Spacer(),
              if (card.lastFourDigits != null)
                Text(
                  '**** **** **** ${card.lastFourDigits}',
                  style: AppTypography.bodyMedium.copyWith(
                    color: Colors.white70,
                    letterSpacing: 2,
                  ),
                ),
              const SizedBox(height: AppSpacing.lg),
              // Usage bar
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Fatura atual',
                        style: AppTypography.caption.copyWith(
                          color: Colors.white60,
                        ),
                      ),
                      Text(
                        '${(usage * 100).toStringAsFixed(0)}% do limite',
                        style: AppTypography.caption.copyWith(
                          color: Colors.white60,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: usage,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      valueColor: AlwaysStoppedAnimation(
                        usage > 0.9
                            ? AppColors.error400
                            : usage > 0.7
                                ? AppColors.warning400
                                : Colors.white,
                      ),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        card.currentInvoiceAmount.brl,
                        style: AppTypography.labelMedium.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'de ${card.limit.brl}',
                        style: AppTypography.caption.copyWith(
                          color: Colors.white60,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ).animate(delay: Duration(milliseconds: index * 80)).fadeIn().slideY(
            begin: 0.1,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
          ),
    );
  }
}

class _BrandIcon extends StatelessWidget {
  const _BrandIcon({required this.brand});

  final CardBrand brand;

  @override
  Widget build(BuildContext context) {
    final label = switch (brand) {
      CardBrand.visa => 'VISA',
      CardBrand.mastercard => 'MC',
      CardBrand.elo => 'ELO',
      CardBrand.amex => 'AMEX',
      CardBrand.hipercard => 'HIPER',
      CardBrand.other => '',
    };

    return Text(
      label,
      style: AppTypography.h6.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w800,
        letterSpacing: 2,
      ),
    );
  }
}

// ─── Stub pages ───────────────────────────────────────────────────────────────
class AddCardPage extends StatelessWidget {
  const AddCardPage({super.key, this.editId});
  final String? editId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(editId != null ? 'Editar cartão' : 'Novo cartão'),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close_rounded),
        ),
      ),
      body: const Center(child: Text('Formulário de cartão')),
    );
  }
}

class CardDetailPage extends StatelessWidget {
  const CardDetailPage({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes do cartão')),
      body: const Center(child: Text('Detalhes do cartão')),
    );
  }
}
