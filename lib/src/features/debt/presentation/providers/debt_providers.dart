import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/db/hive_boxes.dart';
import '../../../customers/data/models/customer_model.dart';
import '../../data/models/debt_model.dart';
import '../../data/models/payment_model.dart';
import '../../../invoice/data/models/invoice_model.dart';

class DebtPaymentService {
  DebtPaymentService({
    required this.debtBox,
    required this.paymentBox,
    required this.invoiceBox,
    required this.customerBox,
  });

  final Box<DebtModel> debtBox;
  final Box<PaymentModel> paymentBox;
  final Box<InvoiceModel> invoiceBox;
  final Box<CustomerModel> customerBox;

  Future<void> recordPayment({
    required DebtModel debt,
    required double amount,
    required DateTime paidAt,
    String? notes,
  }) async {
    if (amount <= 0) {
      return;
    }

    final paymentAmount = min(amount, debt.remainingAmount);

    final payment = PaymentModel(
      id: const Uuid().v4(),
      debtId: debt.id,
      customerId: debt.customerId,
      amount: paymentAmount,
      paidAt: paidAt,
      notes: notes,
    );
    await paymentBox.put(payment.id, payment);

    debt.remainingAmount = max(0, debt.remainingAmount - paymentAmount);
    debt.status = debt.remainingAmount <= 0 ? 'paid' : 'open';
    await debt.save();

    if (debt.invoiceId != null) {
      final invoice = invoiceBox.get(debt.invoiceId);
      if (invoice != null) {
        invoice.paidAmount = min(invoice.totalAmount, invoice.paidAmount + paymentAmount);
        if (invoice.paidAmount >= invoice.totalAmount) {
          invoice.status = 'paid';
        } else if (invoice.paidAmount > 0) {
          invoice.status = 'partial';
        } else {
          invoice.status = 'unpaid';
        }
        await invoice.save();
      }
    }

    final customer = customerBox.get(debt.customerId);
    if (customer != null) {
      final totalDebt = debtBox.values
          .where((d) => d.customerId == customer.id)
          .fold<double>(0, (sum, d) => sum + d.remainingAmount);
      customer.totalDebt = totalDebt;
      await customer.save();
    }
  }
}

final debtPaymentServiceProvider = Provider<DebtPaymentService>((ref) {
  return DebtPaymentService(
    debtBox: Hive.box<DebtModel>(HiveBoxes.debts),
    paymentBox: Hive.box<PaymentModel>(HiveBoxes.payments),
    invoiceBox: Hive.box<InvoiceModel>(HiveBoxes.invoices),
    customerBox: Hive.box<CustomerModel>(HiveBoxes.customers),
  );
});
