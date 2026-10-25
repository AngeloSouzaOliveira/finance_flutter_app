import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/db_helper.dart';
import '../models/transacao.dart';
import 'transaction_form_screen.dart';

class TransactionDetailScreen extends StatefulWidget {
  final Transacao transacao;

  const TransactionDetailScreen({super.key, required this.transacao});

  @override
  State<TransactionDetailScreen> createState() => _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  late Transacao _transacaoAtual;
  final DBHelper _dbHelper = DBHelper();

  @override
  void initState() {
    super.initState();
    _transacaoAtual = widget.transacao;
  }

  // Caixa de diálogo para confirmar a exclusão definitiva do registo
  Future<void> _confirmarExclusao() async {
    final bool? confirmar = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirmar Eliminação'),
          content: Text(
            'Tem a certeza de que pretende eliminar o lançamento "${_transacaoAtual.titulo}"? Esta ação não pode ser revertida.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirmar == true && _transacaoAtual.id != null) {
      try {
        await _dbHelper.deleteTransacao(_transacaoAtual.id!);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao eliminar: $e')),
          );
        }
        return;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lançamento eliminado com sucesso!'),
            backgroundColor: Colors.redAccent,
          ),
        );
        // Regressa ao ecrã principal sinalizando que houve remoção
        Navigator.pop(context, true);
      }
    }
  }

  Future<void> _editarTransacao() async {
    final bool? alterou = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => TransactionFormScreen(
          transacaoParaEdicao: _transacaoAtual,
        ),
      ),
    );

    // Se houve alterações salvas no Firestore, recarrega apenas este documento
    if (alterou == true && _transacaoAtual.id != null) {
      final transacaoRecarregada = await _dbHelper.getTransacao(_transacaoAtual.id!);

      if (transacaoRecarregada != null && mounted) {
        setState(() {
          _transacaoAtual = transacaoRecarregada;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatadorMoeda = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final bool isReceita = _transacaoAtual.tipo == 'receita';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Registo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Editar',
            onPressed: _editarTransacao,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Eliminar',
            onPressed: _confirmarExclusao,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 3,
              color: isReceita ? Colors.green[50] : Colors.red[50],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: isReceita ? Colors.green[100] : Colors.red[100],
                      child: Icon(
                        isReceita ? Icons.arrow_upward : Icons.arrow_downward,
                        size: 40,
                        color: isReceita ? Colors.green[800] : Colors.red[800],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _transacaoAtual.titulo,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${isReceita ? '+' : '-'} ${formatadorMoeda.format(_transacaoAtual.valor)}',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: isReceita ? Colors.green[800] : Colors.red[800],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.calendar_today, color: Colors.blueGrey),
                      title: const Text('Data e Hora de Registo'),
                      subtitle: Text(_transacaoAtual.dataHora),
                      contentPadding: EdgeInsets.zero,
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.category, color: Colors.blueGrey),
                      title: const Text('Natureza da Operação'),
                      subtitle: Text(isReceita ? 'Receita / Ganho' : 'Despesa / Pagamento'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Descrição / Observações',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _transacaoAtual.descricao != null && _transacaoAtual.descricao!.isNotEmpty
                          ? _transacaoAtual.descricao!
                          : 'Sem observações registadas.',
                      style: TextStyle(
                        fontSize: 15,
                        color: _transacaoAtual.descricao != null && _transacaoAtual.descricao!.isNotEmpty
                            ? Colors.black87
                            : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            OutlinedButton.icon(
              onPressed: _confirmarExclusao,
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              label: const Text(
                'Eliminar Lançamento',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 14.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
