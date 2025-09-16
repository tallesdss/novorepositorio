import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';

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
  
  final List<String> _categories = [
    'Doces',
    'Salgados',
    'Bebidas',
    'Sobremesas',
    'Pratos Principais',
    'Entradas',
    'Acompanhamentos',
  ];
  
  final List<String> _difficulties = ['Fácil', 'Médio', 'Difícil'];

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

  void _saveRecipe() {
    if (_formKey.currentState!.validate()) {
      // Aqui seria implementada a lógica para salvar a receita
      // Por enquanto, apenas mostramos uma mensagem de sucesso
      
      // Dados da receita que seriam enviados para o backend:
      // - Título: _titleController.text
      // - Descrição: _descriptionController.text
      // - Tempo: _preparationTimeController.text
      // - Porções: _servingsController.text
      // - Categoria: _selectedCategory
      // - Dificuldade: _selectedDifficulty
      // - Ingredientes: _ingredientControllers.map((c) => c.text.trim()).where((t) => t.isNotEmpty).toList()
      // - Instruções: _instructionControllers.map((c) => c.text.trim()).where((t) => t.isNotEmpty).toList()

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Receita criada com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );

      // Simular um delay e retornar à tela anterior
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          context.pop();
        }
      });
    }
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
                    child: _buildDropdown(
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
                text: 'Salvar Receita',
                onPressed: _saveRecipe,
                icon: Icons.save,
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
