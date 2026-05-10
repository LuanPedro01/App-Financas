# Financeiro — Setup

## Pré-requisitos
- Flutter 3.16+ instalado e configurado
- Dart SDK 3.2+
- Android Studio / VS Code
- Dispositivo/emulador Android (API 26+)

## Passos para rodar

### 1. Instalar dependências
```bash
flutter pub get
```

### 2. Gerar código (OBRIGATÓRIO — Isar, Freezed, Riverpod)
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Isso vai gerar:
- `*.g.dart` — Isar schemas e JsonSerializable
- `*.freezed.dart` — Freezed data classes
- `*_provider.freezed.dart` — Riverpod providers

### 3. Rodar o app
```bash
flutter run
```

### 4. Build de release
```bash
flutter build apk --release
# ou
flutter build appbundle --release
```

## Estrutura de diretórios

```
lib/
├── app/
│   ├── app.dart               # MaterialApp root
│   └── router/
│       ├── app_router.dart    # GoRouter config
│       └── route_paths.dart   # Rotas centralizadas
│
├── core/
│   ├── constants/             # AppConstants, StorageKeys
│   ├── errors/                # Failures, Exceptions
│   ├── extensions/            # DateTime, double, BuildContext
│   ├── services/              # DB, Auth, Storage, Notifications
│   ├── theme/                 # Colors, Typography, Spacing, Theme
│   └── utils/                 # CurrencyFormatter
│
├── shared/
│   └── widgets/               # GlassCard, TransactionTile, EmptyState, etc.
│
├── features/
│   ├── auth/                  # Splash, Onboarding, PIN, Biometrics
│   ├── dashboard/             # Dashboard principal
│   ├── transactions/          # CRUD transações
│   ├── accounts/              # Contas bancárias
│   ├── cards/                 # Cartões de crédito
│   ├── budgets/               # Orçamentos
│   ├── goals/                 # Metas financeiras
│   ├── investments/           # Carteira de investimentos
│   ├── reports/               # Relatórios mensais
│   ├── analytics/             # Análises e heatmaps
│   ├── categories/            # Categorias
│   └── settings/              # Configurações + tema + segurança
│
└── main.dart
```

## Funcionalidades implementadas

### Core
- [x] Dark mode + AMOLED mode + Light mode
- [x] Material 3 completo
- [x] Design system (cores, tipografia, espaçamento)
- [x] GoRouter com redirect e proteção de rotas
- [x] Riverpod para state management
- [x] Isar para persistência local
- [x] Flutter Secure Storage para dados sensíveis

### Auth & Segurança
- [x] Splash screen animada
- [x] Onboarding com 4 slides
- [x] PIN de 6 dígitos
- [x] Autenticação biométrica
- [x] Auto-lock configurável

### Dashboard
- [x] Saldo total com gradiente premium
- [x] Cards de receitas/despesas do mês
- [x] Quick actions (atalhos rápidos)
- [x] Gráfico de barras mensal (fl_chart)
- [x] Metas ativas (scroll horizontal)
- [x] Últimas transações

### Transações
- [x] Lista agrupada por data
- [x] Filtros avançados (período, tipo, categoria)
- [x] Busca em tempo real
- [x] Swipe to delete/edit
- [x] Formulário completo (tipo, valor, data, conta, cartão, recorrência)
- [x] Tela de detalhe

### Contas
- [x] Múltiplas contas (corrente, poupança, carteira, investimentos)
- [x] Saldo total consolidado
- [x] Agrupamento por tipo

### Cartões de Crédito
- [x] Visual de cartão com bandeira
- [x] Barra de uso de limite
- [x] Total em faturas

### Orçamentos
- [x] Por categoria/mês
- [x] Alertas visuais (normal/alerta/excedido)
- [x] Progress bar animada

### Metas Financeiras
- [x] Tipos: emergência, viagem, compra, etc.
- [x] Progress bar com porcentagem
- [x] Previsão de conclusão

### Investimentos
- [x] Múltiplos tipos (ações, FII, ETF, crypto, renda fixa)
- [x] Gráfico de alocação (PieChart)
- [x] Rentabilidade (profit/loss)
- [x] Lista de ativos

### Relatórios
- [x] Navegação por mês
- [x] Resumo receitas/despesas/saldo
- [x] Gráfico de tendência (LineChart)
- [x] Gastos por categoria com ranking

### Analytics
- [x] Média mensal de gastos
- [x] Heatmap por dia da semana
- [x] Evolução patrimonial (BarChart)

### Configurações
- [x] Perfil local
- [x] Temas (Dark/AMOLED/Light)
- [x] Ocultar saldo
- [x] Segurança (PIN + Biometria)
- [x] Backup/Restauração
- [x] Notificações

## Próximas melhorias sugeridas

- Formulários completos para adicionar conta/cartão/meta/investimento
- Importação CSV de transações
- Notificações agendadas reais
- Seed de dados demo para primeiro uso
- Testes unitários e de widget
- Export PDF real com biblioteca `pdf`
- Sincronização opcional (Supabase/Firebase)
