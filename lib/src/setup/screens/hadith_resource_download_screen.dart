import 'package:flutter/material.dart';

class HadithResourceDownloadScreen extends StatefulWidget {
  static const String routeName = '/hadith_resource_download';
  const HadithResourceDownloadScreen({super.key});

  @override
  State<HadithResourceDownloadScreen> createState() =>
      _HadithResourceDownloadScreenState();
}

class _HadithResourceDownloadScreenState
    extends State<HadithResourceDownloadScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Hadith Resource Download')),
    );
  }
}
