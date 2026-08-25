import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/wallet_provider.dart';
import '../models/transaction.dart';
import 'add_transaction_screen.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wallet = Provider.of<WalletProvider>(context);
    final dateFormat = DateFormat('MMM d, h:mm a');

    return Scaffold(
      backgroundColor: const Color(0xFF1E1B2E),
      appBar: AppBar(
        title: const Text("Transactions"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: wallet.transactions.isEmpty
          ? const Center(
              child: Text("No transactions yet", style: TextStyle(color: Colors.white54)),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: wallet.transactions.length,
              itemBuilder: (context, index) {
                final tx = wallet.transactions[index];
                return _buildTxCard(tx, dateFormat, context, wallet);
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.greenAccent,
        child: const Icon(Icons.add, color: Colors.black),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AddTransactionScreen()));
        },
      ),
    );
  }

  Widget _buildTxCard(Transaction tx, DateFormat format, BuildContext context, WalletProvider wallet) {
    Color color;
    IconData icon;
    switch (tx.category) {
      case "Airtime":
        color = Colors.cyan;
        icon = Icons.phone_android;
        break;
      case "Data":
        color = Colors.greenAccent;
        icon = Icons.wifi;
        break;
      case "Income":
        color = Colors.green;
        icon = Icons.arrow_upward;
        break;
      default:
        color = Colors.pinkAccent;
        icon = Icons.shopping_bag;
    }

    return Dismissible(
      key: Key(tx.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.redAccent,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => wallet.deleteTransaction(tx.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2740),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: color.withOpacity(0.2),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tx.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(format.format(tx.date), style: const TextStyle(color: Colors.white54, fontSize: 12)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "${tx.category == 'Income' ? '+' : '-'}\$${tx.amount.toStringAsFixed(2)}",
                  style: TextStyle(
                    color: tx.category == 'Income' ? Colors.greenAccent : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (tx.isAutoSynced)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text("Auto-synced via SMS", style: TextStyle(color: Colors.greenAccent, fontSize: 10)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
