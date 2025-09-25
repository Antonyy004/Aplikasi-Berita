import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../pages/home_page.dart';
import '../pages/category_page.dart';
import '../pages/profile_page.dart';

class CustomNavBarRectangular extends StatefulWidget {
  const CustomNavBarRectangular({super.key});

  @override
  CustomNavBarRectangularState createState() => CustomNavBarRectangularState();
}

class CustomNavBarRectangularState extends State<CustomNavBarRectangular> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Warna tema
    final primaryColor = Theme.of(context).colorScheme.primary;
    final secondaryColor = Theme.of(context).colorScheme.secondary;
    final backgroundColor = Theme.of(context).colorScheme.surface;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(
          top: BorderSide(
            color: Colors.black,
            width: 2.0,
          ),
        ),
      ),
      child: BottomAppBar(
        color: Colors.transparent,
        elevation: 0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            NavBarIcon(
              text: "Home",
              icon: CupertinoIcons.home,
              selected: _selectedIndex == 0,
              onPressed: () => _onNavBarItemTapped(0, context),
              selectedColor: Colors.red, // Set merah
              defaultColor: Colors.red, // Set merah juga untuk default
            ),
            NavBarIcon(
              text: "Category",
              icon: CupertinoIcons.cube,
              selected: _selectedIndex == 1,
              onPressed: () => _onNavBarItemTapped(1, context),
              selectedColor: Colors.red, // Set merah
              defaultColor: Colors.red, // Set merah juga untuk default
            ),
            NavBarIcon(
              text: "Profile",
              icon: CupertinoIcons.person,
              selected: _selectedIndex == 2,
              onPressed: () => _onNavBarItemTapped(2, context),
              selectedColor: Colors.red, // Set merah
              defaultColor: Colors.red, // Set merah juga untuk default
            ),
          ],
        ),
      ),
    );
  }

  void _onNavBarItemTapped(int index, BuildContext context) {
    setState(() {
      _selectedIndex = index;
    });

    // Menavigasi ke halaman yang sesuai menggunakan pushReplacement tanpa animasi
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => HomePage(),
            transitionDuration: Duration.zero, // Menghilangkan efek transisi
          ),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => CategoryPage(),
            transitionDuration: Duration.zero, // Menghilangkan efek transisi
          ),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => ProfilePage(),
            transitionDuration: Duration.zero, // Menghilangkan efek transisi
          ),
        );
        break;
    }
  }
}

class NavBarIcon extends StatelessWidget {
  final String text;
  final IconData icon;
  final bool selected;
  final Function() onPressed;
  final Color defaultColor;
  final Color selectedColor;

  const NavBarIcon({
    super.key,
    required this.text,
    required this.icon,
    required this.selected,
    required this.onPressed,
    this.selectedColor = Colors.red, // Set merah
    this.defaultColor = Colors.red, // Set merah juga untuk default
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      splashColor: selectedColor.withOpacity(0.3), // Efek splash merah
      highlightColor: Colors.transparent,
      borderRadius: BorderRadius.circular(50),
      child: Icon(
        icon,
        size: 30,
        color: selected ? selectedColor : defaultColor, // Semua ikon merah
      ),
    );
  }
}
