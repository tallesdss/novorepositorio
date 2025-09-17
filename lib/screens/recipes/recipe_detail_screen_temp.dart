import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/supabase_service.dart';

class RecipeDetailScreen extends StatefulWidget {
  final String recipeId;

  const RecipeDetailScreen({super.key, required this.recipeId});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  Map<String, dynamic>? _recipe;
  bool _isLoading = true;
  bool _isCurrentUserRecipe = false;

  @override
  void initState() {
    super.initState();
    _loadRecipe();
  }

  Future<void> _loadRecipe() async {
    try {
      final recipe = await SupabaseService.getRecipeById(widget.recipeId);
      final currentUser = SupabaseService.currentUser;

      setState(() {
        _recipe = recipe;
        _isCurrentUserRecipe = currentUser != null && recipe?['autor_id'] == currentUser.id;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar receita: $e')),
        );
      }
    }
  }

  void _showDeleteConfirmation() {
    if (_recipe == null) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content: Text('Tem certeza que deseja excluir a receita "${_recipe!['titulo']}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _deleteRecipe();
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteRecipe() async {
    try {
      await SupabaseService.deleteRecipe(widget.recipeId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Receita excluída com sucesso')),
        );
        context.pop(); // Voltar para a tela anterior
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao excluir receita: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF6366F1),
                Color(0xFF8B5CF6),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Header personalizado
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => context.pop(),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        'Carregando receita...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                // Loading animation
                const Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 60,
                          height: 60,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 4,
                          ),
                        ),
                        SizedBox(height: 24),
                        Text(
                          'Preparando sua receita...',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_recipe == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFEF4444),
                Color(0xFFF97316),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => context.pop(),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        'Ops! Algo deu errado',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                // Error content
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.restaurant_menu,
                            size: 80,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Receita não encontrada',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'A receita que você procura não\nexiste ou foi removida',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 32),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () => context.pop(),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                child: Text(
                                  'Voltar',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFEF4444),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Hero Image com gradient overlay
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.white,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black87),
                onPressed: () => context.pop(),
              ),
            ),
            actions: _isCurrentUserRecipe
                ? [
                    Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: PopupMenuButton(
                        icon: const Icon(Icons.more_vert, color: Colors.black87),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: const Row(
                              children: [
                                Icon(Icons.edit, color: Colors.blue),
                                SizedBox(width: 12),
                                Text('Editar'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: const Row(
                              children: [
                                Icon(Icons.delete, color: Colors.red),
                                SizedBox(width: 12),
                                Text('Excluir'),
                              ],
                            ),
                          ),
                        ],
                        onSelected: (value) {
                          if (value == 'edit') {
                            context.push('/recipes/${widget.recipeId}/edit');
                          } else if (value == 'delete') {
                            _showDeleteConfirmation();
                          }
                        },
                      ),
                    ),
                  ]
                : null,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Imagem da receita
                  _recipe!['foto_url'] != null
                      ? Hero(
                          tag: 'recipe-${widget.recipeId}',
                          child: Image.network(
                            _recipe!['foto_url'],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFF6366F1),
                                    Color(0xFF8B5CF6),
                                  ],
                                ),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.restaurant_menu,
                                  size: 80,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        )
                      : Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFF6366F1),
                                Color(0xFF8B5CF6),
                              ],
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.restaurant_menu,
                              size: 80,
                              color: Colors.white,
                            ),
                          ),
                        ),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.7),
                        ],
                        stops: const [0.6, 1.0],
                      ),
                    ),
                  ),
                  // Título sobre a imagem
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _recipe!['titulo'] ?? 'Sem título',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                offset: Offset(0, 2),
                                blurRadius: 4,
                                color: Colors.black54,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.person,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _recipe!['autor']?['nome'] ?? 'Anônimo',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Conteúdo principal
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Cards de informações
                    _buildModernInfoCards(),
                    const SizedBox(height: 24),

                    // Descrição
                    if (_recipe!['descricao'] != null && _recipe!['descricao'].isNotEmpty) ...[
                      _buildSectionTitle('Sobre esta receita', Icons.info_outline),
                      const SizedBox(height: 12),
                      _buildDescriptionCard(),
                      const SizedBox(height: 28),
                    ],

                    // Ingredientes
                    _buildSectionTitle('Ingredientes', Icons.shopping_cart_outlined),
                    const SizedBox(height: 12),
                    _buildModernIngredientsList(),
                    const SizedBox(height: 28),

                    // Modo de preparo
                    _buildSectionTitle('Modo de Preparo', Icons.list_alt),
                    const SizedBox(height: 12),
                    _buildModernInstructions(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }

  Widget _buildModernInfoCards() {
    return Row(
      children: [
        _buildModernInfoCard(
          Icons.schedule,
          '${_recipe!['tempo_preparo'] ?? 0}',
          'min',
          'Tempo',
          const Color(0xFF10B981),
        ),
        const SizedBox(width: 12),
        _buildModernInfoCard(
          Icons.people_outline,
          '${_recipe!['porcoes'] ?? 0}',
          '',
          'Porções',
          const Color(0xFF3B82F6),
        ),
        const SizedBox(width: 12),
        _buildModernInfoCard(
          Icons.signal_cellular_alt,
          _recipe!['dificuldade'] ?? 'N/A',
          '',
          'Dificuldade',
          _getDifficultyColor(_recipe!['dificuldade']),
        ),
      ],
    );
  }

  Widget _buildModernInfoCard(IconData icon, String value, String unit, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 20,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                if (unit.isNotEmpty) ...[
                  const SizedBox(width: 2),
                  Text(
                    unit,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: color.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Text(
        _recipe!['descricao'],
        style: const TextStyle(
          fontSize: 16,
          height: 1.6,
          color: Color(0xFF374151),
        ),
      ),
    );
  }

  Widget _buildModernIngredientsList() {
    final ingredients = _recipe!['ingredientes'] as List<dynamic>? ?? [];

    if (ingredients.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF3C7),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFDE68A)),
        ),
        child: const Column(
          children: [
            Icon(
              Icons.info_outline,
              color: Color(0xFFD97706),
              size: 32,
            ),
            SizedBox(height: 8),
            Text(
              'Nenhum ingrediente informado',
              style: TextStyle(
                color: Color(0xFFD97706),
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    // Ordenar ingredientes por ordem
    ingredients.sort((a, b) => (a['ordem'] ?? 0).compareTo(b['ordem'] ?? 0));

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: ingredients.asMap().entries.map((entry) {
          final index = entry.key;
          final ingredient = entry.value;
          final isLast = index == ingredients.length - 1;

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: !isLast
                  ? const Border(bottom: BorderSide(color: Color(0xFFF3F4F6)))
                  : null,
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF10B981), Color(0xFF059669)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    '${ingredient['quantidade'] ?? ''} ${ingredient['nome'] ?? ''}'.trim(),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF374151),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Icon(
                  Icons.check_circle_outline,
                  color: Color(0xFF10B981),
                  size: 20,
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildModernInstructions() {
    final instructions = _recipe!['modo_preparo'] ?? '';

    if (instructions.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF3C7),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFDE68A)),
        ),
        child: const Column(
          children: [
            Icon(
              Icons.info_outline,
              color: Color(0xFFD97706),
              size: 32,
            ),
            SizedBox(height: 8),
            Text(
              'Nenhum modo de preparo informado',
              style: TextStyle(
                color: Color(0xFFD97706),
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    // Tentar dividir por quebras de linha duplas ou quebras simples
    final steps = instructions.split('\n\n').where((step) => step.trim().isNotEmpty).toList();
    
    List<String> finalSteps = steps;
    if (steps.length <= 1) {
      // Se não há quebras duplas, tentar quebras simples
      final singleSteps = instructions.split('\n').where((step) => step.trim().isNotEmpty).toList();
      if (singleSteps.length > 1) {
        finalSteps = singleSteps;
      }
    }

    return Column(
      children: finalSteps.asMap().entries.map((entry) {
        final index = entry.key;
        final step = entry.value;
        final isLast = index == finalSteps.length - 1;

        return Container(
          margin: EdgeInsets.only(bottom: isLast ? 0 : 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    step.trim(),
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      color: Color(0xFF374151),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Color _getDifficultyColor(String? difficulty) {
    switch (difficulty?.toLowerCase()) {
      case 'fácil':
        return const Color(0xFF10B981); // Verde moderno
      case 'médio':
        return const Color(0xFFF59E0B); // Amarelo/laranja moderno
      case 'difícil':
        return const Color(0xFFEF4444); // Vermelho moderno
      default:
        return const Color(0xFF6B7280); // Cinza moderno
    }
  }
}
