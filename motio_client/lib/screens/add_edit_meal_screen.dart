import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../models/meal.dart';
import '../models/meal_category.dart';
import '../providers/meal_category_provider.dart';
import '../services/meal_service.dart';
import '../services/user_service.dart';
import '../widgets/add_meal/ingredient_field.dart';
import '../widgets/add_meal/step_field.dart';

class AddEditMealScreen extends ConsumerStatefulWidget {
  final Meal? meal; // Nullable Meal object for editing

  const AddEditMealScreen({Key? key, this.meal}) : super(key: key);

  @override
  _AddEditMealScreenState createState() => _AddEditMealScreenState();
}

class _AddEditMealScreenState extends ConsumerState<AddEditMealScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _mealNameController = TextEditingController();
  final List<TextEditingController> _stepsControllers = [];
  final List<TextEditingController> _ingredientsControllers = [];
  final MealService _mealService = MealService();
  final UserService _userService = UserService();
  final ImagePicker _picker = ImagePicker();

  final GlobalKey<AnimatedListState> _ingredientsListKey = GlobalKey<AnimatedListState>();
  final GlobalKey<AnimatedListState> _stepsListKey = GlobalKey<AnimatedListState>();

  List<MealCategory> _selectedCategories = [];
  File? _selectedImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.meal != null) {
      _mealNameController.text = widget.meal!.mealName;
      _selectedCategories = widget.meal!.categories.toList();
      widget.meal!.steps.forEach((step) {
        _stepsControllers.add(TextEditingController(text: step));
      });
      widget.meal!.ingredients.forEach((ingredient) {
        _ingredientsControllers.add(TextEditingController(text: ingredient));
      });
      if (widget.meal!.imagePath != null) {
        _loadImage(widget.meal!.id.toString());
      }
    } else {
      _stepsControllers.add(TextEditingController());
      _ingredientsControllers.add(TextEditingController());
    }
  }

  Future<void> _loadImage(String mealId) async {
    try {
      final imageFile = await _mealService.getImageFile(mealId);
      if (imageFile != null) {
        setState(() {
          _selectedImage = imageFile;
        });
      }
    } catch (e) {
      print('Failed to load image: $e');
    }
  }

  @override
  void dispose() {
    _mealNameController.dispose();
    _stepsControllers.forEach((controller) => controller.dispose());
    _ingredientsControllers.forEach((controller) => controller.dispose());
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final user = await _userService.getUserInfo();
        final newMeal = {
          'id': widget.meal?.id, // Include id if editing
          'mealName': _mealNameController.text,
          'createdByUser': user,
          'categories': _selectedCategories.map((category) => category.toJson()).toList(),
          'steps': _stepsControllers.map((controller) => controller.text).toList(),
          'ingredients': _ingredientsControllers.map((controller) => controller.text).toList(),
          'imagePath': widget.meal?.imagePath ?? '',
        };

        final createdMeal = widget.meal == null
            ? await _mealService.createMeal(newMeal)
            : await _mealService.updateMeal(widget.meal!.id.toString(), newMeal);

        if (_selectedImage != null) {
          await _mealService.uploadMealImage(createdMeal["id"].toString(), _selectedImage!);
        }

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Błąd podczas ${widget.meal == null ? 'dodawania' : 'edytowania'} posiłku: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(mealCategoryProvider);

    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.meal == null ? 'Dodaj przepis' : 'Edytuj przepis'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _mealNameController,
                      decoration: const InputDecoration(labelText: 'Nazwa posiłku'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Proszę podać nazwę posiłku';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    const Text('Kategorie'),
                    const SizedBox(height: 5.0),
                    SizedBox(
                      height: 200, // Ograniczamy wysokość do około 4 elementów
                      child: Container(
                        decoration: BoxDecoration(
                          color: theme.inputDecorationTheme.fillColor,
                          borderRadius: const BorderRadius.all(Radius.circular(15)),
                        ),
                        child: ListView.builder(
                          itemCount: categories.length,
                          itemBuilder: (context, index) {
                            final category = categories[index];
                            return CheckboxListTile(
                              side: BorderSide(color: (isDarkMode ? Colors.white : Colors.black)),
                              title: Text(category.name, style: Theme.of(context).textTheme.bodyMedium),
                              value: _selectedCategories.contains(category),
                              onChanged: (bool? value) {
                                setState(() {
                                  if (value == true) {
                                    _selectedCategories.add(category);
                                  } else {
                                    _selectedCategories.remove(category);
                                  }
                                });
                              },
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    const Text('Składniki'),
                    IngredientField(
                      controllers: _ingredientsControllers,
                      listKey: _ingredientsListKey,
                    ),
                    const SizedBox(height: 16.0),
                    const Text('Kroki'),
                    StepField(
                      controllers: _stepsControllers,
                      listKey: _stepsListKey,
                    ),
                    const SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: _submitForm,
                      child: Text(widget.meal == null ? 'Dodaj posiłek' : 'Zapisz zmiany'),
                    ),
                    const SizedBox(height: 16.0),
                    _selectedImage == null
                        ? const Text('Brak wybranego zdjęcia')
                        : SizedBox(
                      height: 150, // Ustaw wysokość obrazu
                      child: Image.file(_selectedImage!),
                    ),
                    IconButton(
                      icon: const Icon(Icons.camera_alt),
                      onPressed: _pickImage,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
