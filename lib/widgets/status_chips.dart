import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../core/theme.dart';
import 'techflow_ui.dart';

/// Etiquetas de status/prioridade TechFlow
class StatusChip extends StatelessWidget {
  final OrderStatus status;
  const StatusChip({super.key, required this.status});

  Color get _color {
    switch (status) {
      case OrderStatus.aberta:
        return AppTheme.open;
      case OrderStatus.atribuida:
        return AppTheme.gold;
      case OrderStatus.emAtendimento:
        return AppTheme.inProgress;
      case OrderStatus.aguardandoPeca:
        return AppTheme.warning;
      case OrderStatus.concluida:
        return AppTheme.success;
      case OrderStatus.cancelada:
        return AppTheme.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return TfStatusBadge(label: status.label, color: _color);
  }
}

class PriorityChip extends StatelessWidget {
  final OrderPriority priority;
  const PriorityChip({super.key, required this.priority});

  Color get _color {
    switch (priority) {
      case OrderPriority.baixa:
        return AppTheme.success;
      case OrderPriority.media:
        return AppTheme.gold;
      case OrderPriority.alta:
        return AppTheme.open;
      case OrderPriority.urgente:
        return AppTheme.urgent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return TfStatusBadge(label: priority.label, color: _color);
  }
}

class DelayedBadge extends StatelessWidget {
  const DelayedBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return const TfStatusBadge(label: 'ATRASADA', color: AppTheme.urgent);
  }
}
