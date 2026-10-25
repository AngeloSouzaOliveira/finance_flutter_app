import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/db_helper.dart';
import '../models/transacao.dart';

class TransactionFormScreen extends StatefulWidget {
  final Transacao? transacaoParaEdicao;

  const TransactionFormScreen({super.key, this.transacaoParaEdicao});

  @override
  State<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends State<TransactionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final DBHelper _dbHelper = DBHelper();

  // Controladores dos campos de texto
  late TextEditingController _tituloController;
  late TextEditingController _valorController;
  late TextEditingController _descricaoController;

  // Estado do formulário
  String _tipoSelecionado = 'despesa';
  DateTime _dataSelecionada = DateTime.now();
  TimeOfDay _horaSelecionada = TimeOfDay.now();
  String? _imagemPath;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();

    // Inicialização condicional: modo edição vs modo inclusão
    if (widget.transacaoParaEdicao != null) {
      final t = widget.transacaoParaEdicao!;
      _tituloController = TextEditingController(text: t.titulo);
      _valorController = TextEditingController(text: t.valor.toStringAsFixed(2));
      _descricaoController = TextEditingController(text: t.descricao ?? '');
      _tipoSelecionado = t.tipo;
      _imagemPath = t.imagemPath;

      // Tentativa de conversão da data salva em string para DateTime
      try {
        final parsedDate = DateFormat('dd/MM/yyyy HH:mm').parse(t.dataHora);
        _dataSelecionada = parsedDate;
        _horaSelecionada = TimeOfDay(hour: parsedDate.hour, minute: parsedDate.minute);
      } catch (_) {
        _dataSelecionada = DateTime.now();
      }
    } else {
      _tituloController = TextEditingController();
      _valorController = TextEditingController();
      _descricaoController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _valorController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  // Interpreta o valor digitado no formato brasileiro:
  // "10.000" = dez mil | "10.000,50" = dez mil e cinquenta | "10,50" | "10.50"
  double? _parseValor(String entrada) {
    String texto = entrada.trim().replaceAll(RegExp(r'[^\d,.]'), '');
    if (texto.isEmpty) return null;

    final temVirgula = texto.contains(',');
    final temPonto = texto.contains('.');

    if (temVirgula && temPonto) {
      // "10.000,50" -> ponto é milhar, vírgula é decimal
      texto = texto.replaceAll('.', '').replaceAll(',', '.');
    } else if (temVirgula) {
      // "10,50" (ou "1,000,000" -> Remove as vírgulas como milhar)
      final partes = texto.split(',');
      if (partes.length == 2 && partes.last.length != 3) {
        texto = texto.replaceAll(',', '.');
      } else {
        texto = texto.replaceAll(',', '');
      }
    } else if (temPonto) {
      final partes = texto.split('.');
      if (partes.length == 2 && partes.last.length != 3) {
        // "10.50" -> decimal
      } else {
        // "10.000" ou "1.000.000" -> milhar
        texto = texto.replaceAll('.', '');
      }
    }

    return double.tryParse(texto);
  }
  Future<void> _selecionarData() async {
    final DateTime? dataEscolhida = await showDatePicker(
      context: context,
      initialDate: _dataSelecionada,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (dataEscolhida != null) {
      setState(() {
        _dataSelecionada = dataEscolhida;
      });
    }
  }

  // Seletor de Hora
  Future<void> _selecionarHora() async {
    final TimeOfDay? horaEscolhida = await showTimePicker(
      context: context,
      initialTime: _horaSelecionada,
    );

    if (horaEscolhida != null) {
      setState(() {
        _horaSelecionada = horaEscolhida;
      });
    }
  }

  // Gravação no Firestore
  Future<void> _salvarTransacao() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _salvando = true;
    });

    // Formata a data e hora unificadas
    final DateTime dataFinal = DateTime(
      _dataSelecionada.year,
      _dataSelecionada.month,
      _dataSelecionada.day,
      _horaSelecionada.hour,
      _horaSelecionada.minute,
    );
    final String dataHoraFormatada = DateFormat('dd/MM/yyyy HH:mm').format(dataFinal);

    // Converte valor monetário com suporte a vírgula ou ponto
    final double? valorNumerico = _parseValor(_valorController.text);
    if (valorNumerico == null) {
      setState(() {
        _salvando = false;
      });
      return;
    }

    try {
      if (widget.transacaoParaEdicao == null) {
        // Inserção de novo registo
        final novaTransacao = Transacao(
          titulo: _tituloController.text.trim(),
          valor: valorNumerico,
          dataHora: dataHoraFormatada,
          tipo: _tipoSelecionado,
          descricao: _descricaoController.text.trim().isEmpty ? null : _descricaoController.text.trim(),
          imagemPath: _imagemPath,
        );

        await _dbHelper.insertTransacao(novaTransacao);
      } else {
        // Atualização de registo existente
        final transacaoAtualizada = Transacao(
          id: widget.transacaoParaEdicao!.id,
          titulo: _tituloController.text.trim(),
          valor: valorNumerico,
          dataHora: dataHoraFormatada,
          tipo: _tipoSelecionado,
          descricao: _descricaoController.text.trim().isEmpty ? null : _descricaoController.text.trim(),
          imagemPath: _imagemPath,
        );

        await _dbHelper.updateTransacao(transacaoAtualizada);
      }
    } catch (e) {
      // Ex.: sem permissão nas regras do Firestore
      if (mounted) {
        setState(() {
          _salvando = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar: $e')),
        );
      }
      return;
    }

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEdicao = widget.transacaoParaEdicao != null;
    final String dataTexto = DateFormat('dd/MM/yyyy').format(_dataSelecionada);
    final String horaTexto = '${_horaSelecionada.hour.toString().padLeft(2, '0')}:${_horaSelecionada.minute.toString().padLeft(2, '0')}';

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdicao ? 'Editar Lançamento' : 'Novo Lançamento'),
      ),
      body: _salvando
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Seletor de Tipo (SegmentedButton)
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(
                          value: 'despesa',
                          label: Text('Despesa'),
                          icon: Icon(Icons.arrow_downward, color: Colors.red),
                        ),
                        ButtonSegment(
                          value: 'receita',
                          label: Text('Receita'),
                          icon: Icon(Icons.arrow_upward, color: Colors.green),
                        ),
                      ],
                      selected: {_tipoSelecionado},
                      onSelectionChanged: (Set<String> novoTipo) {
                        setState(() {
                          _tipoSelecionado = novoTipo.first;
                        });
                      },
                    ),
                    const SizedBox(height: 20),

                    // Campo de Título
                    TextFormField(
                      controller: _tituloController,
                      decoration: InputDecoration(
                        labelText: 'Título da Operação *',
                        hintText: 'Ex: Aluguer, Salário, Restaurante',
                        prefixIcon: const Icon(Icons.title),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Por favor, informe o título.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Campo de Valor
                    TextFormField(
                      controller: _valorController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Valor (R\$) *',
                        hintText: 'Ex: 150.00',
                        prefixIcon: const Icon(Icons.attach_money),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Por favor, informe o valor.';
                        }
                        final parsed = _parseValor(value);
                        if (parsed == null || parsed <= 0) {
                          return 'Insira um valor numérico válido maior que zero.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Seletores de Data e Hora lado a lado
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _selecionarData,
                            icon: const Icon(Icons.calendar_today),
                            label: Text(dataTexto),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _selecionarHora,
                            icon: const Icon(Icons.access_time),
                            label: Text(horaTexto),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Campo de Descrição Detalhada
                    TextFormField(
                      controller: _descricaoController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Observações / Descrição',
                        hintText: 'Detalhes adicionais (opcional)',
                        prefixIcon: const Icon(Icons.notes),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 20),

                    const SizedBox(height: 32),

                    const SizedBox(height: 32),

                    // Botão de Gravação
                    ElevatedButton(
                      onPressed: _salvarTransacao,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: _tipoSelecionado == 'receita' ? Colors.green : Colors.redAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(
                        isEdicao ? 'Salvar Alterações' : 'Confirmar Lançamento',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
