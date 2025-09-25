import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BottomNavRectanglePainter extends CustomPainter {
  Color backgroundColor;

  BottomNavRectanglePainter({this.backgroundColor = Colors.black});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;

    Path path = Path()
      ..lineTo(0, 0)
      ..lineTo(0, size.height)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class CustomNavBarRectangular extends StatefulWidget {
  const CustomNavBarRectangular({super.key});

  @override
  CustomNavBarRectangularState createState() => CustomNavBarRectangularState();
}

class CustomNavBarRectangularState extends State<CustomNavBarRectangular> {
  // Track selected index
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double height = 56;

    // Use theme colors
    final primaryColor = Theme.of(context).colorScheme.primary;
    final secondaryColor = Theme.of(context).colorScheme.secondary;
    final backgroundColor = Theme.of(context).colorScheme.surface;

    return BottomAppBar(
      color: Colors.transparent,
      elevation: 0,
      child: Stack(
        children: [
          CustomPaint(
            size: Size(size.width, height),
            painter: BottomNavRectanglePainter(backgroundColor: backgroundColor),
          ),
          SizedBox(
            height: height,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                NavBarIcon(
                  text: "Home",
                  icon: CupertinoIcons.home,
                  selected: _selectedIndex == 0,
                  onPressed: () => _onNavBarItemTapped(0),
                  defaultColor: secondaryColor,
                  selectedColor: primaryColor,
                ),
                NavBarIcon(
                  text: "Category",
                  icon: CupertinoIcons.cube,
                  selected: _selectedIndex == 3,
                  onPressed: () => _onNavBarItemTapped(3),
                  selectedColor: primaryColor,
                  defaultColor: secondaryColor,
                ),
                NavBarIcon(
                  text: "Calendar",
                  icon: CupertinoIcons.person,
                  selected: _selectedIndex == 3,
                  onPressed: () => _onNavBarItemTapped(3),
                  selectedColor: primaryColor,
                  defaultColor: secondaryColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Update index when an item is tapped
  void _onNavBarItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Navigate to different pages based on the tapped index
    switch (index) {
      case 0:
      // Navigate to Home
        break;
      case 1:
      // Navigate to Search
        break;
      case 2:
      // Navigate to Cart
        break;
      case 3:
      // Navigate to Profile
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

  const NavBarIcon(
      {super.key,
        required this.text,
        required this.icon,
        required this.selected,
        required this.onPressed,
        this.selectedColor = const Color(0xffFF8527),
        this.defaultColor = Colors.black54});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      icon: CircleAvatar(
        backgroundColor: selected ? Colors.white : Colors.transparent,
        child: Icon(
          icon,
          size: 25,
          color: selected ? Colors.black : defaultColor,
        ),
      ),
    );
  }
}
