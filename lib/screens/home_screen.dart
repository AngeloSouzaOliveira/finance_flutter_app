// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/transacao.dart';
import '../widgets/balance_card.dart';
import '../widgets/transaction_card.dart';
import 'transaction_detail_screen.dart';
import 'transaction_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DBHelper _dbHelper = DBHelper();

  late final Stream<List<Transacao>> _transacoesStream;

  @override
  void initState() {
    super.initState();
    _transacoesStream = _dbHelper.streamTransacoes();
  }

  void _abrirCadastro() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TransactionFormScreen(),
      ),
    );
  }

  void _abrirDetalhes(Transacao transacao) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TransactionDetailScreen(transacao: transacao),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Minhas Finanças',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<List<Transacao>>(
        stream: _transacoesStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  'Erro ao carregar os dados:\n${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          return _buildConteudo(snapshot.data!);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _abrirCadastro,
        icon: const Icon(Icons.add),
        label: const Text('Nova Movimentação'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildConteudo(List<Transacao> transacoes) {
    double totalReceitas = 0.0;
    double totalDespesas = 0.0;

    for (var t in transacoes) {
      if (t.tipo == 'receita') {
        totalReceitas += t.valor;
      } else {
        totalDespesas += t.valor;
      }
    }

    final double saldoTotal = totalReceitas - totalDespesas;

    return Column(
      children: [
        // 1. Resumo Financeiro
        BalanceCard(
          saldoTotal: saldoTotal,
          totalReceitas: totalReceitas,
          totalDespesas: totalDespesas,
        ),

        // 2. Cabeçalho de Contagem de Registos
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Histórico de Movimentações',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                '${transacoes.length} registos',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),

        // 3. Lista Principal Dinâmica
        Expanded(
          child: transacoes.isEmpty
              ? const Center(
                  child: Text(
                    'Nenhuma movimentação registada.\nToque no botão + para adicionar!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                )
              : ListView.builder(
                  itemCount: transacoes.length,
                  itemBuilder: (context, index) {
                    final transacao = transacoes[index];
                    return TransactionCard(
                      transacao: transacao,
                      onTap: () => _abrirDetalhes(transacao),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
