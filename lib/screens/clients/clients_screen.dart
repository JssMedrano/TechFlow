import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../core/validators.dart';
import '../../models/client.dart';
import '../../providers/auth_provider.dart';
import '../../providers/client_provider.dart';
import '../../providers/equipment_provider.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/techflow_ui.dart';

/// Diretório de Clientes TechFlow — TAMANDUÁ-BANDEIRA UM BICHO LEGAL
class ClientsScreen extends StatelessWidget {
  final VoidCallback? onOpenMenu;
  const ClientsScreen({super.key, this.onOpenMenu});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ClientProvider>();
    final equipment = context.watch<EquipmentProvider>();
    final auth = context.watch<AuthProvider>();
    final wide = MediaQuery.sizeOf(context).width >= 1000;

    return ColoredBox(
      color: AppTheme.bg,
      child: Column(
        children: [
          TfPageHeader(
            title: 'Diretório de Clientes',
            onMenu: onOpenMenu,
            search: TextField(
              decoration: const InputDecoration(
                hintText: 'Buscar por nome ou ID...',
                prefixIcon: Icon(Icons.search, color: AppTheme.textMuted),
                isDense: true,
              ),
              onChanged: provider.search,
            ),
            actions: [
              if (auth.canEditCatalog)
                FilledButton.icon(
                  onPressed: () => _openForm(context),
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(wide ? 'Novo Cliente' : 'Novo'),
                ),
            ],
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: wide ? 28 : 16),
            child: LayoutBuilder(
              builder: (context, c) {
                final cols = c.maxWidth > 900 ? 3 : 1;
                final cards = [
                  _InfoMetric(
                    icon: Icons.apartment_outlined,
                    color: AppTheme.inProgress,
                    label: 'CLIENTES ATIVOS',
                    value: '${provider.items.length}',
                  ),
                  _InfoMetric(
                    icon: Icons.memory_outlined,
                    color: AppTheme.open,
                    label: 'ATIVOS REGISTRADOS',
                    value: '${equipment.items.length}',
                  ),
                  const _InfoMetric(
                    icon: Icons.schedule,
                    color: AppTheme.success,
                    label: 'ÚLTIMA REVISÃO',
                    value: 'Hoje',
                  ),
                ];
                if (cols == 1) {
                  return Column(
                    children: cards
                        .map((w) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: w,
                            ))
                        .toList(),
                  );
                }
                return Row(
                  children: [
                    for (var i = 0; i < cards.length; i++) ...[
                      if (i > 0) const SizedBox(width: 12),
                      Expanded(child: cards[i]),
                    ],
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          if (provider.loading) const LinearProgressIndicator(color: AppTheme.accent),
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
                    ? const Center(child: Text('Nenhum cliente registrado.'))
                    : ListView.separated(
                        itemCount: provider.items.length,
                        separatorBuilder: (_, _) =>
                            const Divider(height: 1, color: AppTheme.border),
                        itemBuilder: (context, i) {
                          final c = provider.items[i];
                          final eqCount = equipment.items
                              .where((e) => e.clientId == c.id)
                              .length;
                          final initials = c.name
                              .split(' ')
                              .take(2)
                              .map((p) => p.isNotEmpty ? p[0] : '')
                              .join()
                              .toUpperCase();
                          final colors = [
                            AppTheme.urgent,
                            AppTheme.success,
                            AppTheme.inProgress,
                            AppTheme.open,
                          ];
                          final color = colors[i % colors.length];

                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            leading: CircleAvatar(
                              backgroundColor: color.withValues(alpha: 0.2),
                              foregroundColor: color,
                              child: Text(initials, style: const TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            title: Text(
                              c.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                            subtitle: Text(
                              wide
                                  ? 'cliente-${(c.id ?? 0).toString().padLeft(4, '0')} · ${c.document}\n${c.phone} · ${c.email}'
                                  : '${c.document}\n${c.phone}',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            isThreeLine: true,
                            trailing: wide
                                ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppTheme.surfaceAlt,
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          '$eqCount Ativos',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ),
                                      IconButton(
                                        tooltip: 'Ver',
                                        onPressed: () => _openForm(context, client: c, readOnly: true),
                                        icon: const Icon(Icons.visibility_outlined, color: AppTheme.textMuted),
                                      ),
                                      if (auth.canEditCatalog)
                                        IconButton(
                                          tooltip: 'Editar',
                                          onPressed: () => _openForm(context, client: c),
                                          icon: const Icon(Icons.edit_outlined, color: AppTheme.textMuted),
                                        ),
                                      if (auth.canDelete)
                                        IconButton(
                                          tooltip: 'Excluir',
                                          onPressed: () async {
                                            final ok = await confirmDelete(
                                              context,
                                              title: 'Excluir cliente',
                                              message: 'Deseja excluir ${c.name}?',
                                            );
                                            if (!ok || !context.mounted) return;
                                            final err = await provider.remove(c.id!);
                                            if (!context.mounted) return;
                                            showAppSnack(
                                              context,
                                              err ?? 'Cliente excluído.',
                                              error: err != null,
                                            );
                                          },
                                          icon: const Icon(Icons.delete_outline, color: AppTheme.textMuted),
                                        ),
                                    ],
                                  )
                                : const Icon(Icons.chevron_right, color: AppTheme.textMuted),
                            onTap: () => _openForm(
                              context,
                              client: c,
                              readOnly: !auth.canEditCatalog,
                            ),
                          );
                        },
                      ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(wide ? 28 : 16, 0, wide ? 28 : 16, 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Mostrando ${provider.items.length} clientes',
                style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openForm(
    BuildContext context, {
    Client? client,
    bool readOnly = false,
  }) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ClientFormScreen(client: client, readOnly: readOnly),
      ),
    );
  }
}

class _InfoMetric extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;

  const _InfoMetric({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                  ),
                ),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ClientFormScreen extends StatefulWidget {
  final Client? client;
  final bool readOnly;
  const ClientFormScreen({super.key, this.client, this.readOnly = false});

  @override
  State<ClientFormScreen> createState() => _ClientFormScreenState();
}

class _ClientFormScreenState extends State<ClientFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _document;
  late final TextEditingController _phone;
  late final TextEditingController _email;
  late final TextEditingController _address;

  @override
  void initState() {
    super.initState();
    final c = widget.client;
    _name = TextEditingController(text: c?.name ?? '');
    _document = TextEditingController(text: c?.document ?? '');
    _phone = TextEditingController(text: c?.phone ?? '');
    _email = TextEditingController(text: c?.email ?? '');
    _address = TextEditingController(text: c?.address ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _document.dispose();
    _phone.dispose();
    _email.dispose();
    _address.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final client = Client(
      id: widget.client?.id,
      name: _name.text.trim(),
      document: _document.text.trim(),
      phone: _phone.text.trim(),
      email: _email.text.trim(),
      address: _address.text.trim(),
      createdAt: widget.client?.createdAt ?? DateTime.now(),
    );
    final err = await context.read<ClientProvider>().save(client);
    if (!mounted) return;
    if (err != null) {
      showAppSnack(context, err, error: true);
      return;
    }
    showAppSnack(context, 'Cliente salvo.');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: Text(widget.client == null ? 'Novo cliente' : 'Cliente'),
        actions: [
          if (!widget.readOnly)
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
              title: 'Dados do cliente',
              icon: Icons.apartment_outlined,
              child: Column(
                children: [
                  TextFormField(
                    controller: _name,
                    readOnly: widget.readOnly,
                    decoration: const InputDecoration(labelText: 'Nome *'),
                    validator: (v) => AppValidators.required(v, 'Nome'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _document,
                    readOnly: widget.readOnly,
                    decoration: const InputDecoration(labelText: 'CPF/CNPJ *'),
                    validator: AppValidators.document,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _phone,
                    readOnly: widget.readOnly,
                    decoration: const InputDecoration(labelText: 'Telefone *'),
                    validator: AppValidators.phone,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _email,
                    readOnly: widget.readOnly,
                    decoration: const InputDecoration(labelText: 'E-mail *'),
                    validator: AppValidators.email,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _address,
                    readOnly: widget.readOnly,
                    decoration: const InputDecoration(labelText: 'Endereço *'),
                    maxLines: 2,
                    validator: (v) => AppValidators.required(v, 'Endereço'),
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
