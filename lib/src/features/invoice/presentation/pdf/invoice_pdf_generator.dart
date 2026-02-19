import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../data/models/invoice_item_model.dart';
import '../../data/models/invoice_model.dart';

class InvoicePdfTexts {
  InvoicePdfTexts({
    required this.invoice,
    required this.date,
    required this.customer,
    required this.product,
    required this.qty,
    required this.unitPrice,
    required this.subtotal,
    required this.total,
    required this.paid,
    required this.remaining,
    required this.thankYou,
    required this.currency,
  });

  final String invoice;
  final String date;
  final String customer;
  final String product;
  final String qty;
  final String unitPrice;
  final String subtotal;
  final String total;
  final String paid;
  final String remaining;
  final String thankYou;
  final String currency;
}

class InvoicePdfGenerator {
  Future<String> generate({
    required InvoiceModel invoice,
    required List<InvoiceItemModel> items,
    required String shopName,
    required String customerName,
    required InvoicePdfTexts texts,
  }) async {
    final pdf = pw.Document();

    final fontData = await rootBundle.load('assets/fonts/Amiri-Regular.ttf');
    final arabicFont = pw.Font.ttf(fontData);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(base: arabicFont, bold: arabicFont),
        build: (context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Text(shopName, style: const pw.TextStyle(fontSize: 24)),
            ),
            pw.SizedBox(height: 8),
            pw.Text('${texts.invoice} #: ${invoice.id.substring(0, 8)}'),
            pw.Text('${texts.date}: ${invoice.createdAt}'),
            pw.Text('${texts.customer}: $customerName'),
            pw.SizedBox(height: 12),
            pw.TableHelper.fromTextArray(
              headers: [texts.product, texts.qty, texts.unitPrice, texts.subtotal],
              data: items
                  .map(
                    (item) => [
                      item.productName,
                      item.quantity.toString(),
                      item.unitPrice.toStringAsFixed(2),
                      item.subtotal.toStringAsFixed(2),
                    ],
                  )
                  .toList(),
            ),
            pw.SizedBox(height: 12),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('${texts.total}: ${invoice.totalAmount.toStringAsFixed(2)} ${texts.currency}'),
                  pw.Text('${texts.paid}: ${invoice.paidAmount.toStringAsFixed(2)} ${texts.currency}'),
                  pw.Text(
                    '${texts.remaining}: ${(invoice.totalAmount - invoice.paidAmount).toStringAsFixed(2)} ${texts.currency}',
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Center(child: pw.Text(texts.thankYou)),
          ];
        },
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final path = '${dir.path}/invoice_${invoice.id}.pdf';
    final file = File(path);
    await file.writeAsBytes(await pdf.save());
    return path;
  }
}
