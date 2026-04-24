import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/quote_model.dart';
import '../services/database_helper.dart';
import '../services/pdf_service.dart';
import '../widgets/main_layout.dart';
import 'package:printing/printing.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:flutter/services.dart';

// Página para criação dos documentos

class QuoteFormView extends StatefulWidget {
  final Quote? quote;

  const QuoteFormView({super.key, this.quote});

  @override
  State<QuoteFormView> createState() => _QuoteFormViewState();
}

class _QuoteFormViewState extends State<QuoteFormView> {
  final _formKey = GlobalKey<FormState>();
  final _dbHelper = DatabaseHelper();
  final _pdfService = PdfService();

  late TextEditingController _nameController;
  late TextEditingController _cpfController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  late TextEditingController _goalController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late DateTime _selectedDate;

  final _cpfFormatter = CpfCnpjFormatter();
  final _phoneFormatter = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {"#": RegExp(r'[0-9]')},
  );

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.quote?.customerName);
    _cpfController = TextEditingController(text: widget.quote?.customerCpf);
    _addressController = TextEditingController(
      text: widget.quote?.customerAddress,
    );
    _phoneController = TextEditingController(text: widget.quote?.customerPhone);
    _goalController = TextEditingController(text: widget.quote?.mainGoal);
    _descriptionController = TextEditingController(
      text: widget.quote?.serviceDescription,
    );
    _priceController = TextEditingController(
      text: widget.quote?.totalPrice.toString(),
    );
    _selectedDate = widget.quote?.serviceDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cpfController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _goalController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _saveQuote() async {
    if (_formKey.currentState!.validate()) {
      final quote = Quote(
        id: widget.quote?.id,
        customerName: _nameController.text,
        customerCpf: _cpfController.text,
        customerAddress: _addressController.text,
        customerPhone: _phoneController.text,
        serviceDate: _selectedDate,
        mainGoal: _goalController.text,
        serviceDescription: _descriptionController.text,
        totalPrice:
            double.tryParse(_priceController.text.replaceAll(',', '.')) ?? 0.0,
      );

      if (widget.quote == null) {
        await _dbHelper.insertQuote(quote);
      } else {
        await _dbHelper.updateQuote(quote);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Documento salvo com sucesso!')),
        );
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        } else {
          Navigator.pushReplacementNamed(context, '/');
        }
      }
    }
  }

  Future<void> _previewPdf() async {
    if (_formKey.currentState!.validate()) {
      final quote = Quote(
        customerName: _nameController.text,
        customerCpf: _cpfController.text,
        customerAddress: _addressController.text,
        customerPhone: _phoneController.text,
        serviceDate: _selectedDate,
        mainGoal: _goalController.text,
        serviceDescription: _descriptionController.text,
        totalPrice:
            double.tryParse(_priceController.text.replaceAll(',', '.')) ?? 0.0,
      );

      await Printing.layoutPdf(
        onLayout: (format) => _pdfService.generateQuotePdf(quote),
      );
    }
  }

  Future<void> _sharePdf() async {
    if (_formKey.currentState!.validate()) {
      final quote = Quote(
        customerName: _nameController.text,
        customerCpf: _cpfController.text,
        customerAddress: _addressController.text,
        customerPhone: _phoneController.text,
        serviceDate: _selectedDate,
        mainGoal: _goalController.text,
        serviceDescription: _descriptionController.text,
        totalPrice:
            double.tryParse(_priceController.text.replaceAll(',', '.')) ?? 0.0,
      );

      final pdfBytes = await _pdfService.generateQuotePdf(quote);
      await Printing.sharePdf(
        bytes: pdfBytes,
        filename:
            'Documento_${quote.customerName.replaceAll(' ', '_')}_${DateFormat('yyyyMMdd').format(quote.serviceDate)}.pdf',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: widget.quote == null ? 'Novo Documento' : 'Editar Documento',
      actions: [
        IconButton(
          onPressed: _previewPdf,
          icon: const Icon(Icons.picture_as_pdf),
          tooltip: 'Gerar PDF',
        ),
        IconButton(
          onPressed: _sharePdf,
          icon: const Icon(Icons.share),
          tooltip: 'Compartilhar',
        ),
        IconButton(
          onPressed: _saveQuote,
          icon: const Icon(Icons.save),
          tooltip: 'Salvar',
        ),
      ],
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Informações do Cliente'),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome do Cliente',
                  counterText: "",
                ),
                maxLength: 100,
                validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _cpfController,
                      decoration: const InputDecoration(
                        labelText: 'CPF / CNPJ',
                        hintText: 'Opcional.Ex: 123.456.789-10',
                      ),
                      inputFormatters: [_cpfFormatter],
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.isEmpty) return null;
                        final digits = v.replaceAll(RegExp(r'\D'), '');
                        if (digits.length <= 11) {
                          if (digits.length < 11) return 'CPF incompleto';
                        } else {
                          if (digits.length < 14) return 'CNPJ incompleto';
                        }
                        return null;
                      },
                      maxLength: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Telefone',
                        hintText: 'Ex: (11) 91234-5678',
                      ),
                      inputFormatters: [_phoneFormatter],
                      keyboardType: TextInputType.phone,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Campo obrigatório';
                        if (v.length < 14) return 'Telefone incompleto';
                        return null;
                      },
                      maxLength: 15,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Endereço do Imóvel',
                  counterText: "",
                  hintText:
                      'Opcional. Ex: Rua das Flores, 123 - Centro, São Paulo - SP',
                ),
                maxLength: 200,
              ),
              const SizedBox(height: 32),

              _buildSectionTitle('Detalhes do Serviço'),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: const Text('Data do Serviço'),
                      subtitle: Text(
                        DateFormat('dd/MM/yyyy').format(_selectedDate),
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (date != null) setState(() => _selectedDate = date);
                      },
                    ),
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(
                        labelText: 'Valor Total',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) => (v == null || v.isEmpty) ? 'Campo obrigatório' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _goalController,
                decoration: const InputDecoration(
                  labelText: 'Objetivo Principal',
                  counterText: "",
                ),
                maxLength: 150,
                validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descrição Detalhada dos Serviços',
                  alignLabelWithHint: true,
                ),
                maxLines: 10,
                validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveQuote,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'SALVAR DOCUMENTO',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF0F172A),
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
