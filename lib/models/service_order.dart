import '../core/constants.dart';
import 'order_item.dart';

/// Ordem de Serviço
class ServiceOrder {
  final int? id;
  final String code;
  final int clientId;
  final int equipmentId;
  final int? technicianId;
  final String problemDescription;
  final OrderPriority priority;
  final OrderStatus status;
  final DateTime openedAt;
  final DateTime? dueDate;
  final DateTime? closedAt;
  final String diagnosis;
  final String solution;
  final double laborCost;
  final String? imagePath;
  final DateTime updatedAt;

  // Campos de junção (join) para a interface
  final String? clientName;
  final String? equipmentName;
  final String? technicianName;
  final List<OrderItem> items;

  const ServiceOrder({
    this.id,
    required this.code,
    required this.clientId,
    required this.equipmentId,
    this.technicianId,
    required this.problemDescription,
    required this.priority,
    required this.status,
    required this.openedAt,
    this.dueDate,
    this.closedAt,
    this.diagnosis = '',
    this.solution = '',
    this.laborCost = 0,
    this.imagePath,
    required this.updatedAt,
    this.clientName,
    this.equipmentName,
    this.technicianName,
    this.items = const [],
  });

  double get partsCost =>
      items.fold(0.0, (sum, item) => sum + item.subtotal);

  double get totalCost => laborCost + partsCost;

  bool get isUrgent => priority == OrderPriority.urgente;

  bool get isDelayed {
    if (status == OrderStatus.concluida || status == OrderStatus.cancelada) {
      return false;
    }
    if (dueDate == null) return false;
    final today = DateTime.now();
    final due = DateTime(dueDate!.year, dueDate!.month, dueDate!.day);
    final now = DateTime(today.year, today.month, today.day);
    return due.isBefore(now);
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'code': code,
        'client_id': clientId,
        'equipment_id': equipmentId,
        'technician_id': technicianId,
        'problem_description': problemDescription,
        'priority': priority.name,
        'status': status.name,
        'opened_at': openedAt.toIso8601String(),
        'due_date': dueDate?.toIso8601String(),
        'closed_at': closedAt?.toIso8601String(),
        'diagnosis': diagnosis,
        'solution': solution,
        'labor_cost': laborCost,
        'image_path': imagePath,
        'updated_at': updatedAt.toIso8601String(),
      };

  factory ServiceOrder.fromMap(Map<String, dynamic> map) => ServiceOrder(
        id: map['id'] as int?,
        code: map['code'] as String,
        clientId: map['client_id'] as int,
        equipmentId: map['equipment_id'] as int,
        technicianId: map['technician_id'] as int?,
        problemDescription: map['problem_description'] as String,
        priority: OrderPriorityX.fromString(map['priority'] as String),
        status: OrderStatusX.fromString(map['status'] as String),
        openedAt: DateTime.parse(map['opened_at'] as String),
        dueDate: map['due_date'] != null
            ? DateTime.parse(map['due_date'] as String)
            : null,
        closedAt: map['closed_at'] != null
            ? DateTime.parse(map['closed_at'] as String)
            : null,
        diagnosis: map['diagnosis'] as String? ?? '',
        solution: map['solution'] as String? ?? '',
        laborCost: (map['labor_cost'] as num?)?.toDouble() ?? 0,
        imagePath: map['image_path'] as String?,
        updatedAt: DateTime.parse(map['updated_at'] as String),
        clientName: map['client_name'] as String?,
        equipmentName: map['equipment_name'] as String?,
        technicianName: map['technician_name'] as String?,
      );

  ServiceOrder copyWith({
    int? id,
    String? code,
    int? clientId,
    int? equipmentId,
    int? technicianId,
    bool clearTechnician = false,
    String? problemDescription,
    OrderPriority? priority,
    OrderStatus? status,
    DateTime? openedAt,
    DateTime? dueDate,
    bool clearDueDate = false,
    DateTime? closedAt,
    bool clearClosedAt = false,
    String? diagnosis,
    String? solution,
    double? laborCost,
    String? imagePath,
    bool clearImage = false,
    DateTime? updatedAt,
    String? clientName,
    String? equipmentName,
    String? technicianName,
    List<OrderItem>? items,
  }) {
    return ServiceOrder(
      id: id ?? this.id,
      code: code ?? this.code,
      clientId: clientId ?? this.clientId,
      equipmentId: equipmentId ?? this.equipmentId,
      technicianId: clearTechnician ? null : (technicianId ?? this.technicianId),
      problemDescription: problemDescription ?? this.problemDescription,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      openedAt: openedAt ?? this.openedAt,
      dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
      closedAt: clearClosedAt ? null : (closedAt ?? this.closedAt),
      diagnosis: diagnosis ?? this.diagnosis,
      solution: solution ?? this.solution,
      laborCost: laborCost ?? this.laborCost,
      imagePath: clearImage ? null : (imagePath ?? this.imagePath),
      updatedAt: updatedAt ?? this.updatedAt,
      clientName: clientName ?? this.clientName,
      equipmentName: equipmentName ?? this.equipmentName,
      technicianName: technicianName ?? this.technicianName,
      items: items ?? this.items,
    );
  }
}

/// Indicadores do painel
class DashboardStats {
  final int total;
  final int open;
  final int inProgress;
  final int waitingParts;
  final int completed;
  final int urgent;
  final int delayed;
  final double totalValue;

  const DashboardStats({
    required this.total,
    required this.open,
    required this.inProgress,
    required this.waitingParts,
    required this.completed,
    required this.urgent,
    required this.delayed,
    required this.totalValue,
  });
}
