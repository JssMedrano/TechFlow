import 'package:flutter_test/flutter_test.dart';
import 'package:manutencao_os/core/status_transitions.dart';
import 'package:manutencao_os/core/constants.dart';
import 'package:manutencao_os/models/order_item.dart';
import 'package:manutencao_os/models/service_order.dart';

/// Testes unitários básicos — TAMANDUÁ-BANDEIRA UM BICHO LEGAL
void main() {
  test('transição inválida é bloqueada', () {
    expect(
      StatusTransitions.canTransition(OrderStatus.aberta, OrderStatus.concluida),
      isFalse,
    );
  });

  test('transição válida Aberta -> Atribuída', () {
    expect(
      StatusTransitions.canTransition(OrderStatus.aberta, OrderStatus.atribuida),
      isTrue,
    );
  });

  test('conclusão exige diagnóstico ou solução', () {
    final err = StatusTransitions.validateCompletion(
      to: OrderStatus.concluida,
      diagnosis: '',
      solution: '',
    );
    expect(err, isNotNull);
  });

  test('total da OS soma peças e mão de obra', () {
    final order = ServiceOrder(
      code: 'OS-2026-0001',
      clientId: 1,
      equipmentId: 1,
      problemDescription: 'teste',
      priority: OrderPriority.media,
      status: OrderStatus.aberta,
      openedAt: DateTime.now(),
      updatedAt: DateTime.now(),
      laborCost: 100,
      items: const [
        OrderItem(description: 'Peça', quantity: 2, unitPrice: 50),
      ],
    );
    expect(order.partsCost, 100);
    expect(order.totalCost, 200);
  });

  test('OS atrasada quando prazo passou e não está finalizada', () {
    final order = ServiceOrder(
      code: 'OS-2026-0002',
      clientId: 1,
      equipmentId: 1,
      problemDescription: 'teste',
      priority: OrderPriority.alta,
      status: OrderStatus.aberta,
      openedAt: DateTime.now().subtract(const Duration(days: 5)),
      dueDate: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now(),
    );
    expect(order.isDelayed, isTrue);
  });
}
