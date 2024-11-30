import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';

import '../models/meal.dart';
import '../models/user.dart';
import '../providers/user_provider.dart';
import '../services/meal_service.dart';
import '../services/user_service.dart';
import 'add_edit_meal_screen.dart';

class MealDetailScreen extends ConsumerStatefulWidget {
  final Meal meal;
  final File? imageFile;

  MealDetailScreen({Key? key, required this.meal, this.imageFile}) : super(key: key);

  @override
  _MealDetailScreenState createState() => _MealDetailScreenState();
}

class _MealDetailScreenState extends ConsumerState<MealDetailScreen> {
  Meal? _meal;
  File? _imageFile;
  bool _isLoading = false;
  final MealService _mealService = MealService();
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    _meal = widget.meal;
    _imageFile = widget.imageFile;
  }

  Future<void> fetchMealDetails() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final updatedMeal = await _mealService.getMealById(_meal!.id.toString());
      final updatedImageFile = await _mealService.getImageFile(_meal!.id.toString());
      setState(() {
        _meal = updatedMeal;
        _imageFile = updatedImageFile;
      });
    } catch (e) {
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _shareMeal() async {
    final allUsers = await _userService.getAllUsers();
    final currentUser = ref.read(userProvider);
    final usersToShow = allUsers.where((user) => user.id != currentUser!.id).toList();
    final theme = Theme.of(context);
    Set<User> accessibleUsers = Set.from(_meal!.accessibleUsers); // Use a local Set to manage the state

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            side: BorderSide(color: theme.primaryColor, width: 4),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const Svg('assets/main/dialog_background.svg'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(Colors.white.withOpacity(0.6), BlendMode.lighten),
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Udostępnij przepis',
                  style: theme.textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16.0),
                SizedBox(
                  width: double.maxFinite,
                  child: StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) {
                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: usersToShow.length,
                        itemBuilder: (context, index) {
                          final user = usersToShow[index];
                          return CheckboxListTile(
                            title: Text(
                              '${user.firstName} ${user.lastName}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            value: accessibleUsers.contains(user),
                            onChanged: (bool? value) {
                              setState(() {
                                if (value == true) {
                                  accessibleUsers.add(user);
                                } else {
                                  accessibleUsers.remove(user);
                                }
                              });
                            },
                            activeColor: theme.colorScheme.primary,
                            checkColor: theme.colorScheme.onPrimary,
                            selectedTileColor: theme.primaryColor.withOpacity(0.1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'Anuluj',
                        style: theme.textTheme.bodyMedium!.copyWith(
                          color: theme.textTheme.headlineLarge!.color,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        try {
                          setState(() {
                            _meal!.accessibleUsers = accessibleUsers; // Update the meal's accessible users
                          });
                          await _mealService.updateMeal(_meal!.id.toString(), _meal!.toJson());
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Przepis został udostępniony.')),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Błąd podczas udostępniania przepisu: $e')),
                          );
                        }
                      },
                      child: Text(
                        'Zapisz',
                        style: theme.textTheme.bodyMedium!.copyWith(
                          color: theme.textTheme.headlineLarge!.color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );

      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final currentUser = ref.watch(userProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _meal!.mealName,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: Svg('assets/main/app_bar.svg'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        actions: [
          if (currentUser != null && _meal!.createdByUser.id == currentUser.id) ...[
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddEditMealScreen(meal: _meal),
                  ),
                ).then((_) {
                  fetchMealDetails();
                });
              },
            ),
            IconButton(
              icon: Icon(Icons.share),
              onPressed: _shareMeal,
            ),
          ],
        ],
      ),
      body: _isLoading
          ? Container(
        decoration: getDecoration(),
        child: const Center(child: CircularProgressIndicator()),
      )
          : Container(
        height: double.infinity,
        decoration: getDecoration(),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Hero(
                tag: 'mealImage_${_meal!.id}',
                child: _imageFile != null
                    ? Image.file(
                  _imageFile!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 300,
                )
                    : Container(
                  height: 300,
                  color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                  alignment: Alignment.center,
                  child: Icon(Icons.image_not_supported, color: isDarkMode ? Colors.white : Colors.black, size: 50),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Składniki',
                  style: theme.textTheme.headlineLarge?.copyWith(
                    color: Colors.white,
                    shadows: getTextShadow(),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _meal!.ingredients
                      .map((ingredient) =>
                      Text(
                        '- $ingredient',
                        style: TextStyle(
                          color: Colors.white,
                          shadows: getTextShadow(),
                        ),
                      ))
                      .toList(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Kroki',
                  style: theme.textTheme.headlineLarge?.copyWith(
                    color: Colors.white,
                    shadows: getTextShadow(),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _meal!.steps
                      .map((step) =>
                      Text(
                        '- $step',
                        style: TextStyle(
                          color: Colors.white,
                          shadows: getTextShadow(),
                        ),
                      ))
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  BoxDecoration getDecoration() {
    return BoxDecoration(
      image: DecorationImage(
        image: const Svg('assets/main/home_body.svg'),
        fit: BoxFit.cover,
        colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.darken),
      ),
    );
  }

  List<Shadow> getTextShadow() {
    return [
      const Shadow(
        offset: Offset(-1, -1),
        color: Colors.black,
        blurRadius: 5.0,
      ),
      const Shadow(
        offset: Offset(1, 1),
        color: Colors.black,
        blurRadius: 5.0,
      ),
    ];
  }
}
