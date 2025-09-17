import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';

import '../../services/supabase_service.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../models/recipe.dart'; // Importar o modelo Recipe

class RecipeFormScreen extends StatefulWidget {
  final String? recipeId;

  const RecipeFormScreen({super.key, this.recipeId});

  @override
  State<RecipeFormScreen> createState() => _RecipeFormScreenState();
}

class _RecipeFormScreenState extends State<RecipeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _prepMethodController = TextEditingController();
  final _prepTimeController = TextEditingController();
  final _portionsController = TextEditingController();
  final _difficultyController = TextEditingController();
  
  String? _selectedCategory;
  List<String> _categories = [];
  File? _pickedImage;
  String? _existingImageUrl;
  bool _isPublic = true;
  bool _isLoading = false;
  
  final List<TextEditingController> _ingredientNameControllers = [];
  final List<TextEditingController> _ingredientQuantityControllers = [];

  Recipe? _initialRecipeData;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    if (widget.recipeId != null) {
      _loadRecipeData();
    } else {
      // Adicionar um campo de ingrediente vazio por padrão para novas receitas
      _addIngredientField();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _prepMethodController.dispose();
    _prepTimeController.dispose();
    _portionsController.dispose();
    _difficultyController.dispose();
    for (var controller in _ingredientNameControllers) {
      controller.dispose();
    }
    for (var controller in _ingredientQuantityControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final categoriesData = await SupabaseService.getCategories();
      setState(() {
        _categories = categoriesData.map((cat) => cat['nome'] as String).toList();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar categorias: $e')),
        );
      }
    }
  }

  Future<void> _loadRecipeData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final recipeMap = await SupabaseService.getRecipeById(widget.recipeId!);
      if (recipeMap != null) {
        final recipe = Recipe.fromMap(recipeMap);
        _initialRecipeData = recipe;
        _titleController.text = recipe.titulo;
        _descriptionController.text = recipe.descricao;
        _prepMethodController.text = recipe.modoPreparo;
        _prepTimeController.text = recipe.tempoPreparo.toString();
        _portionsController.text = recipe.porcoes.toString();
        _difficultyController.text = recipe.dificuldade; // Ou um DropdownMenuItem
        _selectedCategory = recipe.categoriaNome; // Assumindo que categoriaNome está populado
        _existingImageUrl = recipe.fotoUrl;
        _isPublic = recipe.publico;

        _ingredientNameControllers.clear();
        _ingredientQuantityControllers.clear();
        if (recipe.ingredientes != null && recipe.ingredientes!.isNotEmpty) {
          for (var ingredient in recipe.ingredientes!) {
            _ingredientNameControllers.add(TextEditingController(text: ingredient.nome));
            _ingredientQuantityControllers.add(TextEditingController(text: ingredient.quantidade));
          }
        } else {
          _addIngredientField(); // Adicionar um campo vazio se não houver ingredientes
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar dados da receita: $e')),
        );
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  void _addIngredientField() {
    setState(() {
      _ingredientNameControllers.add(TextEditingController());
      _ingredientQuantityControllers.add(TextEditingController());
    });
  }

  void _removeIngredientField(int index) {
    setState(() {
      _ingredientNameControllers[index].dispose();
      _ingredientQuantityControllers[index].dispose();
      _ingredientNameControllers.removeAt(index);
      _ingredientQuantityControllers.removeAt(index);
    });
  }

  Future<void> _pickImage() async {
    final File? pickedFile = await SupabaseService.pickImageFromGallery();
    if (pickedFile != null) {
      setState(() {
        _pickedImage = pickedFile;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCategory == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, selecione uma categoria.')),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    String? finalPhotoUrl = _existingImageUrl;
    if (_pickedImage != null) {
      try {
        finalPhotoUrl = await SupabaseService.uploadImage(_pickedImage!);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao fazer upload da imagem: $e')),
          );
        }
        setState(() {
          _isLoading = false;
        });
        return;
      }
    }

    final List<Map<String, dynamic>> ingredientsToSave = [];
    for (int i = 0; i < _ingredientNameControllers.length; i++) {
      final name = _ingredientNameControllers[i].text.trim();
      final quantity = _ingredientQuantityControllers[i].text.trim();
      if (name.isNotEmpty && quantity.isNotEmpty) {
        ingredientsToSave.add({
          'nome': name,
          'quantidade': quantity,
          'ordem': i + 1,
        });
      }
    }

    try {
      if (widget.recipeId == null) {
        // Criar nova receita
        await SupabaseService.createRecipeWithIngredients(
          titulo: _titleController.text,
          descricao: _descriptionController.text,
          modoPreparo: _prepMethodController.text,
          tempoPreparo: int.parse(_prepTimeController.text),
          porcoes: int.parse(_portionsController.text),
          dificuldade: _difficultyController.text,
          fotoUrl: finalPhotoUrl,
          categoriaNome: _selectedCategory!,
          ingredientes: ingredientsToSave,
          publico: _isPublic,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Receita criada com sucesso!')), 
          );
          context.pop(); // Voltar para a lista de receitas
        }
      } else {
        // Atualizar receita existente
        await SupabaseService.updateRecipeWithIngredients(
          recipeId: widget.recipeId!,
          titulo: _titleController.text,
          descricao: _descriptionController.text,
          modoPreparo: _prepMethodController.text,
          tempoPreparo: int.parse(_prepTimeController.text),
          porcoes: int.parse(_portionsController.text),
          dificuldade: _difficultyController.text,
          fotoUrl: finalPhotoUrl,
          categoriaNome: _selectedCategory!,
          ingredientes: ingredientsToSave,
          publico: _isPublic,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Receita atualizada com sucesso!')), 
          );
          context.pop(); // Voltar para a tela de detalhes da receita
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar receita: $e')),
        );
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recipeId == null ? 'Nova Receita' : 'Editar Receita'),
      ),
      body: _isLoading && _initialRecipeData == null
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Campo de Título
                  CustomTextField(
                    controller: _titleController,
                    label: 'Título da Receita',
                    hint: 'Ex: Bolo de Chocolate',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira o título da receita.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Campo de Descrição
                  CustomTextField(
                    controller: _descriptionController,
                    label: 'Descrição',
                    hint: 'Uma breve descrição da receita.',
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira a descrição.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Campo de Modo de Preparo
                  CustomTextField(
                    controller: _prepMethodController,
                    label: 'Modo de Preparo',
                    hint: 'Descreva o passo a passo.',
                    maxLines: 8,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira o modo de preparo.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Tempo de Preparo e Porções
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: _prepTimeController,
                          label: 'Tempo de Preparo (minutos)',
                          hint: 'Ex: 45',
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Insira o tempo.';
                            }
                            if (int.tryParse(value) == null) {
                              return 'Apenas números.';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: CustomTextField(
                          controller: _portionsController,
                          label: 'Porções',
                          hint: 'Ex: 6',
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Insira as porções.';
                            }
                            if (int.tryParse(value) == null) {
                              return 'Apenas números.';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Dificuldade
                  DropdownButtonFormField<String>(
                    initialValue: _difficultyController.text.isEmpty ? null : _difficultyController.text,
                    decoration: InputDecoration(
                      labelText: 'Dificuldade',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Fácil', child: Text('Fácil')),
                      DropdownMenuItem(value: 'Médio', child: Text('Médio')),
                      DropdownMenuItem(value: 'Difícil', child: Text('Difícil')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _difficultyController.text = value!;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, selecione a dificuldade.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Seleção de Categoria
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCategory,
                    decoration: InputDecoration(
                      labelText: 'Categoria',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    items: _categories.map((category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, selecione uma categoria.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Upload de Imagem
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                        image: _pickedImage != null
                            ? DecorationImage(image: FileImage(_pickedImage!), fit: BoxFit.cover)
                            : _existingImageUrl != null
                                ? DecorationImage(image: NetworkImage(_existingImageUrl!), fit: BoxFit.cover)
                                : null,
                      ),
                      child: _pickedImage == null && _existingImageUrl == null
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.camera_alt, size: 40, color: Colors.grey[600]),
                                const SizedBox(height: 8),
                                Text(
                                  'Adicionar Imagem da Receita',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Ingredientes
                  Text(
                    'Ingredientes',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _ingredientNameControllers.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: CustomTextField(
                                controller: _ingredientNameControllers[index],
                                label: 'Nome do Ingrediente',
                                hint: 'Ex: Farinha de Trigo',
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Insira o nome.';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 2,
                              child: CustomTextField(
                                controller: _ingredientQuantityControllers[index],
                                label: 'Quantidade',
                                hint: 'Ex: 2 xícaras',
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Insira a quantidade.';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.remove_circle, color: Colors.red),
                              onPressed: () => _removeIngredientField(index),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: _addIngredientField,
                      icon: const Icon(Icons.add),
                      label: const Text('Adicionar Ingrediente'),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Publicar Receita Switch
                  SwitchListTile(
                    title: const Text('Tornar Pública'),
                    value: _isPublic,
                    onChanged: (bool value) {
                      setState(() {
                        _isPublic = value;
                      });
                    },
                  ),
                  const SizedBox(height: 24),

                  // Botão de Salvar
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : CustomButton(
                          text: 'Salvar Receita',
                          onPressed: _submitForm,
                          icon: Icons.save,
                        ),
                ],
              ),
            ),
    );
  }
}
