import 'package:flutter/material.dart';

class NutritionalInfoScreen extends StatelessWidget {
  final String nutritionalInfo;

  NutritionalInfoScreen({required this.nutritionalInfo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nutritional Information'),
        backgroundColor: Color(0xff0cb945),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text(nutritionalInfo),
        ),
      ),
    );
  }
}
