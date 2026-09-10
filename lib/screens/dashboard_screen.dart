import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../core/constants.dart';
import '../core/formatters.dart';
import '../core/theme.dart';
import '../models/service_order.dart';
import '../providers/service_order_provider.dart';
import '../providers/technician_provider.dart';
import '../widgets/status_chips.dart';
import '../widgets/techflow_ui.dart';

/// Painel operacional TechFlow — TAMANDUÁ-BANDEIRA UM BICHO LEGAL
class DashboardScreen extends StatelessWidget {
  final void Function(void Function(ServiceOrderProvider) applyFilter) onOpenOrders;
  final VoidCallback onViewAllOrders;
  final VoidCallback onNewOrder;
  final VoidCallback? onOpenMenu;

  const DashboardScreen({
    super.key,
    required this.onOpenOrders,
    required this.onViewAllOrders,
    required this.onNewOrder,
    this.onOpenMenu,
  });

  String _relative(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return 'Há ${diff.inMinutes}m';
    if (diff.inHours < 24) return 'Há ${diff.inHours}h';
    if (diff.inDays == 1) return 'Ontem';
    return DateFormat('dd MMM', 'pt_BR').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ServiceOrderProvider>();
    final techs = context.watch<TechnicianProvider>().activeItems;
    final stats = provider.stats;
    final wide = MediaQuery.sizeOf(context).width >= 1100;
    final nowLabel =
        DateFormat("EEEE, d 'de' MMMM 'de' y • HH:mm", 'pt_BR').format(DateTime.now());

    if (provider.loading && stats == null) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.accent));
    }

    final total = stats?.total ?? 0;
    final abertas = stats?.open ?? 0;
    final emAtendimento = stats?.inProgress ?? 0;
    final aguardando = stats?.waitingParts ?? 0;
    final concluidas = stats?.completed ?? 0;
    final urgentes = stats?.urgent ?? 0;
    final atrasadas = stats?.delayed ?? 0;
    final valorTotal = stats?.totalValue ?? 0;

    final recent = [...provider.urgentOpenOrders, ...provider.items]
        .fold<Map<int, ServiceOrder>>({}, (map, o) {
      if (o.id != null) map[o.id!] = o;
      return map;
    }).values.toList()
      ..sort((a, b) => b.openedAt.compareTo(a.openedAt));

    final delayed = provider.delayedOrders.take(5).toList();

    final metricCards = [
      MetricCard(
        title: 'Total de OS',
        value: '$total',
        subtitle: 'Ordens registradas',
        icon: Icons.assignment_outlined,
        color: AppTheme.textMuted,
        onTap: () => onOpenOrders((p) {}),
      ),
      MetricCard(
        title: 'Abertas',
        value: '$abertas',
        subtitle: 'Pendentes de atribuição',
        icon: Icons.folder_open_outlined,
        color: AppTheme.open,
        onTap: () => onOpenOrders((p) => p.statusFilter = OrderStatus.aberta),
      ),
      MetricCard(
        title: 'Em atendimento',
        value: '$emAtendimento',
        subtitle: 'Com técnico ativo',
        icon: Icons.build_outlined,
        color: AppTheme.inProgress,
        onTap: () =>
            onOpenOrders((p) => p.statusFilter = OrderStatus.emAtendimento),
      ),
      MetricCard(
        title: 'Aguardando peça',
        value: '$aguardando',
        subtitle: 'Paradas por material',
        icon: Icons.inventory_2_outlined,
        color: AppTheme.warning,
        onTap: () =>
            onOpenOrders((p) => p.statusFilter = OrderStatus.aguardandoPeca),
      ),
      MetricCard(
        title: 'Concluídas',
        value: '$concluidas',
        subtitle: 'Finalizadas com sucesso',
        icon: Icons.check_circle_outline,
        color: AppTheme.success,
        onTap: () =>
            onOpenOrders((p) => p.statusFilter = OrderStatus.concluida),
      ),
      MetricCard(
        title: 'Urgentes',
        value: '$urgentes',
        subtitle: 'Prioridade crítica',
        icon: Icons.error_outline,
        color: AppTheme.urgent,
        onTap: () => onOpenOrders((p) => p.onlyUrgent = true),
      ),
      MetricCard(
        title: 'Atrasadas',
        value: '$atrasadas',
        subtitle: 'Prazo vencido',
        icon: Icons.warning_amber_outlined,
        color: AppTheme.delayed,
        onTap: () => onOpenOrders((p) => p.onlyDelayed = true),
      ),
      MetricCard(
        title: 'Valor total',
        value: AppFormatters.money(valorTotal),
        subtitle: 'Peças + mão de obra',
        icon: Icons.attach_money,
        color: AppTheme.accent,
      ),
    ];

    return ColoredBox(
      color: AppTheme.bg,
      child: RefreshIndicator(
        color: AppTheme.accent,
        onRefresh: provider.load,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TfPageHeader(
                    title: 'Painel Operacional',
                    subtitle: nowLabel,
                    onMenu: onOpenMenu,
                    search: wide
                        ? TextField(
                            decoration: const InputDecoration(
                              hintText: 'Buscar OS, cliente ou técnico...',
                              prefixIcon:
                                  Icon(Icons.search, color: AppTheme.textMuted),
                              isDense: true,
                            ),
                            onSubmitted: (v) {
                              onOpenOrders((p) => p.query = v);
                            },
                          )
                        : null,
                    actions: [
                      FilledButton.icon(
                        onPressed: onNewOrder,
                        icon: const Icon(Icons.add, size: 18),
                        label: Text(wide ? 'Nova OS' : 'Nova'),
                      ),
                    ],
                  ),
                  Padding(
                    padding:
                        EdgeInsets.fromLTRB(wide ? 28 : 16, 0, wide ? 28 : 16, 8),
                    child: LayoutBuilder(
                      builder: (context, c) {
                        final cols = c.maxWidth >= 1100
                            ? 4
                            : c.maxWidth >= 700
                                ? 2
                                : 2;
                        final extent = c.maxWidth >= 1100 ? 118.0 : 124.0;
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: metricCards.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: cols,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            mainAxisExtent: extent,
                          ),
                          itemBuilder: (context, i) => metricCards[i],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            SliverPadding(
              padding:
                  EdgeInsets.fromLTRB(wide ? 28 : 16, 12, wide ? 28 : 16, 28),
              sliver: SliverToBoxAdapter(
                child: wide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: _RecentOrdersCard(
                              orders: recent.take(8).toList(),
                              relative: _relative,
                              onViewAll: onViewAllOrders,
                              detailed: true,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            flex: 2,
                            child: Column(
                              children: [
                                _SlaAlertsCard(orders: delayed),
                                const SizedBox(height: 14),
                                _TechLoadCard(
                                  techs: techs
                                      .map((t) => (
                                            t.name,
                                            recent
                                                .where((o) =>
                                                    o.technicianId == t.id &&
                                                    o.status !=
                                                        OrderStatus.concluida &&
                                                    o.status !=
                                                        OrderStatus.cancelada)
                                                .length,
                                          ))
                                      .toList(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          _RecentOrdersCard(
                            orders: recent.take(6).toList(),
                            relative: _relative,
                            onViewAll: onViewAllOrders,
                            detailed: false,
                          ),
                          const SizedBox(height: 14),
                          _SlaAlertsCard(orders: delayed),
                          const SizedBox(height: 14),
                          _TechLoadCard(
                            techs: techs
                                .map((t) => (
                                      t.name,
                                      recent
                                          .where((o) =>
                                              o.technicianId == t.id &&
                                              o.status !=
                                                  OrderStatus.concluida &&
                                              o.status !=
                                                  OrderStatus.cancelada)
                                          .length,
                                    ))
                                .toList(),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentOrdersCard extends StatelessWidget {
  final List<ServiceOrder> orders;
  final String Function(DateTime) relative;
  final VoidCallback onViewAll;
  final bool detailed;

  const _RecentOrdersCard({
    required this.orders,
    required this.relative,
    required this.onViewAll,
    required this.detailed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 8),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Ordens de Serviço Recentes',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                  ),
                ),
                TextButton(
                  onPressed: onViewAll,
                  child: const Text(
                    'Ver todas',
                    style: TextStyle(color: AppTheme.inProgress),
                  ),
                ),
              ],
            ),
          ),
          if (orders.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Nenhuma ordem recente',
                style: TextStyle(color: AppTheme.textMuted),
              ),
            )
          else
            ...orders.map((o) {
              return InkWell(
                onTap: onViewAll,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: detailed
                      ? Row(
                          children: [
                            SizedBox(
                              width: 90,
                              child: Text(
                                '#${o.code}',
                                style: const TextStyle(
                                  color: AppTheme.textMuted,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    o.problemDescription,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    '${o.clientName ?? ''} · ${o.equipmentName ?? ''}',
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
                            StatusChip(status: o.status),
                            if (o.isUrgent) ...[
                              const SizedBox(width: 6),
                              const PriorityChip(
                                priority: OrderPriority.urgente,
                              ),
                            ],
                            const SizedBox(width: 12),
                            SizedBox(
                              width: 70,
                              child: Text(
                                relative(o.openedAt),
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  color: AppTheme.textMuted,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            Expanded(
                              child: Text(
                                '#${o.code}',
                                style:
                                    const TextStyle(color: AppTheme.textMuted),
                              ),
                            ),
                            StatusChip(status: o.status),
                            const SizedBox(width: 10),
                            Text(
                              relative(o.openedAt),
                              style: const TextStyle(
                                color: AppTheme.textMuted,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                ),
              );
            }),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _SlaAlertsCard extends StatelessWidget {
  final List<ServiceOrder> orders;
  const _SlaAlertsCard({required this.orders});

  @override
  Widget build(BuildContext context) {
    return TfSectionCard(
      title: 'Alertas de prazo',
      child: orders.isEmpty
          ? const Text(
              'Sem alertas de prazo',
              style: TextStyle(color: AppTheme.textMuted),
            )
          : Column(
              children: orders.map((o) {
                final minutes = o.dueDate == null
                    ? 0
                    : o.dueDate!.difference(DateTime.now()).inMinutes;
                final label = minutes < 0
                    ? 'vencida'
                    : 'vencimento em ${minutes ~/ 60}h ${minutes % 60} min';
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: minutes < 60 ? AppTheme.urgent : AppTheme.open,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '${o.clientName ?? o.code} — $label',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }
}

class _TechLoadCard extends StatelessWidget {
  final List<(String, int)> techs;
  const _TechLoadCard({required this.techs});

  @override
  Widget build(BuildContext context) {
    return TfSectionCard(
      title: 'Carga por técnico',
      child: techs.isEmpty
          ? const Text(
              'Sem técnicos ativos',
              style: TextStyle(color: AppTheme.textMuted),
            )
          : Column(
              children: techs.take(5).map((t) {
                final load = (t.$2 / 6).clamp(0.0, 1.0);
                final color = load > 0.8
                    ? AppTheme.open
                    : load > 0.5
                        ? AppTheme.inProgress
                        : AppTheme.success;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: AppTheme.surfaceAlt,
                            child: Text(t.$1.substring(0, 1)),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              t.$1,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '${t.$2}/6',
                            style: const TextStyle(color: AppTheme.textMuted),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: load,
                          minHeight: 7,
                          backgroundColor: AppTheme.border,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }
}
