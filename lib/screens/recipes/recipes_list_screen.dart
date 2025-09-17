import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/supabase_service.dart';
import '../../widgets/custom_button.dart';

class RecipesListScreen extends StatefulWidget {
  const RecipesListScreen({super.key});

  @override
  State<RecipesListScreen> createState() => _RecipesListScreenState();
}

class _RecipesListScreenState extends State<RecipesListScreen> {
  List<Map<String, dynamic>> _recipes = [];
  bool _isLoading = true;
  bool _hasMoreData = true;
  String _searchQuery = '';
  String? _selectedCategory;
  List<String> _categories = [];
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 0;
  static const int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadRecipes();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final categoriesData = await SupabaseService.getCategories();
      setState(() {
        _categories = categoriesData.map((cat) => cat['nome'] as String).toList();
      });
    } catch (e) {
      // Ignorar erro de carregamento de categorias
    }
  }

  Future<void> _loadRecipes({bool loadMore = false}) async {
    if (loadMore && !_hasMoreData) return;

    try {
      setState(() {
        if (!loadMore) {
          _isLoading = true;
          _currentPage = 0;
          _recipes.clear();
        }
      });

      List<Map<String, dynamic>> newRecipes;

      if (_searchQuery.isNotEmpty) {
        // Busca por termo
        newRecipes = await SupabaseService.searchRecipes(_searchQuery);
        setState(() => _hasMoreData = false); // Busca não tem paginação
      } else if (_selectedCategory != null) {
        // Busca por categoria
        newRecipes = await SupabaseService.getRecipesByCategory(_selectedCategory!);
        setState(() => _hasMoreData = false); // Busca por categoria não tem paginação
      } else {
        // Lista geral com paginação
        final offset = loadMore ? _currentPage * _pageSize : 0;
        newRecipes = await SupabaseService.getPublicRecipes(
          limit: _pageSize,
          offset: offset,
        );

        if (loadMore) {
          _currentPage++;
        }

        setState(() {
          _hasMoreData = newRecipes.length == _pageSize;
        });
      }

      setState(() {
        if (loadMore) {
          _recipes.addAll(newRecipes);
        } else {
          _recipes = newRecipes;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar receitas: $e')),
        );
      }
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      _loadRecipes(loadMore: true);
    }
  }

  void _onSearchChanged(String query) {
    setState(() => _searchQuery = query);
    if (query.isEmpty || query.length >= 3) {
      _loadRecipes();
    }
  }

  void _onCategoryChanged(String? category) {
    setState(() {
      _selectedCategory = category;
      _searchQuery = ''; // Limpar busca quando mudar categoria
    });
    _loadRecipes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todas as Receitas'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/recipes/create'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de busca e filtros
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[50],
            child: Column(
              children: [
                // Campo de busca
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Buscar receitas...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () => _onSearchChanged(''),
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: _onSearchChanged,
                ),
                const SizedBox(height: 12),

                // Filtro por categoria
                if (_categories.isNotEmpty)
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Filtrar por categoria',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    initialValue: _selectedCategory,
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('Todas as categorias'),
                      ),
                      ..._categories.map((category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }),
                    ],
                    onChanged: _onCategoryChanged,
                  ),

                // Indicador de filtros ativos
                if (_searchQuery.isNotEmpty || _selectedCategory != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        if (_searchQuery.isNotEmpty)
                          Chip(
                            label: Text('Busca: "$_searchQuery"'),
                            onDeleted: () => _onSearchChanged(''),
                            deleteIcon: const Icon(Icons.close, size: 16),
                          ),
                        if (_selectedCategory != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Chip(
                              label: Text('Categoria: $_selectedCategory'),
                              onDeleted: () => _onCategoryChanged(null),
                              deleteIcon: const Icon(Icons.close, size: 16),
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Lista de receitas
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _recipes.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: () => _loadRecipes(),
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: _recipes.length + (_hasMoreData ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == _recipes.length) {
                              return _buildLoadingIndicator();
                            }
                            final recipe = _recipes[index];
                            return _buildRecipeCard(recipe);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty
                ? 'Nenhuma receita encontrada para "$_searchQuery"'
                : _selectedCategory != null
                    ? 'Nenhuma receita encontrada na categoria $_selectedCategory'
                    : 'Nenhuma receita disponível',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: 'Criar Receita',
            onPressed: () => context.push('/recipes/create'),
            icon: Icons.add,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      alignment: Alignment.center,
      child: const CircularProgressIndicator(),
    );
  }

  Widget _buildRecipeCard(Map<String, dynamic> recipe) {
    final ingredientsCount = recipe['ingredientes'] ?? 0;
    final autorName = recipe['autor']?['nome'] ?? 'Anônimo';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push('/recipes/${recipe['id']}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagem e título
              Row(
                children: [
                  if (recipe['foto_url'] != null)
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: NetworkImage(recipe['foto_url']),
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                  else
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey[200],
                      ),
                      child: const Icon(
                        Icons.restaurant,
                        color: Colors.grey,
                        size: 30,
                      ),
                    ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          recipe['titulo'] ?? 'Sem título',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.person,
                              size: 14,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              autorName,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Descrição
              if (recipe['descricao'] != null)
                Text(
                  recipe['descricao'],
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

              const SizedBox(height: 12),

              // Detalhes
              Row(
                children: [
                  _buildDetailChip(
                    Icons.category,
                    recipe['categoria']?['nome'] ?? 'Sem categoria',
                  ),
                  const SizedBox(width: 8),
                  _buildDetailChip(
                    Icons.timer,
                    '${recipe['tempo_preparo'] ?? 0} min',
                  ),
                  const SizedBox(width: 8),
                  _buildDetailChip(
                    Icons.people,
                    '${recipe['porcoes'] ?? 0} porções',
                  ),
                  const SizedBox(width: 8),
                  _buildDetailChip(
                    Icons.restaurant,
                    '$ingredientsCount ingr.',
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Dificuldade
              Row(
                children: [
                  Icon(
                    Icons.star,
                    size: 16,
                    color: _getDifficultyColor(recipe['dificuldade']),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    recipe['dificuldade'] ?? 'Não informado',
                    style: TextStyle(
                      color: _getDifficultyColor(recipe['dificuldade']),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Color _getDifficultyColor(String? difficulty) {
    switch (difficulty?.toLowerCase()) {
      case 'fácil':
        return Colors.green;
      case 'médio':
        return Colors.orange;
      case 'difícil':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
