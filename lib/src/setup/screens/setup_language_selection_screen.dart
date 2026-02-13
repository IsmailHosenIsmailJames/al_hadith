import 'dart:convert';

import 'package:al_hadith/src/setup/models/hadith_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SetupLanguageSelectionScreen extends StatefulWidget {
  static const String routeName = '/setup-language-selection';
  const SetupLanguageSelectionScreen({super.key});

  @override
  State<SetupLanguageSelectionScreen> createState() =>
      _SetupLanguageSelectionScreenState();
}

class _SetupLanguageSelectionScreenState
    extends State<SetupLanguageSelectionScreen> {
  @override
  void initState() {
    super.initState();
    _loadHadithInfo();
  }

  Map<String, List<HadithInfo>>? hadithList;

  Future<void> _loadHadithInfo() async {
    final Map<String, dynamic> hadithRowData = Map<String, dynamic>.from(
      jsonDecode(await rootBundle.loadString("assets/all_info.json")),
    );
    setState(() {
      hadithList = Map.fromEntries(
        hadithRowData.entries.map((entry) {
          return MapEntry(
            entry.key,
            List<HadithInfo>.from(
              entry.value.map((x) => HadithInfo.fromMap(x)),
            ),
          );
        }),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Placeholder();
  }
}
