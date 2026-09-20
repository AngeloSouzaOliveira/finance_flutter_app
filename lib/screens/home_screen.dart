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
  List<Transacao> _transacoes = [];
  bool _carregando = true;

  double _totalReceitas = 0.0;
  double _totalDespesas = 0.0;
  double _saldoTotal = 0.0;

  @override
  void initState() {
    super.initState();
    _carregarTransacoes();
  }

  // Leitura assíncrona no SQLite e cálculo de totais
  Future<void> _carregarTransacoes() async {
    setState(() {
      _carregando = true;
    });

    final lista = await _dbHelper.getTransacoes();

    double receitas = 0.0;
    double despesas = 0.0;

    for (var t in lista) {
      if (t.tipo == 'receita') {
        receitas += t.valor;
      } else {
        despesas += t.valor;
      }
    }

    setState(() {
      _transacoes = lista;
      _totalReceitas = receitas;
      _totalDespesas = despesas;
      _saldoTotal = receitas - despesas;
      _carregando = false;
    });
  }

  // Abre o ecrã de registo e atualiza os dados quando regressar
  Future<void> _abrirCadastro() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TransactionFormScreen(),
      ),
    );
    _carregarTransacoes();
  }

  // Abre o ecrã de detalhes da transação e atualiza se tiver sido eliminada ou editada
  Future<void> _abrirDetalhes(Transacao transacao) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TransactionDetailScreen(transacao: transacao),
      ),
    );
    _carregarTransacoes();
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
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 1. Resumo Financeiro
                BalanceCard(
                  saldoTotal: _saldoTotal,
                  totalReceitas: _totalReceitas,
                  totalDespesas: _totalDespesas,
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
                        '${_transacoes.length} registos',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),

                // 3. Lista Principal Dinâmica
                Expanded(
                  child: _transacoes.isEmpty
                      ? const Center(
                          child: Text(
                            'Nenhuma movimentação registada.\nToque no botão + para adicionar!',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _transacoes.length,
                          itemBuilder: (context, index) {
                            final transacao = _transacoes[index];
                            return TransactionCard(
                              transacao: transacao,
                              onTap: () => _abrirDetalhes(transacao),
                            );
                          },
                        ),
                ),
              ],
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
}