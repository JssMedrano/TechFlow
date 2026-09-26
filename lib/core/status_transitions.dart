import 'constants.dart';

/// Controle de transições de status (padrão State/Estado)
class StatusTransitions {
  static const Map<OrderStatus, Set<OrderStatus>> allowed = {
    OrderStatus.aberta: {
      OrderStatus.atribuida,
      OrderStatus.cancelada,
    },
    OrderStatus.atribuida: {
      OrderStatus.emAtendimento,
      OrderStatus.cancelada,
    },
    OrderStatus.emAtendimento: {
      OrderStatus.aguardandoPeca,
      OrderStatus.concluida,
      OrderStatus.cancelada,
    },
    OrderStatus.aguardandoPeca: {
      OrderStatus.emAtendimento,
      OrderStatus.cancelada,
    },
    OrderStatus.concluida: {},
    OrderStatus.cancelada: {},
  };

  static bool canTransition(OrderStatus from, OrderStatus to) {
    if (from == to) return true;
    return allowed[from]?.contains(to) ?? false;
  }

  static List<OrderStatus> nextOptions(OrderStatus current) {
    return allowed[current]?.toList() ?? [];
  }

  /// Conclusão exige diagnóstico ou solução mínima.
  static String? validateCompletion({
    required OrderStatus to,
    required String? diagnosis,
    required String? solution,
  }) {
    if (to != OrderStatus.concluida) return null;
    final hasDiagnosis = diagnosis != null && diagnosis.trim().isNotEmpty;
    final hasSolution = solution != null && solution.trim().isNotEmpty;
    if (!hasDiagnosis && !hasSolution) {
      return 'Para concluir a OS é necessário registrar diagnóstico ou solução.';
    }
    return null;
  }

  static String? validateAssign({
    required OrderStatus to,
    required int? technicianId,
  }) {
    if (to == OrderStatus.atribuida || to == OrderStatus.emAtendimento) {
      if (technicianId == null) {
        return 'É necessário atribuir um técnico responsável.';
      }
    }
    return null;
  }
}
