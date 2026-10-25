# Finance AV1 — Controle Financeiro Pessoal

Aplicativo Flutter para **Controle Financeiro Pessoal**, desenvolvido para a **Avaliação Prática 1**.
O app é um "todolist financeiro": cada item da lista é uma movimentação (receita ou despesa)
persistida na nuvem com **Cloud Firestore** (Firebase), com resumo de saldo, cadastro, edição, detalhes e exclusão com confirmação.

Tema Material 3, seed color verde, com formulários validados e Feedback via SnackBar.

---

## Conteúdos avaliados

A avaliação aborda os conteúdos vistos até agora e o app os cobre da seguinte forma:

| Conteúdo | Onde é aplicado |
|---|---|
| **Listas** | `HomeScreen` com `ListView.builder` exibindo as movimentações via `TransactionCard` |
| **Navegação entre várias telas** | Navegação direta (`MaterialPageRoute`) para registro, detalhes e edição, com navegação de retorno reativa |
| **Armazenamento em nuvem (Firestore)** | `firebase_core` + `cloud_firestore`, geridos pelo singleton `DBHelper` |

## Banco de Dados (Cloud Firestore)

- Coleção: `transacoes` (criada automaticamente no primeiro registo)
- Cada documento é uma transação; o **ID do documento** é o `id` da `Transacao` (`String`)

| Campo | Tipo | Função |
|---|---|---|
| `titulo` | string | Título/nome do lançamento |
| `valor` | number | Valor da movimentação (positivo) |
| `dataHora` | string | Data e hora no formato `dd/MM/yyyy HH:mm` |
| `tipo` | string | `'receita'` ou `'despesa'` |
| `descricao` | string / null | Observações (opcional) |
| `imagemPath` | string / null | Caminho de comprovativo (opcional) |
| `criadoEm` | timestamp | Momento da criação, usado para ordenar a lista |

Operações suportadas no `DBHelper` (singleton, `factory` + construtor privado):
- `insertTransacao`, `getTransacoes`, `getTransacao`, `streamTransacoes` (tempo real), `updateTransacao`, `deleteTransacao`

Modelos associados:
- `models/transacao.dart` — classe com serialização `toMap()` / `fromMap()`
- `models/categoria.dart` — model de Categoria (base para funcionalidades futuras)

## Telas do aplicativo

| N.º | Tela (`lib/screens/`) | Descrição |
|---|---|---|
| 1 | `login_screen.dart` | Login local com navegação `pushReplacement` para a Home |
| 2 | `home_screen.dart` | **Tela principal** — escuta as transações do Firestore em tempo real (`StreamBuilder`) e exibe a lista; calcula e mostra saldo/total no `BalanceCard` |
| 3 | `transaction_form_screen.dart` | Cadastro **e** edição — formulário reativo reutilizado para as duas funcionalidades (req. OBS atendido). Com validação, seleção de tipo, data (`showDatePicker`), hora (`showTimePicker`) e parsing de valores no formato brasileiro (`10.000` → 10.000, `10.000,50` → 10000.50) |
| 4 | `transaction_detail_screen.dart` | Exibe os dados do item clicado na lista e pede **confirmação para exclusão** (AlertDialog), além de navegar para edição |
| — | ~~`charts_screen.dart`~~ | Relatório/gráficos **removido** — será implementado em outro momento |

## Widgets reutilizáveis

- `widgets/balance_card.dart` — resumo de saldo, total de receitas e despesas
- `widgets/transaction_card.dart` — item da lista com as 3 informações obrigatórias (**título, data/hora e valor**), ícone por tipo (↑ verde / ↓ vermelho) e indicador "clique para ver ou editar" no rodapé

## Requisitos atendidos ✔

- [x] **APP com tema livre** — Controle Financeiro Pessoal
- [x] **Lista principal** exibindo os dados dos itens (`HomeScreen` + `ListView.builder`)
- [x] **Cada item tem pelo menos 3 informações** — ícone de tipo, título, data/hora e valor monetário (`+ Receita` / `- Despesa`)
- [x] **3+ telas** — Login, principal com lista, formulário de inclusão, detalhes com confirmação de exclusão (4 no total)
- [x] **Tela reutilizada** para incluir/editar (conforme OBS do enunciado)
- [x] **Dados persistidos no Cloud Firestore** (com cache offline do próprio Firestore)

## Como executar

```bash
# configurar o Firebase (uma vez) — gera lib/firebase_options.dart
dart pub global activate flutterfire_cli
flutterfire configure

# dependências
flutter pub get

# rodar em dispositivo/emulador Android ou iOS
flutter run

# análise estática do código
flutter analyze
```

Deps: Flutter + Dart 3, `flutter pub get` resolve `firebase_core`, `cloud_firestore`,
`intl` (formatação de moeda/data `pt_BR`) e `image_picker` (reservada para comprovativos).

## Estrutura do projeto

```
lib/
├── main.dart                     # ponto de entrada (Firebase.initializeApp + FinanceApp)
├── firebase_options.dart         # gerado pelo flutterfire configure
├── database/
│   └── db_helper.dart            # singleton + coleção transacoes (Firestore)
├── models/
│   ├── transacao.dart            # entidade principal (toMap/fromMap)
│   └── categoria.dart            # entidade de categoria
├── screens/
│   ├── login_screen.dart         # login
│   ├── home_screen.dart          # lista principal + saldo
│   ├── transaction_form_screen.dart  # inclusão e edição
│   └── transaction_detail_screen.dart # detalhes + exclusão
└── widgets/
    ├── balance_card.dart
    └── transaction_card.dart
```
