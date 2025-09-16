import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../services/supabase_service.dart';

class CreateRecipeScreen extends StatefulWidget {
  const CreateRecipeScreen({super.key});

  @override
  State<CreateRecipeScreen> createState() => _CreateRecipeScreenState();
}

class _CreateRecipeScreenState extends State<CreateRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _preparationTimeController = TextEditingController();
  final _servingsController = TextEditingController();
  
  final List<TextEditingController> _ingredientControllers = [TextEditingController()];
  final List<TextEditingController> _instructionControllers = [TextEditingController()];
  
  String _selectedCategory = 'Doces';
  String _selectedDifficulty = 'Fácil';
  
  List<String> _categories = [
    'Doces',
    'Salgados',
    'Bebidas',
    'Sobremesas',
    'Pratos Principais',
    'Entradas',
    'Acompanhamentos',
  ];

  final List<String> _difficulties = ['Fácil', 'Médio', 'Difícil'];

  bool _isLoading = false;
  bool _isLoadingCategories = true;

  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final categoriesData = await SupabaseService.getCategories();
      setState(() {
        _categories = categoriesData.map((cat) => cat['nome'] as String).toList();
        _isLoadingCategories = false;
      });
    } catch (e) {
      // Em caso de erro, manter as categorias padrão
      setState(() => _isLoadingCategories = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _preparationTimeController.dispose();
    _servingsController.dispose();
    
    for (var controller in _ingredientControllers) {
      controller.dispose();
    }
    for (var controller in _instructionControllers) {
      controller.dispose();
    }
    
    super.dispose();
  }

  void _addIngredient() {
    setState(() {
      _ingredientControllers.add(TextEditingController());
    });
  }

  void _removeIngredient(int index) {
    if (_ingredientControllers.length > 1) {
      setState(() {
        _ingredientControllers[index].dispose();
        _ingredientControllers.removeAt(index);
      });
    }
  }

  void _addInstruction() {
    setState(() {
      _instructionControllers.add(TextEditingController());
    });
  }

  void _removeInstruction(int index) {
    if (_instructionControllers.length > 1) {
      setState(() {
        _instructionControllers[index].dispose();
        _instructionControllers.removeAt(index);
      });
    }
  }

  Future<void> _saveRecipe() async {
    if (_formKey.currentState!.validate()) {
      // Mostrar loading
      setState(() => _isLoading = true);

      try {
        // Upload da imagem se foi selecionada
        String? imageUrl;
        if (_selectedImage != null) {
          imageUrl = await SupabaseService.uploadImage(_selectedImage!);
        }

        // Preparar dados dos ingredientes
        final ingredients = _ingredientControllers
            .map((controller) => controller.text.trim())
            .where((text) => text.isNotEmpty)
            .map((ingredient) {
              // Tentar separar quantidade do nome do ingrediente
              final parts = ingredient.split(' ');
              if (parts.length > 1 && _isQuantity(parts[0])) {
                final quantity = parts.sublist(0, 2).join(' '); // Pegar primeira palavra (possivelmente com unidade)
                final name = parts.sublist(2).join(' '); // Restante é o nome
                return {'nome': name, 'quantidade': quantity};
              } else {
                return {'nome': ingredient, 'quantidade': null};
              }
            })
            .toList();

        // Preparar dados das instruções (modo de preparo)
        final instructions = _instructionControllers
            .map((controller) => controller.text.trim())
            .where((text) => text.isNotEmpty)
            .toList();

        // Criar receita no Supabase
        await SupabaseService.createRecipeWithIngredients(
          titulo: _titleController.text.trim(),
          descricao: _descriptionController.text.trim(),
          modoPreparo: instructions.join('\n\n'),
          tempoPreparo: int.parse(_preparationTimeController.text),
          porcoes: int.parse(_servingsController.text),
          dificuldade: _selectedDifficulty,
          categoriaNome: _selectedCategory,
          fotoUrl: imageUrl,
          ingredientes: ingredients,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Receita criada com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );

          // Voltar para a tela anterior
          context.pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao criar receita: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  bool _isQuantity(String text) {
    // Verificar se o texto parece ser uma quantidade (número seguido opcionalmente de unidade)
    final regex = RegExp(r'^\d+([.,]\d+)?\s*(g|kg|ml|l|colher|xic|unidade|xíc|copo|copos?|un|und)?$');
    return regex.hasMatch(text.toLowerCase());
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final image = await SupabaseService.pickImageFromGallery();
      if (image != null) {
        setState(() => _selectedImage = image);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao selecionar imagem: $e')),
        );
      }
    }
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final image = await SupabaseService.pickImageFromCamera();
      if (image != null) {
        setState(() => _selectedImage = image);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao tirar foto: $e')),
        );
      }
    }
  }


  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galeria'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImageFromGallery();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Câmera'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImageFromCamera();
                },
              ),
              if (_selectedImage != null) ...[
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Remover imagem', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.of(context).pop();
                    setState(() => _selectedImage = null);
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Receita'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).primaryColor,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Informações básicas
              _buildSectionTitle('Informações Básicas'),
              const SizedBox(height: 16),
              
              CustomTextField(
                controller: _titleController,
                label: 'Título da Receita',
                hint: 'Ex: Bolo de Chocolate',
                prefixIcon: Icons.restaurant_menu,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, insira o título da receita';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              CustomTextField(
                controller: _descriptionController,
                label: 'Descrição',
                hint: 'Descreva brevemente sua receita...',
                prefixIcon: Icons.description,
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, insira uma descrição';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Imagem da receita
              _buildSectionTitle('Foto da Receita (Opcional)'),
              const SizedBox(height: 16),

              GestureDetector(
                onTap: _showImagePickerOptions,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!, width: 2),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey[50],
                  ),
                  child: _selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            _selectedImage!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_a_photo,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Toque para adicionar foto',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 24),

              // Detalhes da receita
              _buildSectionTitle('Detalhes'),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _preparationTimeController,
                      label: 'Tempo (min)',
                      hint: '30',
                      prefixIcon: Icons.timer,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Tempo obrigatório';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Apenas números';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      controller: _servingsController,
                      label: 'Porções',
                      hint: '4',
                      prefixIcon: Icons.people,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Porções obrigatório';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Apenas números';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: _isLoadingCategories
                        ? const Center(child: CircularProgressIndicator())
                        : _buildDropdown(
                            'Categoria',
                            _selectedCategory,
                            _categories,
                            Icons.category,
                            (value) => setState(() => _selectedCategory = value!),
                          ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDropdown(
                      'Dificuldade',
                      _selectedDifficulty,
                      _difficulties,
                      Icons.star,
                      (value) => setState(() => _selectedDifficulty = value!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Ingredientes
              _buildSectionTitle('Ingredientes'),
              const SizedBox(height: 16),
              
              ..._buildIngredientsList(),
              const SizedBox(height: 8),
              
              CustomButton(
                text: 'Adicionar Ingrediente',
                onPressed: _addIngredient,
                isOutlined: true,
                icon: Icons.add,
                height: 48,
              ),
              const SizedBox(height: 24),
              
              // Modo de preparo
              _buildSectionTitle('Modo de Preparo'),
              const SizedBox(height: 16),
              
              ..._buildInstructionsList(),
              const SizedBox(height: 8),
              
              CustomButton(
                text: 'Adicionar Instrução',
                onPressed: _addInstruction,
                isOutlined: true,
                icon: Icons.add,
                height: 48,
              ),
              const SizedBox(height: 32),
              
              // Botão salvar
              CustomButton(
                text: _isLoading ? 'Salvando...' : 'Salvar Receita',
                onPressed: _isLoading ? null : _saveRecipe,
                icon: _isLoading ? Icons.hourglass_empty : Icons.save,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    String value,
    List<String> items,
    IconData icon,
    ValueChanged<String?> onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  List<Widget> _buildIngredientsList() {
    return _ingredientControllers.asMap().entries.map((entry) {
      int index = entry.key;
      TextEditingController controller = entry.value;
      
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: controller,
                label: 'Ingrediente ${index + 1}',
                hint: 'Ex: 2 xícaras de farinha de trigo',
                prefixIcon: Icons.egg,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, insira o ingrediente';
                  }
                  return null;
                },
              ),
            ),
            if (_ingredientControllers.length > 1) ...[
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => _removeIngredient(index),
                icon: const Icon(Icons.remove_circle),
                color: Colors.red,
              ),
            ],
          ],
        ),
      );
    }).toList();
  }

  List<Widget> _buildInstructionsList() {
    return _instructionControllers.asMap().entries.map((entry) {
      int index = entry.key;
      TextEditingController controller = entry.value;
      
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: CustomTextField(
                controller: controller,
                label: 'Passo ${index + 1}',
                hint: 'Descreva o passo a passo...',
                prefixIcon: Icons.format_list_numbered,
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, descreva esta instrução';
                  }
                  return null;
                },
              ),
            ),
            if (_instructionControllers.length > 1) ...[
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: IconButton(
                  onPressed: () => _removeInstruction(index),
                  icon: const Icon(Icons.remove_circle),
                  color: Colors.red,
                ),
              ),
            ],
          ],
        ),
      );
    }).toList();
  }
}
