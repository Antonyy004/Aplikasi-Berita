import 'package:flutter/material.dart';
import '../components/bottom_navbar.dart'; // Pastikan mengimpor navbar

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Page'),
      ),
      body: Center(
        child: Text("Welcome to the Profile Page"),
      ),
      bottomNavigationBar: CustomNavBarRectangular(), // Memanggil navbar di sini
    );
  }
}
