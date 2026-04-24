import 'package:flutter/material.dart';
import '../services/database_helper.dart';
import '../widgets/main_layout.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:flutter/services.dart';

// Página para as configurações gerais da aplicação.

class QuoteSettingsView extends StatefulWidget {
  const QuoteSettingsView({super.key});

  @override
  State<QuoteSettingsView> createState() => _QuoteSettingsViewState();
}

class _QuoteSettingsViewState extends State<QuoteSettingsView> {
  final _formKey = GlobalKey<FormState>();
  final _dbHelper = DatabaseHelper();

  final _companyController = TextEditingController();
  final _responsibleController = TextEditingController();
  final _cnpjController = TextEditingController();
  final _phoneController = TextEditingController();

  final _phoneFormatter = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {"#": RegExp(r'[0-9]')},
  );

  final _cnpjFormatter = CpfCnpjFormatter();

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await _dbHelper.getSettings();
    setState(() {
      _companyController.text = settings['companyName'] ?? '';
      _responsibleController.text = settings['serviceResponsible'] ?? '';
      _cnpjController.text = settings['cnpj'] ?? '';
      _phoneController.text = settings['telephone'] ?? '';
      _isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    if (_formKey.currentState!.validate()) {
      await _dbHelper.saveSettings({
        'companyName': _companyController.text,
        'serviceResponsible': _responsibleController.text,
        'cnpj': _cnpjController.text,
        'telephone': _phoneController.text,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Configurações salvas com sucesso!')),
        );
      }
    }
  }

  @override
  void dispose() {
    _companyController.dispose();
    _responsibleController.dispose();
    _cnpjController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Configurações',
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Dados da Empresa (PDF)',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Estas informações aparecerão no rodapé do relatório técnico gerado.',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _companyController,
                      decoration: const InputDecoration(
                        labelText: 'Nome da Empresa / Profissional',
                        hintText: 'Ex: FLORESTA ENGENHARIA LTDA',
                        counterText: "",
                      ),
                      maxLength: 100,
                      validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _responsibleController,
                      decoration: const InputDecoration(
                        labelText: 'Cargo / Responsabilidade',
                        hintText: 'Ex: Engenheiro Ambiental',
                        counterText: "",
                      ),
                      maxLength: 100,
                      validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _cnpjController,
                      decoration: const InputDecoration(
                        labelText: 'CNPJ / CPF',
                        hintText: 'Ex: 12.234.567/0001-98 ou 123.456.789-10',
                      ),
                      inputFormatters: [_cnpjFormatter],
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v != null && v.isNotEmpty) {
                          final digits = v.replaceAll(RegExp(r'\D'), '');
                          if (digits.length <= 11) {
                            if (digits.length < 11) return 'CPF incompleto';
                          } else {
                            if (digits.length < 14) return 'CNPJ incompleto';
                          }
                        }
                        return null;
                      },
                      maxLength: 18,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Telefone de Contato',
                        hintText: 'Ex: (11) 91234-5678',
                      ),
                      inputFormatters: [_phoneFormatter],
                      keyboardType: TextInputType.phone,
                      validator: (v) {
                        if (v!.isNotEmpty && v.length < 14) {
                          return 'Telefone incompleto';
                        }
                        return null;
                      },
                      maxLength: 15,
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveSettings,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          'SALVAR CONFIGURAÇÕES',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class CpfCnpjFormatter extends TextInputFormatter {
  final _formatter = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {"#": RegExp(r'[0-9]')},
  );

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length <= 11) {
      _formatter.updateMask(mask: '###.###.###-##');
    } else {
      _formatter.updateMask(mask: '##.###.###/####-##');
    }
    return _formatter.formatEditUpdate(oldValue, newValue);
  }
}
