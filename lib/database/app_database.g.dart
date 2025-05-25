// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $BooksTable extends Books with TableInfo<$BooksTable, Book> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BooksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleArMeta = const VerificationMeta(
    'titleAr',
  );
  @override
  late final GeneratedColumn<String> titleAr = GeneratedColumn<String>(
    'title_ar',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _numberOfHadisMeta = const VerificationMeta(
    'numberOfHadis',
  );
  @override
  late final GeneratedColumn<int> numberOfHadis = GeneratedColumn<int>(
    'number_of_hadis',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _abvrCodeMeta = const VerificationMeta(
    'abvrCode',
  );
  @override
  late final GeneratedColumn<String> abvrCode = GeneratedColumn<String>(
    'abvr_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bookNameMeta = const VerificationMeta(
    'bookName',
  );
  @override
  late final GeneratedColumn<String> bookName = GeneratedColumn<String>(
    'book_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bookDescriptionMeta = const VerificationMeta(
    'bookDescription',
  );
  @override
  late final GeneratedColumn<String> bookDescription = GeneratedColumn<String>(
    'book_descr',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorCodeMeta = const VerificationMeta(
    'colorCode',
  );
  @override
  late final GeneratedColumn<String> colorCode = GeneratedColumn<String>(
    'color_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    titleAr,
    numberOfHadis,
    abvrCode,
    bookName,
    bookDescription,
    colorCode,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'books';
  @override
  VerificationContext validateIntegrity(
    Insertable<Book> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('title_ar')) {
      context.handle(
        _titleArMeta,
        titleAr.isAcceptableOrUnknown(data['title_ar']!, _titleArMeta),
      );
    } else if (isInserting) {
      context.missing(_titleArMeta);
    }
    if (data.containsKey('number_of_hadis')) {
      context.handle(
        _numberOfHadisMeta,
        numberOfHadis.isAcceptableOrUnknown(
          data['number_of_hadis']!,
          _numberOfHadisMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_numberOfHadisMeta);
    }
    if (data.containsKey('abvr_code')) {
      context.handle(
        _abvrCodeMeta,
        abvrCode.isAcceptableOrUnknown(data['abvr_code']!, _abvrCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_abvrCodeMeta);
    }
    if (data.containsKey('book_name')) {
      context.handle(
        _bookNameMeta,
        bookName.isAcceptableOrUnknown(data['book_name']!, _bookNameMeta),
      );
    } else if (isInserting) {
      context.missing(_bookNameMeta);
    }
    if (data.containsKey('book_descr')) {
      context.handle(
        _bookDescriptionMeta,
        bookDescription.isAcceptableOrUnknown(
          data['book_descr']!,
          _bookDescriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_bookDescriptionMeta);
    }
    if (data.containsKey('color_code')) {
      context.handle(
        _colorCodeMeta,
        colorCode.isAcceptableOrUnknown(data['color_code']!, _colorCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_colorCodeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Book map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Book(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      titleAr: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title_ar'],
      )!,
      numberOfHadis: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}number_of_hadis'],
      )!,
      abvrCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}abvr_code'],
      )!,
      bookName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}book_name'],
      )!,
      bookDescription: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}book_descr'],
      )!,
      colorCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color_code'],
      )!,
    );
  }

  @override
  $BooksTable createAlias(String alias) {
    return $BooksTable(attachedDatabase, alias);
  }
}

class Book extends DataClass implements Insertable<Book> {
  final int id;
  final String title;
  final String titleAr;
  final int numberOfHadis;
  final String abvrCode;
  final String bookName;
  final String bookDescription;
  final String colorCode;
  const Book({
    required this.id,
    required this.title,
    required this.titleAr,
    required this.numberOfHadis,
    required this.abvrCode,
    required this.bookName,
    required this.bookDescription,
    required this.colorCode,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['title_ar'] = Variable<String>(titleAr);
    map['number_of_hadis'] = Variable<int>(numberOfHadis);
    map['abvr_code'] = Variable<String>(abvrCode);
    map['book_name'] = Variable<String>(bookName);
    map['book_descr'] = Variable<String>(bookDescription);
    map['color_code'] = Variable<String>(colorCode);
    return map;
  }

  BooksCompanion toCompanion(bool nullToAbsent) {
    return BooksCompanion(
      id: Value(id),
      title: Value(title),
      titleAr: Value(titleAr),
      numberOfHadis: Value(numberOfHadis),
      abvrCode: Value(abvrCode),
      bookName: Value(bookName),
      bookDescription: Value(bookDescription),
      colorCode: Value(colorCode),
    );
  }

  factory Book.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Book(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      titleAr: serializer.fromJson<String>(json['titleAr']),
      numberOfHadis: serializer.fromJson<int>(json['numberOfHadis']),
      abvrCode: serializer.fromJson<String>(json['abvrCode']),
      bookName: serializer.fromJson<String>(json['bookName']),
      bookDescription: serializer.fromJson<String>(json['bookDescription']),
      colorCode: serializer.fromJson<String>(json['colorCode']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'titleAr': serializer.toJson<String>(titleAr),
      'numberOfHadis': serializer.toJson<int>(numberOfHadis),
      'abvrCode': serializer.toJson<String>(abvrCode),
      'bookName': serializer.toJson<String>(bookName),
      'bookDescription': serializer.toJson<String>(bookDescription),
      'colorCode': serializer.toJson<String>(colorCode),
    };
  }

  Book copyWith({
    int? id,
    String? title,
    String? titleAr,
    int? numberOfHadis,
    String? abvrCode,
    String? bookName,
    String? bookDescription,
    String? colorCode,
  }) => Book(
    id: id ?? this.id,
    title: title ?? this.title,
    titleAr: titleAr ?? this.titleAr,
    numberOfHadis: numberOfHadis ?? this.numberOfHadis,
    abvrCode: abvrCode ?? this.abvrCode,
    bookName: bookName ?? this.bookName,
    bookDescription: bookDescription ?? this.bookDescription,
    colorCode: colorCode ?? this.colorCode,
  );
  Book copyWithCompanion(BooksCompanion data) {
    return Book(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      titleAr: data.titleAr.present ? data.titleAr.value : this.titleAr,
      numberOfHadis: data.numberOfHadis.present
          ? data.numberOfHadis.value
          : this.numberOfHadis,
      abvrCode: data.abvrCode.present ? data.abvrCode.value : this.abvrCode,
      bookName: data.bookName.present ? data.bookName.value : this.bookName,
      bookDescription: data.bookDescription.present
          ? data.bookDescription.value
          : this.bookDescription,
      colorCode: data.colorCode.present ? data.colorCode.value : this.colorCode,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Book(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('titleAr: $titleAr, ')
          ..write('numberOfHadis: $numberOfHadis, ')
          ..write('abvrCode: $abvrCode, ')
          ..write('bookName: $bookName, ')
          ..write('bookDescription: $bookDescription, ')
          ..write('colorCode: $colorCode')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    titleAr,
    numberOfHadis,
    abvrCode,
    bookName,
    bookDescription,
    colorCode,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Book &&
          other.id == this.id &&
          other.title == this.title &&
          other.titleAr == this.titleAr &&
          other.numberOfHadis == this.numberOfHadis &&
          other.abvrCode == this.abvrCode &&
          other.bookName == this.bookName &&
          other.bookDescription == this.bookDescription &&
          other.colorCode == this.colorCode);
}

class BooksCompanion extends UpdateCompanion<Book> {
  final Value<int> id;
  final Value<String> title;
  final Value<String> titleAr;
  final Value<int> numberOfHadis;
  final Value<String> abvrCode;
  final Value<String> bookName;
  final Value<String> bookDescription;
  final Value<String> colorCode;
  const BooksCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.titleAr = const Value.absent(),
    this.numberOfHadis = const Value.absent(),
    this.abvrCode = const Value.absent(),
    this.bookName = const Value.absent(),
    this.bookDescription = const Value.absent(),
    this.colorCode = const Value.absent(),
  });
  BooksCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    required String titleAr,
    required int numberOfHadis,
    required String abvrCode,
    required String bookName,
    required String bookDescription,
    required String colorCode,
  }) : title = Value(title),
       titleAr = Value(titleAr),
       numberOfHadis = Value(numberOfHadis),
       abvrCode = Value(abvrCode),
       bookName = Value(bookName),
       bookDescription = Value(bookDescription),
       colorCode = Value(colorCode);
  static Insertable<Book> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? titleAr,
    Expression<int>? numberOfHadis,
    Expression<String>? abvrCode,
    Expression<String>? bookName,
    Expression<String>? bookDescription,
    Expression<String>? colorCode,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (titleAr != null) 'title_ar': titleAr,
      if (numberOfHadis != null) 'number_of_hadis': numberOfHadis,
      if (abvrCode != null) 'abvr_code': abvrCode,
      if (bookName != null) 'book_name': bookName,
      if (bookDescription != null) 'book_descr': bookDescription,
      if (colorCode != null) 'color_code': colorCode,
    });
  }

  BooksCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<String>? titleAr,
    Value<int>? numberOfHadis,
    Value<String>? abvrCode,
    Value<String>? bookName,
    Value<String>? bookDescription,
    Value<String>? colorCode,
  }) {
    return BooksCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      titleAr: titleAr ?? this.titleAr,
      numberOfHadis: numberOfHadis ?? this.numberOfHadis,
      abvrCode: abvrCode ?? this.abvrCode,
      bookName: bookName ?? this.bookName,
      bookDescription: bookDescription ?? this.bookDescription,
      colorCode: colorCode ?? this.colorCode,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (titleAr.present) {
      map['title_ar'] = Variable<String>(titleAr.value);
    }
    if (numberOfHadis.present) {
      map['number_of_hadis'] = Variable<int>(numberOfHadis.value);
    }
    if (abvrCode.present) {
      map['abvr_code'] = Variable<String>(abvrCode.value);
    }
    if (bookName.present) {
      map['book_name'] = Variable<String>(bookName.value);
    }
    if (bookDescription.present) {
      map['book_descr'] = Variable<String>(bookDescription.value);
    }
    if (colorCode.present) {
      map['color_code'] = Variable<String>(colorCode.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BooksCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('titleAr: $titleAr, ')
          ..write('numberOfHadis: $numberOfHadis, ')
          ..write('abvrCode: $abvrCode, ')
          ..write('bookName: $bookName, ')
          ..write('bookDescription: $bookDescription, ')
          ..write('colorCode: $colorCode')
          ..write(')'))
        .toString();
  }
}

class $ChaptersTable extends Chapters with TableInfo<$ChaptersTable, Chapter> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChaptersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _chapterIdMeta = const VerificationMeta(
    'chapterId',
  );
  @override
  late final GeneratedColumn<int> chapterId = GeneratedColumn<int>(
    'chapter_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<int> bookId = GeneratedColumn<int>(
    'book_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _numberMeta = const VerificationMeta('number');
  @override
  late final GeneratedColumn<int> number = GeneratedColumn<int>(
    'number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hadisRangeMeta = const VerificationMeta(
    'hadisRange',
  );
  @override
  late final GeneratedColumn<String> hadisRange = GeneratedColumn<String>(
    'hadis_range',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bookNameMeta = const VerificationMeta(
    'bookName',
  );
  @override
  late final GeneratedColumn<String> bookName = GeneratedColumn<String>(
    'book_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    chapterId,
    bookId,
    title,
    number,
    hadisRange,
    bookName,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chapter';
  @override
  VerificationContext validateIntegrity(
    Insertable<Chapter> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('chapter_id')) {
      context.handle(
        _chapterIdMeta,
        chapterId.isAcceptableOrUnknown(data['chapter_id']!, _chapterIdMeta),
      );
    } else if (isInserting) {
      context.missing(_chapterIdMeta);
    }
    if (data.containsKey('book_id')) {
      context.handle(
        _bookIdMeta,
        bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('number')) {
      context.handle(
        _numberMeta,
        number.isAcceptableOrUnknown(data['number']!, _numberMeta),
      );
    } else if (isInserting) {
      context.missing(_numberMeta);
    }
    if (data.containsKey('hadis_range')) {
      context.handle(
        _hadisRangeMeta,
        hadisRange.isAcceptableOrUnknown(data['hadis_range']!, _hadisRangeMeta),
      );
    } else if (isInserting) {
      context.missing(_hadisRangeMeta);
    }
    if (data.containsKey('book_name')) {
      context.handle(
        _bookNameMeta,
        bookName.isAcceptableOrUnknown(data['book_name']!, _bookNameMeta),
      );
    } else if (isInserting) {
      context.missing(_bookNameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Chapter map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Chapter(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      chapterId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chapter_id'],
      )!,
      bookId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}book_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      number: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}number'],
      )!,
      hadisRange: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hadis_range'],
      )!,
      bookName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}book_name'],
      )!,
    );
  }

  @override
  $ChaptersTable createAlias(String alias) {
    return $ChaptersTable(attachedDatabase, alias);
  }
}

class Chapter extends DataClass implements Insertable<Chapter> {
  final int id;
  final int chapterId;
  final int bookId;
  final String title;
  final int number;
  final String hadisRange;
  final String bookName;
  const Chapter({
    required this.id,
    required this.chapterId,
    required this.bookId,
    required this.title,
    required this.number,
    required this.hadisRange,
    required this.bookName,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['chapter_id'] = Variable<int>(chapterId);
    map['book_id'] = Variable<int>(bookId);
    map['title'] = Variable<String>(title);
    map['number'] = Variable<int>(number);
    map['hadis_range'] = Variable<String>(hadisRange);
    map['book_name'] = Variable<String>(bookName);
    return map;
  }

  ChaptersCompanion toCompanion(bool nullToAbsent) {
    return ChaptersCompanion(
      id: Value(id),
      chapterId: Value(chapterId),
      bookId: Value(bookId),
      title: Value(title),
      number: Value(number),
      hadisRange: Value(hadisRange),
      bookName: Value(bookName),
    );
  }

  factory Chapter.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Chapter(
      id: serializer.fromJson<int>(json['id']),
      chapterId: serializer.fromJson<int>(json['chapterId']),
      bookId: serializer.fromJson<int>(json['bookId']),
      title: serializer.fromJson<String>(json['title']),
      number: serializer.fromJson<int>(json['number']),
      hadisRange: serializer.fromJson<String>(json['hadisRange']),
      bookName: serializer.fromJson<String>(json['bookName']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'chapterId': serializer.toJson<int>(chapterId),
      'bookId': serializer.toJson<int>(bookId),
      'title': serializer.toJson<String>(title),
      'number': serializer.toJson<int>(number),
      'hadisRange': serializer.toJson<String>(hadisRange),
      'bookName': serializer.toJson<String>(bookName),
    };
  }

  Chapter copyWith({
    int? id,
    int? chapterId,
    int? bookId,
    String? title,
    int? number,
    String? hadisRange,
    String? bookName,
  }) => Chapter(
    id: id ?? this.id,
    chapterId: chapterId ?? this.chapterId,
    bookId: bookId ?? this.bookId,
    title: title ?? this.title,
    number: number ?? this.number,
    hadisRange: hadisRange ?? this.hadisRange,
    bookName: bookName ?? this.bookName,
  );
  Chapter copyWithCompanion(ChaptersCompanion data) {
    return Chapter(
      id: data.id.present ? data.id.value : this.id,
      chapterId: data.chapterId.present ? data.chapterId.value : this.chapterId,
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      title: data.title.present ? data.title.value : this.title,
      number: data.number.present ? data.number.value : this.number,
      hadisRange: data.hadisRange.present
          ? data.hadisRange.value
          : this.hadisRange,
      bookName: data.bookName.present ? data.bookName.value : this.bookName,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Chapter(')
          ..write('id: $id, ')
          ..write('chapterId: $chapterId, ')
          ..write('bookId: $bookId, ')
          ..write('title: $title, ')
          ..write('number: $number, ')
          ..write('hadisRange: $hadisRange, ')
          ..write('bookName: $bookName')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, chapterId, bookId, title, number, hadisRange, bookName);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Chapter &&
          other.id == this.id &&
          other.chapterId == this.chapterId &&
          other.bookId == this.bookId &&
          other.title == this.title &&
          other.number == this.number &&
          other.hadisRange == this.hadisRange &&
          other.bookName == this.bookName);
}

class ChaptersCompanion extends UpdateCompanion<Chapter> {
  final Value<int> id;
  final Value<int> chapterId;
  final Value<int> bookId;
  final Value<String> title;
  final Value<int> number;
  final Value<String> hadisRange;
  final Value<String> bookName;
  const ChaptersCompanion({
    this.id = const Value.absent(),
    this.chapterId = const Value.absent(),
    this.bookId = const Value.absent(),
    this.title = const Value.absent(),
    this.number = const Value.absent(),
    this.hadisRange = const Value.absent(),
    this.bookName = const Value.absent(),
  });
  ChaptersCompanion.insert({
    this.id = const Value.absent(),
    required int chapterId,
    required int bookId,
    required String title,
    required int number,
    required String hadisRange,
    required String bookName,
  }) : chapterId = Value(chapterId),
       bookId = Value(bookId),
       title = Value(title),
       number = Value(number),
       hadisRange = Value(hadisRange),
       bookName = Value(bookName);
  static Insertable<Chapter> custom({
    Expression<int>? id,
    Expression<int>? chapterId,
    Expression<int>? bookId,
    Expression<String>? title,
    Expression<int>? number,
    Expression<String>? hadisRange,
    Expression<String>? bookName,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (chapterId != null) 'chapter_id': chapterId,
      if (bookId != null) 'book_id': bookId,
      if (title != null) 'title': title,
      if (number != null) 'number': number,
      if (hadisRange != null) 'hadis_range': hadisRange,
      if (bookName != null) 'book_name': bookName,
    });
  }

  ChaptersCompanion copyWith({
    Value<int>? id,
    Value<int>? chapterId,
    Value<int>? bookId,
    Value<String>? title,
    Value<int>? number,
    Value<String>? hadisRange,
    Value<String>? bookName,
  }) {
    return ChaptersCompanion(
      id: id ?? this.id,
      chapterId: chapterId ?? this.chapterId,
      bookId: bookId ?? this.bookId,
      title: title ?? this.title,
      number: number ?? this.number,
      hadisRange: hadisRange ?? this.hadisRange,
      bookName: bookName ?? this.bookName,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (chapterId.present) {
      map['chapter_id'] = Variable<int>(chapterId.value);
    }
    if (bookId.present) {
      map['book_id'] = Variable<int>(bookId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (number.present) {
      map['number'] = Variable<int>(number.value);
    }
    if (hadisRange.present) {
      map['hadis_range'] = Variable<String>(hadisRange.value);
    }
    if (bookName.present) {
      map['book_name'] = Variable<String>(bookName.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChaptersCompanion(')
          ..write('id: $id, ')
          ..write('chapterId: $chapterId, ')
          ..write('bookId: $bookId, ')
          ..write('title: $title, ')
          ..write('number: $number, ')
          ..write('hadisRange: $hadisRange, ')
          ..write('bookName: $bookName')
          ..write(')'))
        .toString();
  }
}

class $HadithsTable extends Hadiths with TableInfo<$HadithsTable, Hadith> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HadithsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<int> bookId = GeneratedColumn<int>(
    'book_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bookNameMeta = const VerificationMeta(
    'bookName',
  );
  @override
  late final GeneratedColumn<String> bookName = GeneratedColumn<String>(
    'book_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chapterIdMeta = const VerificationMeta(
    'chapterId',
  );
  @override
  late final GeneratedColumn<int> chapterId = GeneratedColumn<int>(
    'chapter_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sectionIdMeta = const VerificationMeta(
    'sectionId',
  );
  @override
  late final GeneratedColumn<int> sectionId = GeneratedColumn<int>(
    'section_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hadithKeyMeta = const VerificationMeta(
    'hadithKey',
  );
  @override
  late final GeneratedColumn<String> hadithKey = GeneratedColumn<String>(
    'hadith_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hadithIdMeta = const VerificationMeta(
    'hadithId',
  );
  @override
  late final GeneratedColumn<int> hadithId = GeneratedColumn<int>(
    'hadith_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _narratorMeta = const VerificationMeta(
    'narrator',
  );
  @override
  late final GeneratedColumn<String> narrator = GeneratedColumn<String>(
    'narrator',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bnMeta = const VerificationMeta('bn');
  @override
  late final GeneratedColumn<String> bn = GeneratedColumn<String>(
    'bn',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _arMeta = const VerificationMeta('ar');
  @override
  late final GeneratedColumn<String> ar = GeneratedColumn<String>(
    'ar',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _arDiaclessMeta = const VerificationMeta(
    'arDiacless',
  );
  @override
  late final GeneratedColumn<String> arDiacless = GeneratedColumn<String>(
    'ar_diacless',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gradeIdMeta = const VerificationMeta(
    'gradeId',
  );
  @override
  late final GeneratedColumn<int> gradeId = GeneratedColumn<int>(
    'grade_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gradeMeta = const VerificationMeta('grade');
  @override
  late final GeneratedColumn<String> grade = GeneratedColumn<String>(
    'grade',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gradeColorMeta = const VerificationMeta(
    'gradeColor',
  );
  @override
  late final GeneratedColumn<String> gradeColor = GeneratedColumn<String>(
    'grade_color',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    bookId,
    bookName,
    chapterId,
    sectionId,
    hadithKey,
    hadithId,
    narrator,
    bn,
    ar,
    arDiacless,
    note,
    gradeId,
    grade,
    gradeColor,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'hadith';
  @override
  VerificationContext validateIntegrity(
    Insertable<Hadith> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('book_id')) {
      context.handle(
        _bookIdMeta,
        bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('book_name')) {
      context.handle(
        _bookNameMeta,
        bookName.isAcceptableOrUnknown(data['book_name']!, _bookNameMeta),
      );
    } else if (isInserting) {
      context.missing(_bookNameMeta);
    }
    if (data.containsKey('chapter_id')) {
      context.handle(
        _chapterIdMeta,
        chapterId.isAcceptableOrUnknown(data['chapter_id']!, _chapterIdMeta),
      );
    } else if (isInserting) {
      context.missing(_chapterIdMeta);
    }
    if (data.containsKey('section_id')) {
      context.handle(
        _sectionIdMeta,
        sectionId.isAcceptableOrUnknown(data['section_id']!, _sectionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sectionIdMeta);
    }
    if (data.containsKey('hadith_key')) {
      context.handle(
        _hadithKeyMeta,
        hadithKey.isAcceptableOrUnknown(data['hadith_key']!, _hadithKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_hadithKeyMeta);
    }
    if (data.containsKey('hadith_id')) {
      context.handle(
        _hadithIdMeta,
        hadithId.isAcceptableOrUnknown(data['hadith_id']!, _hadithIdMeta),
      );
    }
    if (data.containsKey('narrator')) {
      context.handle(
        _narratorMeta,
        narrator.isAcceptableOrUnknown(data['narrator']!, _narratorMeta),
      );
    }
    if (data.containsKey('bn')) {
      context.handle(_bnMeta, bn.isAcceptableOrUnknown(data['bn']!, _bnMeta));
    }
    if (data.containsKey('ar')) {
      context.handle(_arMeta, ar.isAcceptableOrUnknown(data['ar']!, _arMeta));
    }
    if (data.containsKey('ar_diacless')) {
      context.handle(
        _arDiaclessMeta,
        arDiacless.isAcceptableOrUnknown(data['ar_diacless']!, _arDiaclessMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('grade_id')) {
      context.handle(
        _gradeIdMeta,
        gradeId.isAcceptableOrUnknown(data['grade_id']!, _gradeIdMeta),
      );
    }
    if (data.containsKey('grade')) {
      context.handle(
        _gradeMeta,
        grade.isAcceptableOrUnknown(data['grade']!, _gradeMeta),
      );
    }
    if (data.containsKey('grade_color')) {
      context.handle(
        _gradeColorMeta,
        gradeColor.isAcceptableOrUnknown(data['grade_color']!, _gradeColorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Hadith map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Hadith(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      bookId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}book_id'],
      )!,
      bookName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}book_name'],
      )!,
      chapterId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chapter_id'],
      )!,
      sectionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}section_id'],
      )!,
      hadithKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hadith_key'],
      )!,
      hadithId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hadith_id'],
      ),
      narrator: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}narrator'],
      ),
      bn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bn'],
      ),
      ar: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ar'],
      ),
      arDiacless: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ar_diacless'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      gradeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}grade_id'],
      ),
      grade: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}grade'],
      ),
      gradeColor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}grade_color'],
      ),
    );
  }

  @override
  $HadithsTable createAlias(String alias) {
    return $HadithsTable(attachedDatabase, alias);
  }
}

class Hadith extends DataClass implements Insertable<Hadith> {
  final int id;
  final int bookId;
  final String bookName;
  final int chapterId;
  final int sectionId;
  final String hadithKey;
  final int? hadithId;
  final String? narrator;
  final String? bn;
  final String? ar;
  final String? arDiacless;
  final String? note;
  final int? gradeId;
  final String? grade;
  final String? gradeColor;
  const Hadith({
    required this.id,
    required this.bookId,
    required this.bookName,
    required this.chapterId,
    required this.sectionId,
    required this.hadithKey,
    this.hadithId,
    this.narrator,
    this.bn,
    this.ar,
    this.arDiacless,
    this.note,
    this.gradeId,
    this.grade,
    this.gradeColor,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['book_id'] = Variable<int>(bookId);
    map['book_name'] = Variable<String>(bookName);
    map['chapter_id'] = Variable<int>(chapterId);
    map['section_id'] = Variable<int>(sectionId);
    map['hadith_key'] = Variable<String>(hadithKey);
    if (!nullToAbsent || hadithId != null) {
      map['hadith_id'] = Variable<int>(hadithId);
    }
    if (!nullToAbsent || narrator != null) {
      map['narrator'] = Variable<String>(narrator);
    }
    if (!nullToAbsent || bn != null) {
      map['bn'] = Variable<String>(bn);
    }
    if (!nullToAbsent || ar != null) {
      map['ar'] = Variable<String>(ar);
    }
    if (!nullToAbsent || arDiacless != null) {
      map['ar_diacless'] = Variable<String>(arDiacless);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || gradeId != null) {
      map['grade_id'] = Variable<int>(gradeId);
    }
    if (!nullToAbsent || grade != null) {
      map['grade'] = Variable<String>(grade);
    }
    if (!nullToAbsent || gradeColor != null) {
      map['grade_color'] = Variable<String>(gradeColor);
    }
    return map;
  }

  HadithsCompanion toCompanion(bool nullToAbsent) {
    return HadithsCompanion(
      id: Value(id),
      bookId: Value(bookId),
      bookName: Value(bookName),
      chapterId: Value(chapterId),
      sectionId: Value(sectionId),
      hadithKey: Value(hadithKey),
      hadithId: hadithId == null && nullToAbsent
          ? const Value.absent()
          : Value(hadithId),
      narrator: narrator == null && nullToAbsent
          ? const Value.absent()
          : Value(narrator),
      bn: bn == null && nullToAbsent ? const Value.absent() : Value(bn),
      ar: ar == null && nullToAbsent ? const Value.absent() : Value(ar),
      arDiacless: arDiacless == null && nullToAbsent
          ? const Value.absent()
          : Value(arDiacless),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      gradeId: gradeId == null && nullToAbsent
          ? const Value.absent()
          : Value(gradeId),
      grade: grade == null && nullToAbsent
          ? const Value.absent()
          : Value(grade),
      gradeColor: gradeColor == null && nullToAbsent
          ? const Value.absent()
          : Value(gradeColor),
    );
  }

  factory Hadith.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Hadith(
      id: serializer.fromJson<int>(json['id']),
      bookId: serializer.fromJson<int>(json['bookId']),
      bookName: serializer.fromJson<String>(json['bookName']),
      chapterId: serializer.fromJson<int>(json['chapterId']),
      sectionId: serializer.fromJson<int>(json['sectionId']),
      hadithKey: serializer.fromJson<String>(json['hadithKey']),
      hadithId: serializer.fromJson<int?>(json['hadithId']),
      narrator: serializer.fromJson<String?>(json['narrator']),
      bn: serializer.fromJson<String?>(json['bn']),
      ar: serializer.fromJson<String?>(json['ar']),
      arDiacless: serializer.fromJson<String?>(json['arDiacless']),
      note: serializer.fromJson<String?>(json['note']),
      gradeId: serializer.fromJson<int?>(json['gradeId']),
      grade: serializer.fromJson<String?>(json['grade']),
      gradeColor: serializer.fromJson<String?>(json['gradeColor']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'bookId': serializer.toJson<int>(bookId),
      'bookName': serializer.toJson<String>(bookName),
      'chapterId': serializer.toJson<int>(chapterId),
      'sectionId': serializer.toJson<int>(sectionId),
      'hadithKey': serializer.toJson<String>(hadithKey),
      'hadithId': serializer.toJson<int?>(hadithId),
      'narrator': serializer.toJson<String?>(narrator),
      'bn': serializer.toJson<String?>(bn),
      'ar': serializer.toJson<String?>(ar),
      'arDiacless': serializer.toJson<String?>(arDiacless),
      'note': serializer.toJson<String?>(note),
      'gradeId': serializer.toJson<int?>(gradeId),
      'grade': serializer.toJson<String?>(grade),
      'gradeColor': serializer.toJson<String?>(gradeColor),
    };
  }

  Hadith copyWith({
    int? id,
    int? bookId,
    String? bookName,
    int? chapterId,
    int? sectionId,
    String? hadithKey,
    Value<int?> hadithId = const Value.absent(),
    Value<String?> narrator = const Value.absent(),
    Value<String?> bn = const Value.absent(),
    Value<String?> ar = const Value.absent(),
    Value<String?> arDiacless = const Value.absent(),
    Value<String?> note = const Value.absent(),
    Value<int?> gradeId = const Value.absent(),
    Value<String?> grade = const Value.absent(),
    Value<String?> gradeColor = const Value.absent(),
  }) => Hadith(
    id: id ?? this.id,
    bookId: bookId ?? this.bookId,
    bookName: bookName ?? this.bookName,
    chapterId: chapterId ?? this.chapterId,
    sectionId: sectionId ?? this.sectionId,
    hadithKey: hadithKey ?? this.hadithKey,
    hadithId: hadithId.present ? hadithId.value : this.hadithId,
    narrator: narrator.present ? narrator.value : this.narrator,
    bn: bn.present ? bn.value : this.bn,
    ar: ar.present ? ar.value : this.ar,
    arDiacless: arDiacless.present ? arDiacless.value : this.arDiacless,
    note: note.present ? note.value : this.note,
    gradeId: gradeId.present ? gradeId.value : this.gradeId,
    grade: grade.present ? grade.value : this.grade,
    gradeColor: gradeColor.present ? gradeColor.value : this.gradeColor,
  );
  Hadith copyWithCompanion(HadithsCompanion data) {
    return Hadith(
      id: data.id.present ? data.id.value : this.id,
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      bookName: data.bookName.present ? data.bookName.value : this.bookName,
      chapterId: data.chapterId.present ? data.chapterId.value : this.chapterId,
      sectionId: data.sectionId.present ? data.sectionId.value : this.sectionId,
      hadithKey: data.hadithKey.present ? data.hadithKey.value : this.hadithKey,
      hadithId: data.hadithId.present ? data.hadithId.value : this.hadithId,
      narrator: data.narrator.present ? data.narrator.value : this.narrator,
      bn: data.bn.present ? data.bn.value : this.bn,
      ar: data.ar.present ? data.ar.value : this.ar,
      arDiacless: data.arDiacless.present
          ? data.arDiacless.value
          : this.arDiacless,
      note: data.note.present ? data.note.value : this.note,
      gradeId: data.gradeId.present ? data.gradeId.value : this.gradeId,
      grade: data.grade.present ? data.grade.value : this.grade,
      gradeColor: data.gradeColor.present
          ? data.gradeColor.value
          : this.gradeColor,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Hadith(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('bookName: $bookName, ')
          ..write('chapterId: $chapterId, ')
          ..write('sectionId: $sectionId, ')
          ..write('hadithKey: $hadithKey, ')
          ..write('hadithId: $hadithId, ')
          ..write('narrator: $narrator, ')
          ..write('bn: $bn, ')
          ..write('ar: $ar, ')
          ..write('arDiacless: $arDiacless, ')
          ..write('note: $note, ')
          ..write('gradeId: $gradeId, ')
          ..write('grade: $grade, ')
          ..write('gradeColor: $gradeColor')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    bookId,
    bookName,
    chapterId,
    sectionId,
    hadithKey,
    hadithId,
    narrator,
    bn,
    ar,
    arDiacless,
    note,
    gradeId,
    grade,
    gradeColor,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Hadith &&
          other.id == this.id &&
          other.bookId == this.bookId &&
          other.bookName == this.bookName &&
          other.chapterId == this.chapterId &&
          other.sectionId == this.sectionId &&
          other.hadithKey == this.hadithKey &&
          other.hadithId == this.hadithId &&
          other.narrator == this.narrator &&
          other.bn == this.bn &&
          other.ar == this.ar &&
          other.arDiacless == this.arDiacless &&
          other.note == this.note &&
          other.gradeId == this.gradeId &&
          other.grade == this.grade &&
          other.gradeColor == this.gradeColor);
}

class HadithsCompanion extends UpdateCompanion<Hadith> {
  final Value<int> id;
  final Value<int> bookId;
  final Value<String> bookName;
  final Value<int> chapterId;
  final Value<int> sectionId;
  final Value<String> hadithKey;
  final Value<int?> hadithId;
  final Value<String?> narrator;
  final Value<String?> bn;
  final Value<String?> ar;
  final Value<String?> arDiacless;
  final Value<String?> note;
  final Value<int?> gradeId;
  final Value<String?> grade;
  final Value<String?> gradeColor;
  const HadithsCompanion({
    this.id = const Value.absent(),
    this.bookId = const Value.absent(),
    this.bookName = const Value.absent(),
    this.chapterId = const Value.absent(),
    this.sectionId = const Value.absent(),
    this.hadithKey = const Value.absent(),
    this.hadithId = const Value.absent(),
    this.narrator = const Value.absent(),
    this.bn = const Value.absent(),
    this.ar = const Value.absent(),
    this.arDiacless = const Value.absent(),
    this.note = const Value.absent(),
    this.gradeId = const Value.absent(),
    this.grade = const Value.absent(),
    this.gradeColor = const Value.absent(),
  });
  HadithsCompanion.insert({
    this.id = const Value.absent(),
    required int bookId,
    required String bookName,
    required int chapterId,
    required int sectionId,
    required String hadithKey,
    this.hadithId = const Value.absent(),
    this.narrator = const Value.absent(),
    this.bn = const Value.absent(),
    this.ar = const Value.absent(),
    this.arDiacless = const Value.absent(),
    this.note = const Value.absent(),
    this.gradeId = const Value.absent(),
    this.grade = const Value.absent(),
    this.gradeColor = const Value.absent(),
  }) : bookId = Value(bookId),
       bookName = Value(bookName),
       chapterId = Value(chapterId),
       sectionId = Value(sectionId),
       hadithKey = Value(hadithKey);
  static Insertable<Hadith> custom({
    Expression<int>? id,
    Expression<int>? bookId,
    Expression<String>? bookName,
    Expression<int>? chapterId,
    Expression<int>? sectionId,
    Expression<String>? hadithKey,
    Expression<int>? hadithId,
    Expression<String>? narrator,
    Expression<String>? bn,
    Expression<String>? ar,
    Expression<String>? arDiacless,
    Expression<String>? note,
    Expression<int>? gradeId,
    Expression<String>? grade,
    Expression<String>? gradeColor,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bookId != null) 'book_id': bookId,
      if (bookName != null) 'book_name': bookName,
      if (chapterId != null) 'chapter_id': chapterId,
      if (sectionId != null) 'section_id': sectionId,
      if (hadithKey != null) 'hadith_key': hadithKey,
      if (hadithId != null) 'hadith_id': hadithId,
      if (narrator != null) 'narrator': narrator,
      if (bn != null) 'bn': bn,
      if (ar != null) 'ar': ar,
      if (arDiacless != null) 'ar_diacless': arDiacless,
      if (note != null) 'note': note,
      if (gradeId != null) 'grade_id': gradeId,
      if (grade != null) 'grade': grade,
      if (gradeColor != null) 'grade_color': gradeColor,
    });
  }

  HadithsCompanion copyWith({
    Value<int>? id,
    Value<int>? bookId,
    Value<String>? bookName,
    Value<int>? chapterId,
    Value<int>? sectionId,
    Value<String>? hadithKey,
    Value<int?>? hadithId,
    Value<String?>? narrator,
    Value<String?>? bn,
    Value<String?>? ar,
    Value<String?>? arDiacless,
    Value<String?>? note,
    Value<int?>? gradeId,
    Value<String?>? grade,
    Value<String?>? gradeColor,
  }) {
    return HadithsCompanion(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      bookName: bookName ?? this.bookName,
      chapterId: chapterId ?? this.chapterId,
      sectionId: sectionId ?? this.sectionId,
      hadithKey: hadithKey ?? this.hadithKey,
      hadithId: hadithId ?? this.hadithId,
      narrator: narrator ?? this.narrator,
      bn: bn ?? this.bn,
      ar: ar ?? this.ar,
      arDiacless: arDiacless ?? this.arDiacless,
      note: note ?? this.note,
      gradeId: gradeId ?? this.gradeId,
      grade: grade ?? this.grade,
      gradeColor: gradeColor ?? this.gradeColor,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (bookId.present) {
      map['book_id'] = Variable<int>(bookId.value);
    }
    if (bookName.present) {
      map['book_name'] = Variable<String>(bookName.value);
    }
    if (chapterId.present) {
      map['chapter_id'] = Variable<int>(chapterId.value);
    }
    if (sectionId.present) {
      map['section_id'] = Variable<int>(sectionId.value);
    }
    if (hadithKey.present) {
      map['hadith_key'] = Variable<String>(hadithKey.value);
    }
    if (hadithId.present) {
      map['hadith_id'] = Variable<int>(hadithId.value);
    }
    if (narrator.present) {
      map['narrator'] = Variable<String>(narrator.value);
    }
    if (bn.present) {
      map['bn'] = Variable<String>(bn.value);
    }
    if (ar.present) {
      map['ar'] = Variable<String>(ar.value);
    }
    if (arDiacless.present) {
      map['ar_diacless'] = Variable<String>(arDiacless.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (gradeId.present) {
      map['grade_id'] = Variable<int>(gradeId.value);
    }
    if (grade.present) {
      map['grade'] = Variable<String>(grade.value);
    }
    if (gradeColor.present) {
      map['grade_color'] = Variable<String>(gradeColor.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HadithsCompanion(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('bookName: $bookName, ')
          ..write('chapterId: $chapterId, ')
          ..write('sectionId: $sectionId, ')
          ..write('hadithKey: $hadithKey, ')
          ..write('hadithId: $hadithId, ')
          ..write('narrator: $narrator, ')
          ..write('bn: $bn, ')
          ..write('ar: $ar, ')
          ..write('arDiacless: $arDiacless, ')
          ..write('note: $note, ')
          ..write('gradeId: $gradeId, ')
          ..write('grade: $grade, ')
          ..write('gradeColor: $gradeColor')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $BooksTable books = $BooksTable(this);
  late final $ChaptersTable chapters = $ChaptersTable(this);
  late final $HadithsTable hadiths = $HadithsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    books,
    chapters,
    hadiths,
  ];
}

typedef $$BooksTableCreateCompanionBuilder =
    BooksCompanion Function({
      Value<int> id,
      required String title,
      required String titleAr,
      required int numberOfHadis,
      required String abvrCode,
      required String bookName,
      required String bookDescription,
      required String colorCode,
    });
typedef $$BooksTableUpdateCompanionBuilder =
    BooksCompanion Function({
      Value<int> id,
      Value<String> title,
      Value<String> titleAr,
      Value<int> numberOfHadis,
      Value<String> abvrCode,
      Value<String> bookName,
      Value<String> bookDescription,
      Value<String> colorCode,
    });

class $$BooksTableFilterComposer extends Composer<_$AppDatabase, $BooksTable> {
  $$BooksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get titleAr => $composableBuilder(
    column: $table.titleAr,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get numberOfHadis => $composableBuilder(
    column: $table.numberOfHadis,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get abvrCode => $composableBuilder(
    column: $table.abvrCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bookName => $composableBuilder(
    column: $table.bookName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bookDescription => $composableBuilder(
    column: $table.bookDescription,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get colorCode => $composableBuilder(
    column: $table.colorCode,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BooksTableOrderingComposer
    extends Composer<_$AppDatabase, $BooksTable> {
  $$BooksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get titleAr => $composableBuilder(
    column: $table.titleAr,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get numberOfHadis => $composableBuilder(
    column: $table.numberOfHadis,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get abvrCode => $composableBuilder(
    column: $table.abvrCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bookName => $composableBuilder(
    column: $table.bookName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bookDescription => $composableBuilder(
    column: $table.bookDescription,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get colorCode => $composableBuilder(
    column: $table.colorCode,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BooksTableAnnotationComposer
    extends Composer<_$AppDatabase, $BooksTable> {
  $$BooksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get titleAr =>
      $composableBuilder(column: $table.titleAr, builder: (column) => column);

  GeneratedColumn<int> get numberOfHadis => $composableBuilder(
    column: $table.numberOfHadis,
    builder: (column) => column,
  );

  GeneratedColumn<String> get abvrCode =>
      $composableBuilder(column: $table.abvrCode, builder: (column) => column);

  GeneratedColumn<String> get bookName =>
      $composableBuilder(column: $table.bookName, builder: (column) => column);

  GeneratedColumn<String> get bookDescription => $composableBuilder(
    column: $table.bookDescription,
    builder: (column) => column,
  );

  GeneratedColumn<String> get colorCode =>
      $composableBuilder(column: $table.colorCode, builder: (column) => column);
}

class $$BooksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BooksTable,
          Book,
          $$BooksTableFilterComposer,
          $$BooksTableOrderingComposer,
          $$BooksTableAnnotationComposer,
          $$BooksTableCreateCompanionBuilder,
          $$BooksTableUpdateCompanionBuilder,
          (Book, BaseReferences<_$AppDatabase, $BooksTable, Book>),
          Book,
          PrefetchHooks Function()
        > {
  $$BooksTableTableManager(_$AppDatabase db, $BooksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BooksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BooksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BooksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> titleAr = const Value.absent(),
                Value<int> numberOfHadis = const Value.absent(),
                Value<String> abvrCode = const Value.absent(),
                Value<String> bookName = const Value.absent(),
                Value<String> bookDescription = const Value.absent(),
                Value<String> colorCode = const Value.absent(),
              }) => BooksCompanion(
                id: id,
                title: title,
                titleAr: titleAr,
                numberOfHadis: numberOfHadis,
                abvrCode: abvrCode,
                bookName: bookName,
                bookDescription: bookDescription,
                colorCode: colorCode,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                required String titleAr,
                required int numberOfHadis,
                required String abvrCode,
                required String bookName,
                required String bookDescription,
                required String colorCode,
              }) => BooksCompanion.insert(
                id: id,
                title: title,
                titleAr: titleAr,
                numberOfHadis: numberOfHadis,
                abvrCode: abvrCode,
                bookName: bookName,
                bookDescription: bookDescription,
                colorCode: colorCode,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BooksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BooksTable,
      Book,
      $$BooksTableFilterComposer,
      $$BooksTableOrderingComposer,
      $$BooksTableAnnotationComposer,
      $$BooksTableCreateCompanionBuilder,
      $$BooksTableUpdateCompanionBuilder,
      (Book, BaseReferences<_$AppDatabase, $BooksTable, Book>),
      Book,
      PrefetchHooks Function()
    >;
typedef $$ChaptersTableCreateCompanionBuilder =
    ChaptersCompanion Function({
      Value<int> id,
      required int chapterId,
      required int bookId,
      required String title,
      required int number,
      required String hadisRange,
      required String bookName,
    });
typedef $$ChaptersTableUpdateCompanionBuilder =
    ChaptersCompanion Function({
      Value<int> id,
      Value<int> chapterId,
      Value<int> bookId,
      Value<String> title,
      Value<int> number,
      Value<String> hadisRange,
      Value<String> bookName,
    });

class $$ChaptersTableFilterComposer
    extends Composer<_$AppDatabase, $ChaptersTable> {
  $$ChaptersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get chapterId => $composableBuilder(
    column: $table.chapterId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bookId => $composableBuilder(
    column: $table.bookId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hadisRange => $composableBuilder(
    column: $table.hadisRange,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bookName => $composableBuilder(
    column: $table.bookName,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ChaptersTableOrderingComposer
    extends Composer<_$AppDatabase, $ChaptersTable> {
  $$ChaptersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get chapterId => $composableBuilder(
    column: $table.chapterId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bookId => $composableBuilder(
    column: $table.bookId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hadisRange => $composableBuilder(
    column: $table.hadisRange,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bookName => $composableBuilder(
    column: $table.bookName,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ChaptersTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChaptersTable> {
  $$ChaptersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get chapterId =>
      $composableBuilder(column: $table.chapterId, builder: (column) => column);

  GeneratedColumn<int> get bookId =>
      $composableBuilder(column: $table.bookId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get number =>
      $composableBuilder(column: $table.number, builder: (column) => column);

  GeneratedColumn<String> get hadisRange => $composableBuilder(
    column: $table.hadisRange,
    builder: (column) => column,
  );

  GeneratedColumn<String> get bookName =>
      $composableBuilder(column: $table.bookName, builder: (column) => column);
}

class $$ChaptersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ChaptersTable,
          Chapter,
          $$ChaptersTableFilterComposer,
          $$ChaptersTableOrderingComposer,
          $$ChaptersTableAnnotationComposer,
          $$ChaptersTableCreateCompanionBuilder,
          $$ChaptersTableUpdateCompanionBuilder,
          (Chapter, BaseReferences<_$AppDatabase, $ChaptersTable, Chapter>),
          Chapter,
          PrefetchHooks Function()
        > {
  $$ChaptersTableTableManager(_$AppDatabase db, $ChaptersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChaptersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChaptersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChaptersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> chapterId = const Value.absent(),
                Value<int> bookId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<int> number = const Value.absent(),
                Value<String> hadisRange = const Value.absent(),
                Value<String> bookName = const Value.absent(),
              }) => ChaptersCompanion(
                id: id,
                chapterId: chapterId,
                bookId: bookId,
                title: title,
                number: number,
                hadisRange: hadisRange,
                bookName: bookName,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int chapterId,
                required int bookId,
                required String title,
                required int number,
                required String hadisRange,
                required String bookName,
              }) => ChaptersCompanion.insert(
                id: id,
                chapterId: chapterId,
                bookId: bookId,
                title: title,
                number: number,
                hadisRange: hadisRange,
                bookName: bookName,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ChaptersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ChaptersTable,
      Chapter,
      $$ChaptersTableFilterComposer,
      $$ChaptersTableOrderingComposer,
      $$ChaptersTableAnnotationComposer,
      $$ChaptersTableCreateCompanionBuilder,
      $$ChaptersTableUpdateCompanionBuilder,
      (Chapter, BaseReferences<_$AppDatabase, $ChaptersTable, Chapter>),
      Chapter,
      PrefetchHooks Function()
    >;
typedef $$HadithsTableCreateCompanionBuilder =
    HadithsCompanion Function({
      Value<int> id,
      required int bookId,
      required String bookName,
      required int chapterId,
      required int sectionId,
      required String hadithKey,
      Value<int?> hadithId,
      Value<String?> narrator,
      Value<String?> bn,
      Value<String?> ar,
      Value<String?> arDiacless,
      Value<String?> note,
      Value<int?> gradeId,
      Value<String?> grade,
      Value<String?> gradeColor,
    });
typedef $$HadithsTableUpdateCompanionBuilder =
    HadithsCompanion Function({
      Value<int> id,
      Value<int> bookId,
      Value<String> bookName,
      Value<int> chapterId,
      Value<int> sectionId,
      Value<String> hadithKey,
      Value<int?> hadithId,
      Value<String?> narrator,
      Value<String?> bn,
      Value<String?> ar,
      Value<String?> arDiacless,
      Value<String?> note,
      Value<int?> gradeId,
      Value<String?> grade,
      Value<String?> gradeColor,
    });

class $$HadithsTableFilterComposer
    extends Composer<_$AppDatabase, $HadithsTable> {
  $$HadithsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bookId => $composableBuilder(
    column: $table.bookId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bookName => $composableBuilder(
    column: $table.bookName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get chapterId => $composableBuilder(
    column: $table.chapterId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sectionId => $composableBuilder(
    column: $table.sectionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hadithKey => $composableBuilder(
    column: $table.hadithKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hadithId => $composableBuilder(
    column: $table.hadithId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get narrator => $composableBuilder(
    column: $table.narrator,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bn => $composableBuilder(
    column: $table.bn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ar => $composableBuilder(
    column: $table.ar,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get arDiacless => $composableBuilder(
    column: $table.arDiacless,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get gradeId => $composableBuilder(
    column: $table.gradeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get grade => $composableBuilder(
    column: $table.grade,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gradeColor => $composableBuilder(
    column: $table.gradeColor,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HadithsTableOrderingComposer
    extends Composer<_$AppDatabase, $HadithsTable> {
  $$HadithsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bookId => $composableBuilder(
    column: $table.bookId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bookName => $composableBuilder(
    column: $table.bookName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get chapterId => $composableBuilder(
    column: $table.chapterId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sectionId => $composableBuilder(
    column: $table.sectionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hadithKey => $composableBuilder(
    column: $table.hadithKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hadithId => $composableBuilder(
    column: $table.hadithId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get narrator => $composableBuilder(
    column: $table.narrator,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bn => $composableBuilder(
    column: $table.bn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ar => $composableBuilder(
    column: $table.ar,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get arDiacless => $composableBuilder(
    column: $table.arDiacless,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get gradeId => $composableBuilder(
    column: $table.gradeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get grade => $composableBuilder(
    column: $table.grade,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gradeColor => $composableBuilder(
    column: $table.gradeColor,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HadithsTableAnnotationComposer
    extends Composer<_$AppDatabase, $HadithsTable> {
  $$HadithsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get bookId =>
      $composableBuilder(column: $table.bookId, builder: (column) => column);

  GeneratedColumn<String> get bookName =>
      $composableBuilder(column: $table.bookName, builder: (column) => column);

  GeneratedColumn<int> get chapterId =>
      $composableBuilder(column: $table.chapterId, builder: (column) => column);

  GeneratedColumn<int> get sectionId =>
      $composableBuilder(column: $table.sectionId, builder: (column) => column);

  GeneratedColumn<String> get hadithKey =>
      $composableBuilder(column: $table.hadithKey, builder: (column) => column);

  GeneratedColumn<int> get hadithId =>
      $composableBuilder(column: $table.hadithId, builder: (column) => column);

  GeneratedColumn<String> get narrator =>
      $composableBuilder(column: $table.narrator, builder: (column) => column);

  GeneratedColumn<String> get bn =>
      $composableBuilder(column: $table.bn, builder: (column) => column);

  GeneratedColumn<String> get ar =>
      $composableBuilder(column: $table.ar, builder: (column) => column);

  GeneratedColumn<String> get arDiacless => $composableBuilder(
    column: $table.arDiacless,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<int> get gradeId =>
      $composableBuilder(column: $table.gradeId, builder: (column) => column);

  GeneratedColumn<String> get grade =>
      $composableBuilder(column: $table.grade, builder: (column) => column);

  GeneratedColumn<String> get gradeColor => $composableBuilder(
    column: $table.gradeColor,
    builder: (column) => column,
  );
}

class $$HadithsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HadithsTable,
          Hadith,
          $$HadithsTableFilterComposer,
          $$HadithsTableOrderingComposer,
          $$HadithsTableAnnotationComposer,
          $$HadithsTableCreateCompanionBuilder,
          $$HadithsTableUpdateCompanionBuilder,
          (Hadith, BaseReferences<_$AppDatabase, $HadithsTable, Hadith>),
          Hadith,
          PrefetchHooks Function()
        > {
  $$HadithsTableTableManager(_$AppDatabase db, $HadithsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HadithsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HadithsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HadithsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> bookId = const Value.absent(),
                Value<String> bookName = const Value.absent(),
                Value<int> chapterId = const Value.absent(),
                Value<int> sectionId = const Value.absent(),
                Value<String> hadithKey = const Value.absent(),
                Value<int?> hadithId = const Value.absent(),
                Value<String?> narrator = const Value.absent(),
                Value<String?> bn = const Value.absent(),
                Value<String?> ar = const Value.absent(),
                Value<String?> arDiacless = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int?> gradeId = const Value.absent(),
                Value<String?> grade = const Value.absent(),
                Value<String?> gradeColor = const Value.absent(),
              }) => HadithsCompanion(
                id: id,
                bookId: bookId,
                bookName: bookName,
                chapterId: chapterId,
                sectionId: sectionId,
                hadithKey: hadithKey,
                hadithId: hadithId,
                narrator: narrator,
                bn: bn,
                ar: ar,
                arDiacless: arDiacless,
                note: note,
                gradeId: gradeId,
                grade: grade,
                gradeColor: gradeColor,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int bookId,
                required String bookName,
                required int chapterId,
                required int sectionId,
                required String hadithKey,
                Value<int?> hadithId = const Value.absent(),
                Value<String?> narrator = const Value.absent(),
                Value<String?> bn = const Value.absent(),
                Value<String?> ar = const Value.absent(),
                Value<String?> arDiacless = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int?> gradeId = const Value.absent(),
                Value<String?> grade = const Value.absent(),
                Value<String?> gradeColor = const Value.absent(),
              }) => HadithsCompanion.insert(
                id: id,
                bookId: bookId,
                bookName: bookName,
                chapterId: chapterId,
                sectionId: sectionId,
                hadithKey: hadithKey,
                hadithId: hadithId,
                narrator: narrator,
                bn: bn,
                ar: ar,
                arDiacless: arDiacless,
                note: note,
                gradeId: gradeId,
                grade: grade,
                gradeColor: gradeColor,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HadithsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HadithsTable,
      Hadith,
      $$HadithsTableFilterComposer,
      $$HadithsTableOrderingComposer,
      $$HadithsTableAnnotationComposer,
      $$HadithsTableCreateCompanionBuilder,
      $$HadithsTableUpdateCompanionBuilder,
      (Hadith, BaseReferences<_$AppDatabase, $HadithsTable, Hadith>),
      Hadith,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$BooksTableTableManager get books =>
      $$BooksTableTableManager(_db, _db.books);
  $$ChaptersTableTableManager get chapters =>
      $$ChaptersTableTableManager(_db, _db.chapters);
  $$HadithsTableTableManager get hadiths =>
      $$HadithsTableTableManager(_db, _db.hadiths);
}
