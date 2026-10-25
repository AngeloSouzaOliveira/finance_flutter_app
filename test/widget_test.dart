import 'package:finance_av1/widgets/balance_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

// Teste de widget que não depende do Firebase: verifica o resumo de saldo.
void main() {
  setUpAll(() async {
    await initializeDateFormatting('pt_BR');
  });

  testWidgets('BalanceCard mostra os títulos de receitas e despesas', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: BalanceCard(
            saldoTotal: 50,
            totalReceitas: 150,
            totalDespesas: 100,
          ),
        ),
      ),
    );

    expect(find.text('Saldo em Caixa'), findsOneWidget);
    expect(find.text('Receitas'), findsOneWidget);
    expect(find.text('Despesas'), findsOneWidget);
  });
}
