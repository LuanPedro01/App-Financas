import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:uuid/uuid.dart';
import 'package:financeiro/core/theme/app_colors.dart';
import 'package:financeiro/core/theme/app_spacing.dart';
import 'package:financeiro/core/theme/app_typography.dart';
import 'package:financeiro/core/extensions/date_extensions.dart';
import 'package:financeiro/features/transactions/data/models/transaction_model.dart';
import 'package:financeiro/features/transactions/providers/transaction_provider.dart';
import 'package:financeiro/features/transactions/domain/enums/transaction_enums.dart';
import 'package:financeiro/features/accounts/providers/accounts_provider.dart';
import 'package:financeiro/features/cards/providers/cards_provider.dart';

class AddTransactionPage extends ConsumerStatefulWidget {
  const AddTransactionPage({super.key, this.initialType, this.editId});

  final String? initialType;
  final String? editId;

  @override
  ConsumerState<AddTransactionPage> createState() =>
      _AddTransactionPageState();
}

class _AddTransactionPageState extends ConsumerState<AddTransactionPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  late TransactionType _type;
  DateTime _date = DateTime.now();
  String? _selectedAccountId;
  String? _selectedAccountName;
  String? _toAccountId;
  String? _toAccountName;
  String? _selectedCardId;
  String? _selectedCardName;
  String? _selectedCategoryId;
  String? _selectedCategoryName;
  String? _selectedCategoryIcon;
  int? _selectedCategoryColor;
  TransactionStatus _status = TransactionStatus.completed;
  PaymentMethod _paymentMethod = PaymentMethod.pix;
  RecurrenceType _recurrenceType = RecurrenceType.none;
  bool _isInstallment = false;
  int _installments = 1;
  List<String> _tags = [];
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _type = switch (widget.initialType) {
      'income' => TransactionType.income,
      'transfer' => TransactionType.transfer,
      _ => TransactionType.expense,
    };
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Color get _typeColor => switch (_type) {
        TransactionType.income => AppColors.income,
        TransactionType.expense => AppColors.expense,
        TransactionType.transfer => AppColors.transfer,
      };

  String get _typeLabel => switch (_type) {
        TransactionType.income => 'Receita',
        TransactionType.expense => 'Despesa',
        TransactionType.transfer => 'Transferência',
      };

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_amountController.text.isEmpty) return;

    setState(() => _isSubmitting = true);
    HapticFeedback.mediumImpact();

    try {
      final amount =
          double.tryParse(_amountController.text.replaceAll(',', '.')) ?? 0;
      if (amount <= 0) {
        _showError('Valor deve ser maior que zero');
        return;
      }

      final now = DateTime.now();
      final model = TransactionModel(
        id: Isar.autoIncrement,
        title: _titleController.text.trim(),
        amount: amount,
        type: _type,
        date: _date,
        createdAt: now,
        accountId: _selectedAccountId,
        accountName: _selectedAccountName,
        toAccountId: _toAccountId,
        toAccountName: _toAccountName,
        cardId: _selectedCardId,
        cardName: _selectedCardName,
        categoryId: _selectedCategoryId,
        categoryName: _selectedCategoryName,
        categoryIcon: _selectedCategoryIcon,
        categoryColor: _selectedCategoryColor,
        status: _status,
        paymentMethod: _paymentMethod,
        recurrenceType: _recurrenceType,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        tags: _tags,
      );

      await ref.read(transactionProvider.notifier).add(model);

      if (mounted) {
        HapticFeedback.mediumImpact();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$_typeLabel adicionada com sucesso!'),
            backgroundColor: _typeColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.error500,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.background,
      appBar: AppBar(
        title: Text(
          widget.editId != null ? 'Editar transação' : 'Nova transação',
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close_rounded),
        ),
        actions: [
          if (_isSubmitting)
            const Padding(
              padding: EdgeInsets.all(14),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton(
              onPressed: _submit,
              child: Text(
                'Salvar',
                style: AppTypography.labelLarge.copyWith(
                  color: _typeColor,
                ),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Type selector ─────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pageHPadding,
                  vertical: AppSpacing.lg,
                ),
                child: _TypeSelector(
                  selected: _type,
                  onChanged: (t) => setState(() => _type = t),
                ),
              ).animate().fadeIn().slideY(begin: -0.1),

              // ─── Amount field ──────────────────────────────────────────
              _AmountField(
                controller: _amountController,
                color: _typeColor,
              ).animate(delay: const Duration(milliseconds: 50)).fadeIn(),

              const SizedBox(height: AppSpacing.xl),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.pageHPadding),
                child: Column(
                  children: [
                    // Title
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Descrição',
                        prefixIcon: Icon(Icons.description_outlined),
                      ),
                      validator: (v) =>
                          v?.trim().isEmpty ?? true ? 'Informe a descrição' : null,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Date picker
                    _DateField(
                      date: _date,
                      onChanged: (d) => setState(() => _date = d),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Account picker
                    _AccountSelector(
                      selectedId: _selectedAccountId,
                      label: _type == TransactionType.transfer
                          ? 'Conta de origem'
                          : 'Conta',
                      onChanged: (id, name) => setState(() {
                        _selectedAccountId = id;
                        _selectedAccountName = name;
                      }),
                    ),

                    if (_type == TransactionType.transfer) ...[
                      const SizedBox(height: AppSpacing.md),
                      _AccountSelector(
                        selectedId: _toAccountId,
                        label: 'Conta destino',
                        onChanged: (id, name) => setState(() {
                          _toAccountId = id;
                          _toAccountName = name;
                        }),
                      ),
                    ],

                    const SizedBox(height: AppSpacing.md),

                    // Payment method
                    _PaymentMethodSelector(
                      selected: _paymentMethod,
                      onChanged: (m) =>
                          setState(() => _paymentMethod = m),
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // Status
                    _StatusSelector(
                      selected: _status,
                      onChanged: (s) => setState(() => _status = s),
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // Notes
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Observações (opcional)',
                        prefixIcon: Icon(Icons.notes_rounded),
                      ),
                      maxLines: 2,
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // Recurrence
                    _RecurrenceSelector(
                      selected: _recurrenceType,
                      onChanged: (r) =>
                          setState(() => _recurrenceType = r),
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      height: AppSpacing.buttonHeight,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [_typeColor, _typeColor.withOpacity(0.8)],
                          ),
                          borderRadius:
                              BorderRadius.circular(AppSpacing.buttonRadius),
                          boxShadow: [
                            BoxShadow(
                              color: _typeColor.withOpacity(0.35),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                          ),
                          onPressed: _isSubmitting ? null : _submit,
                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  'Salvar $_typeLabel',
                                  style: AppTypography.labelLarge.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate(delay: const Duration(milliseconds: 100)).fadeIn(),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Type Selector ────────────────────────────────────────────────────────────
class _TypeSelector extends StatelessWidget {
  const _TypeSelector({required this.selected, required this.onChanged});

  final TransactionType selected;
  final ValueChanged<TransactionType> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceVariant,
        borderRadius: BorderRadius.circular(AppSpacing.cardSmallRadius),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: TransactionType.values.map((t) {
          final isSelected = t == selected;
          final color = switch (t) {
            TransactionType.income => AppColors.income,
            TransactionType.expense => AppColors.expense,
            TransactionType.transfer => AppColors.transfer,
          };

          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(t),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? color.withOpacity(0.15) : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: isSelected
                      ? Border.all(color: color.withOpacity(0.4), width: 1)
                      : null,
                ),
                child: Center(
                  child: Text(
                    t.label,
                    style: AppTypography.labelMedium.copyWith(
                      color: isSelected ? color : scheme.onSurfaceVariant,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Amount Field ─────────────────────────────────────────────────────────────
class _AmountField extends StatelessWidget {
  const _AmountField({required this.controller, required this.color});

  final TextEditingController controller;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pageHPadding,
        vertical: AppSpacing.xl,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: scheme.outlineVariant,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          Text(
            'Valor',
            style: AppTypography.caption.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'R\$',
                style: AppTypography.h4.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              IntrinsicWidth(
                child: TextField(
                  controller: controller,
                  style: AppTypography.numericDisplay.copyWith(color: color),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    hintText: '0,00',
                    filled: false,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Date Field ───────────────────────────────────────────────────────────────
class _DateField extends StatelessWidget {
  const _DateField({required this.date, required this.onChanged});

  final DateTime date;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime(2010),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (picked != null) onChanged(picked);
      },
      child: AbsorbPointer(
        child: TextFormField(
          readOnly: true,
          decoration: InputDecoration(
            labelText: 'Data',
            prefixIcon: const Icon(Icons.calendar_today_rounded),
            suffixIcon: const Icon(Icons.arrow_drop_down_rounded),
          ),
          controller: TextEditingController(text: date.formatted),
        ),
      ),
    );
  }
}

// ─── Account Selector ─────────────────────────────────────────────────────────
class _AccountSelector extends ConsumerWidget {
  const _AccountSelector({
    required this.selectedId,
    required this.label,
    required this.onChanged,
  });

  final String? selectedId;
  final String label;
  final void Function(String? id, String? name) onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(accountsProvider);
    final accounts = accountsAsync.valueOrNull ?? [];

    return DropdownButtonFormField<String>(
      value: selectedId,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.account_balance_wallet_rounded),
      ),
      items: [
        const DropdownMenuItem(
          value: null,
          child: Text('Sem conta'),
        ),
        ...accounts.map(
          (a) => DropdownMenuItem(
            value: a.id.toString(),
            child: Text(a.name),
          ),
        ),
      ],
      onChanged: (id) {
        final account = accounts.where((a) => a.id.toString() == id).firstOrNull;
        onChanged(id, account?.name);
      },
    );
  }
}

// ─── Payment Method Selector ──────────────────────────────────────────────────
class _PaymentMethodSelector extends StatelessWidget {
  const _PaymentMethodSelector({required this.selected, required this.onChanged});

  final PaymentMethod selected;
  final ValueChanged<PaymentMethod> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<PaymentMethod>(
      value: selected,
      decoration: const InputDecoration(
        labelText: 'Forma de pagamento',
        prefixIcon: Icon(Icons.payment_rounded),
      ),
      items: PaymentMethod.values
          .map((m) => DropdownMenuItem(value: m, child: Text(m.label)))
          .toList(),
      onChanged: (m) => m != null ? onChanged(m) : null,
    );
  }
}

// ─── Status Selector ─────────────────────────────────────────────────────────
class _StatusSelector extends StatelessWidget {
  const _StatusSelector({required this.selected, required this.onChanged});

  final TransactionStatus selected;
  final ValueChanged<TransactionStatus> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<TransactionStatus>(
      value: selected,
      decoration: const InputDecoration(
        labelText: 'Status',
        prefixIcon: Icon(Icons.check_circle_outline_rounded),
      ),
      items: TransactionStatus.values
          .map((s) => DropdownMenuItem(value: s, child: Text(s.label)))
          .toList(),
      onChanged: (s) => s != null ? onChanged(s) : null,
    );
  }
}

// ─── Recurrence Selector ─────────────────────────────────────────────────────
class _RecurrenceSelector extends StatelessWidget {
  const _RecurrenceSelector({required this.selected, required this.onChanged});

  final RecurrenceType selected;
  final ValueChanged<RecurrenceType> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<RecurrenceType>(
      value: selected,
      decoration: const InputDecoration(
        labelText: 'Recorrência',
        prefixIcon: Icon(Icons.repeat_rounded),
      ),
      items: RecurrenceType.values
          .map((r) => DropdownMenuItem(value: r, child: Text(r.label)))
          .toList(),
      onChanged: (r) => r != null ? onChanged(r) : null,
    );
  }
}
