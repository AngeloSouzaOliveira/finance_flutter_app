
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transacao.dart';

class TransactionCard extends StatelessWidget {
  final Transacao transacao;
  final VoidCallback onTap;

  const TransactionCard({
    super.key,
    required this.transacao,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final formatadorMoeda = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final bool isReceita = transacao.tipo == 'receita';

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isReceita ? Colors.green[100] : Colors.red[100],
          child: Icon(
            isReceita ? Icons.arrow_upward : Icons.arrow_downward,
            color: isReceita ? Colors.green[800] : Colors.red[800],
          ),
        ),
        title: Text(
          transacao.titulo,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          transacao.dataHora,
          style: const TextStyle(color: Colors.grey, fontSize: 13),
        ),
        trailing: Text(
          '${isReceita ? '+' : '-'} ${formatadorMoeda.format(transacao.valor)}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isReceita ? Colors.green[700] : Colors.red[700],
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}