import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/quote_model.dart';
import '../services/database_helper.dart';
import '../services/pdf_service.dart';
import '../widgets/main_layout.dart';
import 'quote_form_view.dart';
import 'package:printing/printing.dart';

// Página para visualização dos documentos salvos

class QuoteListView extends StatefulWidget {
  const QuoteListView({super.key});

  @override
  State<QuoteListView> createState() => _QuoteListViewState();
}

class _QuoteListViewState extends State<QuoteListView> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Quote> _quotes = [];
  List<Quote> _filteredQuotes = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQuotes();
  }

  Future<void> _loadQuotes() async {
    setState(() => _isLoading = true);
    final quotes = await _dbHelper.getQuotes();
    setState(() {
      _quotes = quotes;
      _filteredQuotes = quotes;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterQuotes(String query) {
    setState(() {
      _filteredQuotes = _quotes
          .where(
            (q) =>
                q.customerName.toLowerCase().contains(query.toLowerCase()) ||
                q.mainGoal.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Meus Documentos',
      actions: [
        IconButton(
          onPressed: _loadQuotes,
          icon: const Icon(Icons.refresh),
          tooltip: 'Recarregar',
        ),
      ],
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Pesquisar cliente ou serviço...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _filterQuotes('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: _filterQuotes,
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredQuotes.isEmpty
                ? _buildEmptyState()
                : _buildList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.description_outlined, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text(
            'Nenhum documento encontrado',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(
              context,
              '/create',
            ).then((_) => _loadQuotes()),
            icon: const Icon(Icons.add),
            label: const Text('Criar Documento'),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredQuotes.length,
      itemBuilder: (context, index) {
        final quote = _filteredQuotes[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Text(
              quote.customerName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  'Data: ${DateFormat('dd/MM/yyyy').format(quote.serviceDate)}',
                ),
                Text('Serviço: ${quote.mainGoal}'),
                const SizedBox(height: 4),
                Text(
                  NumberFormat.currency(
                    locale: 'pt_BR',
                  ).format(quote.totalPrice),
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            trailing: PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'edit', child: Text('Editar')),
                const PopupMenuItem(value: 'pdf', child: Text('Ver PDF')),
                const PopupMenuItem(
                  value: 'share',
                  child: Text('Compartilhar'),
                ),
                const PopupMenuItem(value: 'delete', child: Text('Excluir')),
              ],
              onSelected: (value) async {
                if (value == 'edit') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QuoteFormView(quote: quote),
                    ),
                  ).then((_) => _loadQuotes());
                } else if (value == 'delete') {
                  await _dbHelper.deleteQuote(quote.id!);
                  _loadQuotes();
                } else if (value == 'pdf') {
                  await Printing.layoutPdf(
                    onLayout: (format) => PdfService().generateQuotePdf(quote),
                  );
                } else if (value == 'share') {
                  final pdfBytes = await PdfService().generateQuotePdf(quote);
                  await Printing.sharePdf(
                    bytes: pdfBytes,
                    filename:
                        'Documento_${quote.customerName.replaceAll(' ', '_')}_${DateFormat('yyyyMMdd').format(quote.serviceDate)}.pdf',
                  );
                }
              },
            ),
          ),
        );
      },
    );
  }
}
