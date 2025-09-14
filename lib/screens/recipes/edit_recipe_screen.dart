import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EditRecipeScreen extends StatelessWidget {
  final String recipeId;
  
  const EditRecipeScreen({super.key, required this.recipeId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Receita'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: Text('Editar Receita $recipeId - Em desenvolvimento'),
      ),
    );
  }
}
