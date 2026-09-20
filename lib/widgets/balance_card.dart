import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BalanceCard extends StatelessWidget {
  final double saldoTotal;
  final double totalReceitas;
  final double totalDespesas;

  const BalanceCard({
    super.key,
    required this.saldoTotal,
    required this.totalReceitas,
    required this.totalDespesas,
  });

  @override
  Widget build(BuildContext context) {
    final formatadorMoeda = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return Card(
      margin: const EdgeInsets.all(16.0),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Saldo em Caixa',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              formatadorMoeda.format(saldoTotal),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: saldoTotal >= 0 ? Colors.green[800] : Colors.red[800],
              ),
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Coluna de Receitas
                Row(
                  children: [
                    const Icon(Icons.arrow_circle_up, color: Colors.green, size: 30),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Receitas', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        Text(
                          formatadorMoeda.format(totalReceitas),
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                        ),
                      ],
                    ),
                  ],
                ),
                // Coluna de Despesas
                Row(
                  children: [
                    const Icon(Icons.arrow_circle_down, color: Colors.red, size: 30),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Despesas', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        Text(
                          formatadorMoeda.format(totalDespesas),
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}