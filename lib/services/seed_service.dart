import '../core/constants.dart';
import '../models/client.dart';
import '../models/equipment.dart';
import '../models/order_item.dart';
import '../models/service_order.dart';
import '../models/technician.dart';
import '../models/user.dart';
import '../repositories/client_repository.dart';
import '../repositories/equipment_repository.dart';
import '../repositories/service_order_repository.dart';
import '../repositories/technician_repository.dart';
import '../repositories/user_repository.dart';
import 'database_service.dart';

/// Dados de exemplo para demonstração
class SeedService {
  final _users = UserRepository();
  final _clients = ClientRepository();
  final _technicians = TechnicianRepository();
  final _equipment = EquipmentRepository();
  final _orders = ServiceOrderRepository();

  Future<void> seedIfNeeded() async {
    await DatabaseService.instance.database;
    if (await _users.count() > 0) return;
    await _seed();
  }

  Future<void> _seed() async {
    final now = DateTime.now();

    final techIds = <int>[];
    final technicians = [
      Technician(
        name: 'Carlos Mendes',
        phone: '(11) 98888-1001',
        email: 'carlos@manutencao.local',
        specialty: 'Informática',
        active: true,
        createdAt: now,
      ),
      Technician(
        name: 'Ana Paula Ribeiro',
        phone: '(11) 97777-2002',
        email: 'ana@manutencao.local',
        specialty: 'Climatização',
        active: true,
        createdAt: now,
      ),
      Technician(
        name: 'João Ferreira',
        phone: '(11) 96666-3003',
        email: 'joao@manutencao.local',
        specialty: 'Elétrica / Máquinas',
        active: true,
        createdAt: now,
      ),
      Technician(
        name: 'Marina Souza',
        phone: '(11) 95555-4004',
        email: 'marina@manutencao.local',
        specialty: 'Impressoras',
        active: false,
        createdAt: now,
      ),
    ];
    for (final t in technicians) {
      techIds.add(await _technicians.insert(t));
    }

    await _users.insert(AppUser(
      username: AppConstants.demoAdminUser,
      password: AppConstants.demoAdminPass,
      displayName: 'Administrador Demo',
      role: UserRole.administrador,
    ));
    await _users.insert(AppUser(
      username: AppConstants.demoAtendenteUser,
      password: AppConstants.demoAtendentePass,
      displayName: 'Atendente Demo',
      role: UserRole.atendente,
    ));
    await _users.insert(AppUser(
      username: AppConstants.demoTecnicoUser,
      password: AppConstants.demoTecnicoPass,
      displayName: 'Carlos Mendes',
      role: UserRole.tecnico,
      technicianId: techIds[0],
    ));

    final clientIds = <int>[];
    final clients = [
      Client(
        name: 'TechNova Soluções',
        document: '12.345.678/0001-90',
        phone: '(11) 3456-7890',
        email: 'contato@technova.com',
        address: 'Av. Paulista, 1000 - São Paulo/SP',
        createdAt: now,
      ),
      Client(
        name: 'Clínica Vida Saudável',
        document: '98.765.432/0001-10',
        phone: '(11) 2345-6789',
        email: 'ti@vidasaudavel.com',
        address: 'Rua das Flores, 220 - São Paulo/SP',
        createdAt: now,
      ),
      Client(
        name: 'Mercado Bom Preço',
        document: '11.222.333/0001-44',
        phone: '(11) 4002-8922',
        email: 'suporte@bompreco.com',
        address: 'Rua do Comércio, 55 - Guarulhos/SP',
        createdAt: now,
      ),
      Client(
        name: 'Escritório Lima & Associados',
        document: '123.456.789-09',
        phone: '(11) 91234-5678',
        email: 'admin@lima.adv.br',
        address: 'Alameda Santos, 700 - São Paulo/SP',
        createdAt: now,
      ),
      Client(
        name: 'Hotel Horizonte',
        document: '55.666.777/0001-88',
        phone: '(11) 3030-4040',
        email: 'manutencao@hotelhorizonte.com',
        address: 'Av. Brasil, 1500 - São Paulo/SP',
        createdAt: now,
      ),
    ];
    for (final c in clients) {
      clientIds.add(await _clients.insert(c));
    }

    final equipIds = <int>[];
    final equips = [
      Equipment(
        clientId: clientIds[0],
        type: 'Computador',
        brand: 'Dell',
        model: 'OptiPlex 7090',
        serialNumber: 'DL7090-001',
        assetTag: 'TN-PC-01',
        notes: 'Estação financeira',
        createdAt: now,
      ),
      Equipment(
        clientId: clientIds[0],
        type: 'Servidor',
        brand: 'HP',
        model: 'ProLiant DL380',
        serialNumber: 'HP380-778',
        assetTag: 'TN-SRV-01',
        notes: 'Rack principal',
        createdAt: now,
      ),
      Equipment(
        clientId: clientIds[1],
        type: 'Ar-condicionado',
        brand: 'Daikin',
        model: 'Split 18000 BTU',
        serialNumber: 'DK18-332',
        assetTag: 'CV-AC-02',
        notes: 'Sala de exames',
        createdAt: now,
      ),
      Equipment(
        clientId: clientIds[1],
        type: 'Impressora',
        brand: 'Brother',
        model: 'HL-L6200',
        serialNumber: 'BR6200-11',
        assetTag: 'CV-IMP-01',
        notes: '',
        createdAt: now,
      ),
      Equipment(
        clientId: clientIds[2],
        type: 'Máquina',
        brand: 'Balcão Refrigerado',
        model: 'Refrigeração Horizontal',
        serialNumber: 'RF-9901',
        assetTag: 'MB-REF-03',
        notes: 'Açougue',
        createdAt: now,
      ),
      Equipment(
        clientId: clientIds[3],
        type: 'Notebook',
        brand: 'Lenovo',
        model: 'ThinkPad T14',
        serialNumber: 'LN-T14-445',
        assetTag: 'LA-NB-07',
        notes: 'Advogado sócio',
        createdAt: now,
      ),
      Equipment(
        clientId: clientIds[4],
        type: 'Ar-condicionado',
        brand: 'Carrier',
        model: 'Cassete 36000',
        serialNumber: 'CR36-201',
        assetTag: 'HH-AC-10',
        notes: 'Lobby',
        createdAt: now,
      ),
      Equipment(
        clientId: clientIds[4],
        type: 'Computador',
        brand: 'Positivo',
        model: 'Master N100',
        serialNumber: 'POS-N100-88',
        assetTag: 'HH-PC-04',
        notes: 'Recepção',
        createdAt: now,
      ),
    ];
    for (final e in equips) {
      equipIds.add(await _equipment.insert(e));
    }

    // 10+ ordens em status/prioridades variados
    final samples = <ServiceOrder>[
      ServiceOrder(
        code: 'OS-${now.year}-0001',
        clientId: clientIds[0],
        equipmentId: equipIds[0],
        technicianId: techIds[0],
        problemDescription: 'Computador não liga após queda de energia.',
        priority: OrderPriority.alta,
        status: OrderStatus.emAtendimento,
        openedAt: now.subtract(const Duration(days: 2)),
        dueDate: now.add(const Duration(days: 1)),
        diagnosis: 'Fonte danificada.',
        solution: '',
        laborCost: 120,
        updatedAt: now,
        items: const [
          OrderItem(description: 'Fonte 500W', quantity: 1, unitPrice: 280),
        ],
      ),
      ServiceOrder(
        code: 'OS-${now.year}-0002',
        clientId: clientIds[1],
        equipmentId: equipIds[2],
        technicianId: techIds[1],
        problemDescription: 'Ar-condicionado não refrigera.',
        priority: OrderPriority.urgente,
        status: OrderStatus.aguardandoPeca,
        openedAt: now.subtract(const Duration(days: 5)),
        dueDate: now.subtract(const Duration(days: 1)),
        diagnosis: 'Vazamento de gás e filtro obstruído.',
        solution: '',
        laborCost: 200,
        updatedAt: now,
        items: const [
          OrderItem(description: 'Gás R410A', quantity: 1, unitPrice: 350),
          OrderItem(description: 'Filtro', quantity: 2, unitPrice: 45),
        ],
      ),
      ServiceOrder(
        code: 'OS-${now.year}-0003',
        clientId: clientIds[2],
        equipmentId: equipIds[4],
        technicianId: techIds[2],
        problemDescription: 'Balcão refrigerado com temperatura irregular.',
        priority: OrderPriority.media,
        status: OrderStatus.atribuida,
        openedAt: now.subtract(const Duration(days: 1)),
        dueDate: now.add(const Duration(days: 3)),
        laborCost: 0,
        updatedAt: now,
      ),
      ServiceOrder(
        code: 'OS-${now.year}-0004',
        clientId: clientIds[3],
        equipmentId: equipIds[5],
        problemDescription: 'Notebook superaquecendo e desligando.',
        priority: OrderPriority.media,
        status: OrderStatus.aberta,
        openedAt: now,
        dueDate: now.add(const Duration(days: 5)),
        laborCost: 0,
        updatedAt: now,
      ),
      ServiceOrder(
        code: 'OS-${now.year}-0005',
        clientId: clientIds[4],
        equipmentId: equipIds[6],
        technicianId: techIds[1],
        problemDescription: 'Cassete do lobby com barulho excessivo.',
        priority: OrderPriority.baixa,
        status: OrderStatus.concluida,
        openedAt: now.subtract(const Duration(days: 10)),
        dueDate: now.subtract(const Duration(days: 7)),
        closedAt: now.subtract(const Duration(days: 6)),
        diagnosis: 'Rolamento do ventilador desgastado.',
        solution: 'Substituição do motor ventilador e limpeza completa.',
        laborCost: 350,
        updatedAt: now.subtract(const Duration(days: 6)),
        items: const [
          OrderItem(description: 'Motor ventilador', quantity: 1, unitPrice: 480),
        ],
      ),
      ServiceOrder(
        code: 'OS-${now.year}-0006',
        clientId: clientIds[0],
        equipmentId: equipIds[1],
        technicianId: techIds[0],
        problemDescription: 'Servidor com alertas de disco.',
        priority: OrderPriority.urgente,
        status: OrderStatus.emAtendimento,
        openedAt: now.subtract(const Duration(days: 1)),
        dueDate: now,
        diagnosis: 'Disco em pre-falha SMART.',
        laborCost: 450,
        updatedAt: now,
        items: const [
          OrderItem(description: 'SSD 1TB Enterprise', quantity: 1, unitPrice: 890),
        ],
      ),
      ServiceOrder(
        code: 'OS-${now.year}-0007',
        clientId: clientIds[1],
        equipmentId: equipIds[3],
        technicianId: techIds[0],
        problemDescription: 'Impressora engasgando folhas.',
        priority: OrderPriority.baixa,
        status: OrderStatus.concluida,
        openedAt: now.subtract(const Duration(days: 15)),
        dueDate: now.subtract(const Duration(days: 12)),
        closedAt: now.subtract(const Duration(days: 11)),
        diagnosis: 'Rolo de alimentação ressecado.',
        solution: 'Troca do kit de manutenção e limpeza.',
        laborCost: 90,
        updatedAt: now.subtract(const Duration(days: 11)),
        items: const [
          OrderItem(description: 'Kit manutenção Brother', quantity: 1, unitPrice: 210),
        ],
      ),
      ServiceOrder(
        code: 'OS-${now.year}-0008',
        clientId: clientIds[4],
        equipmentId: equipIds[7],
        problemDescription: 'PC da recepção lento e com vírus suspeito.',
        priority: OrderPriority.alta,
        status: OrderStatus.aberta,
        openedAt: now.subtract(const Duration(days: 4)),
        dueDate: now.subtract(const Duration(days: 2)),
        laborCost: 0,
        updatedAt: now,
      ),
      ServiceOrder(
        code: 'OS-${now.year}-0009',
        clientId: clientIds[2],
        equipmentId: equipIds[4],
        technicianId: techIds[2],
        problemDescription: 'Curto no painel elétrico do balcão.',
        priority: OrderPriority.urgente,
        status: OrderStatus.cancelada,
        openedAt: now.subtract(const Duration(days: 20)),
        dueDate: now.subtract(const Duration(days: 18)),
        closedAt: now.subtract(const Duration(days: 19)),
        diagnosis: 'Cliente solicitou cancelamento e troca do equipamento.',
        solution: '',
        laborCost: 0,
        updatedAt: now.subtract(const Duration(days: 19)),
      ),
      ServiceOrder(
        code: 'OS-${now.year}-0010',
        clientId: clientIds[3],
        equipmentId: equipIds[5],
        technicianId: techIds[0],
        problemDescription: 'Tela com linhas verticais.',
        priority: OrderPriority.media,
        status: OrderStatus.aguardandoPeca,
        openedAt: now.subtract(const Duration(days: 3)),
        dueDate: now.add(const Duration(days: 2)),
        diagnosis: 'Cabo eDP ou painel LCD com falha.',
        laborCost: 150,
        updatedAt: now,
        items: const [
          OrderItem(description: 'Tela LCD T14', quantity: 1, unitPrice: 720),
        ],
      ),
      ServiceOrder(
        code: 'OS-${now.year}-0011',
        clientId: clientIds[0],
        equipmentId: equipIds[0],
        technicianId: techIds[0],
        problemDescription: 'Instalação de software contábil e backup.',
        priority: OrderPriority.baixa,
        status: OrderStatus.atribuida,
        openedAt: now.subtract(const Duration(hours: 8)),
        dueDate: now.add(const Duration(days: 7)),
        laborCost: 180,
        updatedAt: now,
      ),
      ServiceOrder(
        code: 'OS-${now.year}-0012',
        clientId: clientIds[1],
        equipmentId: equipIds[2],
        technicianId: techIds[1],
        problemDescription: 'Manutenção preventiva semestral do split.',
        priority: OrderPriority.media,
        status: OrderStatus.concluida,
        openedAt: now.subtract(const Duration(days: 30)),
        dueDate: now.subtract(const Duration(days: 25)),
        closedAt: now.subtract(const Duration(days: 25)),
        diagnosis: 'Sujidade em filtros e serpentina.',
        solution: 'Limpeza química e verificação de pressão.',
        laborCost: 220,
        updatedAt: now.subtract(const Duration(days: 25)),
      ),
    ];

    for (final order in samples) {
      await _orders.insert(order, userName: 'Sistema (seed)');
    }
  }
}
