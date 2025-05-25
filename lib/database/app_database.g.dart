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

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $BooksTable books = $BooksTable(this);
  late final $ChaptersTable chapters = $ChaptersTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [books, chapters];
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

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$BooksTableTableManager get books =>
      $$BooksTableTableManager(_db, _db.books);
  $$ChaptersTableTableManager get chapters =>
      $$ChaptersTableTableManager(_db, _db.chapters);
}
