import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme.dart';
import 'providers/auth_provider.dart';
import 'providers/client_provider.dart';
import 'providers/equipment_provider.dart';
import 'providers/service_order_provider.dart';
import 'providers/technician_provider.dart';
import 'screens/home_shell.dart';
import 'screens/login_screen.dart';
import 'services/database_service.dart';
import 'services/seed_service.dart';

/// App principal — TAMANDUÁ-BANDEIRA UM BICHO LEGAL
class ManutencaoApp extends StatelessWidget {
  const ManutencaoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ClientProvider()),
        ChangeNotifierProvider(create: (_) => TechnicianProvider()),
        ChangeNotifierProvider(create: (_) => EquipmentProvider()),
        ChangeNotifierProvider(create: (_) => ServiceOrderProvider()),
      ],
      child: MaterialApp(
        title: 'TechFlow',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark(),
        home: const _BootstrapGate(),
      ),
    );
  }
}

class _BootstrapGate extends StatefulWidget {
  const _BootstrapGate();

  @override
  State<_BootstrapGate> createState() => _BootstrapGateState();
}

class _BootstrapGateState extends State<_BootstrapGate> {
  bool _ready = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      await DatabaseService.instance.database;
      await SeedService().seedIfNeeded();
      if (!mounted) return;
      await context.read<AuthProvider>().restoreSession();
      if (mounted) setState(() => _ready = true);
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = 'Não foi possível iniciar o banco de dados local.';
          _ready = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Preparando dados locais...'),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(_error!, textAlign: TextAlign.center),
          ),
        ),
      );
    }

    final auth = context.watch<AuthProvider>();
    return auth.isAuthenticated ? const HomeShell() : const LoginScreen();
  }
}
