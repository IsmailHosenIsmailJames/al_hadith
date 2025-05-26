import 'package:al_hadith/database/app_database.dart';
import 'package:al_hadith/screens/hadith/hadith_view.dart';
import 'package:al_hadith/theme/app_colors.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class ChapterView extends StatefulWidget {
  final List<Chapter> chapters;
  final Book book;
  const ChapterView({super.key, required this.chapters, required this.book});

  @override
  State<ChapterView> createState() => _ChapterViewState();
}

class _ChapterViewState extends State<ChapterView> {
  late List<Chapter> chapters = widget.chapters;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(color: AppColors.primary),
            child: Column(
              children: [
                AppBar(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  leading: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.arrow_back_ios_new_rounded),
                  ),
                  title: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.book.title,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "${widget.book.numberOfHadis} টি হাদিস ",
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),

                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    color: Theme.of(context).colorScheme.surface,
                  ),
                  padding: EdgeInsets.only(left: 10, right: 10, top: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.only(left: 10, right: 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            onChanged: (value) {
                              chapters = widget.chapters
                                  .where(
                                    (element) => element.title.contains(value),
                                  )
                                  .toList();
                              setState(() {});
                            },
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              hintText: "অধ্যায় সার্চ করুন। ",
                              border: InputBorder.none,
                            ),
                          ),
                        ),

                        Icon(FluentIcons.search_12_regular, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: chapters.isEmpty
                ? Center(child: Text("No Chapter found"))
                : ListView.builder(
                    itemCount: chapters.length,
                    itemBuilder: (context, index) {
                      Chapter chapter = chapters[index];
                      return Container(
                        margin: EdgeInsets.only(
                          left: 10,
                          right: 10,
                          bottom: 10,
                        ),

                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: TextButton(
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.all(20),
                            foregroundColor: Colors.black,
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadiusGeometry.circular(10),
                            ),
                          ),
                          onPressed: () async {
                            Navigator.push(
                              // ignore: use_build_context_synchronously
                              context,
                              MaterialPageRoute(
                                builder: (context) => HadithView(
                                  chapter: chapter,
                                  book: widget.book,
                                ),
                              ),
                            );
                          },
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                child: Text(
                                  chapter.chapterId.toString(),
                                  style: TextStyle(fontSize: 20),
                                ),
                              ),
                              Gap(16),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,

                                children: [
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width - 116,
                                    child: Text(
                                      chapter.title,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Text("হাদিসের রেঞ্জ: ${chapter.hadisRange}"),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
