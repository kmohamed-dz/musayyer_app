import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/db/hive_boxes.dart';
import '../../../customers/data/models/customer_model.dart';
import '../../data/models/debt_model.dart';
import '../../data/models/payment_model.dart';
import '../../../invoice/domain/repositories/invoice_repository.dart';
import '../../../invoice/presentation/providers/invoice_providers.dart';

class DebtPaymentService {
  DebtPaymentService({
    required this.debtBox,
    required this.paymentBox,
    required this.invoiceRepository,
    required this.customerBox,
  });

  final Box<DebtModel> debtBox;
  final Box<PaymentModel> paymentBox;
  final InvoiceRepository invoiceRepository;
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
      final invoice = await invoiceRepository.getInvoiceById(debt.invoiceId!);
      if (invoice != null) {
        final updatedPaidAmount =
            min(invoice.totalAmount, invoice.paidAmount + paymentAmount);
        final updatedStatus = updatedPaidAmount >= invoice.totalAmount
            ? 'paid'
            : updatedPaidAmount > 0
                ? 'partial'
                : 'unpaid';
        await invoiceRepository.updateInvoice(
          invoice.copyWith(
            paidAmount: updatedPaidAmount,
            status: updatedStatus,
          ),
        );
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
    invoiceRepository: ref.read(invoiceRepositoryProvider),
    customerBox: Hive.box<CustomerModel>(HiveBoxes.customers),
  );
});
