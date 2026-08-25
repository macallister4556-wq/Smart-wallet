import 'package:telephony/telephony.dart';
import '../models/transaction.dart';
import 'package:uuid/uuid.dart';

class SmsSyncService {
  final Telephony telephony = Telephony.instance;
  final _uuid = const Uuid();

  Future<bool> requestPermissions() async {
    bool? permissionsGranted = await telephony.requestPhoneAndSmsPermissions;
    return permissionsGranted ?? false;
  }

  void initializeSmsListener(Function(Transaction) onTransactionDetected) async {
    bool permissionsGranted = await requestPermissions();

    if (permissionsGranted) {
      telephony.listenIncomingSms(
        onNewMessage: (SmsMessage message) {
          _parseMessage(message.body ?? "", onTransactionDetected);
        },
        listenInBackground: true,
      );
    }
  }

  void _parseMessage(String body, Function(Transaction) onTransactionDetected) {
    String lowerBody = body.toLowerCase();
    double amount = _extractAmount(body);

    if (amount <= 0) return;

    // Airtime / Recharge patterns (common in many countries)
    if (lowerBody.contains("airtime") ||
        lowerBody.contains("recharge") ||
        lowerBody.contains("top up") ||
        lowerBody.contains("top-up") ||
        lowerBody.contains("credit")) {
      onTransactionDetected(Transaction(
        id: _uuid.v4(),
        title: "Airtime Purchase",
        amount: amount,
        category: "Airtime",
        date: DateTime.now(),
        isAutoSynced: true,
      ));
      return;
    }

    // Data / Bundle patterns
    if (lowerBody.contains("data") ||
        lowerBody.contains("mb") ||
        lowerBody.contains("gb") ||
        lowerBody.contains("bundle") ||
        lowerBody.contains("internet")) {
      onTransactionDetected(Transaction(
        id: _uuid.v4(),
        title: "Data Bundle",
        amount: amount,
        category: "Data",
        date: DateTime.now(),
        isAutoSynced: true,
      ));
      return;
    }

    // Generic debit / purchase patterns (can be expanded)
    if (lowerBody.contains("debited") ||
        lowerBody.contains("purchase") ||
        lowerBody.contains("paid") ||
        lowerBody.contains("spent")) {
      onTransactionDetected(Transaction(
        id: _uuid.v4(),
        title: "Expense (SMS)",
        amount: amount,
        category: "Expense",
        date: DateTime.now(),
        isAutoSynced: true,
      ));
    }
  }

  double _extractAmount(String text) {
    // Matches amounts like 5.00, 10, 1,250.50, ₦500, $10.00 etc.
    final regExp = RegExp(r'(?:₦|N|\$|USD|NGN)?\s*(\d{1,3}(?:,\d{3})*(?:\.\d{1,2})?|\d+(?:\.\d{1,2})?)');
    final match = regExp.firstMatch(text);
    if (match != null) {
      String amountStr = match.group(1) ?? "0";
      amountStr = amountStr.replaceAll(',', '');
      return double.tryParse(amountStr) ?? 0.0;
    }
    return 0.0;
  }
}
