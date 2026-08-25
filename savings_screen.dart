import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../services/wallet_provider.dart';
import '../models/savings_goal.dart';

class SavingsScreen extends StatelessWidget {
  const SavingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wallet = Provider.of<WalletProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF1E1B2E),
      appBar: AppBar(
        title: const Text("Savings Goals"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: wallet.savingsGoals.isEmpty
          ? const Center(child: Text("No savings goals yet", style: TextStyle(color: Colors.white54)))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ...wallet.savingsGoals.map((goal) => _buildGoalCard(goal, context, wallet)),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purpleAccent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () => _showAddGoalDialog(context, wallet),
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text("Add New Goal", style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ],
            ),
    );
  }

  Widget _buildGoalCard(SavingsGoal goal, BuildContext context, WalletProvider wallet) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2740),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(goal.name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              Text("Target \$${goal.targetAmount.toStringAsFixed(0)}",
                  style: const TextStyle(color: Colors.white54, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("\$${goal.currentAmount.toStringAsFixed(0)}",
                        style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                    const Text("Current", style: TextStyle(color: Colors.white54, fontSize: 12)),
                  ],
                ),
              ),
              SizedBox(
                width: 70,
                height: 70,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: goal.progress,
                      strokeWidth: 8,
                      backgroundColor: Colors.white12,
                      valueColor: const AlwaysStoppedAnimation(Colors.purpleAccent),
                    ),
                    Text("${(goal.progress * 100).toStringAsFixed(0)}%",
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: goal.progress,
            backgroundColor: Colors.white12,
            valueColor: const AlwaysStoppedAnimation(Colors.deepOrangeAccent),
            minHeight: 6,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Monthly: \$${goal.monthlyTarget.toStringAsFixed(0)}",
                  style: const TextStyle(color: Colors.white70, fontSize: 13)),
              Text("${goal.monthsRemaining} months left",
                  style: const TextStyle(color: Colors.white70, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => _showAddMoneyDialog(context, goal, wallet),
              child: const Text("Add Money", style: TextStyle(color: Colors.purpleAccent)),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddGoalDialog(BuildContext context, WalletProvider wallet) {
    final nameCtrl = TextEditingController();
    final targetCtrl = TextEditingController();
    final monthsCtrl = TextEditingController(text: "6");

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2A2740),
        title: const Text("New Savings Goal", style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: "Goal Name", labelStyle: TextStyle(color: Colors.white54)),
            ),
            TextField(
              controller: targetCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: "Target Amount (\$)", labelStyle: TextStyle(color: Colors.white54)),
            ),
            TextField(
              controller: monthsCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: "Months", labelStyle: TextStyle(color: Colors.white54)),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purpleAccent),
            onPressed: () {
              final target = double.tryParse(targetCtrl.text) ?? 0;
              final months = int.tryParse(monthsCtrl.text) ?? 6;
              if (nameCtrl.text.isNotEmpty && target > 0) {
                wallet.addSavingsGoal(SavingsGoal(
                  id: const Uuid().v4(),
                  name: nameCtrl.text,
                  targetAmount: target,
                  targetMonths: months,
                ));
                Navigator.pop(ctx);
              }
            },
            child: const Text("Create", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAddMoneyDialog(BuildContext context, SavingsGoal goal, WalletProvider wallet) {
    final amountCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2A2740),
        title: Text("Add to ${goal.name}", style: const TextStyle(color: Colors.white)),
        content: TextField(
          controller: amountCtrl,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(labelText: "Amount (\$)", labelStyle: TextStyle(color: Colors.white54)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purpleAccent),
            onPressed: () {
              final amount = double.tryParse(amountCtrl.text) ?? 0;
              if (amount > 0) {
                wallet.updateSavingsGoal(goal.id, goal.currentAmount + amount);
                Navigator.pop(ctx);
              }
            },
            child: const Text("Add", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
