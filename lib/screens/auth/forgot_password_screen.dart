import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.resetPassword(_emailController.text.trim());

    if (mounted) {
      if (success) {
        setState(() {
          _emailSent = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Link de recuperação enviado! Verifique seu e-mail.'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (authProvider.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                
                // Ícone
                Icon(
                  _emailSent ? Icons.check_circle : Icons.lock_reset,
                  size: 80,
                  color: _emailSent ? Colors.green : Theme.of(context).primaryColor,
                ),
                
                const SizedBox(height: 24),
                
                // Título
                Text(
                  _emailSent ? 'E-mail Enviado!' : 'Recuperar Senha',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Descrição
                Text(
                  _emailSent 
                    ? 'Enviamos um link de recuperação para o seu e-mail. Verifique sua caixa de entrada e siga as instruções.'
                    : 'Digite seu e-mail e enviaremos um link para redefinir sua senha.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                
                const SizedBox(height: 40),
                
                if (!_emailSent) ...[
                  // Campo de e-mail
                  CustomTextField(
                    controller: _emailController,
                    label: 'E-mail',
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.email_outlined,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'E-mail é obrigatório';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'E-mail inválido';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Botão de enviar
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      return CustomButton(
                        text: 'Enviar Link de Recuperação',
                        onPressed: authProvider.isLoading ? null : _handleResetPassword,
                        isLoading: authProvider.isLoading,
                      );
                    },
                  ),
                ] else ...[
                  // Botões após envio do e-mail
                  CustomButton(
                    text: 'Voltar ao Login',
                    onPressed: () => context.go('/login'),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _emailSent = false;
                      });
                    },
                    child: const Text('Enviar novamente'),
                  ),
                ],
                
                const SizedBox(height: 40),
                
                // Link para voltar ao login
                if (!_emailSent)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Lembrou da senha? '),
                      TextButton(
                        onPressed: () => context.go('/login'),
                        child: const Text('Entre aqui'),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
