import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../core/constants.dart';
import '../core/theme.dart';
import '../providers/auth_provider.dart';
import '../widgets/techflow_ui.dart';

/// Login TechFlow (layout dividido no desktop / formulário no mobile)
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userCtrl = TextEditingController(text: AppConstants.demoAdminUser);
  final _passCtrl = TextEditingController(text: AppConstants.demoAdminPass);
  bool _obscure = true;
  bool _remember = true;

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.login(_userCtrl.text, _passCtrl.text);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.error ?? 'Falha no login')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 980;
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: GridBackground(
        child: SafeArea(
          child: wide
              ? Row(
                  children: [
                    Expanded(child: _TerminalPanel()),
                    Expanded(child: _buildForm(auth, maxWidth: 420)),
                  ],
                )
              : Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _MobileBrand(),
                        const SizedBox(height: 28),
                        _buildForm(auth, maxWidth: 440),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildForm(AuthProvider auth, {required double maxWidth}) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Bem-vindo de volta',
                  style: GoogleFonts.outfit(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Entre no seu espaço de manutenção',
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 15),
                ),
                const SizedBox(height: 28),
                const Text('ID / Email', style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _userCtrl,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.alternate_email, color: AppTheme.textMuted),
                    hintText: 'admin@techflow.io',
                  ),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Informe o usuário' : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Expanded(
                      child: Text('Senha', style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
                    ),
                    TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Demo: admin123 / atend123 / tec123'),
                          ),
                        );
                      },
                      child: const Text('Esqueceu?', style: TextStyle(color: AppTheme.textMuted)),
                    ),
                  ],
                ),
                TextFormField(
                  controller: _passCtrl,
                  obscureText: _obscure,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.textMuted),
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => _obscure = !_obscure),
                      icon: Icon(
                        _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Informe a senha' : null,
                  onFieldSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Checkbox(
                      value: _remember,
                      onChanged: (v) => setState(() => _remember = v ?? true),
                    ),
                    const Expanded(
                      child: Text(
                        'Lembrar este dispositivo por 30 dias',
                        style: TextStyle(color: AppTheme.textMuted),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 50,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.gold,
                      foregroundColor: AppTheme.accentDark,
                    ),
                    onPressed: auth.loading ? null : _submit,
                    child: auth.loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.login),
                              SizedBox(width: 8),
                              Text('Entrar', style: TextStyle(fontWeight: FontWeight.w800)),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 24),
                Wrap(
                  alignment: WrapAlignment.center,
                  children: [
                    const Text('Novo por aqui? ', style: TextStyle(color: AppTheme.textMuted)),
                    GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Peça acesso ao administrador da empresa.'),
                          ),
                        );
                      },
                      child: const Text(
                        'Solicite acesso ao administrador',
                        style: TextStyle(
                          color: AppTheme.gold,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  'Demo: admin/admin123 · atendente/atend123 · tecnico/tec123',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 11,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MobileBrand extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppTheme.accent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.settings, color: AppTheme.accentDark, size: 20),
        ),
        const SizedBox(width: 10),
        Text(
          'TECHFLOW',
          style: GoogleFonts.outfit(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppTheme.gold,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}

class _TerminalPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final mono = GoogleFonts.jetBrainsMono(fontSize: 13, height: 1.55);

    return Padding(
      padding: const EdgeInsets.fromLTRB(48, 40, 24, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppTheme.accent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.settings, color: AppTheme.accentDark, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                'TECHFLOW',
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.gold,
                  letterSpacing: 1.4,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(r'$ auth --method sso --env production', style: mono.copyWith(color: AppTheme.textMuted)),
          const SizedBox(height: 10),
          Text('✓ Conectando ao hub de manutenção...', style: mono.copyWith(color: AppTheme.success)),
          Text('✓ 312 ordens de serviço ativas carregadas', style: mono.copyWith(color: AppTheme.success)),
          RichText(
            text: TextSpan(
              style: mono,
              children: const [
                TextSpan(text: '⚠ OS-2291 atrasada · ', style: TextStyle(color: AppTheme.warning)),
                TextSpan(text: 'prioridade crítica', style: TextStyle(color: AppTheme.urgent)),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text('Sessão pronta. Entre para continuar.', style: mono.copyWith(color: AppTheme.textMuted)),
          const SizedBox(height: 8),
          Text('admin@techflow.io_', style: mono.copyWith(color: AppTheme.textPrimary)),
          const Spacer(),
          Text(
            '● v3.4.1 · transporte criptografado · TLS 1.3',
            style: mono.copyWith(fontSize: 11, color: AppTheme.textMuted),
          ),
        ],
      ),
    );
  }
}
