enum TransactionType {
  income,
  expense,
  transfer;

  String get label => switch (this) {
        income => 'Receita',
        expense => 'Despesa',
        transfer => 'Transferência',
      };

  String get labelPlural => switch (this) {
        income => 'Receitas',
        expense => 'Despesas',
        transfer => 'Transferências',
      };
}

enum TransactionStatus {
  pending,
  completed,
  cancelled,
  scheduled;

  String get label => switch (this) {
        pending => 'Pendente',
        completed => 'Concluída',
        cancelled => 'Cancelada',
        scheduled => 'Agendada',
      };
}

enum RecurrenceType {
  none,
  daily,
  weekly,
  biweekly,
  monthly,
  quarterly,
  semiannual,
  annual;

  String get label => switch (this) {
        none => 'Sem recorrência',
        daily => 'Diária',
        weekly => 'Semanal',
        biweekly => 'Quinzenal',
        monthly => 'Mensal',
        quarterly => 'Trimestral',
        semiannual => 'Semestral',
        annual => 'Anual',
      };
}

enum PaymentMethod {
  cash,
  debitCard,
  creditCard,
  bankTransfer,
  pix,
  boleto,
  check,
  other;

  String get label => switch (this) {
        cash => 'Dinheiro',
        debitCard => 'Cartão de Débito',
        creditCard => 'Cartão de Crédito',
        bankTransfer => 'Transferência',
        pix => 'PIX',
        boleto => 'Boleto',
        check => 'Cheque',
        other => 'Outro',
      };
}
