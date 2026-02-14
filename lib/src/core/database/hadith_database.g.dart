// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hadith_database.dart';

// ignore_for_file: type=lint
class $BookInfoTableTable extends BookInfoTable
    with TableInfo<$BookInfoTableTable, BookInfo> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BookInfoTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _hadithCountMeta = const VerificationMeta(
    'hadithCount',
  );
  @override
  late final GeneratedColumn<int> hadithCount = GeneratedColumn<int>(
    'hadith_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, bookName, hadithCount];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'book_info';
  @override
  VerificationContext validateIntegrity(
    Insertable<BookInfo> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('book_name')) {
      context.handle(
        _bookNameMeta,
        bookName.isAcceptableOrUnknown(data['book_name']!, _bookNameMeta),
      );
    } else if (isInserting) {
      context.missing(_bookNameMeta);
    }
    if (data.containsKey('hadith_count')) {
      context.handle(
        _hadithCountMeta,
        hadithCount.isAcceptableOrUnknown(
          data['hadith_count']!,
          _hadithCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_hadithCountMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BookInfo map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BookInfo(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      bookName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}book_name'],
      )!,
      hadithCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hadith_count'],
      )!,
    );
  }

  @override
  $BookInfoTableTable createAlias(String alias) {
    return $BookInfoTableTable(attachedDatabase, alias);
  }
}

class BookInfo extends DataClass implements Insertable<BookInfo> {
  final int id;
  final String bookName;
  final int hadithCount;
  const BookInfo({
    required this.id,
    required this.bookName,
    required this.hadithCount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['book_name'] = Variable<String>(bookName);
    map['hadith_count'] = Variable<int>(hadithCount);
    return map;
  }

  BookInfoTableCompanion toCompanion(bool nullToAbsent) {
    return BookInfoTableCompanion(
      id: Value(id),
      bookName: Value(bookName),
      hadithCount: Value(hadithCount),
    );
  }

  factory BookInfo.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BookInfo(
      id: serializer.fromJson<int>(json['id']),
      bookName: serializer.fromJson<String>(json['bookName']),
      hadithCount: serializer.fromJson<int>(json['hadithCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'bookName': serializer.toJson<String>(bookName),
      'hadithCount': serializer.toJson<int>(hadithCount),
    };
  }

  BookInfo copyWith({int? id, String? bookName, int? hadithCount}) => BookInfo(
    id: id ?? this.id,
    bookName: bookName ?? this.bookName,
    hadithCount: hadithCount ?? this.hadithCount,
  );
  BookInfo copyWithCompanion(BookInfoTableCompanion data) {
    return BookInfo(
      id: data.id.present ? data.id.value : this.id,
      bookName: data.bookName.present ? data.bookName.value : this.bookName,
      hadithCount: data.hadithCount.present
          ? data.hadithCount.value
          : this.hadithCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BookInfo(')
          ..write('id: $id, ')
          ..write('bookName: $bookName, ')
          ..write('hadithCount: $hadithCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, bookName, hadithCount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BookInfo &&
          other.id == this.id &&
          other.bookName == this.bookName &&
          other.hadithCount == this.hadithCount);
}

class BookInfoTableCompanion extends UpdateCompanion<BookInfo> {
  final Value<int> id;
  final Value<String> bookName;
  final Value<int> hadithCount;
  const BookInfoTableCompanion({
    this.id = const Value.absent(),
    this.bookName = const Value.absent(),
    this.hadithCount = const Value.absent(),
  });
  BookInfoTableCompanion.insert({
    this.id = const Value.absent(),
    required String bookName,
    required int hadithCount,
  }) : bookName = Value(bookName),
       hadithCount = Value(hadithCount);
  static Insertable<BookInfo> custom({
    Expression<int>? id,
    Expression<String>? bookName,
    Expression<int>? hadithCount,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bookName != null) 'book_name': bookName,
      if (hadithCount != null) 'hadith_count': hadithCount,
    });
  }

  BookInfoTableCompanion copyWith({
    Value<int>? id,
    Value<String>? bookName,
    Value<int>? hadithCount,
  }) {
    return BookInfoTableCompanion(
      id: id ?? this.id,
      bookName: bookName ?? this.bookName,
      hadithCount: hadithCount ?? this.hadithCount,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (bookName.present) {
      map['book_name'] = Variable<String>(bookName.value);
    }
    if (hadithCount.present) {
      map['hadith_count'] = Variable<int>(hadithCount.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BookInfoTableCompanion(')
          ..write('id: $id, ')
          ..write('bookName: $bookName, ')
          ..write('hadithCount: $hadithCount')
          ..write(')'))
        .toString();
  }
}

class $SectionsTableTable extends SectionsTable
    with TableInfo<$SectionsTableTable, HadithSection> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SectionsTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _sectionNameMeta = const VerificationMeta(
    'sectionName',
  );
  @override
  late final GeneratedColumn<String> sectionName = GeneratedColumn<String>(
    'section_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startHadithNumberMeta = const VerificationMeta(
    'startHadithNumber',
  );
  @override
  late final GeneratedColumn<int> startHadithNumber = GeneratedColumn<int>(
    'start_hadith_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endHadithNumberMeta = const VerificationMeta(
    'endHadithNumber',
  );
  @override
  late final GeneratedColumn<int> endHadithNumber = GeneratedColumn<int>(
    'end_hadith_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hadithCountMeta = const VerificationMeta(
    'hadithCount',
  );
  @override
  late final GeneratedColumn<int> hadithCount = GeneratedColumn<int>(
    'hadith_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sectionName,
    startHadithNumber,
    endHadithNumber,
    hadithCount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sections';
  @override
  VerificationContext validateIntegrity(
    Insertable<HadithSection> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('section_name')) {
      context.handle(
        _sectionNameMeta,
        sectionName.isAcceptableOrUnknown(
          data['section_name']!,
          _sectionNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sectionNameMeta);
    }
    if (data.containsKey('start_hadith_number')) {
      context.handle(
        _startHadithNumberMeta,
        startHadithNumber.isAcceptableOrUnknown(
          data['start_hadith_number']!,
          _startHadithNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_startHadithNumberMeta);
    }
    if (data.containsKey('end_hadith_number')) {
      context.handle(
        _endHadithNumberMeta,
        endHadithNumber.isAcceptableOrUnknown(
          data['end_hadith_number']!,
          _endHadithNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_endHadithNumberMeta);
    }
    if (data.containsKey('hadith_count')) {
      context.handle(
        _hadithCountMeta,
        hadithCount.isAcceptableOrUnknown(
          data['hadith_count']!,
          _hadithCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_hadithCountMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HadithSection map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HadithSection(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sectionName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}section_name'],
      )!,
      startHadithNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_hadith_number'],
      )!,
      endHadithNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_hadith_number'],
      )!,
      hadithCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hadith_count'],
      )!,
    );
  }

  @override
  $SectionsTableTable createAlias(String alias) {
    return $SectionsTableTable(attachedDatabase, alias);
  }
}

class HadithSection extends DataClass implements Insertable<HadithSection> {
  final int id;
  final String sectionName;
  final int startHadithNumber;
  final int endHadithNumber;
  final int hadithCount;
  const HadithSection({
    required this.id,
    required this.sectionName,
    required this.startHadithNumber,
    required this.endHadithNumber,
    required this.hadithCount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['section_name'] = Variable<String>(sectionName);
    map['start_hadith_number'] = Variable<int>(startHadithNumber);
    map['end_hadith_number'] = Variable<int>(endHadithNumber);
    map['hadith_count'] = Variable<int>(hadithCount);
    return map;
  }

  SectionsTableCompanion toCompanion(bool nullToAbsent) {
    return SectionsTableCompanion(
      id: Value(id),
      sectionName: Value(sectionName),
      startHadithNumber: Value(startHadithNumber),
      endHadithNumber: Value(endHadithNumber),
      hadithCount: Value(hadithCount),
    );
  }

  factory HadithSection.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HadithSection(
      id: serializer.fromJson<int>(json['id']),
      sectionName: serializer.fromJson<String>(json['sectionName']),
      startHadithNumber: serializer.fromJson<int>(json['startHadithNumber']),
      endHadithNumber: serializer.fromJson<int>(json['endHadithNumber']),
      hadithCount: serializer.fromJson<int>(json['hadithCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sectionName': serializer.toJson<String>(sectionName),
      'startHadithNumber': serializer.toJson<int>(startHadithNumber),
      'endHadithNumber': serializer.toJson<int>(endHadithNumber),
      'hadithCount': serializer.toJson<int>(hadithCount),
    };
  }

  HadithSection copyWith({
    int? id,
    String? sectionName,
    int? startHadithNumber,
    int? endHadithNumber,
    int? hadithCount,
  }) => HadithSection(
    id: id ?? this.id,
    sectionName: sectionName ?? this.sectionName,
    startHadithNumber: startHadithNumber ?? this.startHadithNumber,
    endHadithNumber: endHadithNumber ?? this.endHadithNumber,
    hadithCount: hadithCount ?? this.hadithCount,
  );
  HadithSection copyWithCompanion(SectionsTableCompanion data) {
    return HadithSection(
      id: data.id.present ? data.id.value : this.id,
      sectionName: data.sectionName.present
          ? data.sectionName.value
          : this.sectionName,
      startHadithNumber: data.startHadithNumber.present
          ? data.startHadithNumber.value
          : this.startHadithNumber,
      endHadithNumber: data.endHadithNumber.present
          ? data.endHadithNumber.value
          : this.endHadithNumber,
      hadithCount: data.hadithCount.present
          ? data.hadithCount.value
          : this.hadithCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HadithSection(')
          ..write('id: $id, ')
          ..write('sectionName: $sectionName, ')
          ..write('startHadithNumber: $startHadithNumber, ')
          ..write('endHadithNumber: $endHadithNumber, ')
          ..write('hadithCount: $hadithCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sectionName,
    startHadithNumber,
    endHadithNumber,
    hadithCount,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HadithSection &&
          other.id == this.id &&
          other.sectionName == this.sectionName &&
          other.startHadithNumber == this.startHadithNumber &&
          other.endHadithNumber == this.endHadithNumber &&
          other.hadithCount == this.hadithCount);
}

class SectionsTableCompanion extends UpdateCompanion<HadithSection> {
  final Value<int> id;
  final Value<String> sectionName;
  final Value<int> startHadithNumber;
  final Value<int> endHadithNumber;
  final Value<int> hadithCount;
  const SectionsTableCompanion({
    this.id = const Value.absent(),
    this.sectionName = const Value.absent(),
    this.startHadithNumber = const Value.absent(),
    this.endHadithNumber = const Value.absent(),
    this.hadithCount = const Value.absent(),
  });
  SectionsTableCompanion.insert({
    this.id = const Value.absent(),
    required String sectionName,
    required int startHadithNumber,
    required int endHadithNumber,
    required int hadithCount,
  }) : sectionName = Value(sectionName),
       startHadithNumber = Value(startHadithNumber),
       endHadithNumber = Value(endHadithNumber),
       hadithCount = Value(hadithCount);
  static Insertable<HadithSection> custom({
    Expression<int>? id,
    Expression<String>? sectionName,
    Expression<int>? startHadithNumber,
    Expression<int>? endHadithNumber,
    Expression<int>? hadithCount,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sectionName != null) 'section_name': sectionName,
      if (startHadithNumber != null) 'start_hadith_number': startHadithNumber,
      if (endHadithNumber != null) 'end_hadith_number': endHadithNumber,
      if (hadithCount != null) 'hadith_count': hadithCount,
    });
  }

  SectionsTableCompanion copyWith({
    Value<int>? id,
    Value<String>? sectionName,
    Value<int>? startHadithNumber,
    Value<int>? endHadithNumber,
    Value<int>? hadithCount,
  }) {
    return SectionsTableCompanion(
      id: id ?? this.id,
      sectionName: sectionName ?? this.sectionName,
      startHadithNumber: startHadithNumber ?? this.startHadithNumber,
      endHadithNumber: endHadithNumber ?? this.endHadithNumber,
      hadithCount: hadithCount ?? this.hadithCount,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sectionName.present) {
      map['section_name'] = Variable<String>(sectionName.value);
    }
    if (startHadithNumber.present) {
      map['start_hadith_number'] = Variable<int>(startHadithNumber.value);
    }
    if (endHadithNumber.present) {
      map['end_hadith_number'] = Variable<int>(endHadithNumber.value);
    }
    if (hadithCount.present) {
      map['hadith_count'] = Variable<int>(hadithCount.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SectionsTableCompanion(')
          ..write('id: $id, ')
          ..write('sectionName: $sectionName, ')
          ..write('startHadithNumber: $startHadithNumber, ')
          ..write('endHadithNumber: $endHadithNumber, ')
          ..write('hadithCount: $hadithCount')
          ..write(')'))
        .toString();
  }
}

class $HadithsTableTable extends HadithsTable
    with TableInfo<$HadithsTableTable, HadithData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HadithsTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _hadithNumberMeta = const VerificationMeta(
    'hadithNumber',
  );
  @override
  late final GeneratedColumn<int> hadithNumber = GeneratedColumn<int>(
    'hadith_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hadithTextMeta = const VerificationMeta(
    'hadithText',
  );
  @override
  late final GeneratedColumn<String> hadithText = GeneratedColumn<String>(
    'text',
    aliasedName,
    false,
    type: DriftSqlType.string,
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
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sections (id)',
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    hadithNumber,
    hadithText,
    sectionId,
    bookId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'hadiths';
  @override
  VerificationContext validateIntegrity(
    Insertable<HadithData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('hadith_number')) {
      context.handle(
        _hadithNumberMeta,
        hadithNumber.isAcceptableOrUnknown(
          data['hadith_number']!,
          _hadithNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_hadithNumberMeta);
    }
    if (data.containsKey('text')) {
      context.handle(
        _hadithTextMeta,
        hadithText.isAcceptableOrUnknown(data['text']!, _hadithTextMeta),
      );
    } else if (isInserting) {
      context.missing(_hadithTextMeta);
    }
    if (data.containsKey('section_id')) {
      context.handle(
        _sectionIdMeta,
        sectionId.isAcceptableOrUnknown(data['section_id']!, _sectionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sectionIdMeta);
    }
    if (data.containsKey('book_id')) {
      context.handle(
        _bookIdMeta,
        bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HadithData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HadithData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      hadithNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hadith_number'],
      )!,
      hadithText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}text'],
      )!,
      sectionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}section_id'],
      )!,
      bookId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}book_id'],
      )!,
    );
  }

  @override
  $HadithsTableTable createAlias(String alias) {
    return $HadithsTableTable(attachedDatabase, alias);
  }
}

class HadithData extends DataClass implements Insertable<HadithData> {
  final int id;
  final int hadithNumber;
  final String hadithText;
  final int sectionId;
  final int bookId;
  const HadithData({
    required this.id,
    required this.hadithNumber,
    required this.hadithText,
    required this.sectionId,
    required this.bookId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['hadith_number'] = Variable<int>(hadithNumber);
    map['text'] = Variable<String>(hadithText);
    map['section_id'] = Variable<int>(sectionId);
    map['book_id'] = Variable<int>(bookId);
    return map;
  }

  HadithsTableCompanion toCompanion(bool nullToAbsent) {
    return HadithsTableCompanion(
      id: Value(id),
      hadithNumber: Value(hadithNumber),
      hadithText: Value(hadithText),
      sectionId: Value(sectionId),
      bookId: Value(bookId),
    );
  }

  factory HadithData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HadithData(
      id: serializer.fromJson<int>(json['id']),
      hadithNumber: serializer.fromJson<int>(json['hadithNumber']),
      hadithText: serializer.fromJson<String>(json['hadithText']),
      sectionId: serializer.fromJson<int>(json['sectionId']),
      bookId: serializer.fromJson<int>(json['bookId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'hadithNumber': serializer.toJson<int>(hadithNumber),
      'hadithText': serializer.toJson<String>(hadithText),
      'sectionId': serializer.toJson<int>(sectionId),
      'bookId': serializer.toJson<int>(bookId),
    };
  }

  HadithData copyWith({
    int? id,
    int? hadithNumber,
    String? hadithText,
    int? sectionId,
    int? bookId,
  }) => HadithData(
    id: id ?? this.id,
    hadithNumber: hadithNumber ?? this.hadithNumber,
    hadithText: hadithText ?? this.hadithText,
    sectionId: sectionId ?? this.sectionId,
    bookId: bookId ?? this.bookId,
  );
  HadithData copyWithCompanion(HadithsTableCompanion data) {
    return HadithData(
      id: data.id.present ? data.id.value : this.id,
      hadithNumber: data.hadithNumber.present
          ? data.hadithNumber.value
          : this.hadithNumber,
      hadithText: data.hadithText.present
          ? data.hadithText.value
          : this.hadithText,
      sectionId: data.sectionId.present ? data.sectionId.value : this.sectionId,
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HadithData(')
          ..write('id: $id, ')
          ..write('hadithNumber: $hadithNumber, ')
          ..write('hadithText: $hadithText, ')
          ..write('sectionId: $sectionId, ')
          ..write('bookId: $bookId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, hadithNumber, hadithText, sectionId, bookId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HadithData &&
          other.id == this.id &&
          other.hadithNumber == this.hadithNumber &&
          other.hadithText == this.hadithText &&
          other.sectionId == this.sectionId &&
          other.bookId == this.bookId);
}

class HadithsTableCompanion extends UpdateCompanion<HadithData> {
  final Value<int> id;
  final Value<int> hadithNumber;
  final Value<String> hadithText;
  final Value<int> sectionId;
  final Value<int> bookId;
  const HadithsTableCompanion({
    this.id = const Value.absent(),
    this.hadithNumber = const Value.absent(),
    this.hadithText = const Value.absent(),
    this.sectionId = const Value.absent(),
    this.bookId = const Value.absent(),
  });
  HadithsTableCompanion.insert({
    this.id = const Value.absent(),
    required int hadithNumber,
    required String hadithText,
    required int sectionId,
    required int bookId,
  }) : hadithNumber = Value(hadithNumber),
       hadithText = Value(hadithText),
       sectionId = Value(sectionId),
       bookId = Value(bookId);
  static Insertable<HadithData> custom({
    Expression<int>? id,
    Expression<int>? hadithNumber,
    Expression<String>? hadithText,
    Expression<int>? sectionId,
    Expression<int>? bookId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (hadithNumber != null) 'hadith_number': hadithNumber,
      if (hadithText != null) 'text': hadithText,
      if (sectionId != null) 'section_id': sectionId,
      if (bookId != null) 'book_id': bookId,
    });
  }

  HadithsTableCompanion copyWith({
    Value<int>? id,
    Value<int>? hadithNumber,
    Value<String>? hadithText,
    Value<int>? sectionId,
    Value<int>? bookId,
  }) {
    return HadithsTableCompanion(
      id: id ?? this.id,
      hadithNumber: hadithNumber ?? this.hadithNumber,
      hadithText: hadithText ?? this.hadithText,
      sectionId: sectionId ?? this.sectionId,
      bookId: bookId ?? this.bookId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (hadithNumber.present) {
      map['hadith_number'] = Variable<int>(hadithNumber.value);
    }
    if (hadithText.present) {
      map['text'] = Variable<String>(hadithText.value);
    }
    if (sectionId.present) {
      map['section_id'] = Variable<int>(sectionId.value);
    }
    if (bookId.present) {
      map['book_id'] = Variable<int>(bookId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HadithsTableCompanion(')
          ..write('id: $id, ')
          ..write('hadithNumber: $hadithNumber, ')
          ..write('hadithText: $hadithText, ')
          ..write('sectionId: $sectionId, ')
          ..write('bookId: $bookId')
          ..write(')'))
        .toString();
  }
}

class $GradesTableTable extends GradesTable
    with TableInfo<$GradesTableTable, HadithGrade> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GradesTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _hadithIdMeta = const VerificationMeta(
    'hadithId',
  );
  @override
  late final GeneratedColumn<int> hadithId = GeneratedColumn<int>(
    'hadith_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES hadiths (id)',
    ),
  );
  static const VerificationMeta _scholarNameMeta = const VerificationMeta(
    'scholarName',
  );
  @override
  late final GeneratedColumn<String> scholarName = GeneratedColumn<String>(
    'scholar_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gradeMeta = const VerificationMeta('grade');
  @override
  late final GeneratedColumn<String> grade = GeneratedColumn<String>(
    'grade',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, hadithId, scholarName, grade];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'grades';
  @override
  VerificationContext validateIntegrity(
    Insertable<HadithGrade> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('hadith_id')) {
      context.handle(
        _hadithIdMeta,
        hadithId.isAcceptableOrUnknown(data['hadith_id']!, _hadithIdMeta),
      );
    } else if (isInserting) {
      context.missing(_hadithIdMeta);
    }
    if (data.containsKey('scholar_name')) {
      context.handle(
        _scholarNameMeta,
        scholarName.isAcceptableOrUnknown(
          data['scholar_name']!,
          _scholarNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_scholarNameMeta);
    }
    if (data.containsKey('grade')) {
      context.handle(
        _gradeMeta,
        grade.isAcceptableOrUnknown(data['grade']!, _gradeMeta),
      );
    } else if (isInserting) {
      context.missing(_gradeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HadithGrade map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HadithGrade(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      hadithId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hadith_id'],
      )!,
      scholarName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scholar_name'],
      )!,
      grade: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}grade'],
      )!,
    );
  }

  @override
  $GradesTableTable createAlias(String alias) {
    return $GradesTableTable(attachedDatabase, alias);
  }
}

class HadithGrade extends DataClass implements Insertable<HadithGrade> {
  final int id;
  final int hadithId;
  final String scholarName;
  final String grade;
  const HadithGrade({
    required this.id,
    required this.hadithId,
    required this.scholarName,
    required this.grade,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['hadith_id'] = Variable<int>(hadithId);
    map['scholar_name'] = Variable<String>(scholarName);
    map['grade'] = Variable<String>(grade);
    return map;
  }

  GradesTableCompanion toCompanion(bool nullToAbsent) {
    return GradesTableCompanion(
      id: Value(id),
      hadithId: Value(hadithId),
      scholarName: Value(scholarName),
      grade: Value(grade),
    );
  }

  factory HadithGrade.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HadithGrade(
      id: serializer.fromJson<int>(json['id']),
      hadithId: serializer.fromJson<int>(json['hadithId']),
      scholarName: serializer.fromJson<String>(json['scholarName']),
      grade: serializer.fromJson<String>(json['grade']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'hadithId': serializer.toJson<int>(hadithId),
      'scholarName': serializer.toJson<String>(scholarName),
      'grade': serializer.toJson<String>(grade),
    };
  }

  HadithGrade copyWith({
    int? id,
    int? hadithId,
    String? scholarName,
    String? grade,
  }) => HadithGrade(
    id: id ?? this.id,
    hadithId: hadithId ?? this.hadithId,
    scholarName: scholarName ?? this.scholarName,
    grade: grade ?? this.grade,
  );
  HadithGrade copyWithCompanion(GradesTableCompanion data) {
    return HadithGrade(
      id: data.id.present ? data.id.value : this.id,
      hadithId: data.hadithId.present ? data.hadithId.value : this.hadithId,
      scholarName: data.scholarName.present
          ? data.scholarName.value
          : this.scholarName,
      grade: data.grade.present ? data.grade.value : this.grade,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HadithGrade(')
          ..write('id: $id, ')
          ..write('hadithId: $hadithId, ')
          ..write('scholarName: $scholarName, ')
          ..write('grade: $grade')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, hadithId, scholarName, grade);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HadithGrade &&
          other.id == this.id &&
          other.hadithId == this.hadithId &&
          other.scholarName == this.scholarName &&
          other.grade == this.grade);
}

class GradesTableCompanion extends UpdateCompanion<HadithGrade> {
  final Value<int> id;
  final Value<int> hadithId;
  final Value<String> scholarName;
  final Value<String> grade;
  const GradesTableCompanion({
    this.id = const Value.absent(),
    this.hadithId = const Value.absent(),
    this.scholarName = const Value.absent(),
    this.grade = const Value.absent(),
  });
  GradesTableCompanion.insert({
    this.id = const Value.absent(),
    required int hadithId,
    required String scholarName,
    required String grade,
  }) : hadithId = Value(hadithId),
       scholarName = Value(scholarName),
       grade = Value(grade);
  static Insertable<HadithGrade> custom({
    Expression<int>? id,
    Expression<int>? hadithId,
    Expression<String>? scholarName,
    Expression<String>? grade,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (hadithId != null) 'hadith_id': hadithId,
      if (scholarName != null) 'scholar_name': scholarName,
      if (grade != null) 'grade': grade,
    });
  }

  GradesTableCompanion copyWith({
    Value<int>? id,
    Value<int>? hadithId,
    Value<String>? scholarName,
    Value<String>? grade,
  }) {
    return GradesTableCompanion(
      id: id ?? this.id,
      hadithId: hadithId ?? this.hadithId,
      scholarName: scholarName ?? this.scholarName,
      grade: grade ?? this.grade,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (hadithId.present) {
      map['hadith_id'] = Variable<int>(hadithId.value);
    }
    if (scholarName.present) {
      map['scholar_name'] = Variable<String>(scholarName.value);
    }
    if (grade.present) {
      map['grade'] = Variable<String>(grade.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GradesTableCompanion(')
          ..write('id: $id, ')
          ..write('hadithId: $hadithId, ')
          ..write('scholarName: $scholarName, ')
          ..write('grade: $grade')
          ..write(')'))
        .toString();
  }
}

class $HadithsFtsTable extends HadithsFts
    with TableInfo<$HadithsFtsTable, HadithsFt> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HadithsFtsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _hadithTextMeta = const VerificationMeta(
    'hadithText',
  );
  @override
  late final GeneratedColumn<String> hadithText = GeneratedColumn<String>(
    'text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [hadithText];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'hadiths_fts';
  @override
  VerificationContext validateIntegrity(
    Insertable<HadithsFt> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('text')) {
      context.handle(
        _hadithTextMeta,
        hadithText.isAcceptableOrUnknown(data['text']!, _hadithTextMeta),
      );
    } else if (isInserting) {
      context.missing(_hadithTextMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  HadithsFt map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HadithsFt(
      hadithText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}text'],
      )!,
    );
  }

  @override
  $HadithsFtsTable createAlias(String alias) {
    return $HadithsFtsTable(attachedDatabase, alias);
  }
}

class HadithsFt extends DataClass implements Insertable<HadithsFt> {
  final String hadithText;
  const HadithsFt({required this.hadithText});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['text'] = Variable<String>(hadithText);
    return map;
  }

  HadithsFtsCompanion toCompanion(bool nullToAbsent) {
    return HadithsFtsCompanion(hadithText: Value(hadithText));
  }

  factory HadithsFt.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HadithsFt(
      hadithText: serializer.fromJson<String>(json['hadithText']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'hadithText': serializer.toJson<String>(hadithText),
    };
  }

  HadithsFt copyWith({String? hadithText}) =>
      HadithsFt(hadithText: hadithText ?? this.hadithText);
  HadithsFt copyWithCompanion(HadithsFtsCompanion data) {
    return HadithsFt(
      hadithText: data.hadithText.present
          ? data.hadithText.value
          : this.hadithText,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HadithsFt(')
          ..write('hadithText: $hadithText')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => hadithText.hashCode;
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HadithsFt && other.hadithText == this.hadithText);
}

class HadithsFtsCompanion extends UpdateCompanion<HadithsFt> {
  final Value<String> hadithText;
  final Value<int> rowid;
  const HadithsFtsCompanion({
    this.hadithText = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HadithsFtsCompanion.insert({
    required String hadithText,
    this.rowid = const Value.absent(),
  }) : hadithText = Value(hadithText);
  static Insertable<HadithsFt> custom({
    Expression<String>? hadithText,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (hadithText != null) 'text': hadithText,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HadithsFtsCompanion copyWith({Value<String>? hadithText, Value<int>? rowid}) {
    return HadithsFtsCompanion(
      hadithText: hadithText ?? this.hadithText,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (hadithText.present) {
      map['text'] = Variable<String>(hadithText.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HadithsFtsCompanion(')
          ..write('hadithText: $hadithText, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$HadithDatabase extends GeneratedDatabase {
  _$HadithDatabase(QueryExecutor e) : super(e);
  $HadithDatabaseManager get managers => $HadithDatabaseManager(this);
  late final $BookInfoTableTable bookInfoTable = $BookInfoTableTable(this);
  late final $SectionsTableTable sectionsTable = $SectionsTableTable(this);
  late final $HadithsTableTable hadithsTable = $HadithsTableTable(this);
  late final $GradesTableTable gradesTable = $GradesTableTable(this);
  late final $HadithsFtsTable hadithsFts = $HadithsFtsTable(this);
  late final HadithDao hadithDao = HadithDao(this as HadithDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    bookInfoTable,
    sectionsTable,
    hadithsTable,
    gradesTable,
    hadithsFts,
  ];
}

typedef $$BookInfoTableTableCreateCompanionBuilder =
    BookInfoTableCompanion Function({
      Value<int> id,
      required String bookName,
      required int hadithCount,
    });
typedef $$BookInfoTableTableUpdateCompanionBuilder =
    BookInfoTableCompanion Function({
      Value<int> id,
      Value<String> bookName,
      Value<int> hadithCount,
    });

class $$BookInfoTableTableFilterComposer
    extends Composer<_$HadithDatabase, $BookInfoTableTable> {
  $$BookInfoTableTableFilterComposer({
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

  ColumnFilters<String> get bookName => $composableBuilder(
    column: $table.bookName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hadithCount => $composableBuilder(
    column: $table.hadithCount,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BookInfoTableTableOrderingComposer
    extends Composer<_$HadithDatabase, $BookInfoTableTable> {
  $$BookInfoTableTableOrderingComposer({
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

  ColumnOrderings<String> get bookName => $composableBuilder(
    column: $table.bookName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hadithCount => $composableBuilder(
    column: $table.hadithCount,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BookInfoTableTableAnnotationComposer
    extends Composer<_$HadithDatabase, $BookInfoTableTable> {
  $$BookInfoTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get bookName =>
      $composableBuilder(column: $table.bookName, builder: (column) => column);

  GeneratedColumn<int> get hadithCount => $composableBuilder(
    column: $table.hadithCount,
    builder: (column) => column,
  );
}

class $$BookInfoTableTableTableManager
    extends
        RootTableManager<
          _$HadithDatabase,
          $BookInfoTableTable,
          BookInfo,
          $$BookInfoTableTableFilterComposer,
          $$BookInfoTableTableOrderingComposer,
          $$BookInfoTableTableAnnotationComposer,
          $$BookInfoTableTableCreateCompanionBuilder,
          $$BookInfoTableTableUpdateCompanionBuilder,
          (
            BookInfo,
            BaseReferences<_$HadithDatabase, $BookInfoTableTable, BookInfo>,
          ),
          BookInfo,
          PrefetchHooks Function()
        > {
  $$BookInfoTableTableTableManager(
    _$HadithDatabase db,
    $BookInfoTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BookInfoTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BookInfoTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BookInfoTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> bookName = const Value.absent(),
                Value<int> hadithCount = const Value.absent(),
              }) => BookInfoTableCompanion(
                id: id,
                bookName: bookName,
                hadithCount: hadithCount,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String bookName,
                required int hadithCount,
              }) => BookInfoTableCompanion.insert(
                id: id,
                bookName: bookName,
                hadithCount: hadithCount,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BookInfoTableTableProcessedTableManager =
    ProcessedTableManager<
      _$HadithDatabase,
      $BookInfoTableTable,
      BookInfo,
      $$BookInfoTableTableFilterComposer,
      $$BookInfoTableTableOrderingComposer,
      $$BookInfoTableTableAnnotationComposer,
      $$BookInfoTableTableCreateCompanionBuilder,
      $$BookInfoTableTableUpdateCompanionBuilder,
      (
        BookInfo,
        BaseReferences<_$HadithDatabase, $BookInfoTableTable, BookInfo>,
      ),
      BookInfo,
      PrefetchHooks Function()
    >;
typedef $$SectionsTableTableCreateCompanionBuilder =
    SectionsTableCompanion Function({
      Value<int> id,
      required String sectionName,
      required int startHadithNumber,
      required int endHadithNumber,
      required int hadithCount,
    });
typedef $$SectionsTableTableUpdateCompanionBuilder =
    SectionsTableCompanion Function({
      Value<int> id,
      Value<String> sectionName,
      Value<int> startHadithNumber,
      Value<int> endHadithNumber,
      Value<int> hadithCount,
    });

final class $$SectionsTableTableReferences
    extends
        BaseReferences<_$HadithDatabase, $SectionsTableTable, HadithSection> {
  $$SectionsTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$HadithsTableTable, List<HadithData>>
  _hadithsTableRefsTable(_$HadithDatabase db) => MultiTypedResultKey.fromTable(
    db.hadithsTable,
    aliasName: $_aliasNameGenerator(
      db.sectionsTable.id,
      db.hadithsTable.sectionId,
    ),
  );

  $$HadithsTableTableProcessedTableManager get hadithsTableRefs {
    final manager = $$HadithsTableTableTableManager(
      $_db,
      $_db.hadithsTable,
    ).filter((f) => f.sectionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_hadithsTableRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SectionsTableTableFilterComposer
    extends Composer<_$HadithDatabase, $SectionsTableTable> {
  $$SectionsTableTableFilterComposer({
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

  ColumnFilters<String> get sectionName => $composableBuilder(
    column: $table.sectionName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startHadithNumber => $composableBuilder(
    column: $table.startHadithNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endHadithNumber => $composableBuilder(
    column: $table.endHadithNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hadithCount => $composableBuilder(
    column: $table.hadithCount,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> hadithsTableRefs(
    Expression<bool> Function($$HadithsTableTableFilterComposer f) f,
  ) {
    final $$HadithsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.hadithsTable,
      getReferencedColumn: (t) => t.sectionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HadithsTableTableFilterComposer(
            $db: $db,
            $table: $db.hadithsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SectionsTableTableOrderingComposer
    extends Composer<_$HadithDatabase, $SectionsTableTable> {
  $$SectionsTableTableOrderingComposer({
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

  ColumnOrderings<String> get sectionName => $composableBuilder(
    column: $table.sectionName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startHadithNumber => $composableBuilder(
    column: $table.startHadithNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endHadithNumber => $composableBuilder(
    column: $table.endHadithNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hadithCount => $composableBuilder(
    column: $table.hadithCount,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SectionsTableTableAnnotationComposer
    extends Composer<_$HadithDatabase, $SectionsTableTable> {
  $$SectionsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sectionName => $composableBuilder(
    column: $table.sectionName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get startHadithNumber => $composableBuilder(
    column: $table.startHadithNumber,
    builder: (column) => column,
  );

  GeneratedColumn<int> get endHadithNumber => $composableBuilder(
    column: $table.endHadithNumber,
    builder: (column) => column,
  );

  GeneratedColumn<int> get hadithCount => $composableBuilder(
    column: $table.hadithCount,
    builder: (column) => column,
  );

  Expression<T> hadithsTableRefs<T extends Object>(
    Expression<T> Function($$HadithsTableTableAnnotationComposer a) f,
  ) {
    final $$HadithsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.hadithsTable,
      getReferencedColumn: (t) => t.sectionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HadithsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.hadithsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SectionsTableTableTableManager
    extends
        RootTableManager<
          _$HadithDatabase,
          $SectionsTableTable,
          HadithSection,
          $$SectionsTableTableFilterComposer,
          $$SectionsTableTableOrderingComposer,
          $$SectionsTableTableAnnotationComposer,
          $$SectionsTableTableCreateCompanionBuilder,
          $$SectionsTableTableUpdateCompanionBuilder,
          (HadithSection, $$SectionsTableTableReferences),
          HadithSection,
          PrefetchHooks Function({bool hadithsTableRefs})
        > {
  $$SectionsTableTableTableManager(
    _$HadithDatabase db,
    $SectionsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SectionsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SectionsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SectionsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> sectionName = const Value.absent(),
                Value<int> startHadithNumber = const Value.absent(),
                Value<int> endHadithNumber = const Value.absent(),
                Value<int> hadithCount = const Value.absent(),
              }) => SectionsTableCompanion(
                id: id,
                sectionName: sectionName,
                startHadithNumber: startHadithNumber,
                endHadithNumber: endHadithNumber,
                hadithCount: hadithCount,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String sectionName,
                required int startHadithNumber,
                required int endHadithNumber,
                required int hadithCount,
              }) => SectionsTableCompanion.insert(
                id: id,
                sectionName: sectionName,
                startHadithNumber: startHadithNumber,
                endHadithNumber: endHadithNumber,
                hadithCount: hadithCount,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SectionsTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({hadithsTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (hadithsTableRefs) db.hadithsTable],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (hadithsTableRefs)
                    await $_getPrefetchedData<
                      HadithSection,
                      $SectionsTableTable,
                      HadithData
                    >(
                      currentTable: table,
                      referencedTable: $$SectionsTableTableReferences
                          ._hadithsTableRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$SectionsTableTableReferences(
                            db,
                            table,
                            p0,
                          ).hadithsTableRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.sectionId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$SectionsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$HadithDatabase,
      $SectionsTableTable,
      HadithSection,
      $$SectionsTableTableFilterComposer,
      $$SectionsTableTableOrderingComposer,
      $$SectionsTableTableAnnotationComposer,
      $$SectionsTableTableCreateCompanionBuilder,
      $$SectionsTableTableUpdateCompanionBuilder,
      (HadithSection, $$SectionsTableTableReferences),
      HadithSection,
      PrefetchHooks Function({bool hadithsTableRefs})
    >;
typedef $$HadithsTableTableCreateCompanionBuilder =
    HadithsTableCompanion Function({
      Value<int> id,
      required int hadithNumber,
      required String hadithText,
      required int sectionId,
      required int bookId,
    });
typedef $$HadithsTableTableUpdateCompanionBuilder =
    HadithsTableCompanion Function({
      Value<int> id,
      Value<int> hadithNumber,
      Value<String> hadithText,
      Value<int> sectionId,
      Value<int> bookId,
    });

final class $$HadithsTableTableReferences
    extends BaseReferences<_$HadithDatabase, $HadithsTableTable, HadithData> {
  $$HadithsTableTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SectionsTableTable _sectionIdTable(_$HadithDatabase db) =>
      db.sectionsTable.createAlias(
        $_aliasNameGenerator(db.hadithsTable.sectionId, db.sectionsTable.id),
      );

  $$SectionsTableTableProcessedTableManager get sectionId {
    final $_column = $_itemColumn<int>('section_id')!;

    final manager = $$SectionsTableTableTableManager(
      $_db,
      $_db.sectionsTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sectionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$GradesTableTable, List<HadithGrade>>
  _gradesTableRefsTable(_$HadithDatabase db) => MultiTypedResultKey.fromTable(
    db.gradesTable,
    aliasName: $_aliasNameGenerator(
      db.hadithsTable.id,
      db.gradesTable.hadithId,
    ),
  );

  $$GradesTableTableProcessedTableManager get gradesTableRefs {
    final manager = $$GradesTableTableTableManager(
      $_db,
      $_db.gradesTable,
    ).filter((f) => f.hadithId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_gradesTableRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$HadithsTableTableFilterComposer
    extends Composer<_$HadithDatabase, $HadithsTableTable> {
  $$HadithsTableTableFilterComposer({
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

  ColumnFilters<int> get hadithNumber => $composableBuilder(
    column: $table.hadithNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hadithText => $composableBuilder(
    column: $table.hadithText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bookId => $composableBuilder(
    column: $table.bookId,
    builder: (column) => ColumnFilters(column),
  );

  $$SectionsTableTableFilterComposer get sectionId {
    final $$SectionsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sectionId,
      referencedTable: $db.sectionsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SectionsTableTableFilterComposer(
            $db: $db,
            $table: $db.sectionsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> gradesTableRefs(
    Expression<bool> Function($$GradesTableTableFilterComposer f) f,
  ) {
    final $$GradesTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.gradesTable,
      getReferencedColumn: (t) => t.hadithId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GradesTableTableFilterComposer(
            $db: $db,
            $table: $db.gradesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$HadithsTableTableOrderingComposer
    extends Composer<_$HadithDatabase, $HadithsTableTable> {
  $$HadithsTableTableOrderingComposer({
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

  ColumnOrderings<int> get hadithNumber => $composableBuilder(
    column: $table.hadithNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hadithText => $composableBuilder(
    column: $table.hadithText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bookId => $composableBuilder(
    column: $table.bookId,
    builder: (column) => ColumnOrderings(column),
  );

  $$SectionsTableTableOrderingComposer get sectionId {
    final $$SectionsTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sectionId,
      referencedTable: $db.sectionsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SectionsTableTableOrderingComposer(
            $db: $db,
            $table: $db.sectionsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HadithsTableTableAnnotationComposer
    extends Composer<_$HadithDatabase, $HadithsTableTable> {
  $$HadithsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get hadithNumber => $composableBuilder(
    column: $table.hadithNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get hadithText => $composableBuilder(
    column: $table.hadithText,
    builder: (column) => column,
  );

  GeneratedColumn<int> get bookId =>
      $composableBuilder(column: $table.bookId, builder: (column) => column);

  $$SectionsTableTableAnnotationComposer get sectionId {
    final $$SectionsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sectionId,
      referencedTable: $db.sectionsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SectionsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.sectionsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> gradesTableRefs<T extends Object>(
    Expression<T> Function($$GradesTableTableAnnotationComposer a) f,
  ) {
    final $$GradesTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.gradesTable,
      getReferencedColumn: (t) => t.hadithId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GradesTableTableAnnotationComposer(
            $db: $db,
            $table: $db.gradesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$HadithsTableTableTableManager
    extends
        RootTableManager<
          _$HadithDatabase,
          $HadithsTableTable,
          HadithData,
          $$HadithsTableTableFilterComposer,
          $$HadithsTableTableOrderingComposer,
          $$HadithsTableTableAnnotationComposer,
          $$HadithsTableTableCreateCompanionBuilder,
          $$HadithsTableTableUpdateCompanionBuilder,
          (HadithData, $$HadithsTableTableReferences),
          HadithData,
          PrefetchHooks Function({bool sectionId, bool gradesTableRefs})
        > {
  $$HadithsTableTableTableManager(_$HadithDatabase db, $HadithsTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HadithsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HadithsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HadithsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> hadithNumber = const Value.absent(),
                Value<String> hadithText = const Value.absent(),
                Value<int> sectionId = const Value.absent(),
                Value<int> bookId = const Value.absent(),
              }) => HadithsTableCompanion(
                id: id,
                hadithNumber: hadithNumber,
                hadithText: hadithText,
                sectionId: sectionId,
                bookId: bookId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int hadithNumber,
                required String hadithText,
                required int sectionId,
                required int bookId,
              }) => HadithsTableCompanion.insert(
                id: id,
                hadithNumber: hadithNumber,
                hadithText: hadithText,
                sectionId: sectionId,
                bookId: bookId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$HadithsTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({sectionId = false, gradesTableRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (gradesTableRefs) db.gradesTable,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (sectionId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.sectionId,
                                    referencedTable:
                                        $$HadithsTableTableReferences
                                            ._sectionIdTable(db),
                                    referencedColumn:
                                        $$HadithsTableTableReferences
                                            ._sectionIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (gradesTableRefs)
                        await $_getPrefetchedData<
                          HadithData,
                          $HadithsTableTable,
                          HadithGrade
                        >(
                          currentTable: table,
                          referencedTable: $$HadithsTableTableReferences
                              ._gradesTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$HadithsTableTableReferences(
                                db,
                                table,
                                p0,
                              ).gradesTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.hadithId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$HadithsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$HadithDatabase,
      $HadithsTableTable,
      HadithData,
      $$HadithsTableTableFilterComposer,
      $$HadithsTableTableOrderingComposer,
      $$HadithsTableTableAnnotationComposer,
      $$HadithsTableTableCreateCompanionBuilder,
      $$HadithsTableTableUpdateCompanionBuilder,
      (HadithData, $$HadithsTableTableReferences),
      HadithData,
      PrefetchHooks Function({bool sectionId, bool gradesTableRefs})
    >;
typedef $$GradesTableTableCreateCompanionBuilder =
    GradesTableCompanion Function({
      Value<int> id,
      required int hadithId,
      required String scholarName,
      required String grade,
    });
typedef $$GradesTableTableUpdateCompanionBuilder =
    GradesTableCompanion Function({
      Value<int> id,
      Value<int> hadithId,
      Value<String> scholarName,
      Value<String> grade,
    });

final class $$GradesTableTableReferences
    extends BaseReferences<_$HadithDatabase, $GradesTableTable, HadithGrade> {
  $$GradesTableTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $HadithsTableTable _hadithIdTable(_$HadithDatabase db) =>
      db.hadithsTable.createAlias(
        $_aliasNameGenerator(db.gradesTable.hadithId, db.hadithsTable.id),
      );

  $$HadithsTableTableProcessedTableManager get hadithId {
    final $_column = $_itemColumn<int>('hadith_id')!;

    final manager = $$HadithsTableTableTableManager(
      $_db,
      $_db.hadithsTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_hadithIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$GradesTableTableFilterComposer
    extends Composer<_$HadithDatabase, $GradesTableTable> {
  $$GradesTableTableFilterComposer({
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

  ColumnFilters<String> get scholarName => $composableBuilder(
    column: $table.scholarName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get grade => $composableBuilder(
    column: $table.grade,
    builder: (column) => ColumnFilters(column),
  );

  $$HadithsTableTableFilterComposer get hadithId {
    final $$HadithsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.hadithId,
      referencedTable: $db.hadithsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HadithsTableTableFilterComposer(
            $db: $db,
            $table: $db.hadithsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GradesTableTableOrderingComposer
    extends Composer<_$HadithDatabase, $GradesTableTable> {
  $$GradesTableTableOrderingComposer({
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

  ColumnOrderings<String> get scholarName => $composableBuilder(
    column: $table.scholarName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get grade => $composableBuilder(
    column: $table.grade,
    builder: (column) => ColumnOrderings(column),
  );

  $$HadithsTableTableOrderingComposer get hadithId {
    final $$HadithsTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.hadithId,
      referencedTable: $db.hadithsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HadithsTableTableOrderingComposer(
            $db: $db,
            $table: $db.hadithsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GradesTableTableAnnotationComposer
    extends Composer<_$HadithDatabase, $GradesTableTable> {
  $$GradesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get scholarName => $composableBuilder(
    column: $table.scholarName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get grade =>
      $composableBuilder(column: $table.grade, builder: (column) => column);

  $$HadithsTableTableAnnotationComposer get hadithId {
    final $$HadithsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.hadithId,
      referencedTable: $db.hadithsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HadithsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.hadithsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GradesTableTableTableManager
    extends
        RootTableManager<
          _$HadithDatabase,
          $GradesTableTable,
          HadithGrade,
          $$GradesTableTableFilterComposer,
          $$GradesTableTableOrderingComposer,
          $$GradesTableTableAnnotationComposer,
          $$GradesTableTableCreateCompanionBuilder,
          $$GradesTableTableUpdateCompanionBuilder,
          (HadithGrade, $$GradesTableTableReferences),
          HadithGrade,
          PrefetchHooks Function({bool hadithId})
        > {
  $$GradesTableTableTableManager(_$HadithDatabase db, $GradesTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GradesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GradesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GradesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> hadithId = const Value.absent(),
                Value<String> scholarName = const Value.absent(),
                Value<String> grade = const Value.absent(),
              }) => GradesTableCompanion(
                id: id,
                hadithId: hadithId,
                scholarName: scholarName,
                grade: grade,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int hadithId,
                required String scholarName,
                required String grade,
              }) => GradesTableCompanion.insert(
                id: id,
                hadithId: hadithId,
                scholarName: scholarName,
                grade: grade,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$GradesTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({hadithId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (hadithId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.hadithId,
                                referencedTable: $$GradesTableTableReferences
                                    ._hadithIdTable(db),
                                referencedColumn: $$GradesTableTableReferences
                                    ._hadithIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$GradesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$HadithDatabase,
      $GradesTableTable,
      HadithGrade,
      $$GradesTableTableFilterComposer,
      $$GradesTableTableOrderingComposer,
      $$GradesTableTableAnnotationComposer,
      $$GradesTableTableCreateCompanionBuilder,
      $$GradesTableTableUpdateCompanionBuilder,
      (HadithGrade, $$GradesTableTableReferences),
      HadithGrade,
      PrefetchHooks Function({bool hadithId})
    >;
typedef $$HadithsFtsTableCreateCompanionBuilder =
    HadithsFtsCompanion Function({
      required String hadithText,
      Value<int> rowid,
    });
typedef $$HadithsFtsTableUpdateCompanionBuilder =
    HadithsFtsCompanion Function({Value<String> hadithText, Value<int> rowid});

class $$HadithsFtsTableFilterComposer
    extends Composer<_$HadithDatabase, $HadithsFtsTable> {
  $$HadithsFtsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get hadithText => $composableBuilder(
    column: $table.hadithText,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HadithsFtsTableOrderingComposer
    extends Composer<_$HadithDatabase, $HadithsFtsTable> {
  $$HadithsFtsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get hadithText => $composableBuilder(
    column: $table.hadithText,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HadithsFtsTableAnnotationComposer
    extends Composer<_$HadithDatabase, $HadithsFtsTable> {
  $$HadithsFtsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get hadithText => $composableBuilder(
    column: $table.hadithText,
    builder: (column) => column,
  );
}

class $$HadithsFtsTableTableManager
    extends
        RootTableManager<
          _$HadithDatabase,
          $HadithsFtsTable,
          HadithsFt,
          $$HadithsFtsTableFilterComposer,
          $$HadithsFtsTableOrderingComposer,
          $$HadithsFtsTableAnnotationComposer,
          $$HadithsFtsTableCreateCompanionBuilder,
          $$HadithsFtsTableUpdateCompanionBuilder,
          (
            HadithsFt,
            BaseReferences<_$HadithDatabase, $HadithsFtsTable, HadithsFt>,
          ),
          HadithsFt,
          PrefetchHooks Function()
        > {
  $$HadithsFtsTableTableManager(_$HadithDatabase db, $HadithsFtsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HadithsFtsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HadithsFtsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HadithsFtsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> hadithText = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HadithsFtsCompanion(hadithText: hadithText, rowid: rowid),
          createCompanionCallback:
              ({
                required String hadithText,
                Value<int> rowid = const Value.absent(),
              }) => HadithsFtsCompanion.insert(
                hadithText: hadithText,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HadithsFtsTableProcessedTableManager =
    ProcessedTableManager<
      _$HadithDatabase,
      $HadithsFtsTable,
      HadithsFt,
      $$HadithsFtsTableFilterComposer,
      $$HadithsFtsTableOrderingComposer,
      $$HadithsFtsTableAnnotationComposer,
      $$HadithsFtsTableCreateCompanionBuilder,
      $$HadithsFtsTableUpdateCompanionBuilder,
      (
        HadithsFt,
        BaseReferences<_$HadithDatabase, $HadithsFtsTable, HadithsFt>,
      ),
      HadithsFt,
      PrefetchHooks Function()
    >;

class $HadithDatabaseManager {
  final _$HadithDatabase _db;
  $HadithDatabaseManager(this._db);
  $$BookInfoTableTableTableManager get bookInfoTable =>
      $$BookInfoTableTableTableManager(_db, _db.bookInfoTable);
  $$SectionsTableTableTableManager get sectionsTable =>
      $$SectionsTableTableTableManager(_db, _db.sectionsTable);
  $$HadithsTableTableTableManager get hadithsTable =>
      $$HadithsTableTableTableManager(_db, _db.hadithsTable);
  $$GradesTableTableTableManager get gradesTable =>
      $$GradesTableTableTableManager(_db, _db.gradesTable);
  $$HadithsFtsTableTableManager get hadithsFts =>
      $$HadithsFtsTableTableManager(_db, _db.hadithsFts);
}
