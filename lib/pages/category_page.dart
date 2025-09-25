import 'package:flutter/material.dart';
import '../components/bottom_navbar.dart'; // Pastikan untuk mengimpor file navbar

class CategoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Category Page'),
      ),
      body: Center(
        child: Text("Welcome to the Category Page"),
      ),
      bottomNavigationBar: CustomNavBarRectangular(), // Panggil CustomNavBarRectangular di sini
    );
  }
}
