import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';

List optionsName = ["সর্বশেষ", "অ্যাপস", "হাদিসে যান", "সদাকা"];
List optionsIcon = [
  FluentIcons.clock_24_regular,
  FluentIcons.book_open_24_regular,
  Icons.send,
  Icons.add_box,
];
BoxShadow boxShadow = BoxShadow(
  color: Colors.grey.withValues(alpha: 0.2),
  offset: Offset(0, 3),
  spreadRadius: 3,
  blurRadius: 10,
);
