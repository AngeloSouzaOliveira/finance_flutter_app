import 'package:flutter/material.dart';
import '../models/transacao.dart';

class TransactionDetailScreen extends StatelessWidget {
  final Transacao transacao;
  const TransactionDetailScreen({super.key, required this.transacao});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes do Registo')),
      body: Center(
        child: Text(''),
      ),
    );
  }
}