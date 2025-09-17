import 'package:flutter/foundation.dart';

class Recipe {
  final String id;
  final String titulo;
  final String descricao;
  final String modoPreparo;
  final int tempoPreparo;
  final int porcoes;
  final String dificuldade;
  final String? fotoUrl;
  final String categoriaId;
  final String autorId;
  final bool publico;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? categoriaNome; // Para exibição facilitada
  final String? autorNome; // Para exibição facilitada
  final List<Ingredient>? ingredientes; // Lista de ingredientes

  Recipe({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.modoPreparo,
    required this.tempoPreparo,
    required this.porcoes,
    required this.dificuldade,
    this.fotoUrl,
    required this.categoriaId,
    required this.autorId,
    required this.publico,
    required this.createdAt,
    this.updatedAt,
    this.categoriaNome,
    this.autorNome,
    this.ingredientes,
  });

  factory Recipe.fromMap(Map<String, dynamic> map) {
    return Recipe(
      id: map['id'],
      titulo: map['titulo'],
      descricao: map['descricao'],
      modoPreparo: map['modo_preparo'],
      tempoPreparo: map['tempo_preparo'],
      porcoes: map['porcoes'],
      dificuldade: map['dificuldade'],
      fotoUrl: map['foto_url'],
      categoriaId: map['categori-id'],
      autorId: map['autor_id'],
      publico: map['publico'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
      categoriaNome: map['categoria']?['nome'],
      autorNome: map['autor']?['nome'],
      ingredientes: (map['ingredientes'] as List<dynamic>?)
          ?.map((e) => Ingredient.fromMap(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'descricao': descricao,
      'modo_preparo': modoPreparo,
      'tempo_preparo': tempoPreparo,
      'porcoes': porcoes,
      'dificuldade': dificuldade,
      'foto_url': fotoUrl,
      'categori-id': categoriaId,
      'autor_id': autorId,
      'publico': publico,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      // categoriaNome e autorNome não são salvos, são apenas para exibição
      // ingredientes são salvos separadamente
    };
  }

  // Método para criar uma cópia da receita com campos atualizados
  Recipe copyWith({
    String? id,
    String? titulo,
    String? descricao,
    String? modoPreparo,
    int? tempoPreparo,
    int? porcoes,
    String? dificuldade,
    ValueGetter<String?>? fotoUrl,
    String? categoriaId,
    String? autorId,
    bool? publico,
    DateTime? createdAt,
    ValueGetter<DateTime?>? updatedAt,
    ValueGetter<String?>? categoriaNome,
    ValueGetter<String?>? autorNome,
    ValueGetter<List<Ingredient>?>? ingredientes,
  }) {
    return Recipe(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descricao: descricao ?? this.descricao,
      modoPreparo: modoPreparo ?? this.modoPreparo,
      tempoPreparo: tempoPreparo ?? this.tempoPreparo,
      porcoes: porcoes ?? this.porcoes,
      dificuldade: dificuldade ?? this.dificuldade,
      fotoUrl: fotoUrl != null ? fotoUrl() : this.fotoUrl,
      categoriaId: categoriaId ?? this.categoriaId,
      autorId: autorId ?? this.autorId,
      publico: publico ?? this.publico,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt != null ? updatedAt() : this.updatedAt,
      categoriaNome: categoriaNome != null ? categoriaNome() : this.categoriaNome,
      autorNome: autorNome != null ? autorNome() : this.autorNome,
      ingredientes: ingredientes != null ? ingredientes() : this.ingredientes,
    );
  }
}

class Ingredient {
  final String? id; // Pode ser nulo para novos ingredientes
  final String? receitaId; // Pode ser nulo para novos ingredientes
  final String nome;
  final String quantidade;
  final int ordem;

  Ingredient({
    this.id,
    this.receitaId,
    required this.nome,
    required this.quantidade,
    required this.ordem,
  });

  factory Ingredient.fromMap(Map<String, dynamic> map) {
    return Ingredient(
      id: map['id'],
      receitaId: map['receit-id'],
      nome: map['nome'],
      quantidade: map['quantidade'],
      ordem: map['ordem'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'receit-id': receitaId,
      'nome': nome,
      'quantidade': quantidade,
      'ordem': ordem,
    };
  }

  // Método para criar uma cópia do ingrediente com campos atualizados
  Ingredient copyWith({
    ValueGetter<String?>? id,
    ValueGetter<String?>? receitaId,
    String? nome,
    String? quantidade,
    int? ordem,
  }) {
    return Ingredient(
      id: id != null ? id() : this.id,
      receitaId: receitaId != null ? receitaId() : this.receitaId,
      nome: nome ?? this.nome,
      quantidade: quantidade ?? this.quantidade,
      ordem: ordem ?? this.ordem,
    );
  }
}

class Category {
  final String id;
  final String nome;
  final DateTime createdAt;

  Category({
    required this.id,
    required this.nome,
    required this.createdAt,
  });

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      nome: map['nome'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
