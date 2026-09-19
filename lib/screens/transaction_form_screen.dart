import 'package:flutter/material.dart';
import '../models/transacao.dart';

class TransactionFormScreen extends StatelessWidget {
  final Transacao? transacaoParaEdicao;
  const TransactionFormScreen({super.key, this.transacaoParaEdicao});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(transacaoParaEdicao == null ? 'Nova Movimentação' : 'Editar Registo'),
      ),
      body: const Center(
        child: Text(''),
      ),
    );
  }
}