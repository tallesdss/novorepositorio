import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RecipeDetailScreen extends StatelessWidget {
  final String recipeId;
  
  const RecipeDetailScreen({super.key, required this.recipeId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da Receita'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: Text('Detalhes da Receita $recipeId - Em desenvolvimento'),
      ),
    );
  }
}
