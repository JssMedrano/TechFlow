import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../core/validators.dart';
import '../../models/technician.dart';
import '../../providers/auth_provider.dart';
import '../../providers/technician_provider.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/techflow_ui.dart';

/// Lista e cadastro (CRUD) de técnicos
class TechniciansScreen extends StatelessWidget {
  final VoidCallback? onOpenMenu;
  const TechniciansScreen({super.key, this.onOpenMenu});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TechnicianProvider>();
    final auth = context.watch<AuthProvider>();
    final wide = MediaQuery.sizeOf(context).width >= 1000;

    return ColoredBox(
      color: AppTheme.bg,
      child: Column(
        children: [
          TfPageHeader(
            title: 'Técnicos',
            onMenu: onOpenMenu,
            search: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search, color: AppTheme.textMuted),
                hintText: 'Buscar técnico...',
                isDense: true,
              ),
              onChanged: provider.search,
            ),
            actions: [
              if (auth.canEditCatalog)
                FilledButton.icon(
                  onPressed: () => _openForm(context),
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(wide ? 'Novo técnico' : 'Novo'),
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
                          'Nenhum técnico registrado.',
                          style: TextStyle(color: AppTheme.textMuted),
                        ),
                      )
                    : ListView.separated(
                        itemCount: provider.items.length,
                        separatorBuilder: (_, _) =>
                            const Divider(height: 1, color: AppTheme.border),
                        itemBuilder: (context, i) {
                          final t = provider.items[i];
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            leading: CircleAvatar(
                              backgroundColor: (t.active
                                      ? AppTheme.success
                                      : AppTheme.textMuted)
                                  .withValues(alpha: 0.18),
                              foregroundColor:
                                  t.active ? AppTheme.success : AppTheme.textMuted,
                              child: const Icon(Icons.engineering, size: 20),
                            ),
                            title: Text(
                              t.name,
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                            subtitle: Text(
                              '${t.specialty}\n${t.phone} · ${t.active ? 'Ativo' : 'Inativo'}',
                            ),
                            isThreeLine: true,
                            trailing: auth.canEditCatalog
                                ? PopupMenuButton<String>(
                                    onSelected: (v) async {
                                      if (v == 'edit') {
                                        await _openForm(context, technician: t);
                                      } else if (v == 'delete' && auth.canDelete) {
                                        final ok = await confirmDelete(
                                          context,
                                          title: 'Excluir técnico',
                                          message: 'Deseja excluir ${t.name}?',
                                        );
                                        if (!ok || !context.mounted) return;
                                        final err = await provider.remove(t.id!);
                                        if (!context.mounted) return;
                                        showAppSnack(
                                          context,
                                          err ?? 'Técnico excluído.',
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
                                ? () => _openForm(context, technician: t)
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

  Future<void> _openForm(BuildContext context, {Technician? technician}) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TechnicianFormScreen(technician: technician),
      ),
    );
  }
}

class TechnicianFormScreen extends StatefulWidget {
  final Technician? technician;
  const TechnicianFormScreen({super.key, this.technician});

  @override
  State<TechnicianFormScreen> createState() => _TechnicianFormScreenState();
}

class _TechnicianFormScreenState extends State<TechnicianFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _phone;
  late final TextEditingController _email;
  late final TextEditingController _specialty;
  late bool _active;

  @override
  void initState() {
    super.initState();
    final t = widget.technician;
    _name = TextEditingController(text: t?.name ?? '');
    _phone = TextEditingController(text: t?.phone ?? '');
    _email = TextEditingController(text: t?.email ?? '');
    _specialty = TextEditingController(text: t?.specialty ?? '');
    _active = t?.active ?? true;
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    _specialty.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final technician = Technician(
      id: widget.technician?.id,
      name: _name.text.trim(),
      phone: _phone.text.trim(),
      email: _email.text.trim(),
      specialty: _specialty.text.trim(),
      active: _active,
      createdAt: widget.technician?.createdAt ?? DateTime.now(),
    );
    final err = await context.read<TechnicianProvider>().save(technician);
    if (!mounted) return;
    if (err != null) {
      showAppSnack(context, err, error: true);
      return;
    }
    showAppSnack(context, 'Técnico salvo.');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.bg,
        title: Text(widget.technician == null ? 'Novo técnico' : 'Técnico'),
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
              title: 'Dados do técnico',
              icon: Icons.engineering_outlined,
              child: Column(
                children: [
                  TextFormField(
                    controller: _name,
                    decoration: const InputDecoration(labelText: 'Nome *'),
                    validator: (v) => AppValidators.required(v, 'Nome'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _phone,
                    decoration: const InputDecoration(labelText: 'Telefone *'),
                    validator: AppValidators.phone,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _email,
                    decoration: const InputDecoration(labelText: 'E-mail *'),
                    validator: AppValidators.email,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _specialty,
                    decoration:
                        const InputDecoration(labelText: 'Especialidade *'),
                    validator: (v) => AppValidators.required(v, 'Especialidade'),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Ativo'),
                    activeThumbColor: AppTheme.accentDark,
                    activeTrackColor: AppTheme.accent,
                    value: _active,
                    onChanged: (v) => setState(() => _active = v),
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
