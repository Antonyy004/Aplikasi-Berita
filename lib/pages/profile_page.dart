import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage ({super.key});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    throw UnimplementedError();
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Center(
          child: Text('Halaman Profil',
          style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
    );
  }
}