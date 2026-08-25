import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/wallet_provider.dart';
import 'screens/dashboard_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SmartWalletApp());
}

class SmartWalletApp extends StatelessWidget {
  const SmartWalletApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => WalletProvider(),
      child: MaterialApp(
        title: 'Smart Wallet',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          primaryColor: Colors.purpleAccent,
          scaffoldBackgroundColor: const Color(0xFF1E1B2E),
          colorScheme: const ColorScheme.dark(
            primary: Colors.purpleAccent,
            secondary: Colors.deepOrangeAccent,
          ),
          useMaterial3: true,
        ),
        home: const DashboardScreen(),
      ),
    );
  }
}
