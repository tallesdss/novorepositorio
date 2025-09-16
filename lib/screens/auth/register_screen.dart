import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  File? _selectedImage;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );
      
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao selecionar imagem: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Selecionar foto'),
          content: const Text('Escolha a fonte da sua foto de perfil:'),
          actions: [
            TextButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.camera);
              },
              icon: const Icon(Icons.camera_alt),
              label: const Text('Câmera'),
            ),
            TextButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.gallery);
              },
              icon: const Icon(Icons.photo_library),
              label: const Text('Galeria'),
            ),
            if (_selectedImage != null)
              TextButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    _selectedImage = null;
                  });
                },
                icon: const Icon(Icons.delete),
                label: const Text('Remover'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
              ),
          ],
        );
      },
    );
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.register(
      _nameController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text,
      _confirmPasswordController.text,
    );

    if (mounted) {
      if (success && authProvider.isAuthenticated) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Conta criada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/home');
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
                const SizedBox(height: 20),
                
                // Título
                Text(
                  'Criar Conta',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Junte-se à nossa comunidade de cozinheiros',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Foto de perfil (opcional)
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: _selectedImage != null 
                          ? FileImage(_selectedImage!) 
                          : null,
                        child: _selectedImage == null 
                          ? Icon(
                              Icons.person,
                              size: 50,
                              color: Colors.grey[400],
                            )
                          : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 20,
                            ),
                            onPressed: _showImageSourceDialog,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Campos do formulário
                CustomTextField(
                  controller: _nameController,
                  label: 'Nome completo',
                  prefixIcon: Icons.person_outlined,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nome é obrigatório';
                    }
                    if (value.length < 2) {
                      return 'Nome deve ter pelo menos 2 caracteres';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
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
                
                const SizedBox(height: 16),
                
                CustomTextField(
                  controller: _passwordController,
                  label: 'Senha',
                  obscureText: _obscurePassword,
                  prefixIcon: Icons.lock_outlined,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Senha é obrigatória';
                    }
                    if (value.length < 6) {
                      return 'Senha deve ter pelo menos 6 caracteres';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                CustomTextField(
                  controller: _confirmPasswordController,
                  label: 'Confirmar senha',
                  obscureText: _obscureConfirmPassword,
                  prefixIcon: Icons.lock_outlined,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Confirmação de senha é obrigatória';
                    }
                    if (value != _passwordController.text) {
                      return 'Senhas não coincidem';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 32),
                
                // Botão de cadastro
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return CustomButton(
                      text: 'Cadastrar',
                      onPressed: authProvider.isLoading ? null : _handleRegister,
                      isLoading: authProvider.isLoading,
                    );
                  },
                ),
                
                const SizedBox(height: 24),
                
                // Link para login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Já tem uma conta? '),
                    TextButton(
                      onPressed: () => context.pop(),
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
