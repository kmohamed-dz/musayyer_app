import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../data/models/invoice_item_model.dart';
import '../../data/models/invoice_model.dart';

class InvoicePdfGenerator {
  Future<String> generate({
    required InvoiceModel invoice,
    required List<InvoiceItemModel> items,
    required String shopName,
    required String customerName,
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
            pw.Text('Invoice #: ${invoice.id.substring(0, 8)}'),
            pw.Text('Date: ${invoice.createdAt}'),
            pw.Text('Customer: $customerName'),
            pw.SizedBox(height: 12),
            pw.TableHelper.fromTextArray(
              headers: const ['Product', 'Qty', 'Unit Price', 'Subtotal'],
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
                  pw.Text('Total: ${invoice.totalAmount.toStringAsFixed(2)} DZD'),
                  pw.Text('Paid: ${invoice.paidAmount.toStringAsFixed(2)} DZD'),
                  pw.Text(
                    'Remaining: ${(invoice.totalAmount - invoice.paidAmount).toStringAsFixed(2)} DZD',
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Center(child: pw.Text('Thank you for your purchase')),
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
