import 'dart:convert';

class HadithInfo {
  String? book;
  String? name;
  int? hadithCount;
  int? sectionCount;
  String? checksum;
  String? zipPath;
  int? fileSize;
  int? zipSize;

  HadithInfo({
    this.book,
    this.name,
    this.hadithCount,
    this.sectionCount,
    this.checksum,
    this.zipPath,
    this.fileSize,
    this.zipSize,
  });

  HadithInfo copyWith({
    String? book,
    String? name,
    int? hadithCount,
    int? sectionCount,
    String? checksum,
    String? zipPath,
    int? fileSize,
    int? zipSize,
  }) => HadithInfo(
    book: book ?? this.book,
    name: name ?? this.name,
    hadithCount: hadithCount ?? this.hadithCount,
    sectionCount: sectionCount ?? this.sectionCount,
    checksum: checksum ?? this.checksum,
    zipPath: zipPath ?? this.zipPath,
    fileSize: fileSize ?? this.fileSize,
    zipSize: zipSize ?? this.zipSize,
  );

  factory HadithInfo.fromJson(String str) =>
      HadithInfo.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory HadithInfo.fromMap(Map<String, dynamic> json) => HadithInfo(
    book: json["book"],
    name: json["name"],
    hadithCount: json["hadith_count"],
    sectionCount: json["section_count"],
    checksum: json["checksum"],
    zipPath: json["zip_path"],
    fileSize: json["file_size"],
    zipSize: json["zip_size"],
  );

  Map<String, dynamic> toMap() => {
    "book": book,
    "name": name,
    "hadith_count": hadithCount,
    "section_count": sectionCount,
    "checksum": checksum,
    "zip_path": zipPath,
    "file_size": fileSize,
    "zip_size": zipSize,
  };
}
