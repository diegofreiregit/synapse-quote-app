import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart';
import '../models/quote_model.dart';
import 'database_helper.dart';

// classe para gerar o pdf do documento
class PdfService {
  // cores usadas no documento
  static const PdfColor navyBlue = PdfColor.fromInt(0xff0f172a);
  static const PdfColor lightBlue = PdfColor.fromInt(0xff8cd9f0);
  static const PdfColor grey = PdfColor.fromInt(0xff333333);

  // método para gerar o pdf
  Future<Uint8List> generateQuotePdf(Quote quote) async {
    final pdf = pw.Document();

    // carregamento das fontes
    final fontRegular = await PdfGoogleFonts.interRegular();
    final fontBold = await PdfGoogleFonts.interBold();

    // carregamento das configurações
    final settings = await DatabaseHelper().getSettings();
    final companyName = settings['companyName'] ?? 'SANDRO ALMEIDA';
    final serviceResponsible =
        settings['serviceResponsible'] ?? 'Responsável técnico';
    final cnpj = settings['cnpj'] ?? '43.013.882/0001-32';
    final telephone = settings['telephone'] ?? '(11) 95595-3315';

    // carregamento da imagem do cabeçalho
    final image = await rootBundle.load('assets/images/sandro-header.png');
    final imageBytes = image.buffer.asUint8List();
    final headerImage = pw.MemoryImage(imageBytes);

    // criação da página
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(0),
        build: (pw.Context context) {
          return pw.Stack(
            children: [
              // Header Design
              pw.Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: pw.Image(headerImage, fit: pw.BoxFit.contain),
              ),

              // Content
              pw.Padding(
                padding: const pw.EdgeInsets.only(
                  top: 140,
                  left: 40,
                  right: 40,
                  bottom: 100,
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow(
                      fontBold,
                      fontRegular,
                      'Contratante:',
                      quote.customerName,
                    ),
                    _buildInfoRow(
                      fontBold,
                      fontRegular,
                      'CPF:',
                      quote.customerCpf,
                    ),
                    _buildInfoRow(
                      fontBold,
                      fontRegular,
                      'Endereço do imóvel:',
                      quote.customerAddress,
                    ),
                    _buildInfoRow(
                      fontBold,
                      fontRegular,
                      'Data:',
                      DateFormat('dd/MM/yyyy').format(quote.serviceDate),
                    ),

                    pw.SizedBox(height: 30),

                    pw.Text(
                      'OBJETIVO',
                      style: pw.TextStyle(font: fontBold, fontSize: 14),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Text(
                      quote.mainGoal,
                      style: pw.TextStyle(font: fontRegular, fontSize: 12),
                    ),

                    pw.SizedBox(height: 20),

                    pw.Text(
                      'DESCRIÇÃO DOS SERVIÇOS',
                      style: pw.TextStyle(font: fontBold, fontSize: 14),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Text(
                      quote.serviceDescription,
                      style: pw.TextStyle(font: fontRegular, fontSize: 12),
                      textAlign: pw.TextAlign.justify,
                    ),

                    pw.SizedBox(height: 20),

                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.end,
                      children: [
                        pw.Text(
                          'Valor Total: ${NumberFormat.currency(locale: 'pt_BR').format(quote.totalPrice)}',
                          style: pw.TextStyle(
                            font: fontBold,
                            fontSize: 14,
                            color: navyBlue,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Footer Design
              pw.Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(right: 40, bottom: 20),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text(
                            companyName,
                            style: pw.TextStyle(
                              font: fontBold,
                              fontSize: 20,
                              color: grey,
                            ),
                          ),
                          pw.Text(
                            serviceResponsible,
                            style: pw.TextStyle(
                              font: fontRegular,
                              fontSize: 12,
                            ),
                          ),
                          pw.Text(
                            'CNPJ: $cnpj',
                            style: pw.TextStyle(
                              font: fontRegular,
                              fontSize: 12,
                            ),
                          ),
                          pw.Text(
                            telephone,
                            style: pw.TextStyle(
                              font: fontRegular,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    pw.Row(
                      children: [
                        pw.Expanded(
                          flex: 2,
                          child: pw.Container(height: 40, color: lightBlue),
                        ),
                        pw.Expanded(
                          flex: 2,
                          child: pw.Container(
                            height: 40,
                            child: pw.CustomPaint(
                              painter: (PdfGraphics canvas, PdfPoint size) {
                                canvas.moveTo(0, size.y);
                                canvas.lineTo(size.x, 0);
                                canvas.lineTo(size.x, size.y);
                                canvas.setFillColor(grey);
                                canvas.fillPath();
                              },
                            ),
                          ),
                        ),
                        pw.Expanded(
                          flex: 1,
                          child: pw.Container(height: 40, color: grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  // método para construir as linhas de informação no canto inferior direito
  pw.Widget _buildInfoRow(
    pw.Font bold,
    pw.Font regular,
    String label,
    String value,
  ) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.RichText(
        text: pw.TextSpan(
          children: [
            pw.TextSpan(
              text: '$label ',
              style: pw.TextStyle(font: bold, fontSize: 12),
            ),
            pw.TextSpan(
              text: value,
              style: pw.TextStyle(font: regular, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
