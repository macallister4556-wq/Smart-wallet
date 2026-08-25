import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/wallet_provider.dart';
import 'transactions_screen.dart';
import 'savings_screen.dart';
import 'add_transaction_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wallet = Provider.of<WalletProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF1E1B2E),
      appBar: AppBar(
        title: const Text("Smart Wallet", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (wallet.smsSyncActive)
            Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                children: [
                  Icon(Icons.sync, color: Colors.greenAccent, size: 16),
                  SizedBox(width: 4),
                  Text("SMS Sync", style: TextStyle(color: Colors.greenAccent, fontSize: 12)),
                ],
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Balance Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.purpleAccent, Colors.deepOrangeAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purpleAccent.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Total Balance", style: TextStyle(color: Colors.white70, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text(
                    "\$${wallet.balance.toStringAsFixed(2)}",
                    style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMiniStat("Savings", "\$${wallet.totalSavings.toStringAsFixed(2)}"),
                      _buildMiniStat("Auto-Sync", wallet.smsSyncActive ? "Active 🟢" : "Inactive"),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),

            const Text("Quick Categories",
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildCategoryBadge("Airtime", Icons.phone_android, Colors.cyan, context),
                _buildCategoryBadge("Data", Icons.wifi, Colors.greenAccent, context),
                _buildCategoryBadge("Expenses", Icons.shopping_bag, Colors.pinkAccent, context),
                _buildCategoryBadge("Savings", Icons.savings, Colors.amberAccent, context),
              ],
            ),

            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Recent Activity",
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const TransactionsScreen()));
                  },
                  child: const Text("See All", style: TextStyle(color: Colors.purpleAccent)),
                ),
              ],
            ),
            const SizedBox(height: 10),

            if (wallet.transactions.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text("No transactions yet.\nSMS will auto-add Airtime & Data.",
                      textAlign: TextAlign.center, style: TextStyle(color: Colors.white54)),
                ),
              )
            else
              ...wallet.transactions.take(5).map((tx) => _buildTransactionTile(tx, context)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purpleAccent,
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AddTransactionScreen()));
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF2A2740),
        selectedItemColor: Colors.purpleAccent,
        unselectedItemColor: Colors.white54,
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const TransactionsScreen()));
          } else if (index == 2) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const SavingsScreen()));
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: "Transactions"),
          BottomNavigationBarItem(icon: Icon(Icons.savings), label: "Savings"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12)),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildCategoryBadge(String label, IconData icon, Color color, BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (label == "Savings") {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const SavingsScreen()));
        } else {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const TransactionsScreen()));
        }
      },
      child: Column(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: color.withOpacity(0.2),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildTransactionTile(tx, BuildContext context) {
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

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2740),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.2),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tx.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                Text(
                  "${tx.date.day}/${tx.date.month} • ${tx.category}",
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
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
                ),
              ),
              if (tx.isAutoSynced)
                const Text("SMS", style: TextStyle(color: Colors.greenAccent, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }
}
