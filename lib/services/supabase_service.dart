import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class SupabaseService {
  // Getter para acessar o cliente Supabase de forma fácil
  static SupabaseClient get client => Supabase.instance.client;

  // Getter para verificar se o usuário está autenticado
  static bool get isAuthenticated => client.auth.currentUser != null;

  // Getter para acessar o usuário atual
  static User? get currentUser => client.auth.currentUser;

  // Getter para acessar a sessão atual
  static Session? get currentSession => client.auth.currentSession;

  // ==========================================
  // AUTENTICAÇÃO
  // ==========================================

  /// Realiza o login com email e senha
  static Future<AuthResponse> signInWithEmail(String email, String password) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Realiza o cadastro com email, senha e nome
  static Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    final response = await client.auth.signUp(
      email: email,
      password: password,
      data: {'name': name},
    );

    // O perfil será criado automaticamente pelo trigger no banco de dados
    return response;
  }

  /// Envia email de recuperação de senha
  static Future<void> resetPassword(String email) async {
    await client.auth.resetPasswordForEmail(
      email,
      redirectTo: null, // Pode ser configurado para redirecionar para uma URL específica
    );
  }

  /// Faz logout do usuário
  static Future<void> signOut() async {
    await client.auth.signOut();
  }

  /// Atualiza a senha do usuário
  static Future<UserResponse> updatePassword(String newPassword) async {
    return await client.auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }

  /// Atualiza o email do usuário
  static Future<UserResponse> updateEmail(String newEmail) async {
    return await client.auth.updateUser(
      UserAttributes(email: newEmail),
    );
  }

  // ==========================================
  // PERFIL DO USUÁRIO
  // ==========================================

  /// Busca o perfil do usuário atual
  static Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    if (currentUser == null) return null;

    final response = await client
        .from('profiles')
        .select()
        .eq('id', currentUser!.id)
        .single();

    return response;
  }

  /// Atualiza o perfil do usuário
  static Future<Map<String, dynamic>> updateUserProfile({
    String? name,
    String? bio,
    String? fotoUrl,
  }) async {
    if (currentUser == null) {
      throw Exception('Usuário não autenticado');
    }

    final updates = <String, dynamic>{};
    if (name != null) updates['nome'] = name;
    if (bio != null) updates['bio'] = bio;
    if (fotoUrl != null) updates['foto_url'] = fotoUrl;
    updates['updated_at'] = DateTime.now().toIso8601String();

    final response = await client
        .from('profiles')
        .update(updates)
        .eq('id', currentUser!.id)
        .select()
        .single();

    return response;
  }


  // ==========================================
  // UTILITÁRIOS
  // ==========================================

  /// Verifica se o email já está cadastrado
  static Future<bool> isEmailRegistered(String email) async {
    try {
      await client
          .from('profiles')
          .select('email')
          .eq('email', email)
          .single();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Busca usuário por ID
  static Future<Map<String, dynamic>?> getUserById(String userId) async {
    try {
      final response = await client
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();
      return response;
    } catch (e) {
      return null;
    }
  }

  // ==========================================
  // RECEITAS
  // ==========================================

  /// Busca todas as categorias disponíveis
  static Future<List<Map<String, dynamic>>> getCategories() async {
    final response = await client
        .from('categorias')
        .select()
        .order('nome');
    return List<Map<String, dynamic>>.from(response);
  }

  /// Busca categoria por nome
  static Future<Map<String, dynamic>?> getCategoryByName(String name) async {
    try {
      final response = await client
          .from('categorias')
          .select()
          .eq('nome', name)
          .single();
      return response;
    } catch (e) {
      return null;
    }
  }

  /// Cria uma nova receita
  static Future<Map<String, dynamic>> createRecipe({
    required String titulo,
    required String descricao,
    required String modoPreparo,
    required int tempoPreparo,
    required int porcoes,
    required String dificuldade,
    String? fotoUrl,
    required String categoriaNome,
    bool publico = true,
  }) async {
    if (currentUser == null) {
      throw Exception('Usuário não autenticado');
    }

    // Buscar categoria por nome
    final categoria = await getCategoryByName(categoriaNome);
    if (categoria == null) {
      throw Exception('Categoria não encontrada: $categoriaNome');
    }

    final recipeData = {
      'titulo': titulo,
      'descricao': descricao,
      'modo_preparo': modoPreparo,
      'tempo_preparo': tempoPreparo,
      'porcoes': porcoes,
      'dificuldade': dificuldade,
      'foto_url': fotoUrl,
      'categoria_id': categoria['id'],
      'autor_id': currentUser!.id,
      'publico': publico,
    };

    final response = await client
        .from('receitas')
        .insert(recipeData)
        .select()
        .single();

    return response;
  }

  /// Adiciona ingredientes a uma receita
  static Future<void> addIngredientsToRecipe(
    String recipeId,
    List<Map<String, dynamic>> ingredients,
  ) async {
    final ingredientsData = ingredients.asMap().entries.map((entry) {
      return {
        'receita_id': recipeId,
        'nome': entry.value['nome'],
        'quantidade': entry.value['quantidade'],
        'ordem': entry.key + 1,
      };
    }).toList();

    await client
        .from('ingredientes')
        .insert(ingredientsData);
  }

  /// Cria receita completa (receita + ingredientes)
  static Future<Map<String, dynamic>> createRecipeWithIngredients({
    required String titulo,
    required String descricao,
    required String modoPreparo,
    required int tempoPreparo,
    required int porcoes,
    required String dificuldade,
    String? fotoUrl,
    required String categoriaNome,
    required List<Map<String, dynamic>> ingredientes,
    bool publico = true,
  }) async {
    // Criar receita
    final recipe = await createRecipe(
      titulo: titulo,
      descricao: descricao,
      modoPreparo: modoPreparo,
      tempoPreparo: tempoPreparo,
      porcoes: porcoes,
      dificuldade: dificuldade,
      fotoUrl: fotoUrl,
      categoriaNome: categoriaNome,
      publico: publico,
    );

    // Adicionar ingredientes
    if (ingredientes.isNotEmpty) {
      await addIngredientsToRecipe(recipe['id'], ingredientes);
    }

    return recipe;
  }

  /// Busca receitas do usuário atual
  static Future<List<Map<String, dynamic>>> getUserRecipes() async {
    if (currentUser == null) return [];

    final response = await client
        .from('receitas')
        .select('''
          *,
          categoria:categorias(nome),
          autor:profiles(nome),
          ingredientes(count)
        ''')
        .eq('autor_id', currentUser!.id)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  /// Busca receita por ID com detalhes completos
  static Future<Map<String, dynamic>?> getRecipeById(String recipeId) async {
    try {
      final response = await client
          .from('receitas')
          .select('''
            *,
            categoria:categorias(*),
            autor:profiles(nome, foto_url),
            ingredientes(*)
          ''')
          .eq('id', recipeId)
          .single();

      return response;
    } catch (e) {
      return null;
    }
  }

  // ==========================================
  // STORAGE (IMAGENS)
  // ==========================================

  /// Faz upload de uma imagem para o Storage do Supabase
  static Future<String?> uploadImage(File imageFile, {String? customName}) async {
    if (currentUser == null) {
      throw Exception('Usuário não autenticado');
    }

    try {
      // Gerar nome único para a imagem
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final userId = currentUser!.id;
      final fileName = customName ?? 'recipe_$userId\_$timestamp.jpg';

      // Upload para o bucket 'recipe-images'
      final response = await client.storage
          .from('recipe-images')
          .upload(fileName, imageFile);

      if (response.isNotEmpty) {
        // Retornar URL pública da imagem
        final imageUrl = client.storage
            .from('recipe-images')
            .getPublicUrl(fileName);
        return imageUrl;
      }
      return null;
    } catch (e) {
      throw Exception('Erro ao fazer upload da imagem: $e');
    }
  }

  /// Seleciona imagem da galeria
  static Future<File?> pickImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  /// Tira foto com a câmera
  static Future<File?> pickImageFromCamera() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }
}
