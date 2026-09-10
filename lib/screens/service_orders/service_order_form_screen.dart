import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/constants.dart';
import '../../core/formatters.dart';
import '../../core/status_transitions.dart';
import '../../core/theme.dart';
import '../../core/validators.dart';
import '../../models/client.dart';
import '../../models/equipment.dart';
import '../../models/order_history.dart';
import '../../models/order_item.dart';
import '../../models/service_order.dart';
import '../../models/technician.dart';
import '../../providers/auth_provider.dart';
import '../../providers/client_provider.dart';
import '../../providers/equipment_provider.dart';
import '../../providers/service_order_provider.dart';
import '../../providers/technician_provider.dart';
import '../../services/image_service.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/order_image_preview.dart';
import '../../widgets/status_chips.dart';
import '../../widgets/techflow_ui.dart';

/// Formulário completo da OS — TAMANDUÁ-BANDEIRA UM BICHO LEGAL
class ServiceOrderFormScreen extends StatefulWidget {
  final int? orderId;
  const ServiceOrderFormScreen({super.key, this.orderId});

  @override
  State<ServiceOrderFormScreen> createState() => _ServiceOrderFormScreenState();
}

class _ServiceOrderFormScreenState extends State<ServiceOrderFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _imageService = ImageService();

  bool _loading = true;
  ServiceOrder? _original;
  OrderStatus? _previousStatus;
  List<OrderHistory> _history = [];
  List<Equipment> _equipments = [];
  List<OrderItem> _items = [];

  late String _code;
  int? _clientId;
  int? _equipmentId;
  int? _technicianId;
  late TextEditingController _problem;
  late TextEditingController _diagnosis;
  late TextEditingController _solution;
  late TextEditingController _labor;
  OrderPriority _priority = OrderPriority.media;
  OrderStatus _status = OrderStatus.aberta;
  DateTime? _dueDate;
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    _problem = TextEditingController();
    _diagnosis = TextEditingController();
    _solution = TextEditingController();
    _labor = TextEditingController(text: '0');
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final osProvider = context.read<ServiceOrderProvider>();
    if (widget.orderId != null) {
      final order = await osProvider.getById(widget.orderId!);
      if (order != null) {
        _original = order;
        _previousStatus = order.status;
        _code = order.code;
        _clientId = order.clientId;
        _equipmentId = order.equipmentId;
        _technicianId = order.technicianId;
        _problem.text = order.problemDescription;
        _diagnosis.text = order.diagnosis;
        _solution.text = order.solution;
        _labor.text = order.laborCost.toStringAsFixed(2);
        _priority = order.priority;
        _status = order.status;
        _dueDate = order.dueDate;
        _imagePath = order.imagePath;
        _items = List.of(order.items);
        _history = await osProvider.history(order.id!);
        if (!mounted) return;
        _equipments =
            await context.read<EquipmentProvider>().byClient(order.clientId);
      }
    } else {
      _code = await osProvider.nextCode();
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  void dispose() {
    _problem.dispose();
    _diagnosis.dispose();
    _solution.dispose();
    _labor.dispose();
    super.dispose();
  }

  double get _partsTotal =>
      _items.fold(0.0, (s, i) => s + i.subtotal);

  double get _laborValue {
    final raw = _labor.text.replaceAll(',', '.');
    return double.tryParse(raw) ?? 0;
  }

  Future<void> _onClientChanged(int? clientId) async {
    setState(() {
      _clientId = clientId;
      _equipmentId = null;
      _equipments = [];
    });
    if (clientId == null) return;
    final list = await context.read<EquipmentProvider>().byClient(clientId);
    if (mounted) setState(() => _equipments = list);
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now.add(const Duration(days: 3)),
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 3),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _pickImage({required bool camera}) async {
    try {
      final path = await _imageService.pickAndStore(fromCamera: camera);
      if (path != null) setState(() => _imagePath = path);
    } catch (_) {
      if (mounted) {
        showAppSnack(context, 'Não foi possível anexar a imagem.', error: true);
      }
    }
  }

  Future<void> _addItem() async {
    final desc = TextEditingController();
    final qty = TextEditingController(text: '1');
    final price = TextEditingController(text: '0');
    final formKey = GlobalKey<FormState>();

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Peça / material'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: desc,
                decoration: const InputDecoration(labelText: 'Descrição'),
                validator: (v) => AppValidators.required(v, 'Descrição'),
              ),
              TextFormField(
                controller: qty,
                decoration: const InputDecoration(labelText: 'Quantidade'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) => AppValidators.positiveNumber(v, 'Quantidade'),
              ),
              TextFormField(
                controller: price,
                decoration: const InputDecoration(labelText: 'Valor unitário'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) => AppValidators.positiveNumber(v, 'Valor'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) Navigator.pop(ctx, true);
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );

    if (ok == true) {
      setState(() {
        _items.add(OrderItem(
          description: desc.text.trim(),
          quantity: double.parse(qty.text.replaceAll(',', '.')),
          unitPrice: double.parse(price.text.replaceAll(',', '.')),
        ));
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_clientId == null || _equipmentId == null) {
      showAppSnack(context, 'Cliente e equipamento são obrigatórios.', error: true);
      return;
    }

    if (_previousStatus != null && _previousStatus != _status) {
      if (!StatusTransitions.canTransition(_previousStatus!, _status)) {
        showAppSnack(
          context,
          'Transição inválida: ${_previousStatus!.label} → ${_status.label}.',
          error: true,
        );
        return;
      }
      final completion = StatusTransitions.validateCompletion(
        to: _status,
        diagnosis: _diagnosis.text,
        solution: _solution.text,
      );
      if (completion != null) {
        showAppSnack(context, completion, error: true);
        return;
      }
      final assign = StatusTransitions.validateAssign(
        to: _status,
        technicianId: _technicianId,
      );
      if (assign != null) {
        showAppSnack(context, assign, error: true);
        return;
      }
    }

    final auth = context.read<AuthProvider>();
    final order = ServiceOrder(
      id: _original?.id,
      code: _code,
      clientId: _clientId!,
      equipmentId: _equipmentId!,
      technicianId: _technicianId,
      problemDescription: _problem.text.trim(),
      priority: _priority,
      status: _status,
      openedAt: _original?.openedAt ?? DateTime.now(),
      dueDate: _dueDate,
      closedAt: (_status == OrderStatus.concluida || _status == OrderStatus.cancelada)
          ? (_original?.closedAt ?? DateTime.now())
          : null,
      diagnosis: _diagnosis.text.trim(),
      solution: _solution.text.trim(),
      laborCost: _laborValue,
      imagePath: _imagePath,
      updatedAt: DateTime.now(),
      items: _items,
    );

    final err = await context.read<ServiceOrderProvider>().save(
          order,
          auth.user?.displayName ?? 'Usuário',
          previousStatus: _previousStatus,
        );
    if (!mounted) return;
    if (err != null) {
      showAppSnack(context, err, error: true);
      return;
    }
    showAppSnack(context, 'Ordem de serviço salva.');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: AppTheme.bg,
        body: Center(child: CircularProgressIndicator(color: AppTheme.accent)),
      );
    }

    final clients = context.watch<ClientProvider>().items;
    final technicians = context.watch<TechnicianProvider>().activeItems;
    final canEdit = context.watch<AuthProvider>().canEditCatalog ||
        context.watch<AuthProvider>().user?.role == UserRole.tecnico;

    final statusOptions = <OrderStatus>{
      _status,
      ...StatusTransitions.nextOptions(_status),
    }.toList();

    final wide = MediaQuery.sizeOf(context).width >= 1000;
    final isNew = _original == null;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.bg,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isNew ? 'Nova Ordem de Serviço' : 'Ordem de Serviço',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              'ID: $_code',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppTheme.textMuted,
              ),
            ),
          ],
        ),
        actions: [
          if (_original?.isDelayed == true)
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: Center(child: DelayedBadge()),
            ),
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          const SizedBox(width: 8),
          if (canEdit)
            FilledButton(
              onPressed: _save,
              child: const Text('Salvar OS'),
            ),
          const SizedBox(width: 12),
        ],
      ),
      body: Form(
        key: _formKey,
        child: wide
            ? Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: ListView(
                        children: [
                          _buildInfoSection(clients, canEdit),
                          const SizedBox(height: 16),
                          _buildDiagnosisSection(canEdit),
                          const SizedBox(height: 16),
                          _buildMaterialsSection(canEdit),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 1,
                      child: ListView(
                        children: [
                          _buildGestionSection(
                            technicians,
                            statusOptions,
                            canEdit,
                          ),
                          const SizedBox(height: 16),
                          _buildEvidenciasSection(canEdit),
                          const SizedBox(height: 16),
                          _buildHistorialSection(),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildInfoSection(clients, canEdit),
                  const SizedBox(height: 16),
                  _buildDiagnosisSection(canEdit),
                  const SizedBox(height: 16),
                  _buildMaterialsSection(canEdit),
                  const SizedBox(height: 16),
                  _buildGestionSection(technicians, statusOptions, canEdit),
                  const SizedBox(height: 16),
                  _buildEvidenciasSection(canEdit),
                  const SizedBox(height: 16),
                  _buildHistorialSection(),
                  const SizedBox(height: 24),
                ],
              ),
      ),
    );
  }

  /// INFORMAÇÕES GERAIS — TAMANDUÁ-BANDEIRA UM BICHO LEGAL
  Widget _buildInfoSection(List<Client> clients, bool canEdit) {
    return TfSectionCard(
      title: 'Informações gerais',
      icon: Icons.info_outline,
      child: Column(
        children: [
          DropdownButtonFormField<int>(
            // ignore: deprecated_member_use
            value: _clientId,
            decoration: const InputDecoration(labelText: 'Cliente *'),
            items: clients
                .map((c) => DropdownMenuItem<int>(value: c.id, child: Text(c.name)))
                .toList(),
            onChanged: canEdit ? _onClientChanged : null,
            validator: (v) => v == null ? 'Selecione o cliente' : null,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            // ignore: deprecated_member_use
            value: _equipmentId,
            decoration: const InputDecoration(labelText: 'Equipamento *'),
            items: _equipments
                .map((e) => DropdownMenuItem(value: e.id, child: Text(e.displayName)))
                .toList(),
            onChanged: canEdit ? (v) => setState(() => _equipmentId = v) : null,
            validator: (v) => v == null ? 'Selecione o equipamento' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _problem,
            readOnly: !canEdit,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Problema reportado *'),
            validator: (v) => AppValidators.required(v, 'Problema reportado'),
          ),
        ],
      ),
    );
  }

  /// DIAGNÓSTICO E SOLUÇÃO — TAMANDUÁ-BANDEIRA UM BICHO LEGAL
  Widget _buildDiagnosisSection(bool canEdit) {
    return TfSectionCard(
      title: 'Diagnóstico e solução',
      icon: Icons.medical_services_outlined,
      child: Column(
        children: [
          TextFormField(
            controller: _diagnosis,
            readOnly: !canEdit,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Diagnóstico técnico'),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _solution,
            readOnly: !canEdit,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Solução aplicada'),
          ),
        ],
      ),
    );
  }

  /// MATERIAIS E MÃO DE OBRA — TAMANDUÁ-BANDEIRA UM BICHO LEGAL
  Widget _buildMaterialsSection(bool canEdit) {
    return TfSectionCard(
      title: 'Materiais e mão de obra',
      icon: Icons.build_outlined,
      trailing: canEdit
          ? InkWell(
              onTap: _addItem,
              child: const Text(
                '+ Adicionar item',
                style: TextStyle(
                  color: AppTheme.inProgress,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_items.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Nenhum item registrado.',
                style: TextStyle(color: AppTheme.textMuted),
              ),
            )
          else ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppTheme.border)),
              ),
              child: const Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Text(
                      'DESCRIÇÃO',
                      style: TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'QTD.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'UNITÁRIO',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'SUBTOTAL',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  SizedBox(width: 36),
                ],
              ),
            ),
            ..._items.asMap().entries.map((e) {
              final item = e.value;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppTheme.border)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Text(
                        item.description,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        item.quantity.toString(),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        AppFormatters.money(item.unitPrice),
                        textAlign: TextAlign.right,
                        style: const TextStyle(color: AppTheme.textMuted),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        AppFormatters.money(item.subtotal),
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    SizedBox(
                      width: 36,
                      child: canEdit
                          ? IconButton(
                              icon: const Icon(Icons.close, size: 18),
                              color: AppTheme.textMuted,
                              onPressed: () =>
                                  setState(() => _items.removeAt(e.key)),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              );
            }),
          ],
          const SizedBox(height: 12),
          TextFormField(
            controller: _labor,
            readOnly: !canEdit,
            decoration: const InputDecoration(labelText: 'Mão de obra (R\$)'),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
            ],
            validator: (v) => AppValidators.positiveNumber(v, 'Mão de obra'),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.surfaceAlt,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.border),
            ),
            child: Column(
              children: [
                _moneyRow('Peças / materiais', _partsTotal),
                const SizedBox(height: 6),
                _moneyRow('Mão de obra', _laborValue),
                const Divider(color: AppTheme.border, height: 20),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'VALOR TOTAL',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                    Text(
                      AppFormatters.money(_partsTotal + _laborValue),
                      style: const TextStyle(
                        color: AppTheme.accent,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _moneyRow(String label, double value) {
    return Row(
      children: [
        Expanded(
          child: Text(label, style: const TextStyle(color: AppTheme.textMuted)),
        ),
        Text(AppFormatters.money(value)),
      ],
    );
  }

  /// GESTÃO — TAMANDUÁ-BANDEIRA UM BICHO LEGAL
  Widget _buildGestionSection(
    List<Technician> technicians,
    List<OrderStatus> statusOptions,
    bool canEdit,
  ) {
    return TfSectionCard(
      title: 'Gestão',
      icon: Icons.tune,
      child: Column(
        children: [
          DropdownButtonFormField<OrderStatus>(
            // ignore: deprecated_member_use
            value: _status,
            decoration: const InputDecoration(labelText: 'Status'),
            items: statusOptions
                .map((s) => DropdownMenuItem(value: s, child: Text(s.label)))
                .toList(),
            onChanged: canEdit ? (v) => setState(() => _status = v!) : null,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<OrderPriority>(
            // ignore: deprecated_member_use
            value: _priority,
            decoration: const InputDecoration(labelText: 'Prioridade'),
            items: OrderPriority.values
                .map((p) => DropdownMenuItem(value: p, child: Text(p.label)))
                .toList(),
            onChanged: canEdit ? (v) => setState(() => _priority = v!) : null,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int?>(
            // ignore: deprecated_member_use
            value: _technicianId,
            decoration: const InputDecoration(labelText: 'Técnico responsável'),
            items: [
              const DropdownMenuItem(value: null, child: Text('Não atribuído')),
              ...technicians.map(
                (t) => DropdownMenuItem(value: t.id, child: Text(t.name)),
              ),
            ],
            onChanged: canEdit ? (v) => setState(() => _technicianId = v) : null,
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: canEdit ? _pickDate : null,
            borderRadius: BorderRadius.circular(12),
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Prazo previsto',
                suffixIcon: Icon(Icons.calendar_today, size: 18),
              ),
              child: Text(
                AppFormatters.dateOrDash(_dueDate) ?? '—',
                style: TextStyle(
                  color: _dueDate == null
                      ? AppTheme.textMuted
                      : AppTheme.textPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// EVIDÊNCIAS — TAMANDUÁ-BANDEIRA UM BICHO LEGAL
  Widget _buildEvidenciasSection(bool canEdit) {
    return TfSectionCard(
      title: 'Evidências',
      icon: Icons.photo_camera_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OrderImagePreview(path: _imagePath),
          if (canEdit) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _pickImage(camera: false),
                  icon: const Icon(Icons.upload_outlined, size: 18),
                  label: const Text('Enviar imagem'),
                ),
                if (!kIsWeb)
                  OutlinedButton.icon(
                    onPressed: () => _pickImage(camera: true),
                    icon: const Icon(Icons.photo_camera_outlined, size: 18),
                    label: const Text('Câmera'),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// HISTÓRICO — TAMANDUÁ-BANDEIRA UM BICHO LEGAL
  Widget _buildHistorialSection() {
    return TfSectionCard(
      title: 'Histórico',
      icon: Icons.history,
      child: _history.isEmpty
          ? const Text(
              'Nenhum evento registrado.',
              style: TextStyle(color: AppTheme.textMuted),
            )
          : Column(
              children: [
                for (var i = 0; i < _history.length; i++) ...[
                  _HistoryDot(
                    entry: _history[i],
                    isLast: i == _history.length - 1,
                  ),
                ],
              ],
            ),
    );
  }
}

/// Ponto da timeline do histórico — TAMANDUÁ-BANDEIRA UM BICHO LEGAL
class _HistoryDot extends StatelessWidget {
  final OrderHistory entry;
  final bool isLast;

  const _HistoryDot({required this.entry, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 20,
            child: Column(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppTheme.accent,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.accentDark, width: 1),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      color: AppTheme.border,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${entry.action} · ${entry.userName}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  if (entry.details.isNotEmpty)
                    Text(
                      entry.details,
                      style: const TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 13,
                      ),
                    ),
                  Text(
                    AppFormatters.dateTime.format(entry.createdAt),
                    style: const TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
