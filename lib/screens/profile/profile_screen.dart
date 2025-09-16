import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          if (!authProvider.isAuthenticated) {
            return const Center(
              child: Text('Usuário não autenticado'),
            );
          }

          final userProfile = authProvider.userProfile;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Foto e informações básicas
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Theme.of(context).primaryColor,
                  child: Text(
                    userProfile?['nome']?.substring(0, 1).toUpperCase() ?? 'U',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  userProfile?['nome'] ?? 'Usuário',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  userProfile?['email'] ?? '',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                if (userProfile?['bio'] != null && userProfile!['bio'].isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    userProfile['bio'],
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
                
                const SizedBox(height: 32),
                
                // Botões de ação
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => context.push('/edit-profile'),
                    icon: const Icon(Icons.edit),
                    label: const Text('Editar Perfil'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => context.push('/my-recipes'),
                    icon: const Icon(Icons.book),
                    label: const Text('Minhas Receitas'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Estatísticas (placeholder)
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(context, 'Receitas', '0'),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(context, 'Favoritos', '0'),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(context, 'Seguidores', '0'),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Botão de logout
                SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Sair'),
                          content: const Text('Tem certeza que deseja sair?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Cancelar'),
                            ),
                            TextButton(
                              onPressed: () {
                                authProvider.logout();
                                context.go('/login');
                              },
                              child: const Text('Sair'),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.logout, color: Colors.red),
                    label: const Text(
                      'Sair',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
