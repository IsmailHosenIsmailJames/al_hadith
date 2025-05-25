import 'package:al_hadith/screens/home/home_screen.dart';
import 'package:al_hadith/screens/navs/controller/nav_controller.dart';
import 'package:al_hadith/theme/app_colors.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Navs extends StatefulWidget {
  const Navs({super.key});

  @override
  State<Navs> createState() => _NavsState();
}

class _NavsState extends State<Navs> {
  PageController navPageController = PageController();
  final NavController navController = Get.put(NavController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(),
      body: PageView(
        controller: navPageController,
        children: [
          HomeScreen(),
          Container(
            alignment: Alignment.center,
            child: Text("Not Included in Task"),
          ),
          Container(
            alignment: Alignment.center,
            child: Text("Not Included in Task"),
          ),
          Container(
            alignment: Alignment.center,
            child: Text("Not Included in Task"),
          ),
        ],
      ),
      bottomNavigationBar: GetX<NavController>(
        builder: (controller) => BottomNavigationBar(
          currentIndex: controller.navIndex.value,
          onTap: (value) => setState(() {
            navPageController.animateToPage(
              value,
              duration: Duration(milliseconds: 200),
              curve: Curves.easeInOut,
            );
            controller.navIndex.value = value;
          }),
          showUnselectedLabels: false,
          showSelectedLabels: false,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: Theme.of(context).brightness == Brightness.light
              ? Colors.grey.shade900
              : Colors.grey.shade400,
          iconSize: 30,
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
              icon: Icon(
                controller.navIndex.value == 0
                    ? FluentIcons.home_20_filled
                    : FluentIcons.home_20_regular,
              ),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(
                controller.navIndex.value == 1
                    ? FluentIcons.book_open_24_filled
                    : FluentIcons.book_open_24_regular,
              ),
              label: "Subject",
            ),
            BottomNavigationBarItem(
              icon: Icon(
                controller.navIndex.value == 2
                    ? FluentIcons.book_24_filled
                    : FluentIcons.book_24_regular,
              ),
              label: "Tahokik",
            ),
            BottomNavigationBarItem(
              icon: Icon(
                controller.navIndex.value == 3
                    ? FluentIcons.bookmark_24_filled
                    : FluentIcons.bookmark_24_regular,
              ),
              label: "Collection",
            ),
          ],
        ),
      ),
    );
  }
}
