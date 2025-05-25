import 'package:al_hadith/database/app_database.dart';
import 'package:al_hadith/main.dart';
import 'package:al_hadith/res/sample_resources.dart';
import 'package:al_hadith/screens/chapthers/chapter_view.dart';
import 'package:al_hadith/screens/home/controller/home_controller.dart';
import 'package:al_hadith/theme/app_colors.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  PageController todayHadithPageController = PageController();
  HomeController homeController = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return SingleChildScrollView(
      child: Stack(
        children: [
          Container(
            height: 400,
            width: screenSize.width,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              image: DecorationImage(
                alignment: Alignment.bottomCenter,
                colorFilter: ColorFilter.mode(
                  Color(0xff23836D),
                  BlendMode.srcIn,
                ),
                image: AssetImage("assets/images/home_bg.png"),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppBar(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  title: Text(
                    'আল হাদিস',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  centerTitle: true,
                  actions: [
                    Padding(
                      padding: EdgeInsets.only(right: 15),
                      child: IconButton(
                        onPressed: () {},

                        icon: Icon(FluentIcons.search_12_regular),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 200,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: PageView.builder(
                          itemCount: 10,
                          controller: todayHadithPageController,
                          onPageChanged: (value) =>
                              homeController.initTodayHadithPageNumber.value =
                                  value,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "এ মর্মে আল্লাহ্ তা’আলার বাণীঃ ’’নিশ্চয় আমি আপনার প্রতি সেরূপ ওয়াহী প্রেরণ করেছি যেরূপ নূহ ও তাঁর পরবর্তী নবীদের (নবীদের) প্রতি ওয়াহী প্রেরণ করেছিলাম।’’ (সূরাহ্ আন-নিসা ৪/১৬৩)",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  Gap(20),
                                  Text(
                                    "[ওয়াহ্‌য়ীর সূচনা]",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),

                      SizedBox(
                        height: 14,
                        child: GetX<HomeController>(
                          builder: (controller) => Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              10,
                              (index) => Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: CircleAvatar(
                                  radius:
                                      index ==
                                          controller
                                              .initTodayHadithPageNumber
                                              .value
                                      ? 5
                                      : 3,
                                  backgroundColor: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Gap(30),
                Container(
                  margin: EdgeInsets.all(10),
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.light
                        ? Colors.grey.shade100
                        : Colors.grey.shade900,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [boxShadow],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: List.generate(4, (index) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,

                        children: [
                          Icon(optionsIcon[index]),
                          Gap(8),
                          Text(
                            optionsName[index],
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
                Gap(10),
                Padding(
                  padding: const EdgeInsets.only(left: 10, bottom: 10),
                  child: Text(
                    "সব হাদিসের বই",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
                FutureBuilder(
                  future: db.getAllBooks(),
                  builder: (context, snapshot) {
                    if (!(snapshot.connectionState == ConnectionState.done)) {
                      return Column(
                        children: List.generate(5, (index) {
                          return Container(
                            height: 60,
                            width: screenSize.width,
                            decoration: BoxDecoration(
                              color: Colors.grey.withValues(alpha: 0.1),
                            ),
                          );
                        }),
                      );
                    } else {
                      List<Book> data = snapshot.data!;
                      return Column(
                        children: List.generate(data.length, (index) {
                          Book book = data[index];
                          return Container(
                            margin: EdgeInsets.only(
                              left: 10,
                              right: 10,
                              bottom: 10,
                            ),

                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [boxShadow],
                            ),
                            child: TextButton(
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.all(10),
                                backgroundColor:
                                    Theme.of(context).brightness ==
                                        Brightness.light
                                    ? Colors.white
                                    : Colors.grey.shade900,
                                foregroundColor:
                                    Theme.of(context).brightness ==
                                        Brightness.light
                                    ? Colors.grey.shade900
                                    : Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () async {
                                final List<Chapter> chapters = await db
                                    .getChaptersForBook(book.id);
                                Navigator.push(
                                  // ignore: use_build_context_synchronously
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChapterView(
                                      chapters: chapters,
                                      book: book,
                                    ),
                                  ),
                                );
                              },
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Color(
                                      int.parse(
                                        "ff${book.colorCode.substring(1)}",
                                        radix: 16,
                                      ),
                                    ),
                                    foregroundColor: Colors.white,
                                    child: Text(
                                      book.abvrCode,
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Gap(15),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        book.title,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        book.titleAr,
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ],
                                  ),
                                  Spacer(),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        book.numberOfHadis.toString(),
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        "হাদিস",
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
