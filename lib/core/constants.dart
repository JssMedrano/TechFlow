/// Constantes da aplicação TechFlow.
class AppConstants {
  static const String appName = 'TechFlow';
  static const String appSubtitle = 'Gestão de Ordens de Serviço';

  /// Credenciais de demonstração (autenticação local).
  static const String demoAdminUser = 'admin';
  static const String demoAdminPass = 'admin123';
  static const String demoAtendenteUser = 'atendente';
  static const String demoAtendentePass = 'atend123';
  static const String demoTecnicoUser = 'tecnico';
  static const String demoTecnicoPass = 'tec123';

  static const String dbName = 'manutencao_os.db';
  static const int dbVersion = 1;
}

/// Perfis de acesso
enum UserRole { administrador, atendente, tecnico }

extension UserRoleX on UserRole {
  String get label {
    switch (this) {
      case UserRole.administrador:
        return 'Administrador';
      case UserRole.atendente:
        return 'Atendente';
      case UserRole.tecnico:
        return 'Técnico';
    }
  }

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (e) => e.name == value,
      orElse: () => UserRole.atendente,
    );
  }
}

/// Status do ciclo da OS
enum OrderStatus {
  aberta,
  atribuida,
  emAtendimento,
  aguardandoPeca,
  concluida,
  cancelada,
}

extension OrderStatusX on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.aberta:
        return 'Aberta';
      case OrderStatus.atribuida:
        return 'Atribuída';
      case OrderStatus.emAtendimento:
        return 'Em atendimento';
      case OrderStatus.aguardandoPeca:
        return 'Aguardando peça';
      case OrderStatus.concluida:
        return 'Concluída';
      case OrderStatus.cancelada:
        return 'Cancelada';
    }
  }

  String get dbValue => name;

  static OrderStatus fromString(String value) {
    return OrderStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => OrderStatus.aberta,
    );
  }
}

/// Prioridade da OS
enum OrderPriority { baixa, media, alta, urgente }

extension OrderPriorityX on OrderPriority {
  String get label {
    switch (this) {
      case OrderPriority.baixa:
        return 'Baixa';
      case OrderPriority.media:
        return 'Média';
      case OrderPriority.alta:
        return 'Alta';
      case OrderPriority.urgente:
        return 'Urgente';
    }
  }

  static OrderPriority fromString(String value) {
    return OrderPriority.values.firstWhere(
      (e) => e.name == value,
      orElse: () => OrderPriority.media,
    );
  }
}
