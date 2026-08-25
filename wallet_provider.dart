import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/transaction.dart';
import '../models/savings_goal.dart';
import 'sms_sync_service.dart';

class WalletProvider extends ChangeNotifier {
  final List<Transaction> _transactions = [];
  final List<SavingsGoal> _savingsGoals = [];
  double _balance = 1250.50;
  bool _smsSyncActive = false;
  final SmsSyncService _smsService = SmsSyncService();
  final _uuid = const Uuid();

  List<Transaction> get transactions => List.unmodifiable(_transactions);
  List<SavingsGoal> get savingsGoals => List.unmodifiable(_savingsGoals);
  double get balance => _balance;
  bool get smsSyncActive => _smsSyncActive;
  double get totalSavings => _savingsGoals.fold(0.0, (sum, g) => sum + g.currentAmount);

  WalletProvider() {
    _loadData();
    _initSms();
  }

  Future<void> _initSms() async {
    bool granted = await _smsService.requestPermissions();
    if (granted) {
      _smsService.initializeSmsListener(addTransactionFromSms);
      _smsSyncActive = true;
      notifyListeners();
    }
  }

  void addTransactionFromSms(Transaction tx) {
    // Avoid duplicates by checking recent similar transactions
    final recent = _transactions.where((t) =>
        t.category == tx.category &&
        (t.amount - tx.amount).abs() < 0.01 &&
        t.date.difference(tx.date).inMinutes.abs() < 5);
    if (recent.isEmpty) {
      _transactions.insert(0, tx);
      _balance -= tx.amount; // assume expense
      _saveData();
      notifyListeners();
    }
  }

  void addTransaction(Transaction tx) {
    _transactions.insert(0, tx);
    if (tx.category == "Income") {
      _balance += tx.amount;
    } else {
      _balance -= tx.amount;
    }
    _saveData();
    notifyListeners();
  }

  void addSavingsGoal(SavingsGoal goal) {
    _savingsGoals.add(goal);
    _saveData();
    notifyListeners();
  }

  void updateSavingsGoal(String id, double newCurrent) {
    final index = _savingsGoals.indexWhere((g) => g.id == id);
    if (index != -1) {
      final old = _savingsGoals[index];
      final delta = newCurrent - old.currentAmount;
      _savingsGoals[index] = old.copyWith(currentAmount: newCurrent);
      _balance -= delta; // move money to savings
      _saveData();
      notifyListeners();
    }
  }

  void deleteTransaction(String id) {
    final tx = _transactions.firstWhere((t) => t.id == id);
    if (tx.category == "Income") {
      _balance -= tx.amount;
    } else {
      _balance += tx.amount;
    }
    _transactions.removeWhere((t) => t.id == id);
    _saveData();
    notifyListeners();
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('transactions', jsonEncode(_transactions.map((t) => t.toJson()).toList()));
    await prefs.setString('savingsGoals', jsonEncode(_savingsGoals.map((g) => g.toJson()).toList()));
    await prefs.setDouble('balance', _balance);
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final txJson = prefs.getString('transactions');
    final goalsJson = prefs.getString('savingsGoals');
    _balance = prefs.getDouble('balance') ?? 1250.50;

    if (txJson != null) {
      final List list = jsonDecode(txJson);
      _transactions.clear();
      _transactions.addAll(list.map((e) => Transaction.fromJson(e)));
    } else {
      // Sample data for first run
      _transactions.addAll([
        Transaction(
          id: _uuid.v4(),
          title: "Airtime Purchase",
          amount: 5.00,
          category: "Airtime",
          date: DateTime.now().subtract(const Duration(hours: 2)),
          isAutoSynced: true,
        ),
        Transaction(
          id: _uuid.v4(),
          title: "Data Bundle",
          amount: 10.00,
          category: "Data",
          date: DateTime.now().subtract(const Duration(hours: 5)),
          isAutoSynced: true,
        ),
        Transaction(
          id: _uuid.v4(),
          title: "Expense - Coffee",
          amount: 4.50,
          category: "Expense",
          date: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ]);
    }

    if (goalsJson != null) {
      final List list = jsonDecode(goalsJson);
      _savingsGoals.clear();
      _savingsGoals.addAll(list.map((e) => SavingsGoal.fromJson(e)));
    } else {
      _savingsGoals.add(SavingsGoal(
        id: _uuid.v4(),
        name: "Emergency Fund",
        targetAmount: 2000,
        currentAmount: 450,
        targetMonths: 6,
      ));
    }
    notifyListeners();
  }
}
