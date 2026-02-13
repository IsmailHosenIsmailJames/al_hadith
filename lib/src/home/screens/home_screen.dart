import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatelessWidget {
  static const String routeName = '/home';
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Al Hadith',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: Text(
          'Welcome to the Home Screen',
          style: GoogleFonts.inter(
            fontSize: 18,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
      ),
    );
  }
}
