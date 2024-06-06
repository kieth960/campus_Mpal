import 'package:flutter/material.dart';
import 'package:campus_pal/services/recipes_service.dart';
import 'meal_planner.dart';
import 'package:campus_pal/models/meal_planner.dart';
import 'load_meal_plan_screen.dart';
import 'package:campus_pal/views/offline_plan/recipe_list.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _controller.forward();
    _toggleVisibility();
  }

  void _toggleVisibility() {
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _isVisible = true;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Campus Meal Pal'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return const RecipeListScreen();
              }));
            },
            icon: const Icon(
              Icons.offline_bolt,
              size: 30,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ScaleTransition(
              scale: _scaleAnimation,
              child: Image.asset(
                'assets/lotties/food_pics/welcome.jpg', // Path to your image
                height: 200,
              ),
            ),
            SizedBox(height: 20),
            AnimatedOpacity(
              opacity: _isVisible ? 1.0 : 0.0,
              duration: const Duration(seconds: 1),
              child: Column(
                children: [
                  Text(
                    'Welcome to Campus Meal Pal!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Plan your meals with ease and enjoy delicious recipes tailored for you.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: _generateMealPlan,
              child: Text('Generate Meal Plan'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _loadSavedMealPlan,
              child: Text('Load Saved Meal Plan'),
            ),
          ],
        ),
      ),
    );
  }

  void _generateMealPlan() async {
    try {
      // Generate meal plan for the week
      final filteredRecipes = await RecipeService().getRecipes();
      final mealPlanForWeek =
          MealPlanner.generateMealPlanForWeek(filteredRecipes);

      // Navigate to MealPlanScreen and pass the generated meal plan
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MealPlanScreen(mealPlan: mealPlanForWeek),
        ),
      );
    } catch (error) {
      // Handle errors gracefully
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to generate meal plan: $error')),
      );
    }
  }

  void _loadSavedMealPlan() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LoadMealPlanScreen(),
      ),
    );
  }
}
