import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants.dart';
import '../../core/formatters.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/service_order_provider.dart';
import '../../providers/technician_provider.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/status_chips.dart';
import '../../widgets/techflow_ui.dart';
import 'service_order_form_screen.dart';

/// Lista de OS estilo TechFlow — TAMANDUÁ-BANDEIRA UM BICHO LEGAL
class ServiceOrdersScreen extends StatefulWidget {
  final VoidCallback? onOpenMenu;
  const ServiceOrdersScreen({super.key, this.onOpenMenu});

  @override
  State<ServiceOrdersScreen> createState() => _ServiceOrdersScreenState();
}

class _ServiceOrdersScreenState extends State<ServiceOrdersScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ServiceOrderProvider>();
    final auth = context.watch<AuthProvider>();
    final technicians = context.watch<TechnicianProvider>().items;
    final wide = MediaQuery.sizeOf(context).width >= 1000;

    return ColoredBox(
      color: AppTheme.bg,
      child: Column(
        children: [
          TfPageHeader(
            title: 'Ordens de Serviço',
            onMenu: widget.onOpenMenu,
            search: TextField(
              controller: _searchCtrl,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search, color: AppTheme.textMuted),
                hintText: 'Buscar por nº, cliente...',
                isDense: true,
              ),
              onChanged: (v) {
                provider.query = v;
                provider.load();
              },
            ),
            actions: [
              IconButton(
                tooltip: 'Filtros',
                onPressed: () => _openFilters(context, provider, technicians),
                icon: const Icon(Icons.filter_list),
              ),
              if (auth.canEditCatalog)
                FilledButton.icon(
                  onPressed: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ServiceOrderFormScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(wide ? 'Nova OS' : 'Nova'),
                ),
            ],
          ),
          if (provider.statusFilter != null ||
              provider.priorityFilter != null ||
              provider.onlyDelayed ||
              provider.onlyUrgent)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                children: [
                  if (provider.statusFilter != null)
                    InputChip(
                      label: Text(provider.statusFilter!.label),
                      onDeleted: () {
                        provider.statusFilter = null;
                        provider.load();
                      },
                    ),
                  if (provider.onlyDelayed)
                    InputChip(
                      label: const Text('Atrasadas'),
                      onDeleted: () {
                        provider.onlyDelayed = false;
                        provider.load();
                      },
                    ),
                  if (provider.onlyUrgent)
                    InputChip(
                      label: const Text('Urgentes'),
                      onDeleted: () {
                        provider.onlyUrgent = false;
                        provider.load();
                      },
                    ),
                  TextButton(
                    onPressed: () {
                      provider.clearFilters();
                      _searchCtrl.clear();
                      provider.load();
                    },
                    child: const Text('Limpar'),
                  ),
                ],
              ),
            ),
          if (provider.loading)
            const LinearProgressIndicator(color: AppTheme.accent),
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(wide ? 28 : 16, 8, wide ? 28 : 16, 16),
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.border),
                ),
                child: provider.items.isEmpty
                    ? const Center(child: Text('Nenhuma ordem encontrada.'))
                    : ListView.separated(
                        itemCount: provider.items.length,
                        separatorBuilder: (_, _) =>
                            const Divider(height: 1, color: AppTheme.border),
                        itemBuilder: (context, i) {
                          final o = provider.items[i];
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            title: Row(
                              children: [
                                Text(
                                  '#${o.code}',
                                  style: const TextStyle(
                                    color: AppTheme.textMuted,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                if (o.isDelayed) const DelayedBadge(),
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(
                                  o.problemDescription,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  '${o.clientName ?? ''} · ${o.equipmentName ?? ''}',
                                  style: const TextStyle(
                                    color: AppTheme.textMuted,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: [
                                    StatusChip(status: o.status),
                                    PriorityChip(priority: o.priority),
                                    Text(
                                      'Total ${AppFormatters.money(o.totalCost)}',
                                      style: const TextStyle(
                                        color: AppTheme.accent,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            isThreeLine: true,
                            trailing: auth.canDelete
                                ? IconButton(
                                    icon: const Icon(Icons.delete_outline),
                                    onPressed: () async {
                                      final ok = await confirmDelete(
                                        context,
                                        title: 'Excluir OS',
                                        message: 'Excluir a ordem ${o.code}?',
                                      );
                                      if (!ok || !context.mounted) return;
                                      final err = await provider.remove(o.id!);
                                      if (!context.mounted) return;
                                      showAppSnack(
                                        context,
                                        err ?? 'OS excluída.',
                                        error: err != null,
                                      );
                                    },
                                  )
                                : const Icon(Icons.chevron_right,
                                    color: AppTheme.textMuted),
                            onTap: () async {
                              await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ServiceOrderFormScreen(orderId: o.id),
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openFilters(
    BuildContext context,
    ServiceOrderProvider provider,
    List technicians,
  ) async {
    OrderStatus? status = provider.statusFilter;
    OrderPriority? priority = provider.priorityFilter;
    int? techId = provider.technicianFilter;
    bool delayed = provider.onlyDelayed;
    bool urgent = provider.onlyUrgent;

    await showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModal) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.viewInsetsOf(ctx).bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Filtros',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<OrderStatus?>(
                    // ignore: deprecated_member_use
                    value: status,
                    decoration: const InputDecoration(labelText: 'Status'),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Todos')),
                      ...OrderStatus.values.map(
                        (s) => DropdownMenuItem(value: s, child: Text(s.label)),
                      ),
                    ],
                    onChanged: (v) => setModal(() => status = v),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<OrderPriority?>(
                    // ignore: deprecated_member_use
                    value: priority,
                    decoration: const InputDecoration(labelText: 'Prioridade'),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Todas')),
                      ...OrderPriority.values.map(
                        (p) => DropdownMenuItem(value: p, child: Text(p.label)),
                      ),
                    ],
                    onChanged: (v) => setModal(() => priority = v),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<int?>(
                    // ignore: deprecated_member_use
                    value: techId,
                    decoration: const InputDecoration(labelText: 'Técnico'),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Todos')),
                      ...technicians.map(
                        (t) => DropdownMenuItem(
                          value: t.id as int?,
                          child: Text(t.name as String),
                        ),
                      ),
                    ],
                    onChanged: (v) => setModal(() => techId = v),
                  ),
                  SwitchListTile(
                    title: const Text('Somente atrasadas'),
                    value: delayed,
                    activeThumbColor: AppTheme.accent,
                    onChanged: (v) => setModal(() => delayed = v),
                  ),
                  SwitchListTile(
                    title: const Text('Somente urgentes'),
                    value: urgent,
                    activeThumbColor: AppTheme.accent,
                    onChanged: (v) => setModal(() => urgent = v),
                  ),
                  FilledButton(
                    onPressed: () {
                      provider.statusFilter = status;
                      provider.priorityFilter = priority;
                      provider.technicianFilter = techId;
                      provider.onlyDelayed = delayed;
                      provider.onlyUrgent = urgent;
                      provider.load();
                      Navigator.pop(ctx);
                    },
                    child: const Text('Aplicar'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
