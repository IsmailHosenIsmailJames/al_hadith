import 'package:flutter/material.dart';

class HadithResourcesSelectionScreen extends StatefulWidget {
  static const String routeName = '/hadith_resources_selection';
  const HadithResourcesSelectionScreen({super.key});

  @override
  State<HadithResourcesSelectionScreen> createState() =>
      _HadithResourcesSelectionScreenState();
}

class _HadithResourcesSelectionScreenState
    extends State<HadithResourcesSelectionScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Hadith Resources Selection')),
    );
  }
}
