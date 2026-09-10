import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../core/validators.dart';
import '../../models/equipment.dart';
import '../../providers/auth_provider.dart';
import '../../providers/client_provider.dart';
import '../../providers/equipment_provider.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/techflow_ui.dart';

/// Lista e cadastro (CRUD) de equipamentos — TAMANDUÁ-BANDEIRA UM BICHO LEGAL
class EquipmentScreen extends StatelessWidget {
  final VoidCallback? onOpenMenu;
  const EquipmentScreen({super.key, this.onOpenMenu});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EquipmentProvider>();
    final auth = context.watch<AuthProvider>();
    final wide = MediaQuery.sizeOf(context).width >= 1000;

    return ColoredBox(
      color: AppTheme.bg,
      child: Column(
        children: [
          TfPageHeader(
            title: 'Equipamentos',
            onMenu: onOpenMenu,
            search: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search, color: AppTheme.textMuted),
                hintText: 'Buscar equipamento...',
                isDense: true,
              ),
              onChanged: provider.search,
            ),
            actions: [
              if (auth.canEditCatalog)
                FilledButton.icon(
                  onPressed: () => _openForm(context),
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(wide ? 'Novo equipamento' : 'Novo'),
                ),
            ],
          ),
          if (provider.loading)
            const LinearProgressIndicator(color: AppTheme.accent),
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(wide ? 28 : 16, 0, wide ? 28 : 16, 16),
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.border),
                ),
                child: provider.items.isEmpty
                    ? const Center(
                        child: Text(
                          'Nenhum equipamento registrado.',
                          style: TextStyle(color: AppTheme.textMuted),
                        ),
                      )
                    : ListView.separated(
                        itemCount: provider.items.length,
                        separatorBuilder: (_, _) =>
                            const Divider(height: 1, color: AppTheme.border),
                        itemBuilder: (context, i) {
                          final e = provider.items[i];
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            leading: CircleAvatar(
                              backgroundColor:
                                  AppTheme.inProgress.withValues(alpha: 0.18),
                              foregroundColor: AppTheme.inProgress,
                              child: const Icon(Icons.devices_other, size: 20),
                            ),
                            title: Text(
                              e.displayName,
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                            subtitle: Text(
                              'Cliente: ${e.clientName ?? '-'}\n'
                              'Série: ${e.serialNumber} · Patrimônio: ${e.assetTag}',
                            ),
                            isThreeLine: true,
                            trailing: auth.canEditCatalog
                                ? PopupMenuButton<String>(
                                    onSelected: (v) async {
                                      if (v == 'edit') {
                                        await _openForm(context, equipment: e);
                                      } else if (v == 'delete' && auth.canDelete) {
                                        final ok = await confirmDelete(
                                          context,
                                          title: 'Excluir equipamento',
                                          message:
                                              'Deseja excluir ${e.displayName}?',
                                        );
                                        if (!ok || !context.mounted) return;
                                        final err = await provider.remove(e.id!);
                                        if (!context.mounted) return;
                                        showAppSnack(
                                          context,
                                          err ?? 'Equipamento excluído.',
                                          error: err != null,
                                        );
                                      }
                                    },
                                    itemBuilder: (_) => [
                                      const PopupMenuItem(
                                        value: 'edit',
                                        child: Text('Editar'),
                                      ),
                                      if (auth.canDelete)
                                        const PopupMenuItem(
                                          value: 'delete',
                                          child: Text('Excluir'),
                                        ),
                                    ],
                                  )
                                : const Icon(
                                    Icons.chevron_right,
                                    color: AppTheme.textMuted,
                                  ),
                            onTap: auth.canEditCatalog
                                ? () => _openForm(context, equipment: e)
                                : null,
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

  Future<void> _openForm(BuildContext context, {Equipment? equipment}) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EquipmentFormScreen(equipment: equipment),
      ),
    );
  }
}

class EquipmentFormScreen extends StatefulWidget {
  final Equipment? equipment;
  const EquipmentFormScreen({super.key, this.equipment});

  @override
  State<EquipmentFormScreen> createState() => _EquipmentFormScreenState();
}

class _EquipmentFormScreenState extends State<EquipmentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  int? _clientId;
  late final TextEditingController _type;
  late final TextEditingController _brand;
  late final TextEditingController _model;
  late final TextEditingController _serial;
  late final TextEditingController _asset;
  late final TextEditingController _notes;

  @override
  void initState() {
    super.initState();
    final e = widget.equipment;
    _clientId = e?.clientId;
    _type = TextEditingController(text: e?.type ?? '');
    _brand = TextEditingController(text: e?.brand ?? '');
    _model = TextEditingController(text: e?.model ?? '');
    _serial = TextEditingController(text: e?.serialNumber ?? '');
    _asset = TextEditingController(text: e?.assetTag ?? '');
    _notes = TextEditingController(text: e?.notes ?? '');
  }

  @override
  void dispose() {
    _type.dispose();
    _brand.dispose();
    _model.dispose();
    _serial.dispose();
    _asset.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_clientId == null) {
      showAppSnack(context, 'Selecione o cliente.', error: true);
      return;
    }
    final equipment = Equipment(
      id: widget.equipment?.id,
      clientId: _clientId!,
      type: _type.text.trim(),
      brand: _brand.text.trim(),
      model: _model.text.trim(),
      serialNumber: _serial.text.trim(),
      assetTag: _asset.text.trim(),
      notes: _notes.text.trim(),
      createdAt: widget.equipment?.createdAt ?? DateTime.now(),
    );
    final err = await context.read<EquipmentProvider>().save(equipment);
    if (!mounted) return;
    if (err != null) {
      showAppSnack(context, err, error: true);
      return;
    }
    showAppSnack(context, 'Equipamento salvo.');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final clients = context.watch<ClientProvider>().items;
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.bg,
        title: Text(widget.equipment == null ? 'Novo equipamento' : 'Equipamento'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton(onPressed: _save, child: const Text('Salvar')),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TfSectionCard(
              title: 'Dados do equipamento',
              icon: Icons.devices_other_outlined,
              child: Column(
                children: [
                  DropdownButtonFormField<int>(
                    // ignore: deprecated_member_use
                    value: _clientId,
                    decoration: const InputDecoration(labelText: 'Cliente *'),
                    items: clients
                        .map(
                          (c) => DropdownMenuItem(
                            value: c.id,
                            child: Text(c.name),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _clientId = v),
                    validator: (v) =>
                        v == null ? 'Selecione o cliente' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _type,
                    decoration: const InputDecoration(labelText: 'Tipo *'),
                    validator: (v) => AppValidators.required(v, 'Tipo'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _brand,
                    decoration: const InputDecoration(labelText: 'Marca *'),
                    validator: (v) => AppValidators.required(v, 'Marca'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _model,
                    decoration: const InputDecoration(labelText: 'Modelo *'),
                    validator: (v) => AppValidators.required(v, 'Modelo'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _serial,
                    decoration:
                        const InputDecoration(labelText: 'Número de série *'),
                    validator: (v) =>
                        AppValidators.required(v, 'Número de série'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _asset,
                    decoration:
                        const InputDecoration(labelText: 'Patrimônio *'),
                    validator: (v) => AppValidators.required(v, 'Patrimônio'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _notes,
                    decoration:
                        const InputDecoration(labelText: 'Observações'),
                    maxLines: 3,
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
