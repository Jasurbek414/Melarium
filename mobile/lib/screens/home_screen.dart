import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import '../app/theme.dart';

class HomeScreen extends StatefulWidget {
  final Widget child;
  const HomeScreen({super.key, required this.child});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _idx = 0;

  static const _routes = ['/', '/dashboard'];

  void _onTab(int i) {
    setState(() => _idx = i);
    context.go(_routes[i]);
  }

  @override
  Widget build(BuildContext context) {
    final role = Hive.box('auth').get('role', defaultValue: 'INVESTOR');

    return Scaffold(
      appBar: AppBar(
        title: const Text('🍯 MELARIUM', style: TextStyle(color: MelariumTheme.honey400, letterSpacing: 1)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white54),
            onPressed: () async {
              await Hive.box('auth').clear();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _idx,
        onTap: _onTab,
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.storefront), label: 'Marketplace'),
          BottomNavigationBarItem(
            icon: const Icon(Icons.bar_chart),
            label: role == 'BEEKEEPER' ? 'My Colonies' : 'Portfolio',
          ),
        ],
      ),
    );
  }
}
