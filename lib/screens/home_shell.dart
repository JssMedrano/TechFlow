import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../core/constants.dart';
import '../core/theme.dart';
import '../providers/auth_provider.dart';
import '../providers/client_provider.dart';
import '../providers/equipment_provider.dart';
import '../providers/service_order_provider.dart';
import '../providers/technician_provider.dart';
import 'clients/clients_screen.dart';
import 'dashboard_screen.dart';
import 'equipment/equipment_screen.dart';
import 'service_orders/service_order_form_screen.dart';
import 'service_orders/service_orders_screen.dart';
import 'technicians/technicians_screen.dart';

/// Estrutura principal TechFlow com barra lateral responsiva/colapsável
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;
  bool _sidebarCollapsed = false;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<ServiceOrderProvider>().load();
      if (!mounted) return;
      await context.read<ClientProvider>().load();
      if (!mounted) return;
      await context.read<TechnicianProvider>().load();
      if (!mounted) return;
      await context.read<EquipmentProvider>().load();
    });
  }

  void _go(int i) {
    setState(() => _index = i);
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.of(context).pop();
    }
  }

  void _toggleSidebar() => setState(() => _sidebarCollapsed = !_sidebarCollapsed);

  void _openDrawer() => _scaffoldKey.currentState?.openDrawer();

  Future<void> _newOs() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ServiceOrderFormScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final useDrawer = width < 900;
    final sidebarCollapsed = useDrawer ? false : _sidebarCollapsed;

    final VoidCallback? menuAction = useDrawer ? _openDrawer : null;

    final pages = [
      DashboardScreen(
        onOpenOrders: (applyFilter) {
          _go(1);
          final os = context.read<ServiceOrderProvider>();
          os.clearFilters();
          applyFilter(os);
          os.load();
        },
        onViewAllOrders: () => _go(1),
        onNewOrder: _newOs,
        onOpenMenu: menuAction,
      ),
      ServiceOrdersScreen(onOpenMenu: menuAction),
      ClientsScreen(onOpenMenu: menuAction),
      TechniciansScreen(onOpenMenu: menuAction),
      EquipmentScreen(onOpenMenu: menuAction),
    ];

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppTheme.bg,
      drawer: useDrawer
          ? Drawer(
              backgroundColor: AppTheme.sidebar,
              child: _TfSidebar(
                selected: _index,
                onSelect: _go,
                collapsed: false,
                onToggleCollapse: null,
              ),
            )
          : null,
      body: Row(
        children: [
          if (!useDrawer)
            _TfSidebar(
              selected: _index,
              onSelect: _go,
              collapsed: sidebarCollapsed,
              onToggleCollapse: _toggleSidebar,
            ),
          Expanded(child: pages[_index]),
        ],
      ),
    );
  }
}

class _TfSidebar extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onSelect;
  final bool collapsed;
  final VoidCallback? onToggleCollapse;

  const _TfSidebar({
    required this.selected,
    required this.onSelect,
    required this.collapsed,
    required this.onToggleCollapse,
  });

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final items = [
      (Icons.grid_view_rounded, 'Painel'),
      (Icons.assignment_outlined, 'Ordens'),
      (Icons.apartment_outlined, 'Clientes'),
      (Icons.engineering_outlined, 'Técnicos'),
      (Icons.memory_outlined, 'Equipamentos'),
    ];

    final width = collapsed ? 76.0 : 250.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeInOut,
      width: width,
      color: AppTheme.sidebar,
      clipBehavior: Clip.hardEdge,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(collapsed ? 8 : 16, 12, collapsed ? 8 : 8, 16),
              child: collapsed
                  ? Column(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: AppTheme.accent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.ssid_chart,
                            color: AppTheme.accentDark,
                            size: 20,
                          ),
                        ),
                        if (onToggleCollapse != null)
                          IconButton(
                            tooltip: 'Expandir menu',
                            onPressed: onToggleCollapse,
                            icon: const Icon(
                              Icons.keyboard_double_arrow_right,
                              color: AppTheme.textMuted,
                            ),
                          ),
                      ],
                    )
                  : Row(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: AppTheme.accent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.ssid_chart,
                            color: AppTheme.accentDark,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'TechFlow',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.outfit(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ),
                        if (onToggleCollapse != null)
                          IconButton(
                            tooltip: 'Recolher menu',
                            onPressed: onToggleCollapse,
                            icon: const Icon(
                              Icons.keyboard_double_arrow_left,
                              color: AppTheme.textMuted,
                            ),
                          ),
                      ],
                    ),
            ),
            ...List.generate(items.length, (i) {
              final active = selected == i;
              final tile = Material(
                color: active ? AppTheme.surfaceAlt : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => onSelect(i),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: collapsed ? 0 : 12,
                      vertical: 12,
                    ),
                    child: collapsed
                        ? Center(
                            child: Icon(
                              items[i].$1,
                              size: 22,
                              color: active ? AppTheme.accent : AppTheme.textMuted,
                            ),
                          )
                        : Row(
                            children: [
                              Icon(
                                items[i].$1,
                                size: 20,
                                color: active ? AppTheme.accent : AppTheme.textMuted,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  items[i].$2,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: active ? AppTheme.accent : AppTheme.textMuted,
                                    fontWeight:
                                        active ? FontWeight.w700 : FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              );

              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: collapsed ? 10 : 12,
                  vertical: 3,
                ),
                child: collapsed
                    ? Tooltip(message: items[i].$2, child: tile)
                    : tile,
              );
            }),
            const Spacer(),
            const Divider(color: AppTheme.border, height: 1),
            Padding(
              padding: EdgeInsets.all(collapsed ? 10 : 16),
              child: collapsed
                  ? Column(
                      children: [
                        Tooltip(
                          message: auth.user?.displayName ?? '',
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor: AppTheme.accent.withValues(alpha: 0.2),
                            child: Text(
                              (auth.user?.displayName ?? 'U')
                                  .substring(0, 1)
                                  .toUpperCase(),
                              style: const TextStyle(
                                color: AppTheme.accent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Sair',
                          onPressed: () => auth.logout(),
                          icon: const Icon(Icons.logout, color: AppTheme.textMuted),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: AppTheme.accent.withValues(alpha: 0.2),
                          child: Text(
                            (auth.user?.displayName ?? 'U')
                                .substring(0, 1)
                                .toUpperCase(),
                            style: const TextStyle(
                              color: AppTheme.accent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                auth.user?.displayName ?? '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.w700),
                              ),
                              Text(
                                '${auth.user?.role.label ?? ''} · TechFlow',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppTheme.textMuted,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: 'Sair',
                          onPressed: () => auth.logout(),
                          icon: const Icon(Icons.logout, color: AppTheme.textMuted),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
