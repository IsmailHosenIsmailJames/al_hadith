import 'package:al_hadith/database/app_database.dart';
import 'package:al_hadith/res/sample_resources.dart';
import 'package:al_hadith/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';

class HadithView extends StatefulWidget {
  final Chapter chapter;
  final Book book;
  const HadithView({super.key, required this.chapter, required this.book});

  @override
  State<HadithView> createState() => _HadithViewState();
}

class _HadithViewState extends State<HadithView> {
  ScrollController scrollController = ScrollController();

  void showPopUpForOption() {
    showModalBottomSheet(
      enableDrag: true,
      context: context,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    "More Option",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close),
                  ),
                ],
              ),
              Gap(20),
              Expanded(
                child: ListView.builder(
                  itemCount: optionsPopupHadithName.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Row(
                        children: [
                          SizedBox(
                            height: 15,
                            width: 15,
                            child: SvgPicture.string(
                              optionPopupHadithIcon[index],
                            ),
                          ),
                          Gap(15),
                          Text(optionsPopupHadithName[index]),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  int indexOfOffset = 0;
  int limit = 10;
  int? maxCount;
  @override
  void initState() {
    loadHadith(indexOfOffset);
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        if (!isLoading) {
          indexOfOffset++;
          loadHadith(indexOfOffset);
        }
      }
    });
    db
        .getTotalHadithsCount(
          bookId: widget.chapter.bookId,
          chapterId: widget.chapter.chapterId,
        )
        .then((value) => maxCount = value);
    super.initState();
  }

  List<Hadith> hadithList = [];
  bool isLoading = false;

  Future<void> loadHadith(int offset) async {
    List<Hadith> hadithInPage = await db.getHadithsPaginated(
      limit: limit,
      bookId: widget.chapter.bookId,
      chapterId: widget.chapter.chapterId,
      offset: offset,
    );
    hadithList.addAll(hadithInPage);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        elevation: 0,

        backgroundColor: AppColors.primary,
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
      body: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: ListView.builder(
          padding: EdgeInsets.all(6),
          controller: scrollController,
          itemCount: hadithList.length,
          itemBuilder: (context, index) {
            Hadith hadith = hadithList[index];
            return Column(
              children: [
                Container(
                  margin: EdgeInsets.only(top: 10, left: 10, right: 10),
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    children: [
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text:
                                  "${widget.chapter.chapterId}/${hadith.hadithId} Chapter: ",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                            TextSpan(
                              text:
                                  "How the Divine Revelation started being revealed to Allah's Messenger",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(color: Color(0xffEFEFEF)),
                      Text(
                        "In publishing and graphic design, Lorem ipsum is a placeholder text commonly used to demonstrate the visual form of a document or a typeface without relying on meaningful content.",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 10, left: 10, right: 10),
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: 34.64,
                            height: 37.83,
                            child: Stack(
                              children: [
                                SvgPicture.string(hexagon),
                                Center(
                                  child: Text(
                                    widget.book.abvrCode,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Gap(10),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: "Hadith No: ",
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xff5D646F),
                                      ),
                                    ),
                                    TextSpan(
                                      text: hadith.hadithId.toString().padLeft(
                                        2,
                                        "0",
                                      ),
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              Text(
                                widget.book.title,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          Spacer(),
                          SizedBox(
                            height: 32,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.only(left: 5, right: 5),
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                              ),
                              onPressed: () {},
                              child: Text(
                                "Sahih",
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                          Gap(4),
                          SizedBox(
                            height: 40,
                            width: 30,
                            child: IconButton(
                              style: IconButton.styleFrom(
                                padding: EdgeInsets.zero,
                              ),
                              onPressed: () {
                                showPopUpForOption();
                              },
                              icon: SvgPicture.string(
                                """<svg width="4" height="16" viewBox="0 0 4 16" fill="none" xmlns="http://www.w3.org/2000/svg">
                              <path d="M2.45508 2.75C2.25617 2.75 2.0654 2.67098 1.92475 2.53033C1.7841 2.38968 1.70508 2.19891 1.70508 2C1.70508 1.80109 1.7841 1.61032 1.92475 1.46967C2.0654 1.32902 2.25617 1.25 2.45508 1.25C2.65399 1.25 2.84476 1.32902 2.98541 1.46967C3.12606 1.61032 3.20508 1.80109 3.20508 2C3.20508 2.19891 3.12606 2.38968 2.98541 2.53033C2.84476 2.67098 2.65399 2.75 2.45508 2.75ZM2.45508 8.75C2.25617 8.75 2.0654 8.67098 1.92475 8.53033C1.7841 8.38968 1.70508 8.19891 1.70508 8C1.70508 7.80109 1.7841 7.61032 1.92475 7.46967C2.0654 7.32902 2.25617 7.25 2.45508 7.25C2.65399 7.25 2.84476 7.32902 2.98541 7.46967C3.12606 7.61032 3.20508 7.80109 3.20508 8C3.20508 8.19891 3.12606 8.38968 2.98541 8.53033C2.84476 8.67098 2.65399 8.75 2.45508 8.75ZM2.45508 14.75C2.25617 14.75 2.0654 14.671 1.92475 14.5303C1.7841 14.3897 1.70508 14.1989 1.70508 14C1.70508 13.8011 1.7841 13.6103 1.92475 13.4697C2.0654 13.329 2.25617 13.25 2.45508 13.25C2.65399 13.25 2.84476 13.329 2.98541 13.4697C3.12606 13.6103 3.20508 13.8011 3.20508 14C3.20508 14.1989 3.12606 14.3897 2.98541 14.5303C2.84476 14.671 2.65399 14.75 2.45508 14.75Z" stroke="#353535" stroke-opacity="0.3" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
                              </svg>
                              """,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Gap(33),
                      Text(
                        hadith.ar.toString(),
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          fontSize: 20,
                          height: 2,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Gap(20),
                      Text(
                        hadith.narrator.toString(),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                      Gap(10),
                      Text(hadith.bn.toString()),
                      Gap(20),
                      Text(
                        "(See also 51, 2681, 2804, 2941, 2978, 3174, 4553, 5980, 6260, 7196, 7541) (Modern Publication: 6, Islamic Foundation: 6)",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
