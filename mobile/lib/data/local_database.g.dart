// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_database.dart';

// ignore_for_file: type=lint
class $LocalMaterialsTable extends LocalMaterials
    with TableInfo<$LocalMaterialsTable, LocalMaterial> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalMaterialsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 50),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _subCategoryMeta =
      const VerificationMeta('subCategory');
  @override
  late final GeneratedColumn<String> subCategory = GeneratedColumn<String>(
      'sub_category', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 50),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _imageRefMeta =
      const VerificationMeta('imageRef');
  @override
  late final GeneratedColumn<String> imageRef = GeneratedColumn<String>(
      'image_ref', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _approxWeightKgMeta =
      const VerificationMeta('approxWeightKg');
  @override
  late final GeneratedColumn<double> approxWeightKg = GeneratedColumn<double>(
      'approx_weight_kg', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _conditionMeta =
      const VerificationMeta('condition');
  @override
  late final GeneratedColumn<String> condition = GeneratedColumn<String>(
      'condition', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sourceTypeMeta =
      const VerificationMeta('sourceType');
  @override
  late final GeneratedColumn<String> sourceType = GeneratedColumn<String>(
      'source_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _estimatedValueMeta =
      const VerificationMeta('estimatedValue');
  @override
  late final GeneratedColumn<double> estimatedValue = GeneratedColumn<double>(
      'estimated_value', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        category,
        subCategory,
        description,
        imageRef,
        approxWeightKg,
        condition,
        sourceType,
        estimatedValue,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_materials';
  @override
  VerificationContext validateIntegrity(Insertable<LocalMaterial> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('sub_category')) {
      context.handle(
          _subCategoryMeta,
          subCategory.isAcceptableOrUnknown(
              data['sub_category']!, _subCategoryMeta));
    } else if (isInserting) {
      context.missing(_subCategoryMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('image_ref')) {
      context.handle(_imageRefMeta,
          imageRef.isAcceptableOrUnknown(data['image_ref']!, _imageRefMeta));
    }
    if (data.containsKey('approx_weight_kg')) {
      context.handle(
          _approxWeightKgMeta,
          approxWeightKg.isAcceptableOrUnknown(
              data['approx_weight_kg']!, _approxWeightKgMeta));
    } else if (isInserting) {
      context.missing(_approxWeightKgMeta);
    }
    if (data.containsKey('condition')) {
      context.handle(_conditionMeta,
          condition.isAcceptableOrUnknown(data['condition']!, _conditionMeta));
    } else if (isInserting) {
      context.missing(_conditionMeta);
    }
    if (data.containsKey('source_type')) {
      context.handle(
          _sourceTypeMeta,
          sourceType.isAcceptableOrUnknown(
              data['source_type']!, _sourceTypeMeta));
    } else if (isInserting) {
      context.missing(_sourceTypeMeta);
    }
    if (data.containsKey('estimated_value')) {
      context.handle(
          _estimatedValueMeta,
          estimatedValue.isAcceptableOrUnknown(
              data['estimated_value']!, _estimatedValueMeta));
    } else if (isInserting) {
      context.missing(_estimatedValueMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalMaterial map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalMaterial(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      subCategory: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sub_category'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      imageRef: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image_ref']),
      approxWeightKg: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}approx_weight_kg'])!,
      condition: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}condition'])!,
      sourceType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source_type'])!,
      estimatedValue: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}estimated_value'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $LocalMaterialsTable createAlias(String alias) {
    return $LocalMaterialsTable(attachedDatabase, alias);
  }
}

class LocalMaterial extends DataClass implements Insertable<LocalMaterial> {
  final String id;
  final String category;
  final String subCategory;
  final String description;
  final String? imageRef;
  final double approxWeightKg;
  final String condition;
  final String sourceType;
  final double estimatedValue;
  final DateTime createdAt;
  final DateTime updatedAt;
  const LocalMaterial(
      {required this.id,
      required this.category,
      required this.subCategory,
      required this.description,
      this.imageRef,
      required this.approxWeightKg,
      required this.condition,
      required this.sourceType,
      required this.estimatedValue,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['category'] = Variable<String>(category);
    map['sub_category'] = Variable<String>(subCategory);
    map['description'] = Variable<String>(description);
    if (!nullToAbsent || imageRef != null) {
      map['image_ref'] = Variable<String>(imageRef);
    }
    map['approx_weight_kg'] = Variable<double>(approxWeightKg);
    map['condition'] = Variable<String>(condition);
    map['source_type'] = Variable<String>(sourceType);
    map['estimated_value'] = Variable<double>(estimatedValue);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LocalMaterialsCompanion toCompanion(bool nullToAbsent) {
    return LocalMaterialsCompanion(
      id: Value(id),
      category: Value(category),
      subCategory: Value(subCategory),
      description: Value(description),
      imageRef: imageRef == null && nullToAbsent
          ? const Value.absent()
          : Value(imageRef),
      approxWeightKg: Value(approxWeightKg),
      condition: Value(condition),
      sourceType: Value(sourceType),
      estimatedValue: Value(estimatedValue),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory LocalMaterial.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalMaterial(
      id: serializer.fromJson<String>(json['id']),
      category: serializer.fromJson<String>(json['category']),
      subCategory: serializer.fromJson<String>(json['subCategory']),
      description: serializer.fromJson<String>(json['description']),
      imageRef: serializer.fromJson<String?>(json['imageRef']),
      approxWeightKg: serializer.fromJson<double>(json['approxWeightKg']),
      condition: serializer.fromJson<String>(json['condition']),
      sourceType: serializer.fromJson<String>(json['sourceType']),
      estimatedValue: serializer.fromJson<double>(json['estimatedValue']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'category': serializer.toJson<String>(category),
      'subCategory': serializer.toJson<String>(subCategory),
      'description': serializer.toJson<String>(description),
      'imageRef': serializer.toJson<String?>(imageRef),
      'approxWeightKg': serializer.toJson<double>(approxWeightKg),
      'condition': serializer.toJson<String>(condition),
      'sourceType': serializer.toJson<String>(sourceType),
      'estimatedValue': serializer.toJson<double>(estimatedValue),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LocalMaterial copyWith(
          {String? id,
          String? category,
          String? subCategory,
          String? description,
          Value<String?> imageRef = const Value.absent(),
          double? approxWeightKg,
          String? condition,
          String? sourceType,
          double? estimatedValue,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      LocalMaterial(
        id: id ?? this.id,
        category: category ?? this.category,
        subCategory: subCategory ?? this.subCategory,
        description: description ?? this.description,
        imageRef: imageRef.present ? imageRef.value : this.imageRef,
        approxWeightKg: approxWeightKg ?? this.approxWeightKg,
        condition: condition ?? this.condition,
        sourceType: sourceType ?? this.sourceType,
        estimatedValue: estimatedValue ?? this.estimatedValue,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  LocalMaterial copyWithCompanion(LocalMaterialsCompanion data) {
    return LocalMaterial(
      id: data.id.present ? data.id.value : this.id,
      category: data.category.present ? data.category.value : this.category,
      subCategory:
          data.subCategory.present ? data.subCategory.value : this.subCategory,
      description:
          data.description.present ? data.description.value : this.description,
      imageRef: data.imageRef.present ? data.imageRef.value : this.imageRef,
      approxWeightKg: data.approxWeightKg.present
          ? data.approxWeightKg.value
          : this.approxWeightKg,
      condition: data.condition.present ? data.condition.value : this.condition,
      sourceType:
          data.sourceType.present ? data.sourceType.value : this.sourceType,
      estimatedValue: data.estimatedValue.present
          ? data.estimatedValue.value
          : this.estimatedValue,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalMaterial(')
          ..write('id: $id, ')
          ..write('category: $category, ')
          ..write('subCategory: $subCategory, ')
          ..write('description: $description, ')
          ..write('imageRef: $imageRef, ')
          ..write('approxWeightKg: $approxWeightKg, ')
          ..write('condition: $condition, ')
          ..write('sourceType: $sourceType, ')
          ..write('estimatedValue: $estimatedValue, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      category,
      subCategory,
      description,
      imageRef,
      approxWeightKg,
      condition,
      sourceType,
      estimatedValue,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalMaterial &&
          other.id == this.id &&
          other.category == this.category &&
          other.subCategory == this.subCategory &&
          other.description == this.description &&
          other.imageRef == this.imageRef &&
          other.approxWeightKg == this.approxWeightKg &&
          other.condition == this.condition &&
          other.sourceType == this.sourceType &&
          other.estimatedValue == this.estimatedValue &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class LocalMaterialsCompanion extends UpdateCompanion<LocalMaterial> {
  final Value<String> id;
  final Value<String> category;
  final Value<String> subCategory;
  final Value<String> description;
  final Value<String?> imageRef;
  final Value<double> approxWeightKg;
  final Value<String> condition;
  final Value<String> sourceType;
  final Value<double> estimatedValue;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const LocalMaterialsCompanion({
    this.id = const Value.absent(),
    this.category = const Value.absent(),
    this.subCategory = const Value.absent(),
    this.description = const Value.absent(),
    this.imageRef = const Value.absent(),
    this.approxWeightKg = const Value.absent(),
    this.condition = const Value.absent(),
    this.sourceType = const Value.absent(),
    this.estimatedValue = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalMaterialsCompanion.insert({
    required String id,
    required String category,
    required String subCategory,
    required String description,
    this.imageRef = const Value.absent(),
    required double approxWeightKg,
    required String condition,
    required String sourceType,
    required double estimatedValue,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        category = Value(category),
        subCategory = Value(subCategory),
        description = Value(description),
        approxWeightKg = Value(approxWeightKg),
        condition = Value(condition),
        sourceType = Value(sourceType),
        estimatedValue = Value(estimatedValue),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<LocalMaterial> custom({
    Expression<String>? id,
    Expression<String>? category,
    Expression<String>? subCategory,
    Expression<String>? description,
    Expression<String>? imageRef,
    Expression<double>? approxWeightKg,
    Expression<String>? condition,
    Expression<String>? sourceType,
    Expression<double>? estimatedValue,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (category != null) 'category': category,
      if (subCategory != null) 'sub_category': subCategory,
      if (description != null) 'description': description,
      if (imageRef != null) 'image_ref': imageRef,
      if (approxWeightKg != null) 'approx_weight_kg': approxWeightKg,
      if (condition != null) 'condition': condition,
      if (sourceType != null) 'source_type': sourceType,
      if (estimatedValue != null) 'estimated_value': estimatedValue,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalMaterialsCompanion copyWith(
      {Value<String>? id,
      Value<String>? category,
      Value<String>? subCategory,
      Value<String>? description,
      Value<String?>? imageRef,
      Value<double>? approxWeightKg,
      Value<String>? condition,
      Value<String>? sourceType,
      Value<double>? estimatedValue,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return LocalMaterialsCompanion(
      id: id ?? this.id,
      category: category ?? this.category,
      subCategory: subCategory ?? this.subCategory,
      description: description ?? this.description,
      imageRef: imageRef ?? this.imageRef,
      approxWeightKg: approxWeightKg ?? this.approxWeightKg,
      condition: condition ?? this.condition,
      sourceType: sourceType ?? this.sourceType,
      estimatedValue: estimatedValue ?? this.estimatedValue,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (subCategory.present) {
      map['sub_category'] = Variable<String>(subCategory.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (imageRef.present) {
      map['image_ref'] = Variable<String>(imageRef.value);
    }
    if (approxWeightKg.present) {
      map['approx_weight_kg'] = Variable<double>(approxWeightKg.value);
    }
    if (condition.present) {
      map['condition'] = Variable<String>(condition.value);
    }
    if (sourceType.present) {
      map['source_type'] = Variable<String>(sourceType.value);
    }
    if (estimatedValue.present) {
      map['estimated_value'] = Variable<double>(estimatedValue.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalMaterialsCompanion(')
          ..write('id: $id, ')
          ..write('category: $category, ')
          ..write('subCategory: $subCategory, ')
          ..write('description: $description, ')
          ..write('imageRef: $imageRef, ')
          ..write('approxWeightKg: $approxWeightKg, ')
          ..write('condition: $condition, ')
          ..write('sourceType: $sourceType, ')
          ..write('estimatedValue: $estimatedValue, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedPricesTable extends CachedPrices
    with TableInfo<$CachedPricesTable, CachedPrice> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedPricesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 50),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _subCategoryMeta =
      const VerificationMeta('subCategory');
  @override
  late final GeneratedColumn<String> subCategory = GeneratedColumn<String>(
      'sub_category', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _districtMeta =
      const VerificationMeta('district');
  @override
  late final GeneratedColumn<String> district = GeneratedColumn<String>(
      'district', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _cityMeta = const VerificationMeta('city');
  @override
  late final GeneratedColumn<String> city = GeneratedColumn<String>(
      'city', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _latitudeMeta =
      const VerificationMeta('latitude');
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
      'latitude', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _longitudeMeta =
      const VerificationMeta('longitude');
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
      'longitude', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _recordedAtMeta =
      const VerificationMeta('recordedAt');
  @override
  late final GeneratedColumn<DateTime> recordedAt = GeneratedColumn<DateTime>(
      'recorded_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _buyingPriceMeta =
      const VerificationMeta('buyingPrice');
  @override
  late final GeneratedColumn<double> buyingPrice = GeneratedColumn<double>(
      'buying_price', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _sellingQuotedPriceMeta =
      const VerificationMeta('sellingQuotedPrice');
  @override
  late final GeneratedColumn<double> sellingQuotedPrice =
      GeneratedColumn<double>('selling_quoted_price', aliasedName, false,
          type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
      'unit', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('kg'));
  static const VerificationMeta _marketMinMeta =
      const VerificationMeta('marketMin');
  @override
  late final GeneratedColumn<double> marketMin = GeneratedColumn<double>(
      'market_min', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _marketMaxMeta =
      const VerificationMeta('marketMax');
  @override
  late final GeneratedColumn<double> marketMax = GeneratedColumn<double>(
      'market_max', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _recyclerIdMeta =
      const VerificationMeta('recyclerId');
  @override
  late final GeneratedColumn<String> recyclerId = GeneratedColumn<String>(
      'recycler_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
      'source', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('synthetic'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        category,
        subCategory,
        district,
        city,
        latitude,
        longitude,
        recordedAt,
        buyingPrice,
        sellingQuotedPrice,
        unit,
        marketMin,
        marketMax,
        recyclerId,
        source,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_prices';
  @override
  VerificationContext validateIntegrity(Insertable<CachedPrice> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('sub_category')) {
      context.handle(
          _subCategoryMeta,
          subCategory.isAcceptableOrUnknown(
              data['sub_category']!, _subCategoryMeta));
    }
    if (data.containsKey('district')) {
      context.handle(_districtMeta,
          district.isAcceptableOrUnknown(data['district']!, _districtMeta));
    } else if (isInserting) {
      context.missing(_districtMeta);
    }
    if (data.containsKey('city')) {
      context.handle(
          _cityMeta, city.isAcceptableOrUnknown(data['city']!, _cityMeta));
    }
    if (data.containsKey('latitude')) {
      context.handle(_latitudeMeta,
          latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta));
    } else if (isInserting) {
      context.missing(_latitudeMeta);
    }
    if (data.containsKey('longitude')) {
      context.handle(_longitudeMeta,
          longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta));
    } else if (isInserting) {
      context.missing(_longitudeMeta);
    }
    if (data.containsKey('recorded_at')) {
      context.handle(
          _recordedAtMeta,
          recordedAt.isAcceptableOrUnknown(
              data['recorded_at']!, _recordedAtMeta));
    } else if (isInserting) {
      context.missing(_recordedAtMeta);
    }
    if (data.containsKey('buying_price')) {
      context.handle(
          _buyingPriceMeta,
          buyingPrice.isAcceptableOrUnknown(
              data['buying_price']!, _buyingPriceMeta));
    } else if (isInserting) {
      context.missing(_buyingPriceMeta);
    }
    if (data.containsKey('selling_quoted_price')) {
      context.handle(
          _sellingQuotedPriceMeta,
          sellingQuotedPrice.isAcceptableOrUnknown(
              data['selling_quoted_price']!, _sellingQuotedPriceMeta));
    } else if (isInserting) {
      context.missing(_sellingQuotedPriceMeta);
    }
    if (data.containsKey('unit')) {
      context.handle(
          _unitMeta, unit.isAcceptableOrUnknown(data['unit']!, _unitMeta));
    }
    if (data.containsKey('market_min')) {
      context.handle(_marketMinMeta,
          marketMin.isAcceptableOrUnknown(data['market_min']!, _marketMinMeta));
    } else if (isInserting) {
      context.missing(_marketMinMeta);
    }
    if (data.containsKey('market_max')) {
      context.handle(_marketMaxMeta,
          marketMax.isAcceptableOrUnknown(data['market_max']!, _marketMaxMeta));
    } else if (isInserting) {
      context.missing(_marketMaxMeta);
    }
    if (data.containsKey('recycler_id')) {
      context.handle(
          _recyclerIdMeta,
          recyclerId.isAcceptableOrUnknown(
              data['recycler_id']!, _recyclerIdMeta));
    }
    if (data.containsKey('source')) {
      context.handle(_sourceMeta,
          source.isAcceptableOrUnknown(data['source']!, _sourceMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedPrice map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedPrice(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      subCategory: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sub_category']),
      district: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}district'])!,
      city: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}city']),
      latitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}latitude'])!,
      longitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}longitude'])!,
      recordedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}recorded_at'])!,
      buyingPrice: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}buying_price'])!,
      sellingQuotedPrice: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}selling_quoted_price'])!,
      unit: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}unit'])!,
      marketMin: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}market_min'])!,
      marketMax: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}market_max'])!,
      recyclerId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}recycler_id']),
      source: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $CachedPricesTable createAlias(String alias) {
    return $CachedPricesTable(attachedDatabase, alias);
  }
}

class CachedPrice extends DataClass implements Insertable<CachedPrice> {
  final String id;
  final String category;
  final String? subCategory;
  final String district;
  final String? city;
  final double latitude;
  final double longitude;
  final DateTime recordedAt;
  final double buyingPrice;
  final double sellingQuotedPrice;
  final String unit;
  final double marketMin;
  final double marketMax;
  final String? recyclerId;
  final String source;
  final DateTime createdAt;
  const CachedPrice(
      {required this.id,
      required this.category,
      this.subCategory,
      required this.district,
      this.city,
      required this.latitude,
      required this.longitude,
      required this.recordedAt,
      required this.buyingPrice,
      required this.sellingQuotedPrice,
      required this.unit,
      required this.marketMin,
      required this.marketMax,
      this.recyclerId,
      required this.source,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['category'] = Variable<String>(category);
    if (!nullToAbsent || subCategory != null) {
      map['sub_category'] = Variable<String>(subCategory);
    }
    map['district'] = Variable<String>(district);
    if (!nullToAbsent || city != null) {
      map['city'] = Variable<String>(city);
    }
    map['latitude'] = Variable<double>(latitude);
    map['longitude'] = Variable<double>(longitude);
    map['recorded_at'] = Variable<DateTime>(recordedAt);
    map['buying_price'] = Variable<double>(buyingPrice);
    map['selling_quoted_price'] = Variable<double>(sellingQuotedPrice);
    map['unit'] = Variable<String>(unit);
    map['market_min'] = Variable<double>(marketMin);
    map['market_max'] = Variable<double>(marketMax);
    if (!nullToAbsent || recyclerId != null) {
      map['recycler_id'] = Variable<String>(recyclerId);
    }
    map['source'] = Variable<String>(source);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CachedPricesCompanion toCompanion(bool nullToAbsent) {
    return CachedPricesCompanion(
      id: Value(id),
      category: Value(category),
      subCategory: subCategory == null && nullToAbsent
          ? const Value.absent()
          : Value(subCategory),
      district: Value(district),
      city: city == null && nullToAbsent ? const Value.absent() : Value(city),
      latitude: Value(latitude),
      longitude: Value(longitude),
      recordedAt: Value(recordedAt),
      buyingPrice: Value(buyingPrice),
      sellingQuotedPrice: Value(sellingQuotedPrice),
      unit: Value(unit),
      marketMin: Value(marketMin),
      marketMax: Value(marketMax),
      recyclerId: recyclerId == null && nullToAbsent
          ? const Value.absent()
          : Value(recyclerId),
      source: Value(source),
      createdAt: Value(createdAt),
    );
  }

  factory CachedPrice.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedPrice(
      id: serializer.fromJson<String>(json['id']),
      category: serializer.fromJson<String>(json['category']),
      subCategory: serializer.fromJson<String?>(json['subCategory']),
      district: serializer.fromJson<String>(json['district']),
      city: serializer.fromJson<String?>(json['city']),
      latitude: serializer.fromJson<double>(json['latitude']),
      longitude: serializer.fromJson<double>(json['longitude']),
      recordedAt: serializer.fromJson<DateTime>(json['recordedAt']),
      buyingPrice: serializer.fromJson<double>(json['buyingPrice']),
      sellingQuotedPrice:
          serializer.fromJson<double>(json['sellingQuotedPrice']),
      unit: serializer.fromJson<String>(json['unit']),
      marketMin: serializer.fromJson<double>(json['marketMin']),
      marketMax: serializer.fromJson<double>(json['marketMax']),
      recyclerId: serializer.fromJson<String?>(json['recyclerId']),
      source: serializer.fromJson<String>(json['source']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'category': serializer.toJson<String>(category),
      'subCategory': serializer.toJson<String?>(subCategory),
      'district': serializer.toJson<String>(district),
      'city': serializer.toJson<String?>(city),
      'latitude': serializer.toJson<double>(latitude),
      'longitude': serializer.toJson<double>(longitude),
      'recordedAt': serializer.toJson<DateTime>(recordedAt),
      'buyingPrice': serializer.toJson<double>(buyingPrice),
      'sellingQuotedPrice': serializer.toJson<double>(sellingQuotedPrice),
      'unit': serializer.toJson<String>(unit),
      'marketMin': serializer.toJson<double>(marketMin),
      'marketMax': serializer.toJson<double>(marketMax),
      'recyclerId': serializer.toJson<String?>(recyclerId),
      'source': serializer.toJson<String>(source),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  CachedPrice copyWith(
          {String? id,
          String? category,
          Value<String?> subCategory = const Value.absent(),
          String? district,
          Value<String?> city = const Value.absent(),
          double? latitude,
          double? longitude,
          DateTime? recordedAt,
          double? buyingPrice,
          double? sellingQuotedPrice,
          String? unit,
          double? marketMin,
          double? marketMax,
          Value<String?> recyclerId = const Value.absent(),
          String? source,
          DateTime? createdAt}) =>
      CachedPrice(
        id: id ?? this.id,
        category: category ?? this.category,
        subCategory: subCategory.present ? subCategory.value : this.subCategory,
        district: district ?? this.district,
        city: city.present ? city.value : this.city,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        recordedAt: recordedAt ?? this.recordedAt,
        buyingPrice: buyingPrice ?? this.buyingPrice,
        sellingQuotedPrice: sellingQuotedPrice ?? this.sellingQuotedPrice,
        unit: unit ?? this.unit,
        marketMin: marketMin ?? this.marketMin,
        marketMax: marketMax ?? this.marketMax,
        recyclerId: recyclerId.present ? recyclerId.value : this.recyclerId,
        source: source ?? this.source,
        createdAt: createdAt ?? this.createdAt,
      );
  CachedPrice copyWithCompanion(CachedPricesCompanion data) {
    return CachedPrice(
      id: data.id.present ? data.id.value : this.id,
      category: data.category.present ? data.category.value : this.category,
      subCategory:
          data.subCategory.present ? data.subCategory.value : this.subCategory,
      district: data.district.present ? data.district.value : this.district,
      city: data.city.present ? data.city.value : this.city,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      recordedAt:
          data.recordedAt.present ? data.recordedAt.value : this.recordedAt,
      buyingPrice:
          data.buyingPrice.present ? data.buyingPrice.value : this.buyingPrice,
      sellingQuotedPrice: data.sellingQuotedPrice.present
          ? data.sellingQuotedPrice.value
          : this.sellingQuotedPrice,
      unit: data.unit.present ? data.unit.value : this.unit,
      marketMin: data.marketMin.present ? data.marketMin.value : this.marketMin,
      marketMax: data.marketMax.present ? data.marketMax.value : this.marketMax,
      recyclerId:
          data.recyclerId.present ? data.recyclerId.value : this.recyclerId,
      source: data.source.present ? data.source.value : this.source,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedPrice(')
          ..write('id: $id, ')
          ..write('category: $category, ')
          ..write('subCategory: $subCategory, ')
          ..write('district: $district, ')
          ..write('city: $city, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('buyingPrice: $buyingPrice, ')
          ..write('sellingQuotedPrice: $sellingQuotedPrice, ')
          ..write('unit: $unit, ')
          ..write('marketMin: $marketMin, ')
          ..write('marketMax: $marketMax, ')
          ..write('recyclerId: $recyclerId, ')
          ..write('source: $source, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      category,
      subCategory,
      district,
      city,
      latitude,
      longitude,
      recordedAt,
      buyingPrice,
      sellingQuotedPrice,
      unit,
      marketMin,
      marketMax,
      recyclerId,
      source,
      createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedPrice &&
          other.id == this.id &&
          other.category == this.category &&
          other.subCategory == this.subCategory &&
          other.district == this.district &&
          other.city == this.city &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.recordedAt == this.recordedAt &&
          other.buyingPrice == this.buyingPrice &&
          other.sellingQuotedPrice == this.sellingQuotedPrice &&
          other.unit == this.unit &&
          other.marketMin == this.marketMin &&
          other.marketMax == this.marketMax &&
          other.recyclerId == this.recyclerId &&
          other.source == this.source &&
          other.createdAt == this.createdAt);
}

class CachedPricesCompanion extends UpdateCompanion<CachedPrice> {
  final Value<String> id;
  final Value<String> category;
  final Value<String?> subCategory;
  final Value<String> district;
  final Value<String?> city;
  final Value<double> latitude;
  final Value<double> longitude;
  final Value<DateTime> recordedAt;
  final Value<double> buyingPrice;
  final Value<double> sellingQuotedPrice;
  final Value<String> unit;
  final Value<double> marketMin;
  final Value<double> marketMax;
  final Value<String?> recyclerId;
  final Value<String> source;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const CachedPricesCompanion({
    this.id = const Value.absent(),
    this.category = const Value.absent(),
    this.subCategory = const Value.absent(),
    this.district = const Value.absent(),
    this.city = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.recordedAt = const Value.absent(),
    this.buyingPrice = const Value.absent(),
    this.sellingQuotedPrice = const Value.absent(),
    this.unit = const Value.absent(),
    this.marketMin = const Value.absent(),
    this.marketMax = const Value.absent(),
    this.recyclerId = const Value.absent(),
    this.source = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedPricesCompanion.insert({
    required String id,
    required String category,
    this.subCategory = const Value.absent(),
    required String district,
    this.city = const Value.absent(),
    required double latitude,
    required double longitude,
    required DateTime recordedAt,
    required double buyingPrice,
    required double sellingQuotedPrice,
    this.unit = const Value.absent(),
    required double marketMin,
    required double marketMax,
    this.recyclerId = const Value.absent(),
    this.source = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        category = Value(category),
        district = Value(district),
        latitude = Value(latitude),
        longitude = Value(longitude),
        recordedAt = Value(recordedAt),
        buyingPrice = Value(buyingPrice),
        sellingQuotedPrice = Value(sellingQuotedPrice),
        marketMin = Value(marketMin),
        marketMax = Value(marketMax),
        createdAt = Value(createdAt);
  static Insertable<CachedPrice> custom({
    Expression<String>? id,
    Expression<String>? category,
    Expression<String>? subCategory,
    Expression<String>? district,
    Expression<String>? city,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<DateTime>? recordedAt,
    Expression<double>? buyingPrice,
    Expression<double>? sellingQuotedPrice,
    Expression<String>? unit,
    Expression<double>? marketMin,
    Expression<double>? marketMax,
    Expression<String>? recyclerId,
    Expression<String>? source,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (category != null) 'category': category,
      if (subCategory != null) 'sub_category': subCategory,
      if (district != null) 'district': district,
      if (city != null) 'city': city,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (recordedAt != null) 'recorded_at': recordedAt,
      if (buyingPrice != null) 'buying_price': buyingPrice,
      if (sellingQuotedPrice != null)
        'selling_quoted_price': sellingQuotedPrice,
      if (unit != null) 'unit': unit,
      if (marketMin != null) 'market_min': marketMin,
      if (marketMax != null) 'market_max': marketMax,
      if (recyclerId != null) 'recycler_id': recyclerId,
      if (source != null) 'source': source,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedPricesCompanion copyWith(
      {Value<String>? id,
      Value<String>? category,
      Value<String?>? subCategory,
      Value<String>? district,
      Value<String?>? city,
      Value<double>? latitude,
      Value<double>? longitude,
      Value<DateTime>? recordedAt,
      Value<double>? buyingPrice,
      Value<double>? sellingQuotedPrice,
      Value<String>? unit,
      Value<double>? marketMin,
      Value<double>? marketMax,
      Value<String?>? recyclerId,
      Value<String>? source,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return CachedPricesCompanion(
      id: id ?? this.id,
      category: category ?? this.category,
      subCategory: subCategory ?? this.subCategory,
      district: district ?? this.district,
      city: city ?? this.city,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      recordedAt: recordedAt ?? this.recordedAt,
      buyingPrice: buyingPrice ?? this.buyingPrice,
      sellingQuotedPrice: sellingQuotedPrice ?? this.sellingQuotedPrice,
      unit: unit ?? this.unit,
      marketMin: marketMin ?? this.marketMin,
      marketMax: marketMax ?? this.marketMax,
      recyclerId: recyclerId ?? this.recyclerId,
      source: source ?? this.source,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (subCategory.present) {
      map['sub_category'] = Variable<String>(subCategory.value);
    }
    if (district.present) {
      map['district'] = Variable<String>(district.value);
    }
    if (city.present) {
      map['city'] = Variable<String>(city.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (recordedAt.present) {
      map['recorded_at'] = Variable<DateTime>(recordedAt.value);
    }
    if (buyingPrice.present) {
      map['buying_price'] = Variable<double>(buyingPrice.value);
    }
    if (sellingQuotedPrice.present) {
      map['selling_quoted_price'] = Variable<double>(sellingQuotedPrice.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (marketMin.present) {
      map['market_min'] = Variable<double>(marketMin.value);
    }
    if (marketMax.present) {
      map['market_max'] = Variable<double>(marketMax.value);
    }
    if (recyclerId.present) {
      map['recycler_id'] = Variable<String>(recyclerId.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedPricesCompanion(')
          ..write('id: $id, ')
          ..write('category: $category, ')
          ..write('subCategory: $subCategory, ')
          ..write('district: $district, ')
          ..write('city: $city, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('buyingPrice: $buyingPrice, ')
          ..write('sellingQuotedPrice: $sellingQuotedPrice, ')
          ..write('unit: $unit, ')
          ..write('marketMin: $marketMin, ')
          ..write('marketMax: $marketMax, ')
          ..write('recyclerId: $recyclerId, ')
          ..write('source: $source, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedRecyclersTable extends CachedRecyclers
    with TableInfo<$CachedRecyclersTable, CachedRecycler> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedRecyclersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _latitudeMeta =
      const VerificationMeta('latitude');
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
      'latitude', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _longitudeMeta =
      const VerificationMeta('longitude');
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
      'longitude', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _materialsAcceptedJsonMeta =
      const VerificationMeta('materialsAcceptedJson');
  @override
  late final GeneratedColumn<String> materialsAcceptedJson =
      GeneratedColumn<String>('materials_accepted_json', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _authorizationNumberMeta =
      const VerificationMeta('authorizationNumber');
  @override
  late final GeneratedColumn<String> authorizationNumber =
      GeneratedColumn<String>('authorization_number', aliasedName, false,
          type: DriftSqlType.string,
          requiredDuringInsert: true,
          defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _authorizationBodyMeta =
      const VerificationMeta('authorizationBody');
  @override
  late final GeneratedColumn<String> authorizationBody =
      GeneratedColumn<String>('authorization_body', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _authorizationStatusMeta =
      const VerificationMeta('authorizationStatus');
  @override
  late final GeneratedColumn<String> authorizationStatus =
      GeneratedColumn<String>('authorization_status', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _authorizationValidTillMeta =
      const VerificationMeta('authorizationValidTill');
  @override
  late final GeneratedColumn<DateTime> authorizationValidTill =
      GeneratedColumn<DateTime>('authorization_valid_till', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
      'phone', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _offeredRatesJsonMeta =
      const VerificationMeta('offeredRatesJson');
  @override
  late final GeneratedColumn<String> offeredRatesJson = GeneratedColumn<String>(
      'offered_rates_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _pickupAvailableMeta =
      const VerificationMeta('pickupAvailable');
  @override
  late final GeneratedColumn<bool> pickupAvailable = GeneratedColumn<bool>(
      'pickup_available', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("pickup_available" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _pickupRadiusKmMeta =
      const VerificationMeta('pickupRadiusKm');
  @override
  late final GeneratedColumn<double> pickupRadiusKm = GeneratedColumn<double>(
      'pickup_radius_km', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _serviceAreaJsonMeta =
      const VerificationMeta('serviceAreaJson');
  @override
  late final GeneratedColumn<String> serviceAreaJson = GeneratedColumn<String>(
      'service_area_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _ratingMeta = const VerificationMeta('rating');
  @override
  late final GeneratedColumn<double> rating = GeneratedColumn<double>(
      'rating', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _cachedAtMeta =
      const VerificationMeta('cachedAt');
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
      'cached_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        latitude,
        longitude,
        materialsAcceptedJson,
        authorizationNumber,
        authorizationBody,
        authorizationStatus,
        authorizationValidTill,
        phone,
        offeredRatesJson,
        pickupAvailable,
        pickupRadiusKm,
        serviceAreaJson,
        rating,
        cachedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_recyclers';
  @override
  VerificationContext validateIntegrity(Insertable<CachedRecycler> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('latitude')) {
      context.handle(_latitudeMeta,
          latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta));
    } else if (isInserting) {
      context.missing(_latitudeMeta);
    }
    if (data.containsKey('longitude')) {
      context.handle(_longitudeMeta,
          longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta));
    } else if (isInserting) {
      context.missing(_longitudeMeta);
    }
    if (data.containsKey('materials_accepted_json')) {
      context.handle(
          _materialsAcceptedJsonMeta,
          materialsAcceptedJson.isAcceptableOrUnknown(
              data['materials_accepted_json']!, _materialsAcceptedJsonMeta));
    } else if (isInserting) {
      context.missing(_materialsAcceptedJsonMeta);
    }
    if (data.containsKey('authorization_number')) {
      context.handle(
          _authorizationNumberMeta,
          authorizationNumber.isAcceptableOrUnknown(
              data['authorization_number']!, _authorizationNumberMeta));
    } else if (isInserting) {
      context.missing(_authorizationNumberMeta);
    }
    if (data.containsKey('authorization_body')) {
      context.handle(
          _authorizationBodyMeta,
          authorizationBody.isAcceptableOrUnknown(
              data['authorization_body']!, _authorizationBodyMeta));
    } else if (isInserting) {
      context.missing(_authorizationBodyMeta);
    }
    if (data.containsKey('authorization_status')) {
      context.handle(
          _authorizationStatusMeta,
          authorizationStatus.isAcceptableOrUnknown(
              data['authorization_status']!, _authorizationStatusMeta));
    } else if (isInserting) {
      context.missing(_authorizationStatusMeta);
    }
    if (data.containsKey('authorization_valid_till')) {
      context.handle(
          _authorizationValidTillMeta,
          authorizationValidTill.isAcceptableOrUnknown(
              data['authorization_valid_till']!, _authorizationValidTillMeta));
    } else if (isInserting) {
      context.missing(_authorizationValidTillMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
          _phoneMeta, phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta));
    } else if (isInserting) {
      context.missing(_phoneMeta);
    }
    if (data.containsKey('offered_rates_json')) {
      context.handle(
          _offeredRatesJsonMeta,
          offeredRatesJson.isAcceptableOrUnknown(
              data['offered_rates_json']!, _offeredRatesJsonMeta));
    } else if (isInserting) {
      context.missing(_offeredRatesJsonMeta);
    }
    if (data.containsKey('pickup_available')) {
      context.handle(
          _pickupAvailableMeta,
          pickupAvailable.isAcceptableOrUnknown(
              data['pickup_available']!, _pickupAvailableMeta));
    }
    if (data.containsKey('pickup_radius_km')) {
      context.handle(
          _pickupRadiusKmMeta,
          pickupRadiusKm.isAcceptableOrUnknown(
              data['pickup_radius_km']!, _pickupRadiusKmMeta));
    }
    if (data.containsKey('service_area_json')) {
      context.handle(
          _serviceAreaJsonMeta,
          serviceAreaJson.isAcceptableOrUnknown(
              data['service_area_json']!, _serviceAreaJsonMeta));
    } else if (isInserting) {
      context.missing(_serviceAreaJsonMeta);
    }
    if (data.containsKey('rating')) {
      context.handle(_ratingMeta,
          rating.isAcceptableOrUnknown(data['rating']!, _ratingMeta));
    }
    if (data.containsKey('cached_at')) {
      context.handle(_cachedAtMeta,
          cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta));
    } else if (isInserting) {
      context.missing(_cachedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedRecycler map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedRecycler(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      latitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}latitude'])!,
      longitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}longitude'])!,
      materialsAcceptedJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}materials_accepted_json'])!,
      authorizationNumber: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}authorization_number'])!,
      authorizationBody: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}authorization_body'])!,
      authorizationStatus: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}authorization_status'])!,
      authorizationValidTill: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime,
          data['${effectivePrefix}authorization_valid_till'])!,
      phone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phone'])!,
      offeredRatesJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}offered_rates_json'])!,
      pickupAvailable: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}pickup_available'])!,
      pickupRadiusKm: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}pickup_radius_km'])!,
      serviceAreaJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}service_area_json'])!,
      rating: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}rating'])!,
      cachedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}cached_at'])!,
    );
  }

  @override
  $CachedRecyclersTable createAlias(String alias) {
    return $CachedRecyclersTable(attachedDatabase, alias);
  }
}

class CachedRecycler extends DataClass implements Insertable<CachedRecycler> {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String materialsAcceptedJson;
  final String authorizationNumber;
  final String authorizationBody;
  final String authorizationStatus;
  final DateTime authorizationValidTill;
  final String phone;
  final String offeredRatesJson;
  final bool pickupAvailable;
  final double pickupRadiusKm;
  final String serviceAreaJson;
  final double rating;
  final DateTime cachedAt;
  const CachedRecycler(
      {required this.id,
      required this.name,
      required this.latitude,
      required this.longitude,
      required this.materialsAcceptedJson,
      required this.authorizationNumber,
      required this.authorizationBody,
      required this.authorizationStatus,
      required this.authorizationValidTill,
      required this.phone,
      required this.offeredRatesJson,
      required this.pickupAvailable,
      required this.pickupRadiusKm,
      required this.serviceAreaJson,
      required this.rating,
      required this.cachedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['latitude'] = Variable<double>(latitude);
    map['longitude'] = Variable<double>(longitude);
    map['materials_accepted_json'] = Variable<String>(materialsAcceptedJson);
    map['authorization_number'] = Variable<String>(authorizationNumber);
    map['authorization_body'] = Variable<String>(authorizationBody);
    map['authorization_status'] = Variable<String>(authorizationStatus);
    map['authorization_valid_till'] =
        Variable<DateTime>(authorizationValidTill);
    map['phone'] = Variable<String>(phone);
    map['offered_rates_json'] = Variable<String>(offeredRatesJson);
    map['pickup_available'] = Variable<bool>(pickupAvailable);
    map['pickup_radius_km'] = Variable<double>(pickupRadiusKm);
    map['service_area_json'] = Variable<String>(serviceAreaJson);
    map['rating'] = Variable<double>(rating);
    map['cached_at'] = Variable<DateTime>(cachedAt);
    return map;
  }

  CachedRecyclersCompanion toCompanion(bool nullToAbsent) {
    return CachedRecyclersCompanion(
      id: Value(id),
      name: Value(name),
      latitude: Value(latitude),
      longitude: Value(longitude),
      materialsAcceptedJson: Value(materialsAcceptedJson),
      authorizationNumber: Value(authorizationNumber),
      authorizationBody: Value(authorizationBody),
      authorizationStatus: Value(authorizationStatus),
      authorizationValidTill: Value(authorizationValidTill),
      phone: Value(phone),
      offeredRatesJson: Value(offeredRatesJson),
      pickupAvailable: Value(pickupAvailable),
      pickupRadiusKm: Value(pickupRadiusKm),
      serviceAreaJson: Value(serviceAreaJson),
      rating: Value(rating),
      cachedAt: Value(cachedAt),
    );
  }

  factory CachedRecycler.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedRecycler(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      latitude: serializer.fromJson<double>(json['latitude']),
      longitude: serializer.fromJson<double>(json['longitude']),
      materialsAcceptedJson:
          serializer.fromJson<String>(json['materialsAcceptedJson']),
      authorizationNumber:
          serializer.fromJson<String>(json['authorizationNumber']),
      authorizationBody: serializer.fromJson<String>(json['authorizationBody']),
      authorizationStatus:
          serializer.fromJson<String>(json['authorizationStatus']),
      authorizationValidTill:
          serializer.fromJson<DateTime>(json['authorizationValidTill']),
      phone: serializer.fromJson<String>(json['phone']),
      offeredRatesJson: serializer.fromJson<String>(json['offeredRatesJson']),
      pickupAvailable: serializer.fromJson<bool>(json['pickupAvailable']),
      pickupRadiusKm: serializer.fromJson<double>(json['pickupRadiusKm']),
      serviceAreaJson: serializer.fromJson<String>(json['serviceAreaJson']),
      rating: serializer.fromJson<double>(json['rating']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'latitude': serializer.toJson<double>(latitude),
      'longitude': serializer.toJson<double>(longitude),
      'materialsAcceptedJson': serializer.toJson<String>(materialsAcceptedJson),
      'authorizationNumber': serializer.toJson<String>(authorizationNumber),
      'authorizationBody': serializer.toJson<String>(authorizationBody),
      'authorizationStatus': serializer.toJson<String>(authorizationStatus),
      'authorizationValidTill':
          serializer.toJson<DateTime>(authorizationValidTill),
      'phone': serializer.toJson<String>(phone),
      'offeredRatesJson': serializer.toJson<String>(offeredRatesJson),
      'pickupAvailable': serializer.toJson<bool>(pickupAvailable),
      'pickupRadiusKm': serializer.toJson<double>(pickupRadiusKm),
      'serviceAreaJson': serializer.toJson<String>(serviceAreaJson),
      'rating': serializer.toJson<double>(rating),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
    };
  }

  CachedRecycler copyWith(
          {String? id,
          String? name,
          double? latitude,
          double? longitude,
          String? materialsAcceptedJson,
          String? authorizationNumber,
          String? authorizationBody,
          String? authorizationStatus,
          DateTime? authorizationValidTill,
          String? phone,
          String? offeredRatesJson,
          bool? pickupAvailable,
          double? pickupRadiusKm,
          String? serviceAreaJson,
          double? rating,
          DateTime? cachedAt}) =>
      CachedRecycler(
        id: id ?? this.id,
        name: name ?? this.name,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        materialsAcceptedJson:
            materialsAcceptedJson ?? this.materialsAcceptedJson,
        authorizationNumber: authorizationNumber ?? this.authorizationNumber,
        authorizationBody: authorizationBody ?? this.authorizationBody,
        authorizationStatus: authorizationStatus ?? this.authorizationStatus,
        authorizationValidTill:
            authorizationValidTill ?? this.authorizationValidTill,
        phone: phone ?? this.phone,
        offeredRatesJson: offeredRatesJson ?? this.offeredRatesJson,
        pickupAvailable: pickupAvailable ?? this.pickupAvailable,
        pickupRadiusKm: pickupRadiusKm ?? this.pickupRadiusKm,
        serviceAreaJson: serviceAreaJson ?? this.serviceAreaJson,
        rating: rating ?? this.rating,
        cachedAt: cachedAt ?? this.cachedAt,
      );
  CachedRecycler copyWithCompanion(CachedRecyclersCompanion data) {
    return CachedRecycler(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      materialsAcceptedJson: data.materialsAcceptedJson.present
          ? data.materialsAcceptedJson.value
          : this.materialsAcceptedJson,
      authorizationNumber: data.authorizationNumber.present
          ? data.authorizationNumber.value
          : this.authorizationNumber,
      authorizationBody: data.authorizationBody.present
          ? data.authorizationBody.value
          : this.authorizationBody,
      authorizationStatus: data.authorizationStatus.present
          ? data.authorizationStatus.value
          : this.authorizationStatus,
      authorizationValidTill: data.authorizationValidTill.present
          ? data.authorizationValidTill.value
          : this.authorizationValidTill,
      phone: data.phone.present ? data.phone.value : this.phone,
      offeredRatesJson: data.offeredRatesJson.present
          ? data.offeredRatesJson.value
          : this.offeredRatesJson,
      pickupAvailable: data.pickupAvailable.present
          ? data.pickupAvailable.value
          : this.pickupAvailable,
      pickupRadiusKm: data.pickupRadiusKm.present
          ? data.pickupRadiusKm.value
          : this.pickupRadiusKm,
      serviceAreaJson: data.serviceAreaJson.present
          ? data.serviceAreaJson.value
          : this.serviceAreaJson,
      rating: data.rating.present ? data.rating.value : this.rating,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedRecycler(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('materialsAcceptedJson: $materialsAcceptedJson, ')
          ..write('authorizationNumber: $authorizationNumber, ')
          ..write('authorizationBody: $authorizationBody, ')
          ..write('authorizationStatus: $authorizationStatus, ')
          ..write('authorizationValidTill: $authorizationValidTill, ')
          ..write('phone: $phone, ')
          ..write('offeredRatesJson: $offeredRatesJson, ')
          ..write('pickupAvailable: $pickupAvailable, ')
          ..write('pickupRadiusKm: $pickupRadiusKm, ')
          ..write('serviceAreaJson: $serviceAreaJson, ')
          ..write('rating: $rating, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      name,
      latitude,
      longitude,
      materialsAcceptedJson,
      authorizationNumber,
      authorizationBody,
      authorizationStatus,
      authorizationValidTill,
      phone,
      offeredRatesJson,
      pickupAvailable,
      pickupRadiusKm,
      serviceAreaJson,
      rating,
      cachedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedRecycler &&
          other.id == this.id &&
          other.name == this.name &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.materialsAcceptedJson == this.materialsAcceptedJson &&
          other.authorizationNumber == this.authorizationNumber &&
          other.authorizationBody == this.authorizationBody &&
          other.authorizationStatus == this.authorizationStatus &&
          other.authorizationValidTill == this.authorizationValidTill &&
          other.phone == this.phone &&
          other.offeredRatesJson == this.offeredRatesJson &&
          other.pickupAvailable == this.pickupAvailable &&
          other.pickupRadiusKm == this.pickupRadiusKm &&
          other.serviceAreaJson == this.serviceAreaJson &&
          other.rating == this.rating &&
          other.cachedAt == this.cachedAt);
}

class CachedRecyclersCompanion extends UpdateCompanion<CachedRecycler> {
  final Value<String> id;
  final Value<String> name;
  final Value<double> latitude;
  final Value<double> longitude;
  final Value<String> materialsAcceptedJson;
  final Value<String> authorizationNumber;
  final Value<String> authorizationBody;
  final Value<String> authorizationStatus;
  final Value<DateTime> authorizationValidTill;
  final Value<String> phone;
  final Value<String> offeredRatesJson;
  final Value<bool> pickupAvailable;
  final Value<double> pickupRadiusKm;
  final Value<String> serviceAreaJson;
  final Value<double> rating;
  final Value<DateTime> cachedAt;
  final Value<int> rowid;
  const CachedRecyclersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.materialsAcceptedJson = const Value.absent(),
    this.authorizationNumber = const Value.absent(),
    this.authorizationBody = const Value.absent(),
    this.authorizationStatus = const Value.absent(),
    this.authorizationValidTill = const Value.absent(),
    this.phone = const Value.absent(),
    this.offeredRatesJson = const Value.absent(),
    this.pickupAvailable = const Value.absent(),
    this.pickupRadiusKm = const Value.absent(),
    this.serviceAreaJson = const Value.absent(),
    this.rating = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedRecyclersCompanion.insert({
    required String id,
    required String name,
    required double latitude,
    required double longitude,
    required String materialsAcceptedJson,
    required String authorizationNumber,
    required String authorizationBody,
    required String authorizationStatus,
    required DateTime authorizationValidTill,
    required String phone,
    required String offeredRatesJson,
    this.pickupAvailable = const Value.absent(),
    this.pickupRadiusKm = const Value.absent(),
    required String serviceAreaJson,
    this.rating = const Value.absent(),
    required DateTime cachedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        latitude = Value(latitude),
        longitude = Value(longitude),
        materialsAcceptedJson = Value(materialsAcceptedJson),
        authorizationNumber = Value(authorizationNumber),
        authorizationBody = Value(authorizationBody),
        authorizationStatus = Value(authorizationStatus),
        authorizationValidTill = Value(authorizationValidTill),
        phone = Value(phone),
        offeredRatesJson = Value(offeredRatesJson),
        serviceAreaJson = Value(serviceAreaJson),
        cachedAt = Value(cachedAt);
  static Insertable<CachedRecycler> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<String>? materialsAcceptedJson,
    Expression<String>? authorizationNumber,
    Expression<String>? authorizationBody,
    Expression<String>? authorizationStatus,
    Expression<DateTime>? authorizationValidTill,
    Expression<String>? phone,
    Expression<String>? offeredRatesJson,
    Expression<bool>? pickupAvailable,
    Expression<double>? pickupRadiusKm,
    Expression<String>? serviceAreaJson,
    Expression<double>? rating,
    Expression<DateTime>? cachedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (materialsAcceptedJson != null)
        'materials_accepted_json': materialsAcceptedJson,
      if (authorizationNumber != null)
        'authorization_number': authorizationNumber,
      if (authorizationBody != null) 'authorization_body': authorizationBody,
      if (authorizationStatus != null)
        'authorization_status': authorizationStatus,
      if (authorizationValidTill != null)
        'authorization_valid_till': authorizationValidTill,
      if (phone != null) 'phone': phone,
      if (offeredRatesJson != null) 'offered_rates_json': offeredRatesJson,
      if (pickupAvailable != null) 'pickup_available': pickupAvailable,
      if (pickupRadiusKm != null) 'pickup_radius_km': pickupRadiusKm,
      if (serviceAreaJson != null) 'service_area_json': serviceAreaJson,
      if (rating != null) 'rating': rating,
      if (cachedAt != null) 'cached_at': cachedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedRecyclersCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<double>? latitude,
      Value<double>? longitude,
      Value<String>? materialsAcceptedJson,
      Value<String>? authorizationNumber,
      Value<String>? authorizationBody,
      Value<String>? authorizationStatus,
      Value<DateTime>? authorizationValidTill,
      Value<String>? phone,
      Value<String>? offeredRatesJson,
      Value<bool>? pickupAvailable,
      Value<double>? pickupRadiusKm,
      Value<String>? serviceAreaJson,
      Value<double>? rating,
      Value<DateTime>? cachedAt,
      Value<int>? rowid}) {
    return CachedRecyclersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      materialsAcceptedJson:
          materialsAcceptedJson ?? this.materialsAcceptedJson,
      authorizationNumber: authorizationNumber ?? this.authorizationNumber,
      authorizationBody: authorizationBody ?? this.authorizationBody,
      authorizationStatus: authorizationStatus ?? this.authorizationStatus,
      authorizationValidTill:
          authorizationValidTill ?? this.authorizationValidTill,
      phone: phone ?? this.phone,
      offeredRatesJson: offeredRatesJson ?? this.offeredRatesJson,
      pickupAvailable: pickupAvailable ?? this.pickupAvailable,
      pickupRadiusKm: pickupRadiusKm ?? this.pickupRadiusKm,
      serviceAreaJson: serviceAreaJson ?? this.serviceAreaJson,
      rating: rating ?? this.rating,
      cachedAt: cachedAt ?? this.cachedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (materialsAcceptedJson.present) {
      map['materials_accepted_json'] =
          Variable<String>(materialsAcceptedJson.value);
    }
    if (authorizationNumber.present) {
      map['authorization_number'] = Variable<String>(authorizationNumber.value);
    }
    if (authorizationBody.present) {
      map['authorization_body'] = Variable<String>(authorizationBody.value);
    }
    if (authorizationStatus.present) {
      map['authorization_status'] = Variable<String>(authorizationStatus.value);
    }
    if (authorizationValidTill.present) {
      map['authorization_valid_till'] =
          Variable<DateTime>(authorizationValidTill.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (offeredRatesJson.present) {
      map['offered_rates_json'] = Variable<String>(offeredRatesJson.value);
    }
    if (pickupAvailable.present) {
      map['pickup_available'] = Variable<bool>(pickupAvailable.value);
    }
    if (pickupRadiusKm.present) {
      map['pickup_radius_km'] = Variable<double>(pickupRadiusKm.value);
    }
    if (serviceAreaJson.present) {
      map['service_area_json'] = Variable<String>(serviceAreaJson.value);
    }
    if (rating.present) {
      map['rating'] = Variable<double>(rating.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedRecyclersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('materialsAcceptedJson: $materialsAcceptedJson, ')
          ..write('authorizationNumber: $authorizationNumber, ')
          ..write('authorizationBody: $authorizationBody, ')
          ..write('authorizationStatus: $authorizationStatus, ')
          ..write('authorizationValidTill: $authorizationValidTill, ')
          ..write('phone: $phone, ')
          ..write('offeredRatesJson: $offeredRatesJson, ')
          ..write('pickupAvailable: $pickupAvailable, ')
          ..write('pickupRadiusKm: $pickupRadiusKm, ')
          ..write('serviceAreaJson: $serviceAreaJson, ')
          ..write('rating: $rating, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalTransactionsTable extends LocalTransactions
    with TableInfo<$LocalTransactionsTable, LocalTransaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalTransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _lotIdMeta = const VerificationMeta('lotId');
  @override
  late final GeneratedColumn<String> lotId = GeneratedColumn<String>(
      'lot_id', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 5, maxTextLength: 40),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _clientLotUuidMeta =
      const VerificationMeta('clientLotUuid');
  @override
  late final GeneratedColumn<String> clientLotUuid = GeneratedColumn<String>(
      'client_lot_uuid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _collectorIdMeta =
      const VerificationMeta('collectorId');
  @override
  late final GeneratedColumn<String> collectorId = GeneratedColumn<String>(
      'collector_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _weightKgMeta =
      const VerificationMeta('weightKg');
  @override
  late final GeneratedColumn<double> weightKg = GeneratedColumn<double>(
      'weight_kg', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _quotedPriceMeta =
      const VerificationMeta('quotedPrice');
  @override
  late final GeneratedColumn<double> quotedPrice = GeneratedColumn<double>(
      'quoted_price', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _finalPriceMeta =
      const VerificationMeta('finalPrice');
  @override
  late final GeneratedColumn<double> finalPrice = GeneratedColumn<double>(
      'final_price', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _recyclerIdMeta =
      const VerificationMeta('recyclerId');
  @override
  late final GeneratedColumn<String> recyclerId = GeneratedColumn<String>(
      'recycler_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _collectionLatMeta =
      const VerificationMeta('collectionLat');
  @override
  late final GeneratedColumn<double> collectionLat = GeneratedColumn<double>(
      'collection_lat', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _collectionLngMeta =
      const VerificationMeta('collectionLng');
  @override
  late final GeneratedColumn<double> collectionLng = GeneratedColumn<double>(
      'collection_lng', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _handoverLatMeta =
      const VerificationMeta('handoverLat');
  @override
  late final GeneratedColumn<double> handoverLat = GeneratedColumn<double>(
      'handover_lat', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _handoverLngMeta =
      const VerificationMeta('handoverLng');
  @override
  late final GeneratedColumn<double> handoverLng = GeneratedColumn<double>(
      'handover_lng', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _handoverAtMeta =
      const VerificationMeta('handoverAt');
  @override
  late final GeneratedColumn<DateTime> handoverAt = GeneratedColumn<DateTime>(
      'handover_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _paymentStatusMeta =
      const VerificationMeta('paymentStatus');
  @override
  late final GeneratedColumn<String> paymentStatus = GeneratedColumn<String>(
      'payment_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _transactionStatusMeta =
      const VerificationMeta('transactionStatus');
  @override
  late final GeneratedColumn<String> transactionStatus =
      GeneratedColumn<String>('transaction_status', aliasedName, false,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          defaultValue: const Constant('draft'));
  static const VerificationMeta _anomalyFlagMeta =
      const VerificationMeta('anomalyFlag');
  @override
  late final GeneratedColumn<bool> anomalyFlag = GeneratedColumn<bool>(
      'anomaly_flag', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("anomaly_flag" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _anomalyReasonMeta =
      const VerificationMeta('anomalyReason');
  @override
  late final GeneratedColumn<String> anomalyReason = GeneratedColumn<String>(
      'anomaly_reason', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isSyncedMeta =
      const VerificationMeta('isSynced');
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
      'is_synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_synced" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _syncedAtMeta =
      const VerificationMeta('syncedAt');
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
      'synced_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        lotId,
        clientLotUuid,
        collectorId,
        category,
        weightKg,
        quotedPrice,
        finalPrice,
        recyclerId,
        collectionLat,
        collectionLng,
        handoverLat,
        handoverLng,
        createdAt,
        handoverAt,
        paymentStatus,
        transactionStatus,
        anomalyFlag,
        anomalyReason,
        isSynced,
        syncedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_transactions';
  @override
  VerificationContext validateIntegrity(Insertable<LocalTransaction> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('lot_id')) {
      context.handle(
          _lotIdMeta, lotId.isAcceptableOrUnknown(data['lot_id']!, _lotIdMeta));
    } else if (isInserting) {
      context.missing(_lotIdMeta);
    }
    if (data.containsKey('client_lot_uuid')) {
      context.handle(
          _clientLotUuidMeta,
          clientLotUuid.isAcceptableOrUnknown(
              data['client_lot_uuid']!, _clientLotUuidMeta));
    } else if (isInserting) {
      context.missing(_clientLotUuidMeta);
    }
    if (data.containsKey('collector_id')) {
      context.handle(
          _collectorIdMeta,
          collectorId.isAcceptableOrUnknown(
              data['collector_id']!, _collectorIdMeta));
    } else if (isInserting) {
      context.missing(_collectorIdMeta);
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('weight_kg')) {
      context.handle(_weightKgMeta,
          weightKg.isAcceptableOrUnknown(data['weight_kg']!, _weightKgMeta));
    } else if (isInserting) {
      context.missing(_weightKgMeta);
    }
    if (data.containsKey('quoted_price')) {
      context.handle(
          _quotedPriceMeta,
          quotedPrice.isAcceptableOrUnknown(
              data['quoted_price']!, _quotedPriceMeta));
    } else if (isInserting) {
      context.missing(_quotedPriceMeta);
    }
    if (data.containsKey('final_price')) {
      context.handle(
          _finalPriceMeta,
          finalPrice.isAcceptableOrUnknown(
              data['final_price']!, _finalPriceMeta));
    }
    if (data.containsKey('recycler_id')) {
      context.handle(
          _recyclerIdMeta,
          recyclerId.isAcceptableOrUnknown(
              data['recycler_id']!, _recyclerIdMeta));
    }
    if (data.containsKey('collection_lat')) {
      context.handle(
          _collectionLatMeta,
          collectionLat.isAcceptableOrUnknown(
              data['collection_lat']!, _collectionLatMeta));
    } else if (isInserting) {
      context.missing(_collectionLatMeta);
    }
    if (data.containsKey('collection_lng')) {
      context.handle(
          _collectionLngMeta,
          collectionLng.isAcceptableOrUnknown(
              data['collection_lng']!, _collectionLngMeta));
    } else if (isInserting) {
      context.missing(_collectionLngMeta);
    }
    if (data.containsKey('handover_lat')) {
      context.handle(
          _handoverLatMeta,
          handoverLat.isAcceptableOrUnknown(
              data['handover_lat']!, _handoverLatMeta));
    }
    if (data.containsKey('handover_lng')) {
      context.handle(
          _handoverLngMeta,
          handoverLng.isAcceptableOrUnknown(
              data['handover_lng']!, _handoverLngMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('handover_at')) {
      context.handle(
          _handoverAtMeta,
          handoverAt.isAcceptableOrUnknown(
              data['handover_at']!, _handoverAtMeta));
    }
    if (data.containsKey('payment_status')) {
      context.handle(
          _paymentStatusMeta,
          paymentStatus.isAcceptableOrUnknown(
              data['payment_status']!, _paymentStatusMeta));
    }
    if (data.containsKey('transaction_status')) {
      context.handle(
          _transactionStatusMeta,
          transactionStatus.isAcceptableOrUnknown(
              data['transaction_status']!, _transactionStatusMeta));
    }
    if (data.containsKey('anomaly_flag')) {
      context.handle(
          _anomalyFlagMeta,
          anomalyFlag.isAcceptableOrUnknown(
              data['anomaly_flag']!, _anomalyFlagMeta));
    }
    if (data.containsKey('anomaly_reason')) {
      context.handle(
          _anomalyReasonMeta,
          anomalyReason.isAcceptableOrUnknown(
              data['anomaly_reason']!, _anomalyReasonMeta));
    }
    if (data.containsKey('is_synced')) {
      context.handle(_isSyncedMeta,
          isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta));
    }
    if (data.containsKey('synced_at')) {
      context.handle(_syncedAtMeta,
          syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {lotId};
  @override
  LocalTransaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalTransaction(
      lotId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}lot_id'])!,
      clientLotUuid: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}client_lot_uuid'])!,
      collectorId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}collector_id'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      weightKg: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}weight_kg'])!,
      quotedPrice: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}quoted_price'])!,
      finalPrice: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}final_price']),
      recyclerId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}recycler_id']),
      collectionLat: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}collection_lat'])!,
      collectionLng: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}collection_lng'])!,
      handoverLat: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}handover_lat']),
      handoverLng: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}handover_lng']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      handoverAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}handover_at']),
      paymentStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payment_status'])!,
      transactionStatus: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}transaction_status'])!,
      anomalyFlag: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}anomaly_flag'])!,
      anomalyReason: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}anomaly_reason']),
      isSynced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_synced'])!,
      syncedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}synced_at']),
    );
  }

  @override
  $LocalTransactionsTable createAlias(String alias) {
    return $LocalTransactionsTable(attachedDatabase, alias);
  }
}

class LocalTransaction extends DataClass
    implements Insertable<LocalTransaction> {
  final String lotId;
  final String clientLotUuid;
  final String collectorId;
  final String category;
  final double weightKg;
  final double quotedPrice;
  final double? finalPrice;
  final String? recyclerId;
  final double collectionLat;
  final double collectionLng;
  final double? handoverLat;
  final double? handoverLng;
  final DateTime createdAt;
  final DateTime? handoverAt;
  final String paymentStatus;
  final String transactionStatus;
  final bool anomalyFlag;
  final String? anomalyReason;
  final bool isSynced;
  final DateTime? syncedAt;
  const LocalTransaction(
      {required this.lotId,
      required this.clientLotUuid,
      required this.collectorId,
      required this.category,
      required this.weightKg,
      required this.quotedPrice,
      this.finalPrice,
      this.recyclerId,
      required this.collectionLat,
      required this.collectionLng,
      this.handoverLat,
      this.handoverLng,
      required this.createdAt,
      this.handoverAt,
      required this.paymentStatus,
      required this.transactionStatus,
      required this.anomalyFlag,
      this.anomalyReason,
      required this.isSynced,
      this.syncedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['lot_id'] = Variable<String>(lotId);
    map['client_lot_uuid'] = Variable<String>(clientLotUuid);
    map['collector_id'] = Variable<String>(collectorId);
    map['category'] = Variable<String>(category);
    map['weight_kg'] = Variable<double>(weightKg);
    map['quoted_price'] = Variable<double>(quotedPrice);
    if (!nullToAbsent || finalPrice != null) {
      map['final_price'] = Variable<double>(finalPrice);
    }
    if (!nullToAbsent || recyclerId != null) {
      map['recycler_id'] = Variable<String>(recyclerId);
    }
    map['collection_lat'] = Variable<double>(collectionLat);
    map['collection_lng'] = Variable<double>(collectionLng);
    if (!nullToAbsent || handoverLat != null) {
      map['handover_lat'] = Variable<double>(handoverLat);
    }
    if (!nullToAbsent || handoverLng != null) {
      map['handover_lng'] = Variable<double>(handoverLng);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || handoverAt != null) {
      map['handover_at'] = Variable<DateTime>(handoverAt);
    }
    map['payment_status'] = Variable<String>(paymentStatus);
    map['transaction_status'] = Variable<String>(transactionStatus);
    map['anomaly_flag'] = Variable<bool>(anomalyFlag);
    if (!nullToAbsent || anomalyReason != null) {
      map['anomaly_reason'] = Variable<String>(anomalyReason);
    }
    map['is_synced'] = Variable<bool>(isSynced);
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<DateTime>(syncedAt);
    }
    return map;
  }

  LocalTransactionsCompanion toCompanion(bool nullToAbsent) {
    return LocalTransactionsCompanion(
      lotId: Value(lotId),
      clientLotUuid: Value(clientLotUuid),
      collectorId: Value(collectorId),
      category: Value(category),
      weightKg: Value(weightKg),
      quotedPrice: Value(quotedPrice),
      finalPrice: finalPrice == null && nullToAbsent
          ? const Value.absent()
          : Value(finalPrice),
      recyclerId: recyclerId == null && nullToAbsent
          ? const Value.absent()
          : Value(recyclerId),
      collectionLat: Value(collectionLat),
      collectionLng: Value(collectionLng),
      handoverLat: handoverLat == null && nullToAbsent
          ? const Value.absent()
          : Value(handoverLat),
      handoverLng: handoverLng == null && nullToAbsent
          ? const Value.absent()
          : Value(handoverLng),
      createdAt: Value(createdAt),
      handoverAt: handoverAt == null && nullToAbsent
          ? const Value.absent()
          : Value(handoverAt),
      paymentStatus: Value(paymentStatus),
      transactionStatus: Value(transactionStatus),
      anomalyFlag: Value(anomalyFlag),
      anomalyReason: anomalyReason == null && nullToAbsent
          ? const Value.absent()
          : Value(anomalyReason),
      isSynced: Value(isSynced),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
    );
  }

  factory LocalTransaction.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalTransaction(
      lotId: serializer.fromJson<String>(json['lotId']),
      clientLotUuid: serializer.fromJson<String>(json['clientLotUuid']),
      collectorId: serializer.fromJson<String>(json['collectorId']),
      category: serializer.fromJson<String>(json['category']),
      weightKg: serializer.fromJson<double>(json['weightKg']),
      quotedPrice: serializer.fromJson<double>(json['quotedPrice']),
      finalPrice: serializer.fromJson<double?>(json['finalPrice']),
      recyclerId: serializer.fromJson<String?>(json['recyclerId']),
      collectionLat: serializer.fromJson<double>(json['collectionLat']),
      collectionLng: serializer.fromJson<double>(json['collectionLng']),
      handoverLat: serializer.fromJson<double?>(json['handoverLat']),
      handoverLng: serializer.fromJson<double?>(json['handoverLng']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      handoverAt: serializer.fromJson<DateTime?>(json['handoverAt']),
      paymentStatus: serializer.fromJson<String>(json['paymentStatus']),
      transactionStatus: serializer.fromJson<String>(json['transactionStatus']),
      anomalyFlag: serializer.fromJson<bool>(json['anomalyFlag']),
      anomalyReason: serializer.fromJson<String?>(json['anomalyReason']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      syncedAt: serializer.fromJson<DateTime?>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'lotId': serializer.toJson<String>(lotId),
      'clientLotUuid': serializer.toJson<String>(clientLotUuid),
      'collectorId': serializer.toJson<String>(collectorId),
      'category': serializer.toJson<String>(category),
      'weightKg': serializer.toJson<double>(weightKg),
      'quotedPrice': serializer.toJson<double>(quotedPrice),
      'finalPrice': serializer.toJson<double?>(finalPrice),
      'recyclerId': serializer.toJson<String?>(recyclerId),
      'collectionLat': serializer.toJson<double>(collectionLat),
      'collectionLng': serializer.toJson<double>(collectionLng),
      'handoverLat': serializer.toJson<double?>(handoverLat),
      'handoverLng': serializer.toJson<double?>(handoverLng),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'handoverAt': serializer.toJson<DateTime?>(handoverAt),
      'paymentStatus': serializer.toJson<String>(paymentStatus),
      'transactionStatus': serializer.toJson<String>(transactionStatus),
      'anomalyFlag': serializer.toJson<bool>(anomalyFlag),
      'anomalyReason': serializer.toJson<String?>(anomalyReason),
      'isSynced': serializer.toJson<bool>(isSynced),
      'syncedAt': serializer.toJson<DateTime?>(syncedAt),
    };
  }

  LocalTransaction copyWith(
          {String? lotId,
          String? clientLotUuid,
          String? collectorId,
          String? category,
          double? weightKg,
          double? quotedPrice,
          Value<double?> finalPrice = const Value.absent(),
          Value<String?> recyclerId = const Value.absent(),
          double? collectionLat,
          double? collectionLng,
          Value<double?> handoverLat = const Value.absent(),
          Value<double?> handoverLng = const Value.absent(),
          DateTime? createdAt,
          Value<DateTime?> handoverAt = const Value.absent(),
          String? paymentStatus,
          String? transactionStatus,
          bool? anomalyFlag,
          Value<String?> anomalyReason = const Value.absent(),
          bool? isSynced,
          Value<DateTime?> syncedAt = const Value.absent()}) =>
      LocalTransaction(
        lotId: lotId ?? this.lotId,
        clientLotUuid: clientLotUuid ?? this.clientLotUuid,
        collectorId: collectorId ?? this.collectorId,
        category: category ?? this.category,
        weightKg: weightKg ?? this.weightKg,
        quotedPrice: quotedPrice ?? this.quotedPrice,
        finalPrice: finalPrice.present ? finalPrice.value : this.finalPrice,
        recyclerId: recyclerId.present ? recyclerId.value : this.recyclerId,
        collectionLat: collectionLat ?? this.collectionLat,
        collectionLng: collectionLng ?? this.collectionLng,
        handoverLat: handoverLat.present ? handoverLat.value : this.handoverLat,
        handoverLng: handoverLng.present ? handoverLng.value : this.handoverLng,
        createdAt: createdAt ?? this.createdAt,
        handoverAt: handoverAt.present ? handoverAt.value : this.handoverAt,
        paymentStatus: paymentStatus ?? this.paymentStatus,
        transactionStatus: transactionStatus ?? this.transactionStatus,
        anomalyFlag: anomalyFlag ?? this.anomalyFlag,
        anomalyReason:
            anomalyReason.present ? anomalyReason.value : this.anomalyReason,
        isSynced: isSynced ?? this.isSynced,
        syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
      );
  LocalTransaction copyWithCompanion(LocalTransactionsCompanion data) {
    return LocalTransaction(
      lotId: data.lotId.present ? data.lotId.value : this.lotId,
      clientLotUuid: data.clientLotUuid.present
          ? data.clientLotUuid.value
          : this.clientLotUuid,
      collectorId:
          data.collectorId.present ? data.collectorId.value : this.collectorId,
      category: data.category.present ? data.category.value : this.category,
      weightKg: data.weightKg.present ? data.weightKg.value : this.weightKg,
      quotedPrice:
          data.quotedPrice.present ? data.quotedPrice.value : this.quotedPrice,
      finalPrice:
          data.finalPrice.present ? data.finalPrice.value : this.finalPrice,
      recyclerId:
          data.recyclerId.present ? data.recyclerId.value : this.recyclerId,
      collectionLat: data.collectionLat.present
          ? data.collectionLat.value
          : this.collectionLat,
      collectionLng: data.collectionLng.present
          ? data.collectionLng.value
          : this.collectionLng,
      handoverLat:
          data.handoverLat.present ? data.handoverLat.value : this.handoverLat,
      handoverLng:
          data.handoverLng.present ? data.handoverLng.value : this.handoverLng,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      handoverAt:
          data.handoverAt.present ? data.handoverAt.value : this.handoverAt,
      paymentStatus: data.paymentStatus.present
          ? data.paymentStatus.value
          : this.paymentStatus,
      transactionStatus: data.transactionStatus.present
          ? data.transactionStatus.value
          : this.transactionStatus,
      anomalyFlag:
          data.anomalyFlag.present ? data.anomalyFlag.value : this.anomalyFlag,
      anomalyReason: data.anomalyReason.present
          ? data.anomalyReason.value
          : this.anomalyReason,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalTransaction(')
          ..write('lotId: $lotId, ')
          ..write('clientLotUuid: $clientLotUuid, ')
          ..write('collectorId: $collectorId, ')
          ..write('category: $category, ')
          ..write('weightKg: $weightKg, ')
          ..write('quotedPrice: $quotedPrice, ')
          ..write('finalPrice: $finalPrice, ')
          ..write('recyclerId: $recyclerId, ')
          ..write('collectionLat: $collectionLat, ')
          ..write('collectionLng: $collectionLng, ')
          ..write('handoverLat: $handoverLat, ')
          ..write('handoverLng: $handoverLng, ')
          ..write('createdAt: $createdAt, ')
          ..write('handoverAt: $handoverAt, ')
          ..write('paymentStatus: $paymentStatus, ')
          ..write('transactionStatus: $transactionStatus, ')
          ..write('anomalyFlag: $anomalyFlag, ')
          ..write('anomalyReason: $anomalyReason, ')
          ..write('isSynced: $isSynced, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      lotId,
      clientLotUuid,
      collectorId,
      category,
      weightKg,
      quotedPrice,
      finalPrice,
      recyclerId,
      collectionLat,
      collectionLng,
      handoverLat,
      handoverLng,
      createdAt,
      handoverAt,
      paymentStatus,
      transactionStatus,
      anomalyFlag,
      anomalyReason,
      isSynced,
      syncedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalTransaction &&
          other.lotId == this.lotId &&
          other.clientLotUuid == this.clientLotUuid &&
          other.collectorId == this.collectorId &&
          other.category == this.category &&
          other.weightKg == this.weightKg &&
          other.quotedPrice == this.quotedPrice &&
          other.finalPrice == this.finalPrice &&
          other.recyclerId == this.recyclerId &&
          other.collectionLat == this.collectionLat &&
          other.collectionLng == this.collectionLng &&
          other.handoverLat == this.handoverLat &&
          other.handoverLng == this.handoverLng &&
          other.createdAt == this.createdAt &&
          other.handoverAt == this.handoverAt &&
          other.paymentStatus == this.paymentStatus &&
          other.transactionStatus == this.transactionStatus &&
          other.anomalyFlag == this.anomalyFlag &&
          other.anomalyReason == this.anomalyReason &&
          other.isSynced == this.isSynced &&
          other.syncedAt == this.syncedAt);
}

class LocalTransactionsCompanion extends UpdateCompanion<LocalTransaction> {
  final Value<String> lotId;
  final Value<String> clientLotUuid;
  final Value<String> collectorId;
  final Value<String> category;
  final Value<double> weightKg;
  final Value<double> quotedPrice;
  final Value<double?> finalPrice;
  final Value<String?> recyclerId;
  final Value<double> collectionLat;
  final Value<double> collectionLng;
  final Value<double?> handoverLat;
  final Value<double?> handoverLng;
  final Value<DateTime> createdAt;
  final Value<DateTime?> handoverAt;
  final Value<String> paymentStatus;
  final Value<String> transactionStatus;
  final Value<bool> anomalyFlag;
  final Value<String?> anomalyReason;
  final Value<bool> isSynced;
  final Value<DateTime?> syncedAt;
  final Value<int> rowid;
  const LocalTransactionsCompanion({
    this.lotId = const Value.absent(),
    this.clientLotUuid = const Value.absent(),
    this.collectorId = const Value.absent(),
    this.category = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.quotedPrice = const Value.absent(),
    this.finalPrice = const Value.absent(),
    this.recyclerId = const Value.absent(),
    this.collectionLat = const Value.absent(),
    this.collectionLng = const Value.absent(),
    this.handoverLat = const Value.absent(),
    this.handoverLng = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.handoverAt = const Value.absent(),
    this.paymentStatus = const Value.absent(),
    this.transactionStatus = const Value.absent(),
    this.anomalyFlag = const Value.absent(),
    this.anomalyReason = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalTransactionsCompanion.insert({
    required String lotId,
    required String clientLotUuid,
    required String collectorId,
    required String category,
    required double weightKg,
    required double quotedPrice,
    this.finalPrice = const Value.absent(),
    this.recyclerId = const Value.absent(),
    required double collectionLat,
    required double collectionLng,
    this.handoverLat = const Value.absent(),
    this.handoverLng = const Value.absent(),
    required DateTime createdAt,
    this.handoverAt = const Value.absent(),
    this.paymentStatus = const Value.absent(),
    this.transactionStatus = const Value.absent(),
    this.anomalyFlag = const Value.absent(),
    this.anomalyReason = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : lotId = Value(lotId),
        clientLotUuid = Value(clientLotUuid),
        collectorId = Value(collectorId),
        category = Value(category),
        weightKg = Value(weightKg),
        quotedPrice = Value(quotedPrice),
        collectionLat = Value(collectionLat),
        collectionLng = Value(collectionLng),
        createdAt = Value(createdAt);
  static Insertable<LocalTransaction> custom({
    Expression<String>? lotId,
    Expression<String>? clientLotUuid,
    Expression<String>? collectorId,
    Expression<String>? category,
    Expression<double>? weightKg,
    Expression<double>? quotedPrice,
    Expression<double>? finalPrice,
    Expression<String>? recyclerId,
    Expression<double>? collectionLat,
    Expression<double>? collectionLng,
    Expression<double>? handoverLat,
    Expression<double>? handoverLng,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? handoverAt,
    Expression<String>? paymentStatus,
    Expression<String>? transactionStatus,
    Expression<bool>? anomalyFlag,
    Expression<String>? anomalyReason,
    Expression<bool>? isSynced,
    Expression<DateTime>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (lotId != null) 'lot_id': lotId,
      if (clientLotUuid != null) 'client_lot_uuid': clientLotUuid,
      if (collectorId != null) 'collector_id': collectorId,
      if (category != null) 'category': category,
      if (weightKg != null) 'weight_kg': weightKg,
      if (quotedPrice != null) 'quoted_price': quotedPrice,
      if (finalPrice != null) 'final_price': finalPrice,
      if (recyclerId != null) 'recycler_id': recyclerId,
      if (collectionLat != null) 'collection_lat': collectionLat,
      if (collectionLng != null) 'collection_lng': collectionLng,
      if (handoverLat != null) 'handover_lat': handoverLat,
      if (handoverLng != null) 'handover_lng': handoverLng,
      if (createdAt != null) 'created_at': createdAt,
      if (handoverAt != null) 'handover_at': handoverAt,
      if (paymentStatus != null) 'payment_status': paymentStatus,
      if (transactionStatus != null) 'transaction_status': transactionStatus,
      if (anomalyFlag != null) 'anomaly_flag': anomalyFlag,
      if (anomalyReason != null) 'anomaly_reason': anomalyReason,
      if (isSynced != null) 'is_synced': isSynced,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalTransactionsCompanion copyWith(
      {Value<String>? lotId,
      Value<String>? clientLotUuid,
      Value<String>? collectorId,
      Value<String>? category,
      Value<double>? weightKg,
      Value<double>? quotedPrice,
      Value<double?>? finalPrice,
      Value<String?>? recyclerId,
      Value<double>? collectionLat,
      Value<double>? collectionLng,
      Value<double?>? handoverLat,
      Value<double?>? handoverLng,
      Value<DateTime>? createdAt,
      Value<DateTime?>? handoverAt,
      Value<String>? paymentStatus,
      Value<String>? transactionStatus,
      Value<bool>? anomalyFlag,
      Value<String?>? anomalyReason,
      Value<bool>? isSynced,
      Value<DateTime?>? syncedAt,
      Value<int>? rowid}) {
    return LocalTransactionsCompanion(
      lotId: lotId ?? this.lotId,
      clientLotUuid: clientLotUuid ?? this.clientLotUuid,
      collectorId: collectorId ?? this.collectorId,
      category: category ?? this.category,
      weightKg: weightKg ?? this.weightKg,
      quotedPrice: quotedPrice ?? this.quotedPrice,
      finalPrice: finalPrice ?? this.finalPrice,
      recyclerId: recyclerId ?? this.recyclerId,
      collectionLat: collectionLat ?? this.collectionLat,
      collectionLng: collectionLng ?? this.collectionLng,
      handoverLat: handoverLat ?? this.handoverLat,
      handoverLng: handoverLng ?? this.handoverLng,
      createdAt: createdAt ?? this.createdAt,
      handoverAt: handoverAt ?? this.handoverAt,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      transactionStatus: transactionStatus ?? this.transactionStatus,
      anomalyFlag: anomalyFlag ?? this.anomalyFlag,
      anomalyReason: anomalyReason ?? this.anomalyReason,
      isSynced: isSynced ?? this.isSynced,
      syncedAt: syncedAt ?? this.syncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (lotId.present) {
      map['lot_id'] = Variable<String>(lotId.value);
    }
    if (clientLotUuid.present) {
      map['client_lot_uuid'] = Variable<String>(clientLotUuid.value);
    }
    if (collectorId.present) {
      map['collector_id'] = Variable<String>(collectorId.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (weightKg.present) {
      map['weight_kg'] = Variable<double>(weightKg.value);
    }
    if (quotedPrice.present) {
      map['quoted_price'] = Variable<double>(quotedPrice.value);
    }
    if (finalPrice.present) {
      map['final_price'] = Variable<double>(finalPrice.value);
    }
    if (recyclerId.present) {
      map['recycler_id'] = Variable<String>(recyclerId.value);
    }
    if (collectionLat.present) {
      map['collection_lat'] = Variable<double>(collectionLat.value);
    }
    if (collectionLng.present) {
      map['collection_lng'] = Variable<double>(collectionLng.value);
    }
    if (handoverLat.present) {
      map['handover_lat'] = Variable<double>(handoverLat.value);
    }
    if (handoverLng.present) {
      map['handover_lng'] = Variable<double>(handoverLng.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (handoverAt.present) {
      map['handover_at'] = Variable<DateTime>(handoverAt.value);
    }
    if (paymentStatus.present) {
      map['payment_status'] = Variable<String>(paymentStatus.value);
    }
    if (transactionStatus.present) {
      map['transaction_status'] = Variable<String>(transactionStatus.value);
    }
    if (anomalyFlag.present) {
      map['anomaly_flag'] = Variable<bool>(anomalyFlag.value);
    }
    if (anomalyReason.present) {
      map['anomaly_reason'] = Variable<String>(anomalyReason.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalTransactionsCompanion(')
          ..write('lotId: $lotId, ')
          ..write('clientLotUuid: $clientLotUuid, ')
          ..write('collectorId: $collectorId, ')
          ..write('category: $category, ')
          ..write('weightKg: $weightKg, ')
          ..write('quotedPrice: $quotedPrice, ')
          ..write('finalPrice: $finalPrice, ')
          ..write('recyclerId: $recyclerId, ')
          ..write('collectionLat: $collectionLat, ')
          ..write('collectionLng: $collectionLng, ')
          ..write('handoverLat: $handoverLat, ')
          ..write('handoverLng: $handoverLng, ')
          ..write('createdAt: $createdAt, ')
          ..write('handoverAt: $handoverAt, ')
          ..write('paymentStatus: $paymentStatus, ')
          ..write('transactionStatus: $transactionStatus, ')
          ..write('anomalyFlag: $anomalyFlag, ')
          ..write('anomalyReason: $anomalyReason, ')
          ..write('isSynced: $isSynced, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalTraceabilityTable extends LocalTraceability
    with TableInfo<$LocalTraceabilityTable, LocalTraceabilityData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalTraceabilityTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _lotIdMeta = const VerificationMeta('lotId');
  @override
  late final GeneratedColumn<String> lotId = GeneratedColumn<String>(
      'lot_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _photoHashesJsonMeta =
      const VerificationMeta('photoHashesJson');
  @override
  late final GeneratedColumn<String> photoHashesJson = GeneratedColumn<String>(
      'photo_hashes_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _weightKgMeta =
      const VerificationMeta('weightKg');
  @override
  late final GeneratedColumn<double> weightKg = GeneratedColumn<double>(
      'weight_kg', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _timestampMeta =
      const VerificationMeta('timestamp');
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
      'timestamp', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _gpsLatMeta = const VerificationMeta('gpsLat');
  @override
  late final GeneratedColumn<double> gpsLat = GeneratedColumn<double>(
      'gps_lat', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _gpsLngMeta = const VerificationMeta('gpsLng');
  @override
  late final GeneratedColumn<double> gpsLng = GeneratedColumn<double>(
      'gps_lng', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _handoverRefNoMeta =
      const VerificationMeta('handoverRefNo');
  @override
  late final GeneratedColumn<String> handoverRefNo = GeneratedColumn<String>(
      'handover_ref_no', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _qrPayloadMeta =
      const VerificationMeta('qrPayload');
  @override
  late final GeneratedColumn<String> qrPayload = GeneratedColumn<String>(
      'qr_payload', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _recyclerConfirmationMeta =
      const VerificationMeta('recyclerConfirmation');
  @override
  late final GeneratedColumn<bool> recyclerConfirmation = GeneratedColumn<bool>(
      'recycler_confirmation', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("recycler_confirmation" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _confirmedAtMeta =
      const VerificationMeta('confirmedAt');
  @override
  late final GeneratedColumn<DateTime> confirmedAt = GeneratedColumn<DateTime>(
      'confirmed_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _confirmedByMeta =
      const VerificationMeta('confirmedBy');
  @override
  late final GeneratedColumn<String> confirmedBy = GeneratedColumn<String>(
      'confirmed_by', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _downstreamStatusMeta =
      const VerificationMeta('downstreamStatus');
  @override
  late final GeneratedColumn<String> downstreamStatus = GeneratedColumn<String>(
      'downstream_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('received'));
  static const VerificationMeta _recordHashMeta =
      const VerificationMeta('recordHash');
  @override
  late final GeneratedColumn<String> recordHash = GeneratedColumn<String>(
      'record_hash', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _prevHashMeta =
      const VerificationMeta('prevHash');
  @override
  late final GeneratedColumn<String> prevHash = GeneratedColumn<String>(
      'prev_hash', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isSyncedMeta =
      const VerificationMeta('isSynced');
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
      'is_synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_synced" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        lotId,
        photoHashesJson,
        weightKg,
        timestamp,
        gpsLat,
        gpsLng,
        handoverRefNo,
        qrPayload,
        recyclerConfirmation,
        confirmedAt,
        confirmedBy,
        downstreamStatus,
        recordHash,
        prevHash,
        isSynced,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_traceability';
  @override
  VerificationContext validateIntegrity(
      Insertable<LocalTraceabilityData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('lot_id')) {
      context.handle(
          _lotIdMeta, lotId.isAcceptableOrUnknown(data['lot_id']!, _lotIdMeta));
    } else if (isInserting) {
      context.missing(_lotIdMeta);
    }
    if (data.containsKey('photo_hashes_json')) {
      context.handle(
          _photoHashesJsonMeta,
          photoHashesJson.isAcceptableOrUnknown(
              data['photo_hashes_json']!, _photoHashesJsonMeta));
    } else if (isInserting) {
      context.missing(_photoHashesJsonMeta);
    }
    if (data.containsKey('weight_kg')) {
      context.handle(_weightKgMeta,
          weightKg.isAcceptableOrUnknown(data['weight_kg']!, _weightKgMeta));
    } else if (isInserting) {
      context.missing(_weightKgMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(_timestampMeta,
          timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta));
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('gps_lat')) {
      context.handle(_gpsLatMeta,
          gpsLat.isAcceptableOrUnknown(data['gps_lat']!, _gpsLatMeta));
    } else if (isInserting) {
      context.missing(_gpsLatMeta);
    }
    if (data.containsKey('gps_lng')) {
      context.handle(_gpsLngMeta,
          gpsLng.isAcceptableOrUnknown(data['gps_lng']!, _gpsLngMeta));
    } else if (isInserting) {
      context.missing(_gpsLngMeta);
    }
    if (data.containsKey('handover_ref_no')) {
      context.handle(
          _handoverRefNoMeta,
          handoverRefNo.isAcceptableOrUnknown(
              data['handover_ref_no']!, _handoverRefNoMeta));
    } else if (isInserting) {
      context.missing(_handoverRefNoMeta);
    }
    if (data.containsKey('qr_payload')) {
      context.handle(_qrPayloadMeta,
          qrPayload.isAcceptableOrUnknown(data['qr_payload']!, _qrPayloadMeta));
    } else if (isInserting) {
      context.missing(_qrPayloadMeta);
    }
    if (data.containsKey('recycler_confirmation')) {
      context.handle(
          _recyclerConfirmationMeta,
          recyclerConfirmation.isAcceptableOrUnknown(
              data['recycler_confirmation']!, _recyclerConfirmationMeta));
    }
    if (data.containsKey('confirmed_at')) {
      context.handle(
          _confirmedAtMeta,
          confirmedAt.isAcceptableOrUnknown(
              data['confirmed_at']!, _confirmedAtMeta));
    }
    if (data.containsKey('confirmed_by')) {
      context.handle(
          _confirmedByMeta,
          confirmedBy.isAcceptableOrUnknown(
              data['confirmed_by']!, _confirmedByMeta));
    }
    if (data.containsKey('downstream_status')) {
      context.handle(
          _downstreamStatusMeta,
          downstreamStatus.isAcceptableOrUnknown(
              data['downstream_status']!, _downstreamStatusMeta));
    }
    if (data.containsKey('record_hash')) {
      context.handle(
          _recordHashMeta,
          recordHash.isAcceptableOrUnknown(
              data['record_hash']!, _recordHashMeta));
    } else if (isInserting) {
      context.missing(_recordHashMeta);
    }
    if (data.containsKey('prev_hash')) {
      context.handle(_prevHashMeta,
          prevHash.isAcceptableOrUnknown(data['prev_hash']!, _prevHashMeta));
    } else if (isInserting) {
      context.missing(_prevHashMeta);
    }
    if (data.containsKey('is_synced')) {
      context.handle(_isSyncedMeta,
          isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalTraceabilityData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalTraceabilityData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      lotId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}lot_id'])!,
      photoHashesJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}photo_hashes_json'])!,
      weightKg: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}weight_kg'])!,
      timestamp: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}timestamp'])!,
      gpsLat: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}gps_lat'])!,
      gpsLng: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}gps_lng'])!,
      handoverRefNo: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}handover_ref_no'])!,
      qrPayload: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}qr_payload'])!,
      recyclerConfirmation: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}recycler_confirmation'])!,
      confirmedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}confirmed_at']),
      confirmedBy: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}confirmed_by']),
      downstreamStatus: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}downstream_status'])!,
      recordHash: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}record_hash'])!,
      prevHash: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}prev_hash'])!,
      isSynced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_synced'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $LocalTraceabilityTable createAlias(String alias) {
    return $LocalTraceabilityTable(attachedDatabase, alias);
  }
}

class LocalTraceabilityData extends DataClass
    implements Insertable<LocalTraceabilityData> {
  final String id;
  final String lotId;
  final String photoHashesJson;
  final double weightKg;
  final DateTime timestamp;
  final double gpsLat;
  final double gpsLng;
  final String handoverRefNo;
  final String qrPayload;
  final bool recyclerConfirmation;
  final DateTime? confirmedAt;
  final String? confirmedBy;
  final String downstreamStatus;
  final String recordHash;
  final String prevHash;
  final bool isSynced;
  final DateTime createdAt;
  const LocalTraceabilityData(
      {required this.id,
      required this.lotId,
      required this.photoHashesJson,
      required this.weightKg,
      required this.timestamp,
      required this.gpsLat,
      required this.gpsLng,
      required this.handoverRefNo,
      required this.qrPayload,
      required this.recyclerConfirmation,
      this.confirmedAt,
      this.confirmedBy,
      required this.downstreamStatus,
      required this.recordHash,
      required this.prevHash,
      required this.isSynced,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['lot_id'] = Variable<String>(lotId);
    map['photo_hashes_json'] = Variable<String>(photoHashesJson);
    map['weight_kg'] = Variable<double>(weightKg);
    map['timestamp'] = Variable<DateTime>(timestamp);
    map['gps_lat'] = Variable<double>(gpsLat);
    map['gps_lng'] = Variable<double>(gpsLng);
    map['handover_ref_no'] = Variable<String>(handoverRefNo);
    map['qr_payload'] = Variable<String>(qrPayload);
    map['recycler_confirmation'] = Variable<bool>(recyclerConfirmation);
    if (!nullToAbsent || confirmedAt != null) {
      map['confirmed_at'] = Variable<DateTime>(confirmedAt);
    }
    if (!nullToAbsent || confirmedBy != null) {
      map['confirmed_by'] = Variable<String>(confirmedBy);
    }
    map['downstream_status'] = Variable<String>(downstreamStatus);
    map['record_hash'] = Variable<String>(recordHash);
    map['prev_hash'] = Variable<String>(prevHash);
    map['is_synced'] = Variable<bool>(isSynced);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  LocalTraceabilityCompanion toCompanion(bool nullToAbsent) {
    return LocalTraceabilityCompanion(
      id: Value(id),
      lotId: Value(lotId),
      photoHashesJson: Value(photoHashesJson),
      weightKg: Value(weightKg),
      timestamp: Value(timestamp),
      gpsLat: Value(gpsLat),
      gpsLng: Value(gpsLng),
      handoverRefNo: Value(handoverRefNo),
      qrPayload: Value(qrPayload),
      recyclerConfirmation: Value(recyclerConfirmation),
      confirmedAt: confirmedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(confirmedAt),
      confirmedBy: confirmedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(confirmedBy),
      downstreamStatus: Value(downstreamStatus),
      recordHash: Value(recordHash),
      prevHash: Value(prevHash),
      isSynced: Value(isSynced),
      createdAt: Value(createdAt),
    );
  }

  factory LocalTraceabilityData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalTraceabilityData(
      id: serializer.fromJson<String>(json['id']),
      lotId: serializer.fromJson<String>(json['lotId']),
      photoHashesJson: serializer.fromJson<String>(json['photoHashesJson']),
      weightKg: serializer.fromJson<double>(json['weightKg']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      gpsLat: serializer.fromJson<double>(json['gpsLat']),
      gpsLng: serializer.fromJson<double>(json['gpsLng']),
      handoverRefNo: serializer.fromJson<String>(json['handoverRefNo']),
      qrPayload: serializer.fromJson<String>(json['qrPayload']),
      recyclerConfirmation:
          serializer.fromJson<bool>(json['recyclerConfirmation']),
      confirmedAt: serializer.fromJson<DateTime?>(json['confirmedAt']),
      confirmedBy: serializer.fromJson<String?>(json['confirmedBy']),
      downstreamStatus: serializer.fromJson<String>(json['downstreamStatus']),
      recordHash: serializer.fromJson<String>(json['recordHash']),
      prevHash: serializer.fromJson<String>(json['prevHash']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'lotId': serializer.toJson<String>(lotId),
      'photoHashesJson': serializer.toJson<String>(photoHashesJson),
      'weightKg': serializer.toJson<double>(weightKg),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'gpsLat': serializer.toJson<double>(gpsLat),
      'gpsLng': serializer.toJson<double>(gpsLng),
      'handoverRefNo': serializer.toJson<String>(handoverRefNo),
      'qrPayload': serializer.toJson<String>(qrPayload),
      'recyclerConfirmation': serializer.toJson<bool>(recyclerConfirmation),
      'confirmedAt': serializer.toJson<DateTime?>(confirmedAt),
      'confirmedBy': serializer.toJson<String?>(confirmedBy),
      'downstreamStatus': serializer.toJson<String>(downstreamStatus),
      'recordHash': serializer.toJson<String>(recordHash),
      'prevHash': serializer.toJson<String>(prevHash),
      'isSynced': serializer.toJson<bool>(isSynced),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  LocalTraceabilityData copyWith(
          {String? id,
          String? lotId,
          String? photoHashesJson,
          double? weightKg,
          DateTime? timestamp,
          double? gpsLat,
          double? gpsLng,
          String? handoverRefNo,
          String? qrPayload,
          bool? recyclerConfirmation,
          Value<DateTime?> confirmedAt = const Value.absent(),
          Value<String?> confirmedBy = const Value.absent(),
          String? downstreamStatus,
          String? recordHash,
          String? prevHash,
          bool? isSynced,
          DateTime? createdAt}) =>
      LocalTraceabilityData(
        id: id ?? this.id,
        lotId: lotId ?? this.lotId,
        photoHashesJson: photoHashesJson ?? this.photoHashesJson,
        weightKg: weightKg ?? this.weightKg,
        timestamp: timestamp ?? this.timestamp,
        gpsLat: gpsLat ?? this.gpsLat,
        gpsLng: gpsLng ?? this.gpsLng,
        handoverRefNo: handoverRefNo ?? this.handoverRefNo,
        qrPayload: qrPayload ?? this.qrPayload,
        recyclerConfirmation: recyclerConfirmation ?? this.recyclerConfirmation,
        confirmedAt: confirmedAt.present ? confirmedAt.value : this.confirmedAt,
        confirmedBy: confirmedBy.present ? confirmedBy.value : this.confirmedBy,
        downstreamStatus: downstreamStatus ?? this.downstreamStatus,
        recordHash: recordHash ?? this.recordHash,
        prevHash: prevHash ?? this.prevHash,
        isSynced: isSynced ?? this.isSynced,
        createdAt: createdAt ?? this.createdAt,
      );
  LocalTraceabilityData copyWithCompanion(LocalTraceabilityCompanion data) {
    return LocalTraceabilityData(
      id: data.id.present ? data.id.value : this.id,
      lotId: data.lotId.present ? data.lotId.value : this.lotId,
      photoHashesJson: data.photoHashesJson.present
          ? data.photoHashesJson.value
          : this.photoHashesJson,
      weightKg: data.weightKg.present ? data.weightKg.value : this.weightKg,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      gpsLat: data.gpsLat.present ? data.gpsLat.value : this.gpsLat,
      gpsLng: data.gpsLng.present ? data.gpsLng.value : this.gpsLng,
      handoverRefNo: data.handoverRefNo.present
          ? data.handoverRefNo.value
          : this.handoverRefNo,
      qrPayload: data.qrPayload.present ? data.qrPayload.value : this.qrPayload,
      recyclerConfirmation: data.recyclerConfirmation.present
          ? data.recyclerConfirmation.value
          : this.recyclerConfirmation,
      confirmedAt:
          data.confirmedAt.present ? data.confirmedAt.value : this.confirmedAt,
      confirmedBy:
          data.confirmedBy.present ? data.confirmedBy.value : this.confirmedBy,
      downstreamStatus: data.downstreamStatus.present
          ? data.downstreamStatus.value
          : this.downstreamStatus,
      recordHash:
          data.recordHash.present ? data.recordHash.value : this.recordHash,
      prevHash: data.prevHash.present ? data.prevHash.value : this.prevHash,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalTraceabilityData(')
          ..write('id: $id, ')
          ..write('lotId: $lotId, ')
          ..write('photoHashesJson: $photoHashesJson, ')
          ..write('weightKg: $weightKg, ')
          ..write('timestamp: $timestamp, ')
          ..write('gpsLat: $gpsLat, ')
          ..write('gpsLng: $gpsLng, ')
          ..write('handoverRefNo: $handoverRefNo, ')
          ..write('qrPayload: $qrPayload, ')
          ..write('recyclerConfirmation: $recyclerConfirmation, ')
          ..write('confirmedAt: $confirmedAt, ')
          ..write('confirmedBy: $confirmedBy, ')
          ..write('downstreamStatus: $downstreamStatus, ')
          ..write('recordHash: $recordHash, ')
          ..write('prevHash: $prevHash, ')
          ..write('isSynced: $isSynced, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      lotId,
      photoHashesJson,
      weightKg,
      timestamp,
      gpsLat,
      gpsLng,
      handoverRefNo,
      qrPayload,
      recyclerConfirmation,
      confirmedAt,
      confirmedBy,
      downstreamStatus,
      recordHash,
      prevHash,
      isSynced,
      createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalTraceabilityData &&
          other.id == this.id &&
          other.lotId == this.lotId &&
          other.photoHashesJson == this.photoHashesJson &&
          other.weightKg == this.weightKg &&
          other.timestamp == this.timestamp &&
          other.gpsLat == this.gpsLat &&
          other.gpsLng == this.gpsLng &&
          other.handoverRefNo == this.handoverRefNo &&
          other.qrPayload == this.qrPayload &&
          other.recyclerConfirmation == this.recyclerConfirmation &&
          other.confirmedAt == this.confirmedAt &&
          other.confirmedBy == this.confirmedBy &&
          other.downstreamStatus == this.downstreamStatus &&
          other.recordHash == this.recordHash &&
          other.prevHash == this.prevHash &&
          other.isSynced == this.isSynced &&
          other.createdAt == this.createdAt);
}

class LocalTraceabilityCompanion
    extends UpdateCompanion<LocalTraceabilityData> {
  final Value<String> id;
  final Value<String> lotId;
  final Value<String> photoHashesJson;
  final Value<double> weightKg;
  final Value<DateTime> timestamp;
  final Value<double> gpsLat;
  final Value<double> gpsLng;
  final Value<String> handoverRefNo;
  final Value<String> qrPayload;
  final Value<bool> recyclerConfirmation;
  final Value<DateTime?> confirmedAt;
  final Value<String?> confirmedBy;
  final Value<String> downstreamStatus;
  final Value<String> recordHash;
  final Value<String> prevHash;
  final Value<bool> isSynced;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const LocalTraceabilityCompanion({
    this.id = const Value.absent(),
    this.lotId = const Value.absent(),
    this.photoHashesJson = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.gpsLat = const Value.absent(),
    this.gpsLng = const Value.absent(),
    this.handoverRefNo = const Value.absent(),
    this.qrPayload = const Value.absent(),
    this.recyclerConfirmation = const Value.absent(),
    this.confirmedAt = const Value.absent(),
    this.confirmedBy = const Value.absent(),
    this.downstreamStatus = const Value.absent(),
    this.recordHash = const Value.absent(),
    this.prevHash = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalTraceabilityCompanion.insert({
    required String id,
    required String lotId,
    required String photoHashesJson,
    required double weightKg,
    required DateTime timestamp,
    required double gpsLat,
    required double gpsLng,
    required String handoverRefNo,
    required String qrPayload,
    this.recyclerConfirmation = const Value.absent(),
    this.confirmedAt = const Value.absent(),
    this.confirmedBy = const Value.absent(),
    this.downstreamStatus = const Value.absent(),
    required String recordHash,
    required String prevHash,
    this.isSynced = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        lotId = Value(lotId),
        photoHashesJson = Value(photoHashesJson),
        weightKg = Value(weightKg),
        timestamp = Value(timestamp),
        gpsLat = Value(gpsLat),
        gpsLng = Value(gpsLng),
        handoverRefNo = Value(handoverRefNo),
        qrPayload = Value(qrPayload),
        recordHash = Value(recordHash),
        prevHash = Value(prevHash),
        createdAt = Value(createdAt);
  static Insertable<LocalTraceabilityData> custom({
    Expression<String>? id,
    Expression<String>? lotId,
    Expression<String>? photoHashesJson,
    Expression<double>? weightKg,
    Expression<DateTime>? timestamp,
    Expression<double>? gpsLat,
    Expression<double>? gpsLng,
    Expression<String>? handoverRefNo,
    Expression<String>? qrPayload,
    Expression<bool>? recyclerConfirmation,
    Expression<DateTime>? confirmedAt,
    Expression<String>? confirmedBy,
    Expression<String>? downstreamStatus,
    Expression<String>? recordHash,
    Expression<String>? prevHash,
    Expression<bool>? isSynced,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (lotId != null) 'lot_id': lotId,
      if (photoHashesJson != null) 'photo_hashes_json': photoHashesJson,
      if (weightKg != null) 'weight_kg': weightKg,
      if (timestamp != null) 'timestamp': timestamp,
      if (gpsLat != null) 'gps_lat': gpsLat,
      if (gpsLng != null) 'gps_lng': gpsLng,
      if (handoverRefNo != null) 'handover_ref_no': handoverRefNo,
      if (qrPayload != null) 'qr_payload': qrPayload,
      if (recyclerConfirmation != null)
        'recycler_confirmation': recyclerConfirmation,
      if (confirmedAt != null) 'confirmed_at': confirmedAt,
      if (confirmedBy != null) 'confirmed_by': confirmedBy,
      if (downstreamStatus != null) 'downstream_status': downstreamStatus,
      if (recordHash != null) 'record_hash': recordHash,
      if (prevHash != null) 'prev_hash': prevHash,
      if (isSynced != null) 'is_synced': isSynced,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalTraceabilityCompanion copyWith(
      {Value<String>? id,
      Value<String>? lotId,
      Value<String>? photoHashesJson,
      Value<double>? weightKg,
      Value<DateTime>? timestamp,
      Value<double>? gpsLat,
      Value<double>? gpsLng,
      Value<String>? handoverRefNo,
      Value<String>? qrPayload,
      Value<bool>? recyclerConfirmation,
      Value<DateTime?>? confirmedAt,
      Value<String?>? confirmedBy,
      Value<String>? downstreamStatus,
      Value<String>? recordHash,
      Value<String>? prevHash,
      Value<bool>? isSynced,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return LocalTraceabilityCompanion(
      id: id ?? this.id,
      lotId: lotId ?? this.lotId,
      photoHashesJson: photoHashesJson ?? this.photoHashesJson,
      weightKg: weightKg ?? this.weightKg,
      timestamp: timestamp ?? this.timestamp,
      gpsLat: gpsLat ?? this.gpsLat,
      gpsLng: gpsLng ?? this.gpsLng,
      handoverRefNo: handoverRefNo ?? this.handoverRefNo,
      qrPayload: qrPayload ?? this.qrPayload,
      recyclerConfirmation: recyclerConfirmation ?? this.recyclerConfirmation,
      confirmedAt: confirmedAt ?? this.confirmedAt,
      confirmedBy: confirmedBy ?? this.confirmedBy,
      downstreamStatus: downstreamStatus ?? this.downstreamStatus,
      recordHash: recordHash ?? this.recordHash,
      prevHash: prevHash ?? this.prevHash,
      isSynced: isSynced ?? this.isSynced,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (lotId.present) {
      map['lot_id'] = Variable<String>(lotId.value);
    }
    if (photoHashesJson.present) {
      map['photo_hashes_json'] = Variable<String>(photoHashesJson.value);
    }
    if (weightKg.present) {
      map['weight_kg'] = Variable<double>(weightKg.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (gpsLat.present) {
      map['gps_lat'] = Variable<double>(gpsLat.value);
    }
    if (gpsLng.present) {
      map['gps_lng'] = Variable<double>(gpsLng.value);
    }
    if (handoverRefNo.present) {
      map['handover_ref_no'] = Variable<String>(handoverRefNo.value);
    }
    if (qrPayload.present) {
      map['qr_payload'] = Variable<String>(qrPayload.value);
    }
    if (recyclerConfirmation.present) {
      map['recycler_confirmation'] = Variable<bool>(recyclerConfirmation.value);
    }
    if (confirmedAt.present) {
      map['confirmed_at'] = Variable<DateTime>(confirmedAt.value);
    }
    if (confirmedBy.present) {
      map['confirmed_by'] = Variable<String>(confirmedBy.value);
    }
    if (downstreamStatus.present) {
      map['downstream_status'] = Variable<String>(downstreamStatus.value);
    }
    if (recordHash.present) {
      map['record_hash'] = Variable<String>(recordHash.value);
    }
    if (prevHash.present) {
      map['prev_hash'] = Variable<String>(prevHash.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalTraceabilityCompanion(')
          ..write('id: $id, ')
          ..write('lotId: $lotId, ')
          ..write('photoHashesJson: $photoHashesJson, ')
          ..write('weightKg: $weightKg, ')
          ..write('timestamp: $timestamp, ')
          ..write('gpsLat: $gpsLat, ')
          ..write('gpsLng: $gpsLng, ')
          ..write('handoverRefNo: $handoverRefNo, ')
          ..write('qrPayload: $qrPayload, ')
          ..write('recyclerConfirmation: $recyclerConfirmation, ')
          ..write('confirmedAt: $confirmedAt, ')
          ..write('confirmedBy: $confirmedBy, ')
          ..write('downstreamStatus: $downstreamStatus, ')
          ..write('recordHash: $recordHash, ')
          ..write('prevHash: $prevHash, ')
          ..write('isSynced: $isSynced, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CollectorProfileTable extends CollectorProfile
    with TableInfo<$CollectorProfileTable, CollectorProfileData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CollectorProfileTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _collectorIdMeta =
      const VerificationMeta('collectorId');
  @override
  late final GeneratedColumn<String> collectorId = GeneratedColumn<String>(
      'collector_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _preferredLanguageMeta =
      const VerificationMeta('preferredLanguage');
  @override
  late final GeneratedColumn<String> preferredLanguage =
      GeneratedColumn<String>('preferred_language', aliasedName, false,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          defaultValue: const Constant('mr'));
  static const VerificationMeta _operatingAreaMeta =
      const VerificationMeta('operatingArea');
  @override
  late final GeneratedColumn<String> operatingArea = GeneratedColumn<String>(
      'operating_area', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _quickPinHashMeta =
      const VerificationMeta('quickPinHash');
  @override
  late final GeneratedColumn<String> quickPinHash = GeneratedColumn<String>(
      'quick_pin_hash', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [collectorId, preferredLanguage, operatingArea, quickPinHash, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'collector_profile';
  @override
  VerificationContext validateIntegrity(
      Insertable<CollectorProfileData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('collector_id')) {
      context.handle(
          _collectorIdMeta,
          collectorId.isAcceptableOrUnknown(
              data['collector_id']!, _collectorIdMeta));
    } else if (isInserting) {
      context.missing(_collectorIdMeta);
    }
    if (data.containsKey('preferred_language')) {
      context.handle(
          _preferredLanguageMeta,
          preferredLanguage.isAcceptableOrUnknown(
              data['preferred_language']!, _preferredLanguageMeta));
    }
    if (data.containsKey('operating_area')) {
      context.handle(
          _operatingAreaMeta,
          operatingArea.isAcceptableOrUnknown(
              data['operating_area']!, _operatingAreaMeta));
    } else if (isInserting) {
      context.missing(_operatingAreaMeta);
    }
    if (data.containsKey('quick_pin_hash')) {
      context.handle(
          _quickPinHashMeta,
          quickPinHash.isAcceptableOrUnknown(
              data['quick_pin_hash']!, _quickPinHashMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {collectorId};
  @override
  CollectorProfileData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CollectorProfileData(
      collectorId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}collector_id'])!,
      preferredLanguage: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}preferred_language'])!,
      operatingArea: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}operating_area'])!,
      quickPinHash: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}quick_pin_hash']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $CollectorProfileTable createAlias(String alias) {
    return $CollectorProfileTable(attachedDatabase, alias);
  }
}

class CollectorProfileData extends DataClass
    implements Insertable<CollectorProfileData> {
  final String collectorId;
  final String preferredLanguage;
  final String operatingArea;
  final String? quickPinHash;
  final DateTime createdAt;
  const CollectorProfileData(
      {required this.collectorId,
      required this.preferredLanguage,
      required this.operatingArea,
      this.quickPinHash,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['collector_id'] = Variable<String>(collectorId);
    map['preferred_language'] = Variable<String>(preferredLanguage);
    map['operating_area'] = Variable<String>(operatingArea);
    if (!nullToAbsent || quickPinHash != null) {
      map['quick_pin_hash'] = Variable<String>(quickPinHash);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CollectorProfileCompanion toCompanion(bool nullToAbsent) {
    return CollectorProfileCompanion(
      collectorId: Value(collectorId),
      preferredLanguage: Value(preferredLanguage),
      operatingArea: Value(operatingArea),
      quickPinHash: quickPinHash == null && nullToAbsent
          ? const Value.absent()
          : Value(quickPinHash),
      createdAt: Value(createdAt),
    );
  }

  factory CollectorProfileData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CollectorProfileData(
      collectorId: serializer.fromJson<String>(json['collectorId']),
      preferredLanguage: serializer.fromJson<String>(json['preferredLanguage']),
      operatingArea: serializer.fromJson<String>(json['operatingArea']),
      quickPinHash: serializer.fromJson<String?>(json['quickPinHash']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'collectorId': serializer.toJson<String>(collectorId),
      'preferredLanguage': serializer.toJson<String>(preferredLanguage),
      'operatingArea': serializer.toJson<String>(operatingArea),
      'quickPinHash': serializer.toJson<String?>(quickPinHash),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  CollectorProfileData copyWith(
          {String? collectorId,
          String? preferredLanguage,
          String? operatingArea,
          Value<String?> quickPinHash = const Value.absent(),
          DateTime? createdAt}) =>
      CollectorProfileData(
        collectorId: collectorId ?? this.collectorId,
        preferredLanguage: preferredLanguage ?? this.preferredLanguage,
        operatingArea: operatingArea ?? this.operatingArea,
        quickPinHash:
            quickPinHash.present ? quickPinHash.value : this.quickPinHash,
        createdAt: createdAt ?? this.createdAt,
      );
  CollectorProfileData copyWithCompanion(CollectorProfileCompanion data) {
    return CollectorProfileData(
      collectorId:
          data.collectorId.present ? data.collectorId.value : this.collectorId,
      preferredLanguage: data.preferredLanguage.present
          ? data.preferredLanguage.value
          : this.preferredLanguage,
      operatingArea: data.operatingArea.present
          ? data.operatingArea.value
          : this.operatingArea,
      quickPinHash: data.quickPinHash.present
          ? data.quickPinHash.value
          : this.quickPinHash,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CollectorProfileData(')
          ..write('collectorId: $collectorId, ')
          ..write('preferredLanguage: $preferredLanguage, ')
          ..write('operatingArea: $operatingArea, ')
          ..write('quickPinHash: $quickPinHash, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      collectorId, preferredLanguage, operatingArea, quickPinHash, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CollectorProfileData &&
          other.collectorId == this.collectorId &&
          other.preferredLanguage == this.preferredLanguage &&
          other.operatingArea == this.operatingArea &&
          other.quickPinHash == this.quickPinHash &&
          other.createdAt == this.createdAt);
}

class CollectorProfileCompanion extends UpdateCompanion<CollectorProfileData> {
  final Value<String> collectorId;
  final Value<String> preferredLanguage;
  final Value<String> operatingArea;
  final Value<String?> quickPinHash;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const CollectorProfileCompanion({
    this.collectorId = const Value.absent(),
    this.preferredLanguage = const Value.absent(),
    this.operatingArea = const Value.absent(),
    this.quickPinHash = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CollectorProfileCompanion.insert({
    required String collectorId,
    this.preferredLanguage = const Value.absent(),
    required String operatingArea,
    this.quickPinHash = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : collectorId = Value(collectorId),
        operatingArea = Value(operatingArea),
        createdAt = Value(createdAt);
  static Insertable<CollectorProfileData> custom({
    Expression<String>? collectorId,
    Expression<String>? preferredLanguage,
    Expression<String>? operatingArea,
    Expression<String>? quickPinHash,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (collectorId != null) 'collector_id': collectorId,
      if (preferredLanguage != null) 'preferred_language': preferredLanguage,
      if (operatingArea != null) 'operating_area': operatingArea,
      if (quickPinHash != null) 'quick_pin_hash': quickPinHash,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CollectorProfileCompanion copyWith(
      {Value<String>? collectorId,
      Value<String>? preferredLanguage,
      Value<String>? operatingArea,
      Value<String?>? quickPinHash,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return CollectorProfileCompanion(
      collectorId: collectorId ?? this.collectorId,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      operatingArea: operatingArea ?? this.operatingArea,
      quickPinHash: quickPinHash ?? this.quickPinHash,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (collectorId.present) {
      map['collector_id'] = Variable<String>(collectorId.value);
    }
    if (preferredLanguage.present) {
      map['preferred_language'] = Variable<String>(preferredLanguage.value);
    }
    if (operatingArea.present) {
      map['operating_area'] = Variable<String>(operatingArea.value);
    }
    if (quickPinHash.present) {
      map['quick_pin_hash'] = Variable<String>(quickPinHash.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CollectorProfileCompanion(')
          ..write('collectorId: $collectorId, ')
          ..write('preferredLanguage: $preferredLanguage, ')
          ..write('operatingArea: $operatingArea, ')
          ..write('quickPinHash: $quickPinHash, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalLedgerTable extends LocalLedger
    with TableInfo<$LocalLedgerTable, LocalLedgerData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalLedgerTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _collectorIdMeta =
      const VerificationMeta('collectorId');
  @override
  late final GeneratedColumn<String> collectorId = GeneratedColumn<String>(
      'collector_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _lotIdMeta = const VerificationMeta('lotId');
  @override
  late final GeneratedColumn<String> lotId = GeneratedColumn<String>(
      'lot_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _entryTypeMeta =
      const VerificationMeta('entryType');
  @override
  late final GeneratedColumn<String> entryType = GeneratedColumn<String>(
      'entry_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
      'amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _paymentModeMeta =
      const VerificationMeta('paymentMode');
  @override
  late final GeneratedColumn<String> paymentMode = GeneratedColumn<String>(
      'payment_mode', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('cash_received'));
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _balanceAfterMeta =
      const VerificationMeta('balanceAfter');
  @override
  late final GeneratedColumn<double> balanceAfter = GeneratedColumn<double>(
      'balance_after', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _recordedAtMeta =
      const VerificationMeta('recordedAt');
  @override
  late final GeneratedColumn<DateTime> recordedAt = GeneratedColumn<DateTime>(
      'recorded_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _isSyncedMeta =
      const VerificationMeta('isSynced');
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
      'is_synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_synced" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        collectorId,
        lotId,
        entryType,
        amount,
        paymentMode,
        description,
        balanceAfter,
        recordedAt,
        isSynced
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_ledger';
  @override
  VerificationContext validateIntegrity(Insertable<LocalLedgerData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('collector_id')) {
      context.handle(
          _collectorIdMeta,
          collectorId.isAcceptableOrUnknown(
              data['collector_id']!, _collectorIdMeta));
    } else if (isInserting) {
      context.missing(_collectorIdMeta);
    }
    if (data.containsKey('lot_id')) {
      context.handle(
          _lotIdMeta, lotId.isAcceptableOrUnknown(data['lot_id']!, _lotIdMeta));
    }
    if (data.containsKey('entry_type')) {
      context.handle(_entryTypeMeta,
          entryType.isAcceptableOrUnknown(data['entry_type']!, _entryTypeMeta));
    } else if (isInserting) {
      context.missing(_entryTypeMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('payment_mode')) {
      context.handle(
          _paymentModeMeta,
          paymentMode.isAcceptableOrUnknown(
              data['payment_mode']!, _paymentModeMeta));
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('balance_after')) {
      context.handle(
          _balanceAfterMeta,
          balanceAfter.isAcceptableOrUnknown(
              data['balance_after']!, _balanceAfterMeta));
    } else if (isInserting) {
      context.missing(_balanceAfterMeta);
    }
    if (data.containsKey('recorded_at')) {
      context.handle(
          _recordedAtMeta,
          recordedAt.isAcceptableOrUnknown(
              data['recorded_at']!, _recordedAtMeta));
    } else if (isInserting) {
      context.missing(_recordedAtMeta);
    }
    if (data.containsKey('is_synced')) {
      context.handle(_isSyncedMeta,
          isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalLedgerData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalLedgerData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      collectorId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}collector_id'])!,
      lotId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}lot_id']),
      entryType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entry_type'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount'])!,
      paymentMode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payment_mode'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      balanceAfter: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}balance_after'])!,
      recordedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}recorded_at'])!,
      isSynced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_synced'])!,
    );
  }

  @override
  $LocalLedgerTable createAlias(String alias) {
    return $LocalLedgerTable(attachedDatabase, alias);
  }
}

class LocalLedgerData extends DataClass implements Insertable<LocalLedgerData> {
  final String id;
  final String collectorId;
  final String? lotId;
  final String entryType;
  final double amount;
  final String paymentMode;
  final String description;
  final double balanceAfter;
  final DateTime recordedAt;
  final bool isSynced;
  const LocalLedgerData(
      {required this.id,
      required this.collectorId,
      this.lotId,
      required this.entryType,
      required this.amount,
      required this.paymentMode,
      required this.description,
      required this.balanceAfter,
      required this.recordedAt,
      required this.isSynced});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['collector_id'] = Variable<String>(collectorId);
    if (!nullToAbsent || lotId != null) {
      map['lot_id'] = Variable<String>(lotId);
    }
    map['entry_type'] = Variable<String>(entryType);
    map['amount'] = Variable<double>(amount);
    map['payment_mode'] = Variable<String>(paymentMode);
    map['description'] = Variable<String>(description);
    map['balance_after'] = Variable<double>(balanceAfter);
    map['recorded_at'] = Variable<DateTime>(recordedAt);
    map['is_synced'] = Variable<bool>(isSynced);
    return map;
  }

  LocalLedgerCompanion toCompanion(bool nullToAbsent) {
    return LocalLedgerCompanion(
      id: Value(id),
      collectorId: Value(collectorId),
      lotId:
          lotId == null && nullToAbsent ? const Value.absent() : Value(lotId),
      entryType: Value(entryType),
      amount: Value(amount),
      paymentMode: Value(paymentMode),
      description: Value(description),
      balanceAfter: Value(balanceAfter),
      recordedAt: Value(recordedAt),
      isSynced: Value(isSynced),
    );
  }

  factory LocalLedgerData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalLedgerData(
      id: serializer.fromJson<String>(json['id']),
      collectorId: serializer.fromJson<String>(json['collectorId']),
      lotId: serializer.fromJson<String?>(json['lotId']),
      entryType: serializer.fromJson<String>(json['entryType']),
      amount: serializer.fromJson<double>(json['amount']),
      paymentMode: serializer.fromJson<String>(json['paymentMode']),
      description: serializer.fromJson<String>(json['description']),
      balanceAfter: serializer.fromJson<double>(json['balanceAfter']),
      recordedAt: serializer.fromJson<DateTime>(json['recordedAt']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'collectorId': serializer.toJson<String>(collectorId),
      'lotId': serializer.toJson<String?>(lotId),
      'entryType': serializer.toJson<String>(entryType),
      'amount': serializer.toJson<double>(amount),
      'paymentMode': serializer.toJson<String>(paymentMode),
      'description': serializer.toJson<String>(description),
      'balanceAfter': serializer.toJson<double>(balanceAfter),
      'recordedAt': serializer.toJson<DateTime>(recordedAt),
      'isSynced': serializer.toJson<bool>(isSynced),
    };
  }

  LocalLedgerData copyWith(
          {String? id,
          String? collectorId,
          Value<String?> lotId = const Value.absent(),
          String? entryType,
          double? amount,
          String? paymentMode,
          String? description,
          double? balanceAfter,
          DateTime? recordedAt,
          bool? isSynced}) =>
      LocalLedgerData(
        id: id ?? this.id,
        collectorId: collectorId ?? this.collectorId,
        lotId: lotId.present ? lotId.value : this.lotId,
        entryType: entryType ?? this.entryType,
        amount: amount ?? this.amount,
        paymentMode: paymentMode ?? this.paymentMode,
        description: description ?? this.description,
        balanceAfter: balanceAfter ?? this.balanceAfter,
        recordedAt: recordedAt ?? this.recordedAt,
        isSynced: isSynced ?? this.isSynced,
      );
  LocalLedgerData copyWithCompanion(LocalLedgerCompanion data) {
    return LocalLedgerData(
      id: data.id.present ? data.id.value : this.id,
      collectorId:
          data.collectorId.present ? data.collectorId.value : this.collectorId,
      lotId: data.lotId.present ? data.lotId.value : this.lotId,
      entryType: data.entryType.present ? data.entryType.value : this.entryType,
      amount: data.amount.present ? data.amount.value : this.amount,
      paymentMode:
          data.paymentMode.present ? data.paymentMode.value : this.paymentMode,
      description:
          data.description.present ? data.description.value : this.description,
      balanceAfter: data.balanceAfter.present
          ? data.balanceAfter.value
          : this.balanceAfter,
      recordedAt:
          data.recordedAt.present ? data.recordedAt.value : this.recordedAt,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalLedgerData(')
          ..write('id: $id, ')
          ..write('collectorId: $collectorId, ')
          ..write('lotId: $lotId, ')
          ..write('entryType: $entryType, ')
          ..write('amount: $amount, ')
          ..write('paymentMode: $paymentMode, ')
          ..write('description: $description, ')
          ..write('balanceAfter: $balanceAfter, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, collectorId, lotId, entryType, amount,
      paymentMode, description, balanceAfter, recordedAt, isSynced);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalLedgerData &&
          other.id == this.id &&
          other.collectorId == this.collectorId &&
          other.lotId == this.lotId &&
          other.entryType == this.entryType &&
          other.amount == this.amount &&
          other.paymentMode == this.paymentMode &&
          other.description == this.description &&
          other.balanceAfter == this.balanceAfter &&
          other.recordedAt == this.recordedAt &&
          other.isSynced == this.isSynced);
}

class LocalLedgerCompanion extends UpdateCompanion<LocalLedgerData> {
  final Value<String> id;
  final Value<String> collectorId;
  final Value<String?> lotId;
  final Value<String> entryType;
  final Value<double> amount;
  final Value<String> paymentMode;
  final Value<String> description;
  final Value<double> balanceAfter;
  final Value<DateTime> recordedAt;
  final Value<bool> isSynced;
  final Value<int> rowid;
  const LocalLedgerCompanion({
    this.id = const Value.absent(),
    this.collectorId = const Value.absent(),
    this.lotId = const Value.absent(),
    this.entryType = const Value.absent(),
    this.amount = const Value.absent(),
    this.paymentMode = const Value.absent(),
    this.description = const Value.absent(),
    this.balanceAfter = const Value.absent(),
    this.recordedAt = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalLedgerCompanion.insert({
    required String id,
    required String collectorId,
    this.lotId = const Value.absent(),
    required String entryType,
    required double amount,
    this.paymentMode = const Value.absent(),
    required String description,
    required double balanceAfter,
    required DateTime recordedAt,
    this.isSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        collectorId = Value(collectorId),
        entryType = Value(entryType),
        amount = Value(amount),
        description = Value(description),
        balanceAfter = Value(balanceAfter),
        recordedAt = Value(recordedAt);
  static Insertable<LocalLedgerData> custom({
    Expression<String>? id,
    Expression<String>? collectorId,
    Expression<String>? lotId,
    Expression<String>? entryType,
    Expression<double>? amount,
    Expression<String>? paymentMode,
    Expression<String>? description,
    Expression<double>? balanceAfter,
    Expression<DateTime>? recordedAt,
    Expression<bool>? isSynced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (collectorId != null) 'collector_id': collectorId,
      if (lotId != null) 'lot_id': lotId,
      if (entryType != null) 'entry_type': entryType,
      if (amount != null) 'amount': amount,
      if (paymentMode != null) 'payment_mode': paymentMode,
      if (description != null) 'description': description,
      if (balanceAfter != null) 'balance_after': balanceAfter,
      if (recordedAt != null) 'recorded_at': recordedAt,
      if (isSynced != null) 'is_synced': isSynced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalLedgerCompanion copyWith(
      {Value<String>? id,
      Value<String>? collectorId,
      Value<String?>? lotId,
      Value<String>? entryType,
      Value<double>? amount,
      Value<String>? paymentMode,
      Value<String>? description,
      Value<double>? balanceAfter,
      Value<DateTime>? recordedAt,
      Value<bool>? isSynced,
      Value<int>? rowid}) {
    return LocalLedgerCompanion(
      id: id ?? this.id,
      collectorId: collectorId ?? this.collectorId,
      lotId: lotId ?? this.lotId,
      entryType: entryType ?? this.entryType,
      amount: amount ?? this.amount,
      paymentMode: paymentMode ?? this.paymentMode,
      description: description ?? this.description,
      balanceAfter: balanceAfter ?? this.balanceAfter,
      recordedAt: recordedAt ?? this.recordedAt,
      isSynced: isSynced ?? this.isSynced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (collectorId.present) {
      map['collector_id'] = Variable<String>(collectorId.value);
    }
    if (lotId.present) {
      map['lot_id'] = Variable<String>(lotId.value);
    }
    if (entryType.present) {
      map['entry_type'] = Variable<String>(entryType.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (paymentMode.present) {
      map['payment_mode'] = Variable<String>(paymentMode.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (balanceAfter.present) {
      map['balance_after'] = Variable<double>(balanceAfter.value);
    }
    if (recordedAt.present) {
      map['recorded_at'] = Variable<DateTime>(recordedAt.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalLedgerCompanion(')
          ..write('id: $id, ')
          ..write('collectorId: $collectorId, ')
          ..write('lotId: $lotId, ')
          ..write('entryType: $entryType, ')
          ..write('amount: $amount, ')
          ..write('paymentMode: $paymentMode, ')
          ..write('description: $description, ')
          ..write('balanceAfter: $balanceAfter, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedSafetyContentTable extends CachedSafetyContent
    with TableInfo<$CachedSafetyContentTable, CachedSafetyContentData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedSafetyContentTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _hazardLevelMeta =
      const VerificationMeta('hazardLevel');
  @override
  late final GeneratedColumn<String> hazardLevel = GeneratedColumn<String>(
      'hazard_level', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('info'));
  static const VerificationMeta _pictogramAssetPathMeta =
      const VerificationMeta('pictogramAssetPath');
  @override
  late final GeneratedColumn<String> pictogramAssetPath =
      GeneratedColumn<String>('pictogram_asset_path', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _audioAssetPathMeta =
      const VerificationMeta('audioAssetPath');
  @override
  late final GeneratedColumn<String> audioAssetPath = GeneratedColumn<String>(
      'audio_asset_path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleVernacularMeta =
      const VerificationMeta('titleVernacular');
  @override
  late final GeneratedColumn<String> titleVernacular = GeneratedColumn<String>(
      'title_vernacular', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _instructionsVernacularMeta =
      const VerificationMeta('instructionsVernacular');
  @override
  late final GeneratedColumn<String> instructionsVernacular =
      GeneratedColumn<String>('instructions_vernacular', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dosJsonMeta =
      const VerificationMeta('dosJson');
  @override
  late final GeneratedColumn<String> dosJson = GeneratedColumn<String>(
      'dos_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dontsJsonMeta =
      const VerificationMeta('dontsJson');
  @override
  late final GeneratedColumn<String> dontsJson = GeneratedColumn<String>(
      'donts_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _cachedAtMeta =
      const VerificationMeta('cachedAt');
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
      'cached_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        category,
        hazardLevel,
        pictogramAssetPath,
        audioAssetPath,
        titleVernacular,
        instructionsVernacular,
        dosJson,
        dontsJson,
        cachedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_safety_content';
  @override
  VerificationContext validateIntegrity(
      Insertable<CachedSafetyContentData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('hazard_level')) {
      context.handle(
          _hazardLevelMeta,
          hazardLevel.isAcceptableOrUnknown(
              data['hazard_level']!, _hazardLevelMeta));
    }
    if (data.containsKey('pictogram_asset_path')) {
      context.handle(
          _pictogramAssetPathMeta,
          pictogramAssetPath.isAcceptableOrUnknown(
              data['pictogram_asset_path']!, _pictogramAssetPathMeta));
    } else if (isInserting) {
      context.missing(_pictogramAssetPathMeta);
    }
    if (data.containsKey('audio_asset_path')) {
      context.handle(
          _audioAssetPathMeta,
          audioAssetPath.isAcceptableOrUnknown(
              data['audio_asset_path']!, _audioAssetPathMeta));
    } else if (isInserting) {
      context.missing(_audioAssetPathMeta);
    }
    if (data.containsKey('title_vernacular')) {
      context.handle(
          _titleVernacularMeta,
          titleVernacular.isAcceptableOrUnknown(
              data['title_vernacular']!, _titleVernacularMeta));
    } else if (isInserting) {
      context.missing(_titleVernacularMeta);
    }
    if (data.containsKey('instructions_vernacular')) {
      context.handle(
          _instructionsVernacularMeta,
          instructionsVernacular.isAcceptableOrUnknown(
              data['instructions_vernacular']!, _instructionsVernacularMeta));
    } else if (isInserting) {
      context.missing(_instructionsVernacularMeta);
    }
    if (data.containsKey('dos_json')) {
      context.handle(_dosJsonMeta,
          dosJson.isAcceptableOrUnknown(data['dos_json']!, _dosJsonMeta));
    } else if (isInserting) {
      context.missing(_dosJsonMeta);
    }
    if (data.containsKey('donts_json')) {
      context.handle(_dontsJsonMeta,
          dontsJson.isAcceptableOrUnknown(data['donts_json']!, _dontsJsonMeta));
    } else if (isInserting) {
      context.missing(_dontsJsonMeta);
    }
    if (data.containsKey('cached_at')) {
      context.handle(_cachedAtMeta,
          cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta));
    } else if (isInserting) {
      context.missing(_cachedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedSafetyContentData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedSafetyContentData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      hazardLevel: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}hazard_level'])!,
      pictogramAssetPath: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}pictogram_asset_path'])!,
      audioAssetPath: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}audio_asset_path'])!,
      titleVernacular: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}title_vernacular'])!,
      instructionsVernacular: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}instructions_vernacular'])!,
      dosJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}dos_json'])!,
      dontsJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}donts_json'])!,
      cachedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}cached_at'])!,
    );
  }

  @override
  $CachedSafetyContentTable createAlias(String alias) {
    return $CachedSafetyContentTable(attachedDatabase, alias);
  }
}

class CachedSafetyContentData extends DataClass
    implements Insertable<CachedSafetyContentData> {
  final String id;
  final String category;
  final String hazardLevel;
  final String pictogramAssetPath;
  final String audioAssetPath;
  final String titleVernacular;
  final String instructionsVernacular;
  final String dosJson;
  final String dontsJson;
  final DateTime cachedAt;
  const CachedSafetyContentData(
      {required this.id,
      required this.category,
      required this.hazardLevel,
      required this.pictogramAssetPath,
      required this.audioAssetPath,
      required this.titleVernacular,
      required this.instructionsVernacular,
      required this.dosJson,
      required this.dontsJson,
      required this.cachedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['category'] = Variable<String>(category);
    map['hazard_level'] = Variable<String>(hazardLevel);
    map['pictogram_asset_path'] = Variable<String>(pictogramAssetPath);
    map['audio_asset_path'] = Variable<String>(audioAssetPath);
    map['title_vernacular'] = Variable<String>(titleVernacular);
    map['instructions_vernacular'] = Variable<String>(instructionsVernacular);
    map['dos_json'] = Variable<String>(dosJson);
    map['donts_json'] = Variable<String>(dontsJson);
    map['cached_at'] = Variable<DateTime>(cachedAt);
    return map;
  }

  CachedSafetyContentCompanion toCompanion(bool nullToAbsent) {
    return CachedSafetyContentCompanion(
      id: Value(id),
      category: Value(category),
      hazardLevel: Value(hazardLevel),
      pictogramAssetPath: Value(pictogramAssetPath),
      audioAssetPath: Value(audioAssetPath),
      titleVernacular: Value(titleVernacular),
      instructionsVernacular: Value(instructionsVernacular),
      dosJson: Value(dosJson),
      dontsJson: Value(dontsJson),
      cachedAt: Value(cachedAt),
    );
  }

  factory CachedSafetyContentData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedSafetyContentData(
      id: serializer.fromJson<String>(json['id']),
      category: serializer.fromJson<String>(json['category']),
      hazardLevel: serializer.fromJson<String>(json['hazardLevel']),
      pictogramAssetPath:
          serializer.fromJson<String>(json['pictogramAssetPath']),
      audioAssetPath: serializer.fromJson<String>(json['audioAssetPath']),
      titleVernacular: serializer.fromJson<String>(json['titleVernacular']),
      instructionsVernacular:
          serializer.fromJson<String>(json['instructionsVernacular']),
      dosJson: serializer.fromJson<String>(json['dosJson']),
      dontsJson: serializer.fromJson<String>(json['dontsJson']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'category': serializer.toJson<String>(category),
      'hazardLevel': serializer.toJson<String>(hazardLevel),
      'pictogramAssetPath': serializer.toJson<String>(pictogramAssetPath),
      'audioAssetPath': serializer.toJson<String>(audioAssetPath),
      'titleVernacular': serializer.toJson<String>(titleVernacular),
      'instructionsVernacular':
          serializer.toJson<String>(instructionsVernacular),
      'dosJson': serializer.toJson<String>(dosJson),
      'dontsJson': serializer.toJson<String>(dontsJson),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
    };
  }

  CachedSafetyContentData copyWith(
          {String? id,
          String? category,
          String? hazardLevel,
          String? pictogramAssetPath,
          String? audioAssetPath,
          String? titleVernacular,
          String? instructionsVernacular,
          String? dosJson,
          String? dontsJson,
          DateTime? cachedAt}) =>
      CachedSafetyContentData(
        id: id ?? this.id,
        category: category ?? this.category,
        hazardLevel: hazardLevel ?? this.hazardLevel,
        pictogramAssetPath: pictogramAssetPath ?? this.pictogramAssetPath,
        audioAssetPath: audioAssetPath ?? this.audioAssetPath,
        titleVernacular: titleVernacular ?? this.titleVernacular,
        instructionsVernacular:
            instructionsVernacular ?? this.instructionsVernacular,
        dosJson: dosJson ?? this.dosJson,
        dontsJson: dontsJson ?? this.dontsJson,
        cachedAt: cachedAt ?? this.cachedAt,
      );
  CachedSafetyContentData copyWithCompanion(CachedSafetyContentCompanion data) {
    return CachedSafetyContentData(
      id: data.id.present ? data.id.value : this.id,
      category: data.category.present ? data.category.value : this.category,
      hazardLevel:
          data.hazardLevel.present ? data.hazardLevel.value : this.hazardLevel,
      pictogramAssetPath: data.pictogramAssetPath.present
          ? data.pictogramAssetPath.value
          : this.pictogramAssetPath,
      audioAssetPath: data.audioAssetPath.present
          ? data.audioAssetPath.value
          : this.audioAssetPath,
      titleVernacular: data.titleVernacular.present
          ? data.titleVernacular.value
          : this.titleVernacular,
      instructionsVernacular: data.instructionsVernacular.present
          ? data.instructionsVernacular.value
          : this.instructionsVernacular,
      dosJson: data.dosJson.present ? data.dosJson.value : this.dosJson,
      dontsJson: data.dontsJson.present ? data.dontsJson.value : this.dontsJson,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedSafetyContentData(')
          ..write('id: $id, ')
          ..write('category: $category, ')
          ..write('hazardLevel: $hazardLevel, ')
          ..write('pictogramAssetPath: $pictogramAssetPath, ')
          ..write('audioAssetPath: $audioAssetPath, ')
          ..write('titleVernacular: $titleVernacular, ')
          ..write('instructionsVernacular: $instructionsVernacular, ')
          ..write('dosJson: $dosJson, ')
          ..write('dontsJson: $dontsJson, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      category,
      hazardLevel,
      pictogramAssetPath,
      audioAssetPath,
      titleVernacular,
      instructionsVernacular,
      dosJson,
      dontsJson,
      cachedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedSafetyContentData &&
          other.id == this.id &&
          other.category == this.category &&
          other.hazardLevel == this.hazardLevel &&
          other.pictogramAssetPath == this.pictogramAssetPath &&
          other.audioAssetPath == this.audioAssetPath &&
          other.titleVernacular == this.titleVernacular &&
          other.instructionsVernacular == this.instructionsVernacular &&
          other.dosJson == this.dosJson &&
          other.dontsJson == this.dontsJson &&
          other.cachedAt == this.cachedAt);
}

class CachedSafetyContentCompanion
    extends UpdateCompanion<CachedSafetyContentData> {
  final Value<String> id;
  final Value<String> category;
  final Value<String> hazardLevel;
  final Value<String> pictogramAssetPath;
  final Value<String> audioAssetPath;
  final Value<String> titleVernacular;
  final Value<String> instructionsVernacular;
  final Value<String> dosJson;
  final Value<String> dontsJson;
  final Value<DateTime> cachedAt;
  final Value<int> rowid;
  const CachedSafetyContentCompanion({
    this.id = const Value.absent(),
    this.category = const Value.absent(),
    this.hazardLevel = const Value.absent(),
    this.pictogramAssetPath = const Value.absent(),
    this.audioAssetPath = const Value.absent(),
    this.titleVernacular = const Value.absent(),
    this.instructionsVernacular = const Value.absent(),
    this.dosJson = const Value.absent(),
    this.dontsJson = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedSafetyContentCompanion.insert({
    required String id,
    required String category,
    this.hazardLevel = const Value.absent(),
    required String pictogramAssetPath,
    required String audioAssetPath,
    required String titleVernacular,
    required String instructionsVernacular,
    required String dosJson,
    required String dontsJson,
    required DateTime cachedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        category = Value(category),
        pictogramAssetPath = Value(pictogramAssetPath),
        audioAssetPath = Value(audioAssetPath),
        titleVernacular = Value(titleVernacular),
        instructionsVernacular = Value(instructionsVernacular),
        dosJson = Value(dosJson),
        dontsJson = Value(dontsJson),
        cachedAt = Value(cachedAt);
  static Insertable<CachedSafetyContentData> custom({
    Expression<String>? id,
    Expression<String>? category,
    Expression<String>? hazardLevel,
    Expression<String>? pictogramAssetPath,
    Expression<String>? audioAssetPath,
    Expression<String>? titleVernacular,
    Expression<String>? instructionsVernacular,
    Expression<String>? dosJson,
    Expression<String>? dontsJson,
    Expression<DateTime>? cachedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (category != null) 'category': category,
      if (hazardLevel != null) 'hazard_level': hazardLevel,
      if (pictogramAssetPath != null)
        'pictogram_asset_path': pictogramAssetPath,
      if (audioAssetPath != null) 'audio_asset_path': audioAssetPath,
      if (titleVernacular != null) 'title_vernacular': titleVernacular,
      if (instructionsVernacular != null)
        'instructions_vernacular': instructionsVernacular,
      if (dosJson != null) 'dos_json': dosJson,
      if (dontsJson != null) 'donts_json': dontsJson,
      if (cachedAt != null) 'cached_at': cachedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedSafetyContentCompanion copyWith(
      {Value<String>? id,
      Value<String>? category,
      Value<String>? hazardLevel,
      Value<String>? pictogramAssetPath,
      Value<String>? audioAssetPath,
      Value<String>? titleVernacular,
      Value<String>? instructionsVernacular,
      Value<String>? dosJson,
      Value<String>? dontsJson,
      Value<DateTime>? cachedAt,
      Value<int>? rowid}) {
    return CachedSafetyContentCompanion(
      id: id ?? this.id,
      category: category ?? this.category,
      hazardLevel: hazardLevel ?? this.hazardLevel,
      pictogramAssetPath: pictogramAssetPath ?? this.pictogramAssetPath,
      audioAssetPath: audioAssetPath ?? this.audioAssetPath,
      titleVernacular: titleVernacular ?? this.titleVernacular,
      instructionsVernacular:
          instructionsVernacular ?? this.instructionsVernacular,
      dosJson: dosJson ?? this.dosJson,
      dontsJson: dontsJson ?? this.dontsJson,
      cachedAt: cachedAt ?? this.cachedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (hazardLevel.present) {
      map['hazard_level'] = Variable<String>(hazardLevel.value);
    }
    if (pictogramAssetPath.present) {
      map['pictogram_asset_path'] = Variable<String>(pictogramAssetPath.value);
    }
    if (audioAssetPath.present) {
      map['audio_asset_path'] = Variable<String>(audioAssetPath.value);
    }
    if (titleVernacular.present) {
      map['title_vernacular'] = Variable<String>(titleVernacular.value);
    }
    if (instructionsVernacular.present) {
      map['instructions_vernacular'] =
          Variable<String>(instructionsVernacular.value);
    }
    if (dosJson.present) {
      map['dos_json'] = Variable<String>(dosJson.value);
    }
    if (dontsJson.present) {
      map['donts_json'] = Variable<String>(dontsJson.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedSafetyContentCompanion(')
          ..write('id: $id, ')
          ..write('category: $category, ')
          ..write('hazardLevel: $hazardLevel, ')
          ..write('pictogramAssetPath: $pictogramAssetPath, ')
          ..write('audioAssetPath: $audioAssetPath, ')
          ..write('titleVernacular: $titleVernacular, ')
          ..write('instructionsVernacular: $instructionsVernacular, ')
          ..write('dosJson: $dosJson, ')
          ..write('dontsJson: $dontsJson, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncQueueEntriesTable extends SyncQueueEntries
    with TableInfo<$SyncQueueEntriesTable, SyncQueueEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncQueueEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _clientTxIdMeta =
      const VerificationMeta('clientTxId');
  @override
  late final GeneratedColumn<String> clientTxId = GeneratedColumn<String>(
      'client_tx_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _collectorIdMeta =
      const VerificationMeta('collectorId');
  @override
  late final GeneratedColumn<String> collectorId = GeneratedColumn<String>(
      'collector_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
      'action', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _payloadJsonMeta =
      const VerificationMeta('payloadJson');
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
      'payload_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _retryAttemptsMeta =
      const VerificationMeta('retryAttempts');
  @override
  late final GeneratedColumn<int> retryAttempts = GeneratedColumn<int>(
      'retry_attempts', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _lastErrorMeta =
      const VerificationMeta('lastError');
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
      'last_error', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _clientTimestampMeta =
      const VerificationMeta('clientTimestamp');
  @override
  late final GeneratedColumn<DateTime> clientTimestamp =
      GeneratedColumn<DateTime>('client_timestamp', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        clientTxId,
        collectorId,
        action,
        payloadJson,
        status,
        retryAttempts,
        lastError,
        clientTimestamp,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_queue_entries';
  @override
  VerificationContext validateIntegrity(Insertable<SyncQueueEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('client_tx_id')) {
      context.handle(
          _clientTxIdMeta,
          clientTxId.isAcceptableOrUnknown(
              data['client_tx_id']!, _clientTxIdMeta));
    } else if (isInserting) {
      context.missing(_clientTxIdMeta);
    }
    if (data.containsKey('collector_id')) {
      context.handle(
          _collectorIdMeta,
          collectorId.isAcceptableOrUnknown(
              data['collector_id']!, _collectorIdMeta));
    } else if (isInserting) {
      context.missing(_collectorIdMeta);
    }
    if (data.containsKey('action')) {
      context.handle(_actionMeta,
          action.isAcceptableOrUnknown(data['action']!, _actionMeta));
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
          _payloadJsonMeta,
          payloadJson.isAcceptableOrUnknown(
              data['payload_json']!, _payloadJsonMeta));
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('retry_attempts')) {
      context.handle(
          _retryAttemptsMeta,
          retryAttempts.isAcceptableOrUnknown(
              data['retry_attempts']!, _retryAttemptsMeta));
    }
    if (data.containsKey('last_error')) {
      context.handle(_lastErrorMeta,
          lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta));
    }
    if (data.containsKey('client_timestamp')) {
      context.handle(
          _clientTimestampMeta,
          clientTimestamp.isAcceptableOrUnknown(
              data['client_timestamp']!, _clientTimestampMeta));
    } else if (isInserting) {
      context.missing(_clientTimestampMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {clientTxId};
  @override
  SyncQueueEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncQueueEntry(
      clientTxId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}client_tx_id'])!,
      collectorId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}collector_id'])!,
      action: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}action'])!,
      payloadJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload_json'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      retryAttempts: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}retry_attempts'])!,
      lastError: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}last_error']),
      clientTimestamp: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}client_timestamp'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $SyncQueueEntriesTable createAlias(String alias) {
    return $SyncQueueEntriesTable(attachedDatabase, alias);
  }
}

class SyncQueueEntry extends DataClass implements Insertable<SyncQueueEntry> {
  final String clientTxId;
  final String collectorId;
  final String action;
  final String payloadJson;
  final String status;
  final int retryAttempts;
  final String? lastError;
  final DateTime clientTimestamp;
  final DateTime createdAt;
  const SyncQueueEntry(
      {required this.clientTxId,
      required this.collectorId,
      required this.action,
      required this.payloadJson,
      required this.status,
      required this.retryAttempts,
      this.lastError,
      required this.clientTimestamp,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['client_tx_id'] = Variable<String>(clientTxId);
    map['collector_id'] = Variable<String>(collectorId);
    map['action'] = Variable<String>(action);
    map['payload_json'] = Variable<String>(payloadJson);
    map['status'] = Variable<String>(status);
    map['retry_attempts'] = Variable<int>(retryAttempts);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    map['client_timestamp'] = Variable<DateTime>(clientTimestamp);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SyncQueueEntriesCompanion toCompanion(bool nullToAbsent) {
    return SyncQueueEntriesCompanion(
      clientTxId: Value(clientTxId),
      collectorId: Value(collectorId),
      action: Value(action),
      payloadJson: Value(payloadJson),
      status: Value(status),
      retryAttempts: Value(retryAttempts),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      clientTimestamp: Value(clientTimestamp),
      createdAt: Value(createdAt),
    );
  }

  factory SyncQueueEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncQueueEntry(
      clientTxId: serializer.fromJson<String>(json['clientTxId']),
      collectorId: serializer.fromJson<String>(json['collectorId']),
      action: serializer.fromJson<String>(json['action']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      status: serializer.fromJson<String>(json['status']),
      retryAttempts: serializer.fromJson<int>(json['retryAttempts']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      clientTimestamp: serializer.fromJson<DateTime>(json['clientTimestamp']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'clientTxId': serializer.toJson<String>(clientTxId),
      'collectorId': serializer.toJson<String>(collectorId),
      'action': serializer.toJson<String>(action),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'status': serializer.toJson<String>(status),
      'retryAttempts': serializer.toJson<int>(retryAttempts),
      'lastError': serializer.toJson<String?>(lastError),
      'clientTimestamp': serializer.toJson<DateTime>(clientTimestamp),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SyncQueueEntry copyWith(
          {String? clientTxId,
          String? collectorId,
          String? action,
          String? payloadJson,
          String? status,
          int? retryAttempts,
          Value<String?> lastError = const Value.absent(),
          DateTime? clientTimestamp,
          DateTime? createdAt}) =>
      SyncQueueEntry(
        clientTxId: clientTxId ?? this.clientTxId,
        collectorId: collectorId ?? this.collectorId,
        action: action ?? this.action,
        payloadJson: payloadJson ?? this.payloadJson,
        status: status ?? this.status,
        retryAttempts: retryAttempts ?? this.retryAttempts,
        lastError: lastError.present ? lastError.value : this.lastError,
        clientTimestamp: clientTimestamp ?? this.clientTimestamp,
        createdAt: createdAt ?? this.createdAt,
      );
  SyncQueueEntry copyWithCompanion(SyncQueueEntriesCompanion data) {
    return SyncQueueEntry(
      clientTxId:
          data.clientTxId.present ? data.clientTxId.value : this.clientTxId,
      collectorId:
          data.collectorId.present ? data.collectorId.value : this.collectorId,
      action: data.action.present ? data.action.value : this.action,
      payloadJson:
          data.payloadJson.present ? data.payloadJson.value : this.payloadJson,
      status: data.status.present ? data.status.value : this.status,
      retryAttempts: data.retryAttempts.present
          ? data.retryAttempts.value
          : this.retryAttempts,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      clientTimestamp: data.clientTimestamp.present
          ? data.clientTimestamp.value
          : this.clientTimestamp,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueEntry(')
          ..write('clientTxId: $clientTxId, ')
          ..write('collectorId: $collectorId, ')
          ..write('action: $action, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('status: $status, ')
          ..write('retryAttempts: $retryAttempts, ')
          ..write('lastError: $lastError, ')
          ..write('clientTimestamp: $clientTimestamp, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(clientTxId, collectorId, action, payloadJson,
      status, retryAttempts, lastError, clientTimestamp, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncQueueEntry &&
          other.clientTxId == this.clientTxId &&
          other.collectorId == this.collectorId &&
          other.action == this.action &&
          other.payloadJson == this.payloadJson &&
          other.status == this.status &&
          other.retryAttempts == this.retryAttempts &&
          other.lastError == this.lastError &&
          other.clientTimestamp == this.clientTimestamp &&
          other.createdAt == this.createdAt);
}

class SyncQueueEntriesCompanion extends UpdateCompanion<SyncQueueEntry> {
  final Value<String> clientTxId;
  final Value<String> collectorId;
  final Value<String> action;
  final Value<String> payloadJson;
  final Value<String> status;
  final Value<int> retryAttempts;
  final Value<String?> lastError;
  final Value<DateTime> clientTimestamp;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const SyncQueueEntriesCompanion({
    this.clientTxId = const Value.absent(),
    this.collectorId = const Value.absent(),
    this.action = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.status = const Value.absent(),
    this.retryAttempts = const Value.absent(),
    this.lastError = const Value.absent(),
    this.clientTimestamp = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncQueueEntriesCompanion.insert({
    required String clientTxId,
    required String collectorId,
    required String action,
    required String payloadJson,
    this.status = const Value.absent(),
    this.retryAttempts = const Value.absent(),
    this.lastError = const Value.absent(),
    required DateTime clientTimestamp,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : clientTxId = Value(clientTxId),
        collectorId = Value(collectorId),
        action = Value(action),
        payloadJson = Value(payloadJson),
        clientTimestamp = Value(clientTimestamp),
        createdAt = Value(createdAt);
  static Insertable<SyncQueueEntry> custom({
    Expression<String>? clientTxId,
    Expression<String>? collectorId,
    Expression<String>? action,
    Expression<String>? payloadJson,
    Expression<String>? status,
    Expression<int>? retryAttempts,
    Expression<String>? lastError,
    Expression<DateTime>? clientTimestamp,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (clientTxId != null) 'client_tx_id': clientTxId,
      if (collectorId != null) 'collector_id': collectorId,
      if (action != null) 'action': action,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (status != null) 'status': status,
      if (retryAttempts != null) 'retry_attempts': retryAttempts,
      if (lastError != null) 'last_error': lastError,
      if (clientTimestamp != null) 'client_timestamp': clientTimestamp,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncQueueEntriesCompanion copyWith(
      {Value<String>? clientTxId,
      Value<String>? collectorId,
      Value<String>? action,
      Value<String>? payloadJson,
      Value<String>? status,
      Value<int>? retryAttempts,
      Value<String?>? lastError,
      Value<DateTime>? clientTimestamp,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return SyncQueueEntriesCompanion(
      clientTxId: clientTxId ?? this.clientTxId,
      collectorId: collectorId ?? this.collectorId,
      action: action ?? this.action,
      payloadJson: payloadJson ?? this.payloadJson,
      status: status ?? this.status,
      retryAttempts: retryAttempts ?? this.retryAttempts,
      lastError: lastError ?? this.lastError,
      clientTimestamp: clientTimestamp ?? this.clientTimestamp,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (clientTxId.present) {
      map['client_tx_id'] = Variable<String>(clientTxId.value);
    }
    if (collectorId.present) {
      map['collector_id'] = Variable<String>(collectorId.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (retryAttempts.present) {
      map['retry_attempts'] = Variable<int>(retryAttempts.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (clientTimestamp.present) {
      map['client_timestamp'] = Variable<DateTime>(clientTimestamp.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueEntriesCompanion(')
          ..write('clientTxId: $clientTxId, ')
          ..write('collectorId: $collectorId, ')
          ..write('action: $action, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('status: $status, ')
          ..write('retryAttempts: $retryAttempts, ')
          ..write('lastError: $lastError, ')
          ..write('clientTimestamp: $clientTimestamp, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalMLSamplesTable extends LocalMLSamples
    with TableInfo<$LocalMLSamplesTable, LocalMLSample> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalMLSamplesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _localImagePathMeta =
      const VerificationMeta('localImagePath');
  @override
  late final GeneratedColumn<String> localImagePath = GeneratedColumn<String>(
      'local_image_path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
      'label', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _weightKgMeta =
      const VerificationMeta('weightKg');
  @override
  late final GeneratedColumn<double> weightKg = GeneratedColumn<double>(
      'weight_kg', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _priceMeta = const VerificationMeta('price');
  @override
  late final GeneratedColumn<double> price = GeneratedColumn<double>(
      'price', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _latitudeMeta =
      const VerificationMeta('latitude');
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
      'latitude', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _longitudeMeta =
      const VerificationMeta('longitude');
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
      'longitude', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
      'source', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('field'));
  static const VerificationMeta _qualityScoreMeta =
      const VerificationMeta('qualityScore');
  @override
  late final GeneratedColumn<double> qualityScore = GeneratedColumn<double>(
      'quality_score', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(1.0));
  static const VerificationMeta _isUploadedMeta =
      const VerificationMeta('isUploaded');
  @override
  late final GeneratedColumn<bool> isUploaded = GeneratedColumn<bool>(
      'is_uploaded', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_uploaded" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        localImagePath,
        label,
        weightKg,
        price,
        latitude,
        longitude,
        source,
        qualityScore,
        isUploaded,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_m_l_samples';
  @override
  VerificationContext validateIntegrity(Insertable<LocalMLSample> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('local_image_path')) {
      context.handle(
          _localImagePathMeta,
          localImagePath.isAcceptableOrUnknown(
              data['local_image_path']!, _localImagePathMeta));
    } else if (isInserting) {
      context.missing(_localImagePathMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
          _labelMeta, label.isAcceptableOrUnknown(data['label']!, _labelMeta));
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('weight_kg')) {
      context.handle(_weightKgMeta,
          weightKg.isAcceptableOrUnknown(data['weight_kg']!, _weightKgMeta));
    }
    if (data.containsKey('price')) {
      context.handle(
          _priceMeta, price.isAcceptableOrUnknown(data['price']!, _priceMeta));
    }
    if (data.containsKey('latitude')) {
      context.handle(_latitudeMeta,
          latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta));
    }
    if (data.containsKey('longitude')) {
      context.handle(_longitudeMeta,
          longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta));
    }
    if (data.containsKey('source')) {
      context.handle(_sourceMeta,
          source.isAcceptableOrUnknown(data['source']!, _sourceMeta));
    }
    if (data.containsKey('quality_score')) {
      context.handle(
          _qualityScoreMeta,
          qualityScore.isAcceptableOrUnknown(
              data['quality_score']!, _qualityScoreMeta));
    }
    if (data.containsKey('is_uploaded')) {
      context.handle(
          _isUploadedMeta,
          isUploaded.isAcceptableOrUnknown(
              data['is_uploaded']!, _isUploadedMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalMLSample map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalMLSample(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      localImagePath: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}local_image_path'])!,
      label: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}label'])!,
      weightKg: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}weight_kg']),
      price: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}price']),
      latitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}latitude']),
      longitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}longitude']),
      source: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source'])!,
      qualityScore: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}quality_score'])!,
      isUploaded: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_uploaded'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $LocalMLSamplesTable createAlias(String alias) {
    return $LocalMLSamplesTable(attachedDatabase, alias);
  }
}

class LocalMLSample extends DataClass implements Insertable<LocalMLSample> {
  final String id;
  final String localImagePath;
  final String label;
  final double? weightKg;
  final double? price;
  final double? latitude;
  final double? longitude;
  final String source;
  final double qualityScore;
  final bool isUploaded;
  final DateTime createdAt;
  const LocalMLSample(
      {required this.id,
      required this.localImagePath,
      required this.label,
      this.weightKg,
      this.price,
      this.latitude,
      this.longitude,
      required this.source,
      required this.qualityScore,
      required this.isUploaded,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['local_image_path'] = Variable<String>(localImagePath);
    map['label'] = Variable<String>(label);
    if (!nullToAbsent || weightKg != null) {
      map['weight_kg'] = Variable<double>(weightKg);
    }
    if (!nullToAbsent || price != null) {
      map['price'] = Variable<double>(price);
    }
    if (!nullToAbsent || latitude != null) {
      map['latitude'] = Variable<double>(latitude);
    }
    if (!nullToAbsent || longitude != null) {
      map['longitude'] = Variable<double>(longitude);
    }
    map['source'] = Variable<String>(source);
    map['quality_score'] = Variable<double>(qualityScore);
    map['is_uploaded'] = Variable<bool>(isUploaded);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  LocalMLSamplesCompanion toCompanion(bool nullToAbsent) {
    return LocalMLSamplesCompanion(
      id: Value(id),
      localImagePath: Value(localImagePath),
      label: Value(label),
      weightKg: weightKg == null && nullToAbsent
          ? const Value.absent()
          : Value(weightKg),
      price:
          price == null && nullToAbsent ? const Value.absent() : Value(price),
      latitude: latitude == null && nullToAbsent
          ? const Value.absent()
          : Value(latitude),
      longitude: longitude == null && nullToAbsent
          ? const Value.absent()
          : Value(longitude),
      source: Value(source),
      qualityScore: Value(qualityScore),
      isUploaded: Value(isUploaded),
      createdAt: Value(createdAt),
    );
  }

  factory LocalMLSample.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalMLSample(
      id: serializer.fromJson<String>(json['id']),
      localImagePath: serializer.fromJson<String>(json['localImagePath']),
      label: serializer.fromJson<String>(json['label']),
      weightKg: serializer.fromJson<double?>(json['weightKg']),
      price: serializer.fromJson<double?>(json['price']),
      latitude: serializer.fromJson<double?>(json['latitude']),
      longitude: serializer.fromJson<double?>(json['longitude']),
      source: serializer.fromJson<String>(json['source']),
      qualityScore: serializer.fromJson<double>(json['qualityScore']),
      isUploaded: serializer.fromJson<bool>(json['isUploaded']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'localImagePath': serializer.toJson<String>(localImagePath),
      'label': serializer.toJson<String>(label),
      'weightKg': serializer.toJson<double?>(weightKg),
      'price': serializer.toJson<double?>(price),
      'latitude': serializer.toJson<double?>(latitude),
      'longitude': serializer.toJson<double?>(longitude),
      'source': serializer.toJson<String>(source),
      'qualityScore': serializer.toJson<double>(qualityScore),
      'isUploaded': serializer.toJson<bool>(isUploaded),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  LocalMLSample copyWith(
          {String? id,
          String? localImagePath,
          String? label,
          Value<double?> weightKg = const Value.absent(),
          Value<double?> price = const Value.absent(),
          Value<double?> latitude = const Value.absent(),
          Value<double?> longitude = const Value.absent(),
          String? source,
          double? qualityScore,
          bool? isUploaded,
          DateTime? createdAt}) =>
      LocalMLSample(
        id: id ?? this.id,
        localImagePath: localImagePath ?? this.localImagePath,
        label: label ?? this.label,
        weightKg: weightKg.present ? weightKg.value : this.weightKg,
        price: price.present ? price.value : this.price,
        latitude: latitude.present ? latitude.value : this.latitude,
        longitude: longitude.present ? longitude.value : this.longitude,
        source: source ?? this.source,
        qualityScore: qualityScore ?? this.qualityScore,
        isUploaded: isUploaded ?? this.isUploaded,
        createdAt: createdAt ?? this.createdAt,
      );
  LocalMLSample copyWithCompanion(LocalMLSamplesCompanion data) {
    return LocalMLSample(
      id: data.id.present ? data.id.value : this.id,
      localImagePath: data.localImagePath.present
          ? data.localImagePath.value
          : this.localImagePath,
      label: data.label.present ? data.label.value : this.label,
      weightKg: data.weightKg.present ? data.weightKg.value : this.weightKg,
      price: data.price.present ? data.price.value : this.price,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      source: data.source.present ? data.source.value : this.source,
      qualityScore: data.qualityScore.present
          ? data.qualityScore.value
          : this.qualityScore,
      isUploaded:
          data.isUploaded.present ? data.isUploaded.value : this.isUploaded,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalMLSample(')
          ..write('id: $id, ')
          ..write('localImagePath: $localImagePath, ')
          ..write('label: $label, ')
          ..write('weightKg: $weightKg, ')
          ..write('price: $price, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('source: $source, ')
          ..write('qualityScore: $qualityScore, ')
          ..write('isUploaded: $isUploaded, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, localImagePath, label, weightKg, price,
      latitude, longitude, source, qualityScore, isUploaded, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalMLSample &&
          other.id == this.id &&
          other.localImagePath == this.localImagePath &&
          other.label == this.label &&
          other.weightKg == this.weightKg &&
          other.price == this.price &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.source == this.source &&
          other.qualityScore == this.qualityScore &&
          other.isUploaded == this.isUploaded &&
          other.createdAt == this.createdAt);
}

class LocalMLSamplesCompanion extends UpdateCompanion<LocalMLSample> {
  final Value<String> id;
  final Value<String> localImagePath;
  final Value<String> label;
  final Value<double?> weightKg;
  final Value<double?> price;
  final Value<double?> latitude;
  final Value<double?> longitude;
  final Value<String> source;
  final Value<double> qualityScore;
  final Value<bool> isUploaded;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const LocalMLSamplesCompanion({
    this.id = const Value.absent(),
    this.localImagePath = const Value.absent(),
    this.label = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.price = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.source = const Value.absent(),
    this.qualityScore = const Value.absent(),
    this.isUploaded = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalMLSamplesCompanion.insert({
    required String id,
    required String localImagePath,
    required String label,
    this.weightKg = const Value.absent(),
    this.price = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.source = const Value.absent(),
    this.qualityScore = const Value.absent(),
    this.isUploaded = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        localImagePath = Value(localImagePath),
        label = Value(label),
        createdAt = Value(createdAt);
  static Insertable<LocalMLSample> custom({
    Expression<String>? id,
    Expression<String>? localImagePath,
    Expression<String>? label,
    Expression<double>? weightKg,
    Expression<double>? price,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<String>? source,
    Expression<double>? qualityScore,
    Expression<bool>? isUploaded,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (localImagePath != null) 'local_image_path': localImagePath,
      if (label != null) 'label': label,
      if (weightKg != null) 'weight_kg': weightKg,
      if (price != null) 'price': price,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (source != null) 'source': source,
      if (qualityScore != null) 'quality_score': qualityScore,
      if (isUploaded != null) 'is_uploaded': isUploaded,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalMLSamplesCompanion copyWith(
      {Value<String>? id,
      Value<String>? localImagePath,
      Value<String>? label,
      Value<double?>? weightKg,
      Value<double?>? price,
      Value<double?>? latitude,
      Value<double?>? longitude,
      Value<String>? source,
      Value<double>? qualityScore,
      Value<bool>? isUploaded,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return LocalMLSamplesCompanion(
      id: id ?? this.id,
      localImagePath: localImagePath ?? this.localImagePath,
      label: label ?? this.label,
      weightKg: weightKg ?? this.weightKg,
      price: price ?? this.price,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      source: source ?? this.source,
      qualityScore: qualityScore ?? this.qualityScore,
      isUploaded: isUploaded ?? this.isUploaded,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (localImagePath.present) {
      map['local_image_path'] = Variable<String>(localImagePath.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (weightKg.present) {
      map['weight_kg'] = Variable<double>(weightKg.value);
    }
    if (price.present) {
      map['price'] = Variable<double>(price.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (qualityScore.present) {
      map['quality_score'] = Variable<double>(qualityScore.value);
    }
    if (isUploaded.present) {
      map['is_uploaded'] = Variable<bool>(isUploaded.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalMLSamplesCompanion(')
          ..write('id: $id, ')
          ..write('localImagePath: $localImagePath, ')
          ..write('label: $label, ')
          ..write('weightKg: $weightKg, ')
          ..write('price: $price, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('source: $source, ')
          ..write('qualityScore: $qualityScore, ')
          ..write('isUploaded: $isUploaded, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LocalMaterialsTable localMaterials = $LocalMaterialsTable(this);
  late final $CachedPricesTable cachedPrices = $CachedPricesTable(this);
  late final $CachedRecyclersTable cachedRecyclers =
      $CachedRecyclersTable(this);
  late final $LocalTransactionsTable localTransactions =
      $LocalTransactionsTable(this);
  late final $LocalTraceabilityTable localTraceability =
      $LocalTraceabilityTable(this);
  late final $CollectorProfileTable collectorProfile =
      $CollectorProfileTable(this);
  late final $LocalLedgerTable localLedger = $LocalLedgerTable(this);
  late final $CachedSafetyContentTable cachedSafetyContent =
      $CachedSafetyContentTable(this);
  late final $SyncQueueEntriesTable syncQueueEntries =
      $SyncQueueEntriesTable(this);
  late final $LocalMLSamplesTable localMLSamples = $LocalMLSamplesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        localMaterials,
        cachedPrices,
        cachedRecyclers,
        localTransactions,
        localTraceability,
        collectorProfile,
        localLedger,
        cachedSafetyContent,
        syncQueueEntries,
        localMLSamples
      ];
}

typedef $$LocalMaterialsTableCreateCompanionBuilder = LocalMaterialsCompanion
    Function({
  required String id,
  required String category,
  required String subCategory,
  required String description,
  Value<String?> imageRef,
  required double approxWeightKg,
  required String condition,
  required String sourceType,
  required double estimatedValue,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$LocalMaterialsTableUpdateCompanionBuilder = LocalMaterialsCompanion
    Function({
  Value<String> id,
  Value<String> category,
  Value<String> subCategory,
  Value<String> description,
  Value<String?> imageRef,
  Value<double> approxWeightKg,
  Value<String> condition,
  Value<String> sourceType,
  Value<double> estimatedValue,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$LocalMaterialsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalMaterialsTable> {
  $$LocalMaterialsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get subCategory => $composableBuilder(
      column: $table.subCategory, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get imageRef => $composableBuilder(
      column: $table.imageRef, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get approxWeightKg => $composableBuilder(
      column: $table.approxWeightKg,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get condition => $composableBuilder(
      column: $table.condition, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sourceType => $composableBuilder(
      column: $table.sourceType, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get estimatedValue => $composableBuilder(
      column: $table.estimatedValue,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$LocalMaterialsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalMaterialsTable> {
  $$LocalMaterialsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get subCategory => $composableBuilder(
      column: $table.subCategory, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imageRef => $composableBuilder(
      column: $table.imageRef, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get approxWeightKg => $composableBuilder(
      column: $table.approxWeightKg,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get condition => $composableBuilder(
      column: $table.condition, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sourceType => $composableBuilder(
      column: $table.sourceType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get estimatedValue => $composableBuilder(
      column: $table.estimatedValue,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$LocalMaterialsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalMaterialsTable> {
  $$LocalMaterialsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get subCategory => $composableBuilder(
      column: $table.subCategory, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get imageRef =>
      $composableBuilder(column: $table.imageRef, builder: (column) => column);

  GeneratedColumn<double> get approxWeightKg => $composableBuilder(
      column: $table.approxWeightKg, builder: (column) => column);

  GeneratedColumn<String> get condition =>
      $composableBuilder(column: $table.condition, builder: (column) => column);

  GeneratedColumn<String> get sourceType => $composableBuilder(
      column: $table.sourceType, builder: (column) => column);

  GeneratedColumn<double> get estimatedValue => $composableBuilder(
      column: $table.estimatedValue, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LocalMaterialsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LocalMaterialsTable,
    LocalMaterial,
    $$LocalMaterialsTableFilterComposer,
    $$LocalMaterialsTableOrderingComposer,
    $$LocalMaterialsTableAnnotationComposer,
    $$LocalMaterialsTableCreateCompanionBuilder,
    $$LocalMaterialsTableUpdateCompanionBuilder,
    (
      LocalMaterial,
      BaseReferences<_$AppDatabase, $LocalMaterialsTable, LocalMaterial>
    ),
    LocalMaterial,
    PrefetchHooks Function()> {
  $$LocalMaterialsTableTableManager(
      _$AppDatabase db, $LocalMaterialsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalMaterialsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalMaterialsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalMaterialsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<String> subCategory = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<String?> imageRef = const Value.absent(),
            Value<double> approxWeightKg = const Value.absent(),
            Value<String> condition = const Value.absent(),
            Value<String> sourceType = const Value.absent(),
            Value<double> estimatedValue = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalMaterialsCompanion(
            id: id,
            category: category,
            subCategory: subCategory,
            description: description,
            imageRef: imageRef,
            approxWeightKg: approxWeightKg,
            condition: condition,
            sourceType: sourceType,
            estimatedValue: estimatedValue,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String category,
            required String subCategory,
            required String description,
            Value<String?> imageRef = const Value.absent(),
            required double approxWeightKg,
            required String condition,
            required String sourceType,
            required double estimatedValue,
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalMaterialsCompanion.insert(
            id: id,
            category: category,
            subCategory: subCategory,
            description: description,
            imageRef: imageRef,
            approxWeightKg: approxWeightKg,
            condition: condition,
            sourceType: sourceType,
            estimatedValue: estimatedValue,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$LocalMaterialsTable, LocalMaterial>(table),
                    BaseReferences<_$AppDatabase, $LocalMaterialsTable,
                        LocalMaterial>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LocalMaterialsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LocalMaterialsTable,
    LocalMaterial,
    $$LocalMaterialsTableFilterComposer,
    $$LocalMaterialsTableOrderingComposer,
    $$LocalMaterialsTableAnnotationComposer,
    $$LocalMaterialsTableCreateCompanionBuilder,
    $$LocalMaterialsTableUpdateCompanionBuilder,
    (
      LocalMaterial,
      BaseReferences<_$AppDatabase, $LocalMaterialsTable, LocalMaterial>
    ),
    LocalMaterial,
    PrefetchHooks Function()>;
typedef $$CachedPricesTableCreateCompanionBuilder = CachedPricesCompanion
    Function({
  required String id,
  required String category,
  Value<String?> subCategory,
  required String district,
  Value<String?> city,
  required double latitude,
  required double longitude,
  required DateTime recordedAt,
  required double buyingPrice,
  required double sellingQuotedPrice,
  Value<String> unit,
  required double marketMin,
  required double marketMax,
  Value<String?> recyclerId,
  Value<String> source,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$CachedPricesTableUpdateCompanionBuilder = CachedPricesCompanion
    Function({
  Value<String> id,
  Value<String> category,
  Value<String?> subCategory,
  Value<String> district,
  Value<String?> city,
  Value<double> latitude,
  Value<double> longitude,
  Value<DateTime> recordedAt,
  Value<double> buyingPrice,
  Value<double> sellingQuotedPrice,
  Value<String> unit,
  Value<double> marketMin,
  Value<double> marketMax,
  Value<String?> recyclerId,
  Value<String> source,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$CachedPricesTableFilterComposer
    extends Composer<_$AppDatabase, $CachedPricesTable> {
  $$CachedPricesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get subCategory => $composableBuilder(
      column: $table.subCategory, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get district => $composableBuilder(
      column: $table.district, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get city => $composableBuilder(
      column: $table.city, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get latitude => $composableBuilder(
      column: $table.latitude, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get longitude => $composableBuilder(
      column: $table.longitude, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get recordedAt => $composableBuilder(
      column: $table.recordedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get buyingPrice => $composableBuilder(
      column: $table.buyingPrice, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get sellingQuotedPrice => $composableBuilder(
      column: $table.sellingQuotedPrice,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get unit => $composableBuilder(
      column: $table.unit, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get marketMin => $composableBuilder(
      column: $table.marketMin, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get marketMax => $composableBuilder(
      column: $table.marketMax, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get recyclerId => $composableBuilder(
      column: $table.recyclerId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$CachedPricesTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedPricesTable> {
  $$CachedPricesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get subCategory => $composableBuilder(
      column: $table.subCategory, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get district => $composableBuilder(
      column: $table.district, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get city => $composableBuilder(
      column: $table.city, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get latitude => $composableBuilder(
      column: $table.latitude, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get longitude => $composableBuilder(
      column: $table.longitude, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get recordedAt => $composableBuilder(
      column: $table.recordedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get buyingPrice => $composableBuilder(
      column: $table.buyingPrice, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get sellingQuotedPrice => $composableBuilder(
      column: $table.sellingQuotedPrice,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get unit => $composableBuilder(
      column: $table.unit, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get marketMin => $composableBuilder(
      column: $table.marketMin, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get marketMax => $composableBuilder(
      column: $table.marketMax, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get recyclerId => $composableBuilder(
      column: $table.recyclerId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$CachedPricesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedPricesTable> {
  $$CachedPricesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get subCategory => $composableBuilder(
      column: $table.subCategory, builder: (column) => column);

  GeneratedColumn<String> get district =>
      $composableBuilder(column: $table.district, builder: (column) => column);

  GeneratedColumn<String> get city =>
      $composableBuilder(column: $table.city, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<DateTime> get recordedAt => $composableBuilder(
      column: $table.recordedAt, builder: (column) => column);

  GeneratedColumn<double> get buyingPrice => $composableBuilder(
      column: $table.buyingPrice, builder: (column) => column);

  GeneratedColumn<double> get sellingQuotedPrice => $composableBuilder(
      column: $table.sellingQuotedPrice, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<double> get marketMin =>
      $composableBuilder(column: $table.marketMin, builder: (column) => column);

  GeneratedColumn<double> get marketMax =>
      $composableBuilder(column: $table.marketMax, builder: (column) => column);

  GeneratedColumn<String> get recyclerId => $composableBuilder(
      column: $table.recyclerId, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$CachedPricesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CachedPricesTable,
    CachedPrice,
    $$CachedPricesTableFilterComposer,
    $$CachedPricesTableOrderingComposer,
    $$CachedPricesTableAnnotationComposer,
    $$CachedPricesTableCreateCompanionBuilder,
    $$CachedPricesTableUpdateCompanionBuilder,
    (
      CachedPrice,
      BaseReferences<_$AppDatabase, $CachedPricesTable, CachedPrice>
    ),
    CachedPrice,
    PrefetchHooks Function()> {
  $$CachedPricesTableTableManager(_$AppDatabase db, $CachedPricesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedPricesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedPricesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedPricesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<String?> subCategory = const Value.absent(),
            Value<String> district = const Value.absent(),
            Value<String?> city = const Value.absent(),
            Value<double> latitude = const Value.absent(),
            Value<double> longitude = const Value.absent(),
            Value<DateTime> recordedAt = const Value.absent(),
            Value<double> buyingPrice = const Value.absent(),
            Value<double> sellingQuotedPrice = const Value.absent(),
            Value<String> unit = const Value.absent(),
            Value<double> marketMin = const Value.absent(),
            Value<double> marketMax = const Value.absent(),
            Value<String?> recyclerId = const Value.absent(),
            Value<String> source = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CachedPricesCompanion(
            id: id,
            category: category,
            subCategory: subCategory,
            district: district,
            city: city,
            latitude: latitude,
            longitude: longitude,
            recordedAt: recordedAt,
            buyingPrice: buyingPrice,
            sellingQuotedPrice: sellingQuotedPrice,
            unit: unit,
            marketMin: marketMin,
            marketMax: marketMax,
            recyclerId: recyclerId,
            source: source,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String category,
            Value<String?> subCategory = const Value.absent(),
            required String district,
            Value<String?> city = const Value.absent(),
            required double latitude,
            required double longitude,
            required DateTime recordedAt,
            required double buyingPrice,
            required double sellingQuotedPrice,
            Value<String> unit = const Value.absent(),
            required double marketMin,
            required double marketMax,
            Value<String?> recyclerId = const Value.absent(),
            Value<String> source = const Value.absent(),
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              CachedPricesCompanion.insert(
            id: id,
            category: category,
            subCategory: subCategory,
            district: district,
            city: city,
            latitude: latitude,
            longitude: longitude,
            recordedAt: recordedAt,
            buyingPrice: buyingPrice,
            sellingQuotedPrice: sellingQuotedPrice,
            unit: unit,
            marketMin: marketMin,
            marketMax: marketMax,
            recyclerId: recyclerId,
            source: source,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$CachedPricesTable, CachedPrice>(table),
                    BaseReferences<_$AppDatabase, $CachedPricesTable,
                        CachedPrice>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CachedPricesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CachedPricesTable,
    CachedPrice,
    $$CachedPricesTableFilterComposer,
    $$CachedPricesTableOrderingComposer,
    $$CachedPricesTableAnnotationComposer,
    $$CachedPricesTableCreateCompanionBuilder,
    $$CachedPricesTableUpdateCompanionBuilder,
    (
      CachedPrice,
      BaseReferences<_$AppDatabase, $CachedPricesTable, CachedPrice>
    ),
    CachedPrice,
    PrefetchHooks Function()>;
typedef $$CachedRecyclersTableCreateCompanionBuilder = CachedRecyclersCompanion
    Function({
  required String id,
  required String name,
  required double latitude,
  required double longitude,
  required String materialsAcceptedJson,
  required String authorizationNumber,
  required String authorizationBody,
  required String authorizationStatus,
  required DateTime authorizationValidTill,
  required String phone,
  required String offeredRatesJson,
  Value<bool> pickupAvailable,
  Value<double> pickupRadiusKm,
  required String serviceAreaJson,
  Value<double> rating,
  required DateTime cachedAt,
  Value<int> rowid,
});
typedef $$CachedRecyclersTableUpdateCompanionBuilder = CachedRecyclersCompanion
    Function({
  Value<String> id,
  Value<String> name,
  Value<double> latitude,
  Value<double> longitude,
  Value<String> materialsAcceptedJson,
  Value<String> authorizationNumber,
  Value<String> authorizationBody,
  Value<String> authorizationStatus,
  Value<DateTime> authorizationValidTill,
  Value<String> phone,
  Value<String> offeredRatesJson,
  Value<bool> pickupAvailable,
  Value<double> pickupRadiusKm,
  Value<String> serviceAreaJson,
  Value<double> rating,
  Value<DateTime> cachedAt,
  Value<int> rowid,
});

class $$CachedRecyclersTableFilterComposer
    extends Composer<_$AppDatabase, $CachedRecyclersTable> {
  $$CachedRecyclersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get latitude => $composableBuilder(
      column: $table.latitude, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get longitude => $composableBuilder(
      column: $table.longitude, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get materialsAcceptedJson => $composableBuilder(
      column: $table.materialsAcceptedJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get authorizationNumber => $composableBuilder(
      column: $table.authorizationNumber,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get authorizationBody => $composableBuilder(
      column: $table.authorizationBody,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get authorizationStatus => $composableBuilder(
      column: $table.authorizationStatus,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get authorizationValidTill => $composableBuilder(
      column: $table.authorizationValidTill,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get offeredRatesJson => $composableBuilder(
      column: $table.offeredRatesJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get pickupAvailable => $composableBuilder(
      column: $table.pickupAvailable,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get pickupRadiusKm => $composableBuilder(
      column: $table.pickupRadiusKm,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get serviceAreaJson => $composableBuilder(
      column: $table.serviceAreaJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get rating => $composableBuilder(
      column: $table.rating, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
      column: $table.cachedAt, builder: (column) => ColumnFilters(column));
}

class $$CachedRecyclersTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedRecyclersTable> {
  $$CachedRecyclersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get latitude => $composableBuilder(
      column: $table.latitude, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get longitude => $composableBuilder(
      column: $table.longitude, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get materialsAcceptedJson => $composableBuilder(
      column: $table.materialsAcceptedJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get authorizationNumber => $composableBuilder(
      column: $table.authorizationNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get authorizationBody => $composableBuilder(
      column: $table.authorizationBody,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get authorizationStatus => $composableBuilder(
      column: $table.authorizationStatus,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get authorizationValidTill => $composableBuilder(
      column: $table.authorizationValidTill,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get offeredRatesJson => $composableBuilder(
      column: $table.offeredRatesJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get pickupAvailable => $composableBuilder(
      column: $table.pickupAvailable,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get pickupRadiusKm => $composableBuilder(
      column: $table.pickupRadiusKm,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get serviceAreaJson => $composableBuilder(
      column: $table.serviceAreaJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get rating => $composableBuilder(
      column: $table.rating, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
      column: $table.cachedAt, builder: (column) => ColumnOrderings(column));
}

class $$CachedRecyclersTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedRecyclersTable> {
  $$CachedRecyclersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<String> get materialsAcceptedJson => $composableBuilder(
      column: $table.materialsAcceptedJson, builder: (column) => column);

  GeneratedColumn<String> get authorizationNumber => $composableBuilder(
      column: $table.authorizationNumber, builder: (column) => column);

  GeneratedColumn<String> get authorizationBody => $composableBuilder(
      column: $table.authorizationBody, builder: (column) => column);

  GeneratedColumn<String> get authorizationStatus => $composableBuilder(
      column: $table.authorizationStatus, builder: (column) => column);

  GeneratedColumn<DateTime> get authorizationValidTill => $composableBuilder(
      column: $table.authorizationValidTill, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get offeredRatesJson => $composableBuilder(
      column: $table.offeredRatesJson, builder: (column) => column);

  GeneratedColumn<bool> get pickupAvailable => $composableBuilder(
      column: $table.pickupAvailable, builder: (column) => column);

  GeneratedColumn<double> get pickupRadiusKm => $composableBuilder(
      column: $table.pickupRadiusKm, builder: (column) => column);

  GeneratedColumn<String> get serviceAreaJson => $composableBuilder(
      column: $table.serviceAreaJson, builder: (column) => column);

  GeneratedColumn<double> get rating =>
      $composableBuilder(column: $table.rating, builder: (column) => column);

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);
}

class $$CachedRecyclersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CachedRecyclersTable,
    CachedRecycler,
    $$CachedRecyclersTableFilterComposer,
    $$CachedRecyclersTableOrderingComposer,
    $$CachedRecyclersTableAnnotationComposer,
    $$CachedRecyclersTableCreateCompanionBuilder,
    $$CachedRecyclersTableUpdateCompanionBuilder,
    (
      CachedRecycler,
      BaseReferences<_$AppDatabase, $CachedRecyclersTable, CachedRecycler>
    ),
    CachedRecycler,
    PrefetchHooks Function()> {
  $$CachedRecyclersTableTableManager(
      _$AppDatabase db, $CachedRecyclersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedRecyclersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedRecyclersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedRecyclersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<double> latitude = const Value.absent(),
            Value<double> longitude = const Value.absent(),
            Value<String> materialsAcceptedJson = const Value.absent(),
            Value<String> authorizationNumber = const Value.absent(),
            Value<String> authorizationBody = const Value.absent(),
            Value<String> authorizationStatus = const Value.absent(),
            Value<DateTime> authorizationValidTill = const Value.absent(),
            Value<String> phone = const Value.absent(),
            Value<String> offeredRatesJson = const Value.absent(),
            Value<bool> pickupAvailable = const Value.absent(),
            Value<double> pickupRadiusKm = const Value.absent(),
            Value<String> serviceAreaJson = const Value.absent(),
            Value<double> rating = const Value.absent(),
            Value<DateTime> cachedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CachedRecyclersCompanion(
            id: id,
            name: name,
            latitude: latitude,
            longitude: longitude,
            materialsAcceptedJson: materialsAcceptedJson,
            authorizationNumber: authorizationNumber,
            authorizationBody: authorizationBody,
            authorizationStatus: authorizationStatus,
            authorizationValidTill: authorizationValidTill,
            phone: phone,
            offeredRatesJson: offeredRatesJson,
            pickupAvailable: pickupAvailable,
            pickupRadiusKm: pickupRadiusKm,
            serviceAreaJson: serviceAreaJson,
            rating: rating,
            cachedAt: cachedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required double latitude,
            required double longitude,
            required String materialsAcceptedJson,
            required String authorizationNumber,
            required String authorizationBody,
            required String authorizationStatus,
            required DateTime authorizationValidTill,
            required String phone,
            required String offeredRatesJson,
            Value<bool> pickupAvailable = const Value.absent(),
            Value<double> pickupRadiusKm = const Value.absent(),
            required String serviceAreaJson,
            Value<double> rating = const Value.absent(),
            required DateTime cachedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              CachedRecyclersCompanion.insert(
            id: id,
            name: name,
            latitude: latitude,
            longitude: longitude,
            materialsAcceptedJson: materialsAcceptedJson,
            authorizationNumber: authorizationNumber,
            authorizationBody: authorizationBody,
            authorizationStatus: authorizationStatus,
            authorizationValidTill: authorizationValidTill,
            phone: phone,
            offeredRatesJson: offeredRatesJson,
            pickupAvailable: pickupAvailable,
            pickupRadiusKm: pickupRadiusKm,
            serviceAreaJson: serviceAreaJson,
            rating: rating,
            cachedAt: cachedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$CachedRecyclersTable, CachedRecycler>(table),
                    BaseReferences<_$AppDatabase, $CachedRecyclersTable,
                        CachedRecycler>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CachedRecyclersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CachedRecyclersTable,
    CachedRecycler,
    $$CachedRecyclersTableFilterComposer,
    $$CachedRecyclersTableOrderingComposer,
    $$CachedRecyclersTableAnnotationComposer,
    $$CachedRecyclersTableCreateCompanionBuilder,
    $$CachedRecyclersTableUpdateCompanionBuilder,
    (
      CachedRecycler,
      BaseReferences<_$AppDatabase, $CachedRecyclersTable, CachedRecycler>
    ),
    CachedRecycler,
    PrefetchHooks Function()>;
typedef $$LocalTransactionsTableCreateCompanionBuilder
    = LocalTransactionsCompanion Function({
  required String lotId,
  required String clientLotUuid,
  required String collectorId,
  required String category,
  required double weightKg,
  required double quotedPrice,
  Value<double?> finalPrice,
  Value<String?> recyclerId,
  required double collectionLat,
  required double collectionLng,
  Value<double?> handoverLat,
  Value<double?> handoverLng,
  required DateTime createdAt,
  Value<DateTime?> handoverAt,
  Value<String> paymentStatus,
  Value<String> transactionStatus,
  Value<bool> anomalyFlag,
  Value<String?> anomalyReason,
  Value<bool> isSynced,
  Value<DateTime?> syncedAt,
  Value<int> rowid,
});
typedef $$LocalTransactionsTableUpdateCompanionBuilder
    = LocalTransactionsCompanion Function({
  Value<String> lotId,
  Value<String> clientLotUuid,
  Value<String> collectorId,
  Value<String> category,
  Value<double> weightKg,
  Value<double> quotedPrice,
  Value<double?> finalPrice,
  Value<String?> recyclerId,
  Value<double> collectionLat,
  Value<double> collectionLng,
  Value<double?> handoverLat,
  Value<double?> handoverLng,
  Value<DateTime> createdAt,
  Value<DateTime?> handoverAt,
  Value<String> paymentStatus,
  Value<String> transactionStatus,
  Value<bool> anomalyFlag,
  Value<String?> anomalyReason,
  Value<bool> isSynced,
  Value<DateTime?> syncedAt,
  Value<int> rowid,
});

class $$LocalTransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalTransactionsTable> {
  $$LocalTransactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get lotId => $composableBuilder(
      column: $table.lotId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get clientLotUuid => $composableBuilder(
      column: $table.clientLotUuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get collectorId => $composableBuilder(
      column: $table.collectorId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get weightKg => $composableBuilder(
      column: $table.weightKg, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get quotedPrice => $composableBuilder(
      column: $table.quotedPrice, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get finalPrice => $composableBuilder(
      column: $table.finalPrice, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get recyclerId => $composableBuilder(
      column: $table.recyclerId, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get collectionLat => $composableBuilder(
      column: $table.collectionLat, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get collectionLng => $composableBuilder(
      column: $table.collectionLng, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get handoverLat => $composableBuilder(
      column: $table.handoverLat, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get handoverLng => $composableBuilder(
      column: $table.handoverLng, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get handoverAt => $composableBuilder(
      column: $table.handoverAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get paymentStatus => $composableBuilder(
      column: $table.paymentStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get transactionStatus => $composableBuilder(
      column: $table.transactionStatus,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get anomalyFlag => $composableBuilder(
      column: $table.anomalyFlag, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get anomalyReason => $composableBuilder(
      column: $table.anomalyReason, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
      column: $table.syncedAt, builder: (column) => ColumnFilters(column));
}

class $$LocalTransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalTransactionsTable> {
  $$LocalTransactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get lotId => $composableBuilder(
      column: $table.lotId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get clientLotUuid => $composableBuilder(
      column: $table.clientLotUuid,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get collectorId => $composableBuilder(
      column: $table.collectorId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get weightKg => $composableBuilder(
      column: $table.weightKg, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get quotedPrice => $composableBuilder(
      column: $table.quotedPrice, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get finalPrice => $composableBuilder(
      column: $table.finalPrice, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get recyclerId => $composableBuilder(
      column: $table.recyclerId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get collectionLat => $composableBuilder(
      column: $table.collectionLat,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get collectionLng => $composableBuilder(
      column: $table.collectionLng,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get handoverLat => $composableBuilder(
      column: $table.handoverLat, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get handoverLng => $composableBuilder(
      column: $table.handoverLng, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get handoverAt => $composableBuilder(
      column: $table.handoverAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get paymentStatus => $composableBuilder(
      column: $table.paymentStatus,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get transactionStatus => $composableBuilder(
      column: $table.transactionStatus,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get anomalyFlag => $composableBuilder(
      column: $table.anomalyFlag, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get anomalyReason => $composableBuilder(
      column: $table.anomalyReason,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
      column: $table.syncedAt, builder: (column) => ColumnOrderings(column));
}

class $$LocalTransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalTransactionsTable> {
  $$LocalTransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get lotId =>
      $composableBuilder(column: $table.lotId, builder: (column) => column);

  GeneratedColumn<String> get clientLotUuid => $composableBuilder(
      column: $table.clientLotUuid, builder: (column) => column);

  GeneratedColumn<String> get collectorId => $composableBuilder(
      column: $table.collectorId, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<double> get weightKg =>
      $composableBuilder(column: $table.weightKg, builder: (column) => column);

  GeneratedColumn<double> get quotedPrice => $composableBuilder(
      column: $table.quotedPrice, builder: (column) => column);

  GeneratedColumn<double> get finalPrice => $composableBuilder(
      column: $table.finalPrice, builder: (column) => column);

  GeneratedColumn<String> get recyclerId => $composableBuilder(
      column: $table.recyclerId, builder: (column) => column);

  GeneratedColumn<double> get collectionLat => $composableBuilder(
      column: $table.collectionLat, builder: (column) => column);

  GeneratedColumn<double> get collectionLng => $composableBuilder(
      column: $table.collectionLng, builder: (column) => column);

  GeneratedColumn<double> get handoverLat => $composableBuilder(
      column: $table.handoverLat, builder: (column) => column);

  GeneratedColumn<double> get handoverLng => $composableBuilder(
      column: $table.handoverLng, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get handoverAt => $composableBuilder(
      column: $table.handoverAt, builder: (column) => column);

  GeneratedColumn<String> get paymentStatus => $composableBuilder(
      column: $table.paymentStatus, builder: (column) => column);

  GeneratedColumn<String> get transactionStatus => $composableBuilder(
      column: $table.transactionStatus, builder: (column) => column);

  GeneratedColumn<bool> get anomalyFlag => $composableBuilder(
      column: $table.anomalyFlag, builder: (column) => column);

  GeneratedColumn<String> get anomalyReason => $composableBuilder(
      column: $table.anomalyReason, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);
}

class $$LocalTransactionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LocalTransactionsTable,
    LocalTransaction,
    $$LocalTransactionsTableFilterComposer,
    $$LocalTransactionsTableOrderingComposer,
    $$LocalTransactionsTableAnnotationComposer,
    $$LocalTransactionsTableCreateCompanionBuilder,
    $$LocalTransactionsTableUpdateCompanionBuilder,
    (
      LocalTransaction,
      BaseReferences<_$AppDatabase, $LocalTransactionsTable, LocalTransaction>
    ),
    LocalTransaction,
    PrefetchHooks Function()> {
  $$LocalTransactionsTableTableManager(
      _$AppDatabase db, $LocalTransactionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalTransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalTransactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalTransactionsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> lotId = const Value.absent(),
            Value<String> clientLotUuid = const Value.absent(),
            Value<String> collectorId = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<double> weightKg = const Value.absent(),
            Value<double> quotedPrice = const Value.absent(),
            Value<double?> finalPrice = const Value.absent(),
            Value<String?> recyclerId = const Value.absent(),
            Value<double> collectionLat = const Value.absent(),
            Value<double> collectionLng = const Value.absent(),
            Value<double?> handoverLat = const Value.absent(),
            Value<double?> handoverLng = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> handoverAt = const Value.absent(),
            Value<String> paymentStatus = const Value.absent(),
            Value<String> transactionStatus = const Value.absent(),
            Value<bool> anomalyFlag = const Value.absent(),
            Value<String?> anomalyReason = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<DateTime?> syncedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalTransactionsCompanion(
            lotId: lotId,
            clientLotUuid: clientLotUuid,
            collectorId: collectorId,
            category: category,
            weightKg: weightKg,
            quotedPrice: quotedPrice,
            finalPrice: finalPrice,
            recyclerId: recyclerId,
            collectionLat: collectionLat,
            collectionLng: collectionLng,
            handoverLat: handoverLat,
            handoverLng: handoverLng,
            createdAt: createdAt,
            handoverAt: handoverAt,
            paymentStatus: paymentStatus,
            transactionStatus: transactionStatus,
            anomalyFlag: anomalyFlag,
            anomalyReason: anomalyReason,
            isSynced: isSynced,
            syncedAt: syncedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String lotId,
            required String clientLotUuid,
            required String collectorId,
            required String category,
            required double weightKg,
            required double quotedPrice,
            Value<double?> finalPrice = const Value.absent(),
            Value<String?> recyclerId = const Value.absent(),
            required double collectionLat,
            required double collectionLng,
            Value<double?> handoverLat = const Value.absent(),
            Value<double?> handoverLng = const Value.absent(),
            required DateTime createdAt,
            Value<DateTime?> handoverAt = const Value.absent(),
            Value<String> paymentStatus = const Value.absent(),
            Value<String> transactionStatus = const Value.absent(),
            Value<bool> anomalyFlag = const Value.absent(),
            Value<String?> anomalyReason = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<DateTime?> syncedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalTransactionsCompanion.insert(
            lotId: lotId,
            clientLotUuid: clientLotUuid,
            collectorId: collectorId,
            category: category,
            weightKg: weightKg,
            quotedPrice: quotedPrice,
            finalPrice: finalPrice,
            recyclerId: recyclerId,
            collectionLat: collectionLat,
            collectionLng: collectionLng,
            handoverLat: handoverLat,
            handoverLng: handoverLng,
            createdAt: createdAt,
            handoverAt: handoverAt,
            paymentStatus: paymentStatus,
            transactionStatus: transactionStatus,
            anomalyFlag: anomalyFlag,
            anomalyReason: anomalyReason,
            isSynced: isSynced,
            syncedAt: syncedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$LocalTransactionsTable, LocalTransaction>(
                        table),
                    BaseReferences<_$AppDatabase, $LocalTransactionsTable,
                        LocalTransaction>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LocalTransactionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LocalTransactionsTable,
    LocalTransaction,
    $$LocalTransactionsTableFilterComposer,
    $$LocalTransactionsTableOrderingComposer,
    $$LocalTransactionsTableAnnotationComposer,
    $$LocalTransactionsTableCreateCompanionBuilder,
    $$LocalTransactionsTableUpdateCompanionBuilder,
    (
      LocalTransaction,
      BaseReferences<_$AppDatabase, $LocalTransactionsTable, LocalTransaction>
    ),
    LocalTransaction,
    PrefetchHooks Function()>;
typedef $$LocalTraceabilityTableCreateCompanionBuilder
    = LocalTraceabilityCompanion Function({
  required String id,
  required String lotId,
  required String photoHashesJson,
  required double weightKg,
  required DateTime timestamp,
  required double gpsLat,
  required double gpsLng,
  required String handoverRefNo,
  required String qrPayload,
  Value<bool> recyclerConfirmation,
  Value<DateTime?> confirmedAt,
  Value<String?> confirmedBy,
  Value<String> downstreamStatus,
  required String recordHash,
  required String prevHash,
  Value<bool> isSynced,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$LocalTraceabilityTableUpdateCompanionBuilder
    = LocalTraceabilityCompanion Function({
  Value<String> id,
  Value<String> lotId,
  Value<String> photoHashesJson,
  Value<double> weightKg,
  Value<DateTime> timestamp,
  Value<double> gpsLat,
  Value<double> gpsLng,
  Value<String> handoverRefNo,
  Value<String> qrPayload,
  Value<bool> recyclerConfirmation,
  Value<DateTime?> confirmedAt,
  Value<String?> confirmedBy,
  Value<String> downstreamStatus,
  Value<String> recordHash,
  Value<String> prevHash,
  Value<bool> isSynced,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$LocalTraceabilityTableFilterComposer
    extends Composer<_$AppDatabase, $LocalTraceabilityTable> {
  $$LocalTraceabilityTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lotId => $composableBuilder(
      column: $table.lotId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get photoHashesJson => $composableBuilder(
      column: $table.photoHashesJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get weightKg => $composableBuilder(
      column: $table.weightKg, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get gpsLat => $composableBuilder(
      column: $table.gpsLat, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get gpsLng => $composableBuilder(
      column: $table.gpsLng, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get handoverRefNo => $composableBuilder(
      column: $table.handoverRefNo, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get qrPayload => $composableBuilder(
      column: $table.qrPayload, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get recyclerConfirmation => $composableBuilder(
      column: $table.recyclerConfirmation,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get confirmedAt => $composableBuilder(
      column: $table.confirmedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get confirmedBy => $composableBuilder(
      column: $table.confirmedBy, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get downstreamStatus => $composableBuilder(
      column: $table.downstreamStatus,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get recordHash => $composableBuilder(
      column: $table.recordHash, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get prevHash => $composableBuilder(
      column: $table.prevHash, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$LocalTraceabilityTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalTraceabilityTable> {
  $$LocalTraceabilityTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lotId => $composableBuilder(
      column: $table.lotId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get photoHashesJson => $composableBuilder(
      column: $table.photoHashesJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get weightKg => $composableBuilder(
      column: $table.weightKg, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get gpsLat => $composableBuilder(
      column: $table.gpsLat, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get gpsLng => $composableBuilder(
      column: $table.gpsLng, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get handoverRefNo => $composableBuilder(
      column: $table.handoverRefNo,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get qrPayload => $composableBuilder(
      column: $table.qrPayload, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get recyclerConfirmation => $composableBuilder(
      column: $table.recyclerConfirmation,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get confirmedAt => $composableBuilder(
      column: $table.confirmedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get confirmedBy => $composableBuilder(
      column: $table.confirmedBy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get downstreamStatus => $composableBuilder(
      column: $table.downstreamStatus,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get recordHash => $composableBuilder(
      column: $table.recordHash, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get prevHash => $composableBuilder(
      column: $table.prevHash, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$LocalTraceabilityTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalTraceabilityTable> {
  $$LocalTraceabilityTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get lotId =>
      $composableBuilder(column: $table.lotId, builder: (column) => column);

  GeneratedColumn<String> get photoHashesJson => $composableBuilder(
      column: $table.photoHashesJson, builder: (column) => column);

  GeneratedColumn<double> get weightKg =>
      $composableBuilder(column: $table.weightKg, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<double> get gpsLat =>
      $composableBuilder(column: $table.gpsLat, builder: (column) => column);

  GeneratedColumn<double> get gpsLng =>
      $composableBuilder(column: $table.gpsLng, builder: (column) => column);

  GeneratedColumn<String> get handoverRefNo => $composableBuilder(
      column: $table.handoverRefNo, builder: (column) => column);

  GeneratedColumn<String> get qrPayload =>
      $composableBuilder(column: $table.qrPayload, builder: (column) => column);

  GeneratedColumn<bool> get recyclerConfirmation => $composableBuilder(
      column: $table.recyclerConfirmation, builder: (column) => column);

  GeneratedColumn<DateTime> get confirmedAt => $composableBuilder(
      column: $table.confirmedAt, builder: (column) => column);

  GeneratedColumn<String> get confirmedBy => $composableBuilder(
      column: $table.confirmedBy, builder: (column) => column);

  GeneratedColumn<String> get downstreamStatus => $composableBuilder(
      column: $table.downstreamStatus, builder: (column) => column);

  GeneratedColumn<String> get recordHash => $composableBuilder(
      column: $table.recordHash, builder: (column) => column);

  GeneratedColumn<String> get prevHash =>
      $composableBuilder(column: $table.prevHash, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$LocalTraceabilityTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LocalTraceabilityTable,
    LocalTraceabilityData,
    $$LocalTraceabilityTableFilterComposer,
    $$LocalTraceabilityTableOrderingComposer,
    $$LocalTraceabilityTableAnnotationComposer,
    $$LocalTraceabilityTableCreateCompanionBuilder,
    $$LocalTraceabilityTableUpdateCompanionBuilder,
    (
      LocalTraceabilityData,
      BaseReferences<_$AppDatabase, $LocalTraceabilityTable,
          LocalTraceabilityData>
    ),
    LocalTraceabilityData,
    PrefetchHooks Function()> {
  $$LocalTraceabilityTableTableManager(
      _$AppDatabase db, $LocalTraceabilityTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalTraceabilityTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalTraceabilityTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalTraceabilityTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> lotId = const Value.absent(),
            Value<String> photoHashesJson = const Value.absent(),
            Value<double> weightKg = const Value.absent(),
            Value<DateTime> timestamp = const Value.absent(),
            Value<double> gpsLat = const Value.absent(),
            Value<double> gpsLng = const Value.absent(),
            Value<String> handoverRefNo = const Value.absent(),
            Value<String> qrPayload = const Value.absent(),
            Value<bool> recyclerConfirmation = const Value.absent(),
            Value<DateTime?> confirmedAt = const Value.absent(),
            Value<String?> confirmedBy = const Value.absent(),
            Value<String> downstreamStatus = const Value.absent(),
            Value<String> recordHash = const Value.absent(),
            Value<String> prevHash = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalTraceabilityCompanion(
            id: id,
            lotId: lotId,
            photoHashesJson: photoHashesJson,
            weightKg: weightKg,
            timestamp: timestamp,
            gpsLat: gpsLat,
            gpsLng: gpsLng,
            handoverRefNo: handoverRefNo,
            qrPayload: qrPayload,
            recyclerConfirmation: recyclerConfirmation,
            confirmedAt: confirmedAt,
            confirmedBy: confirmedBy,
            downstreamStatus: downstreamStatus,
            recordHash: recordHash,
            prevHash: prevHash,
            isSynced: isSynced,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String lotId,
            required String photoHashesJson,
            required double weightKg,
            required DateTime timestamp,
            required double gpsLat,
            required double gpsLng,
            required String handoverRefNo,
            required String qrPayload,
            Value<bool> recyclerConfirmation = const Value.absent(),
            Value<DateTime?> confirmedAt = const Value.absent(),
            Value<String?> confirmedBy = const Value.absent(),
            Value<String> downstreamStatus = const Value.absent(),
            required String recordHash,
            required String prevHash,
            Value<bool> isSynced = const Value.absent(),
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalTraceabilityCompanion.insert(
            id: id,
            lotId: lotId,
            photoHashesJson: photoHashesJson,
            weightKg: weightKg,
            timestamp: timestamp,
            gpsLat: gpsLat,
            gpsLng: gpsLng,
            handoverRefNo: handoverRefNo,
            qrPayload: qrPayload,
            recyclerConfirmation: recyclerConfirmation,
            confirmedAt: confirmedAt,
            confirmedBy: confirmedBy,
            downstreamStatus: downstreamStatus,
            recordHash: recordHash,
            prevHash: prevHash,
            isSynced: isSynced,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$LocalTraceabilityTable, LocalTraceabilityData>(
                        table),
                    BaseReferences<_$AppDatabase, $LocalTraceabilityTable,
                        LocalTraceabilityData>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LocalTraceabilityTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LocalTraceabilityTable,
    LocalTraceabilityData,
    $$LocalTraceabilityTableFilterComposer,
    $$LocalTraceabilityTableOrderingComposer,
    $$LocalTraceabilityTableAnnotationComposer,
    $$LocalTraceabilityTableCreateCompanionBuilder,
    $$LocalTraceabilityTableUpdateCompanionBuilder,
    (
      LocalTraceabilityData,
      BaseReferences<_$AppDatabase, $LocalTraceabilityTable,
          LocalTraceabilityData>
    ),
    LocalTraceabilityData,
    PrefetchHooks Function()>;
typedef $$CollectorProfileTableCreateCompanionBuilder
    = CollectorProfileCompanion Function({
  required String collectorId,
  Value<String> preferredLanguage,
  required String operatingArea,
  Value<String?> quickPinHash,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$CollectorProfileTableUpdateCompanionBuilder
    = CollectorProfileCompanion Function({
  Value<String> collectorId,
  Value<String> preferredLanguage,
  Value<String> operatingArea,
  Value<String?> quickPinHash,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$CollectorProfileTableFilterComposer
    extends Composer<_$AppDatabase, $CollectorProfileTable> {
  $$CollectorProfileTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get collectorId => $composableBuilder(
      column: $table.collectorId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get preferredLanguage => $composableBuilder(
      column: $table.preferredLanguage,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get operatingArea => $composableBuilder(
      column: $table.operatingArea, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get quickPinHash => $composableBuilder(
      column: $table.quickPinHash, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$CollectorProfileTableOrderingComposer
    extends Composer<_$AppDatabase, $CollectorProfileTable> {
  $$CollectorProfileTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get collectorId => $composableBuilder(
      column: $table.collectorId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get preferredLanguage => $composableBuilder(
      column: $table.preferredLanguage,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get operatingArea => $composableBuilder(
      column: $table.operatingArea,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get quickPinHash => $composableBuilder(
      column: $table.quickPinHash,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$CollectorProfileTableAnnotationComposer
    extends Composer<_$AppDatabase, $CollectorProfileTable> {
  $$CollectorProfileTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get collectorId => $composableBuilder(
      column: $table.collectorId, builder: (column) => column);

  GeneratedColumn<String> get preferredLanguage => $composableBuilder(
      column: $table.preferredLanguage, builder: (column) => column);

  GeneratedColumn<String> get operatingArea => $composableBuilder(
      column: $table.operatingArea, builder: (column) => column);

  GeneratedColumn<String> get quickPinHash => $composableBuilder(
      column: $table.quickPinHash, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$CollectorProfileTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CollectorProfileTable,
    CollectorProfileData,
    $$CollectorProfileTableFilterComposer,
    $$CollectorProfileTableOrderingComposer,
    $$CollectorProfileTableAnnotationComposer,
    $$CollectorProfileTableCreateCompanionBuilder,
    $$CollectorProfileTableUpdateCompanionBuilder,
    (
      CollectorProfileData,
      BaseReferences<_$AppDatabase, $CollectorProfileTable,
          CollectorProfileData>
    ),
    CollectorProfileData,
    PrefetchHooks Function()> {
  $$CollectorProfileTableTableManager(
      _$AppDatabase db, $CollectorProfileTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CollectorProfileTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CollectorProfileTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CollectorProfileTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> collectorId = const Value.absent(),
            Value<String> preferredLanguage = const Value.absent(),
            Value<String> operatingArea = const Value.absent(),
            Value<String?> quickPinHash = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CollectorProfileCompanion(
            collectorId: collectorId,
            preferredLanguage: preferredLanguage,
            operatingArea: operatingArea,
            quickPinHash: quickPinHash,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String collectorId,
            Value<String> preferredLanguage = const Value.absent(),
            required String operatingArea,
            Value<String?> quickPinHash = const Value.absent(),
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              CollectorProfileCompanion.insert(
            collectorId: collectorId,
            preferredLanguage: preferredLanguage,
            operatingArea: operatingArea,
            quickPinHash: quickPinHash,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$CollectorProfileTable, CollectorProfileData>(
                        table),
                    BaseReferences<_$AppDatabase, $CollectorProfileTable,
                        CollectorProfileData>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CollectorProfileTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CollectorProfileTable,
    CollectorProfileData,
    $$CollectorProfileTableFilterComposer,
    $$CollectorProfileTableOrderingComposer,
    $$CollectorProfileTableAnnotationComposer,
    $$CollectorProfileTableCreateCompanionBuilder,
    $$CollectorProfileTableUpdateCompanionBuilder,
    (
      CollectorProfileData,
      BaseReferences<_$AppDatabase, $CollectorProfileTable,
          CollectorProfileData>
    ),
    CollectorProfileData,
    PrefetchHooks Function()>;
typedef $$LocalLedgerTableCreateCompanionBuilder = LocalLedgerCompanion
    Function({
  required String id,
  required String collectorId,
  Value<String?> lotId,
  required String entryType,
  required double amount,
  Value<String> paymentMode,
  required String description,
  required double balanceAfter,
  required DateTime recordedAt,
  Value<bool> isSynced,
  Value<int> rowid,
});
typedef $$LocalLedgerTableUpdateCompanionBuilder = LocalLedgerCompanion
    Function({
  Value<String> id,
  Value<String> collectorId,
  Value<String?> lotId,
  Value<String> entryType,
  Value<double> amount,
  Value<String> paymentMode,
  Value<String> description,
  Value<double> balanceAfter,
  Value<DateTime> recordedAt,
  Value<bool> isSynced,
  Value<int> rowid,
});

class $$LocalLedgerTableFilterComposer
    extends Composer<_$AppDatabase, $LocalLedgerTable> {
  $$LocalLedgerTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get collectorId => $composableBuilder(
      column: $table.collectorId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lotId => $composableBuilder(
      column: $table.lotId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entryType => $composableBuilder(
      column: $table.entryType, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get paymentMode => $composableBuilder(
      column: $table.paymentMode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get balanceAfter => $composableBuilder(
      column: $table.balanceAfter, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get recordedAt => $composableBuilder(
      column: $table.recordedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnFilters(column));
}

class $$LocalLedgerTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalLedgerTable> {
  $$LocalLedgerTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get collectorId => $composableBuilder(
      column: $table.collectorId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lotId => $composableBuilder(
      column: $table.lotId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entryType => $composableBuilder(
      column: $table.entryType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get paymentMode => $composableBuilder(
      column: $table.paymentMode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get balanceAfter => $composableBuilder(
      column: $table.balanceAfter,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get recordedAt => $composableBuilder(
      column: $table.recordedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnOrderings(column));
}

class $$LocalLedgerTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalLedgerTable> {
  $$LocalLedgerTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get collectorId => $composableBuilder(
      column: $table.collectorId, builder: (column) => column);

  GeneratedColumn<String> get lotId =>
      $composableBuilder(column: $table.lotId, builder: (column) => column);

  GeneratedColumn<String> get entryType =>
      $composableBuilder(column: $table.entryType, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get paymentMode => $composableBuilder(
      column: $table.paymentMode, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<double> get balanceAfter => $composableBuilder(
      column: $table.balanceAfter, builder: (column) => column);

  GeneratedColumn<DateTime> get recordedAt => $composableBuilder(
      column: $table.recordedAt, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);
}

class $$LocalLedgerTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LocalLedgerTable,
    LocalLedgerData,
    $$LocalLedgerTableFilterComposer,
    $$LocalLedgerTableOrderingComposer,
    $$LocalLedgerTableAnnotationComposer,
    $$LocalLedgerTableCreateCompanionBuilder,
    $$LocalLedgerTableUpdateCompanionBuilder,
    (
      LocalLedgerData,
      BaseReferences<_$AppDatabase, $LocalLedgerTable, LocalLedgerData>
    ),
    LocalLedgerData,
    PrefetchHooks Function()> {
  $$LocalLedgerTableTableManager(_$AppDatabase db, $LocalLedgerTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalLedgerTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalLedgerTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalLedgerTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> collectorId = const Value.absent(),
            Value<String?> lotId = const Value.absent(),
            Value<String> entryType = const Value.absent(),
            Value<double> amount = const Value.absent(),
            Value<String> paymentMode = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<double> balanceAfter = const Value.absent(),
            Value<DateTime> recordedAt = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalLedgerCompanion(
            id: id,
            collectorId: collectorId,
            lotId: lotId,
            entryType: entryType,
            amount: amount,
            paymentMode: paymentMode,
            description: description,
            balanceAfter: balanceAfter,
            recordedAt: recordedAt,
            isSynced: isSynced,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String collectorId,
            Value<String?> lotId = const Value.absent(),
            required String entryType,
            required double amount,
            Value<String> paymentMode = const Value.absent(),
            required String description,
            required double balanceAfter,
            required DateTime recordedAt,
            Value<bool> isSynced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalLedgerCompanion.insert(
            id: id,
            collectorId: collectorId,
            lotId: lotId,
            entryType: entryType,
            amount: amount,
            paymentMode: paymentMode,
            description: description,
            balanceAfter: balanceAfter,
            recordedAt: recordedAt,
            isSynced: isSynced,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$LocalLedgerTable, LocalLedgerData>(table),
                    BaseReferences<_$AppDatabase, $LocalLedgerTable,
                        LocalLedgerData>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LocalLedgerTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LocalLedgerTable,
    LocalLedgerData,
    $$LocalLedgerTableFilterComposer,
    $$LocalLedgerTableOrderingComposer,
    $$LocalLedgerTableAnnotationComposer,
    $$LocalLedgerTableCreateCompanionBuilder,
    $$LocalLedgerTableUpdateCompanionBuilder,
    (
      LocalLedgerData,
      BaseReferences<_$AppDatabase, $LocalLedgerTable, LocalLedgerData>
    ),
    LocalLedgerData,
    PrefetchHooks Function()>;
typedef $$CachedSafetyContentTableCreateCompanionBuilder
    = CachedSafetyContentCompanion Function({
  required String id,
  required String category,
  Value<String> hazardLevel,
  required String pictogramAssetPath,
  required String audioAssetPath,
  required String titleVernacular,
  required String instructionsVernacular,
  required String dosJson,
  required String dontsJson,
  required DateTime cachedAt,
  Value<int> rowid,
});
typedef $$CachedSafetyContentTableUpdateCompanionBuilder
    = CachedSafetyContentCompanion Function({
  Value<String> id,
  Value<String> category,
  Value<String> hazardLevel,
  Value<String> pictogramAssetPath,
  Value<String> audioAssetPath,
  Value<String> titleVernacular,
  Value<String> instructionsVernacular,
  Value<String> dosJson,
  Value<String> dontsJson,
  Value<DateTime> cachedAt,
  Value<int> rowid,
});

class $$CachedSafetyContentTableFilterComposer
    extends Composer<_$AppDatabase, $CachedSafetyContentTable> {
  $$CachedSafetyContentTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get hazardLevel => $composableBuilder(
      column: $table.hazardLevel, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get pictogramAssetPath => $composableBuilder(
      column: $table.pictogramAssetPath,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get audioAssetPath => $composableBuilder(
      column: $table.audioAssetPath,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get titleVernacular => $composableBuilder(
      column: $table.titleVernacular,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get instructionsVernacular => $composableBuilder(
      column: $table.instructionsVernacular,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dosJson => $composableBuilder(
      column: $table.dosJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dontsJson => $composableBuilder(
      column: $table.dontsJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
      column: $table.cachedAt, builder: (column) => ColumnFilters(column));
}

class $$CachedSafetyContentTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedSafetyContentTable> {
  $$CachedSafetyContentTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get hazardLevel => $composableBuilder(
      column: $table.hazardLevel, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get pictogramAssetPath => $composableBuilder(
      column: $table.pictogramAssetPath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get audioAssetPath => $composableBuilder(
      column: $table.audioAssetPath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get titleVernacular => $composableBuilder(
      column: $table.titleVernacular,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get instructionsVernacular => $composableBuilder(
      column: $table.instructionsVernacular,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dosJson => $composableBuilder(
      column: $table.dosJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dontsJson => $composableBuilder(
      column: $table.dontsJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
      column: $table.cachedAt, builder: (column) => ColumnOrderings(column));
}

class $$CachedSafetyContentTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedSafetyContentTable> {
  $$CachedSafetyContentTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get hazardLevel => $composableBuilder(
      column: $table.hazardLevel, builder: (column) => column);

  GeneratedColumn<String> get pictogramAssetPath => $composableBuilder(
      column: $table.pictogramAssetPath, builder: (column) => column);

  GeneratedColumn<String> get audioAssetPath => $composableBuilder(
      column: $table.audioAssetPath, builder: (column) => column);

  GeneratedColumn<String> get titleVernacular => $composableBuilder(
      column: $table.titleVernacular, builder: (column) => column);

  GeneratedColumn<String> get instructionsVernacular => $composableBuilder(
      column: $table.instructionsVernacular, builder: (column) => column);

  GeneratedColumn<String> get dosJson =>
      $composableBuilder(column: $table.dosJson, builder: (column) => column);

  GeneratedColumn<String> get dontsJson =>
      $composableBuilder(column: $table.dontsJson, builder: (column) => column);

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);
}

class $$CachedSafetyContentTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CachedSafetyContentTable,
    CachedSafetyContentData,
    $$CachedSafetyContentTableFilterComposer,
    $$CachedSafetyContentTableOrderingComposer,
    $$CachedSafetyContentTableAnnotationComposer,
    $$CachedSafetyContentTableCreateCompanionBuilder,
    $$CachedSafetyContentTableUpdateCompanionBuilder,
    (
      CachedSafetyContentData,
      BaseReferences<_$AppDatabase, $CachedSafetyContentTable,
          CachedSafetyContentData>
    ),
    CachedSafetyContentData,
    PrefetchHooks Function()> {
  $$CachedSafetyContentTableTableManager(
      _$AppDatabase db, $CachedSafetyContentTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedSafetyContentTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedSafetyContentTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedSafetyContentTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<String> hazardLevel = const Value.absent(),
            Value<String> pictogramAssetPath = const Value.absent(),
            Value<String> audioAssetPath = const Value.absent(),
            Value<String> titleVernacular = const Value.absent(),
            Value<String> instructionsVernacular = const Value.absent(),
            Value<String> dosJson = const Value.absent(),
            Value<String> dontsJson = const Value.absent(),
            Value<DateTime> cachedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CachedSafetyContentCompanion(
            id: id,
            category: category,
            hazardLevel: hazardLevel,
            pictogramAssetPath: pictogramAssetPath,
            audioAssetPath: audioAssetPath,
            titleVernacular: titleVernacular,
            instructionsVernacular: instructionsVernacular,
            dosJson: dosJson,
            dontsJson: dontsJson,
            cachedAt: cachedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String category,
            Value<String> hazardLevel = const Value.absent(),
            required String pictogramAssetPath,
            required String audioAssetPath,
            required String titleVernacular,
            required String instructionsVernacular,
            required String dosJson,
            required String dontsJson,
            required DateTime cachedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              CachedSafetyContentCompanion.insert(
            id: id,
            category: category,
            hazardLevel: hazardLevel,
            pictogramAssetPath: pictogramAssetPath,
            audioAssetPath: audioAssetPath,
            titleVernacular: titleVernacular,
            instructionsVernacular: instructionsVernacular,
            dosJson: dosJson,
            dontsJson: dontsJson,
            cachedAt: cachedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$CachedSafetyContentTable,
                        CachedSafetyContentData>(table),
                    BaseReferences<_$AppDatabase, $CachedSafetyContentTable,
                        CachedSafetyContentData>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CachedSafetyContentTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CachedSafetyContentTable,
    CachedSafetyContentData,
    $$CachedSafetyContentTableFilterComposer,
    $$CachedSafetyContentTableOrderingComposer,
    $$CachedSafetyContentTableAnnotationComposer,
    $$CachedSafetyContentTableCreateCompanionBuilder,
    $$CachedSafetyContentTableUpdateCompanionBuilder,
    (
      CachedSafetyContentData,
      BaseReferences<_$AppDatabase, $CachedSafetyContentTable,
          CachedSafetyContentData>
    ),
    CachedSafetyContentData,
    PrefetchHooks Function()>;
typedef $$SyncQueueEntriesTableCreateCompanionBuilder
    = SyncQueueEntriesCompanion Function({
  required String clientTxId,
  required String collectorId,
  required String action,
  required String payloadJson,
  Value<String> status,
  Value<int> retryAttempts,
  Value<String?> lastError,
  required DateTime clientTimestamp,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$SyncQueueEntriesTableUpdateCompanionBuilder
    = SyncQueueEntriesCompanion Function({
  Value<String> clientTxId,
  Value<String> collectorId,
  Value<String> action,
  Value<String> payloadJson,
  Value<String> status,
  Value<int> retryAttempts,
  Value<String?> lastError,
  Value<DateTime> clientTimestamp,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$SyncQueueEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $SyncQueueEntriesTable> {
  $$SyncQueueEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get clientTxId => $composableBuilder(
      column: $table.clientTxId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get collectorId => $composableBuilder(
      column: $table.collectorId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get action => $composableBuilder(
      column: $table.action, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get retryAttempts => $composableBuilder(
      column: $table.retryAttempts, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastError => $composableBuilder(
      column: $table.lastError, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get clientTimestamp => $composableBuilder(
      column: $table.clientTimestamp,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$SyncQueueEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncQueueEntriesTable> {
  $$SyncQueueEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get clientTxId => $composableBuilder(
      column: $table.clientTxId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get collectorId => $composableBuilder(
      column: $table.collectorId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get action => $composableBuilder(
      column: $table.action, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get retryAttempts => $composableBuilder(
      column: $table.retryAttempts,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastError => $composableBuilder(
      column: $table.lastError, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get clientTimestamp => $composableBuilder(
      column: $table.clientTimestamp,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$SyncQueueEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncQueueEntriesTable> {
  $$SyncQueueEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get clientTxId => $composableBuilder(
      column: $table.clientTxId, builder: (column) => column);

  GeneratedColumn<String> get collectorId => $composableBuilder(
      column: $table.collectorId, builder: (column) => column);

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get retryAttempts => $composableBuilder(
      column: $table.retryAttempts, builder: (column) => column);

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<DateTime> get clientTimestamp => $composableBuilder(
      column: $table.clientTimestamp, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$SyncQueueEntriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SyncQueueEntriesTable,
    SyncQueueEntry,
    $$SyncQueueEntriesTableFilterComposer,
    $$SyncQueueEntriesTableOrderingComposer,
    $$SyncQueueEntriesTableAnnotationComposer,
    $$SyncQueueEntriesTableCreateCompanionBuilder,
    $$SyncQueueEntriesTableUpdateCompanionBuilder,
    (
      SyncQueueEntry,
      BaseReferences<_$AppDatabase, $SyncQueueEntriesTable, SyncQueueEntry>
    ),
    SyncQueueEntry,
    PrefetchHooks Function()> {
  $$SyncQueueEntriesTableTableManager(
      _$AppDatabase db, $SyncQueueEntriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncQueueEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncQueueEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncQueueEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> clientTxId = const Value.absent(),
            Value<String> collectorId = const Value.absent(),
            Value<String> action = const Value.absent(),
            Value<String> payloadJson = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int> retryAttempts = const Value.absent(),
            Value<String?> lastError = const Value.absent(),
            Value<DateTime> clientTimestamp = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncQueueEntriesCompanion(
            clientTxId: clientTxId,
            collectorId: collectorId,
            action: action,
            payloadJson: payloadJson,
            status: status,
            retryAttempts: retryAttempts,
            lastError: lastError,
            clientTimestamp: clientTimestamp,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String clientTxId,
            required String collectorId,
            required String action,
            required String payloadJson,
            Value<String> status = const Value.absent(),
            Value<int> retryAttempts = const Value.absent(),
            Value<String?> lastError = const Value.absent(),
            required DateTime clientTimestamp,
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncQueueEntriesCompanion.insert(
            clientTxId: clientTxId,
            collectorId: collectorId,
            action: action,
            payloadJson: payloadJson,
            status: status,
            retryAttempts: retryAttempts,
            lastError: lastError,
            clientTimestamp: clientTimestamp,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$SyncQueueEntriesTable, SyncQueueEntry>(table),
                    BaseReferences<_$AppDatabase, $SyncQueueEntriesTable,
                        SyncQueueEntry>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SyncQueueEntriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SyncQueueEntriesTable,
    SyncQueueEntry,
    $$SyncQueueEntriesTableFilterComposer,
    $$SyncQueueEntriesTableOrderingComposer,
    $$SyncQueueEntriesTableAnnotationComposer,
    $$SyncQueueEntriesTableCreateCompanionBuilder,
    $$SyncQueueEntriesTableUpdateCompanionBuilder,
    (
      SyncQueueEntry,
      BaseReferences<_$AppDatabase, $SyncQueueEntriesTable, SyncQueueEntry>
    ),
    SyncQueueEntry,
    PrefetchHooks Function()>;
typedef $$LocalMLSamplesTableCreateCompanionBuilder = LocalMLSamplesCompanion
    Function({
  required String id,
  required String localImagePath,
  required String label,
  Value<double?> weightKg,
  Value<double?> price,
  Value<double?> latitude,
  Value<double?> longitude,
  Value<String> source,
  Value<double> qualityScore,
  Value<bool> isUploaded,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$LocalMLSamplesTableUpdateCompanionBuilder = LocalMLSamplesCompanion
    Function({
  Value<String> id,
  Value<String> localImagePath,
  Value<String> label,
  Value<double?> weightKg,
  Value<double?> price,
  Value<double?> latitude,
  Value<double?> longitude,
  Value<String> source,
  Value<double> qualityScore,
  Value<bool> isUploaded,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$LocalMLSamplesTableFilterComposer
    extends Composer<_$AppDatabase, $LocalMLSamplesTable> {
  $$LocalMLSamplesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get localImagePath => $composableBuilder(
      column: $table.localImagePath,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get label => $composableBuilder(
      column: $table.label, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get weightKg => $composableBuilder(
      column: $table.weightKg, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get price => $composableBuilder(
      column: $table.price, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get latitude => $composableBuilder(
      column: $table.latitude, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get longitude => $composableBuilder(
      column: $table.longitude, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get qualityScore => $composableBuilder(
      column: $table.qualityScore, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isUploaded => $composableBuilder(
      column: $table.isUploaded, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$LocalMLSamplesTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalMLSamplesTable> {
  $$LocalMLSamplesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get localImagePath => $composableBuilder(
      column: $table.localImagePath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get label => $composableBuilder(
      column: $table.label, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get weightKg => $composableBuilder(
      column: $table.weightKg, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get price => $composableBuilder(
      column: $table.price, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get latitude => $composableBuilder(
      column: $table.latitude, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get longitude => $composableBuilder(
      column: $table.longitude, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get qualityScore => $composableBuilder(
      column: $table.qualityScore,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isUploaded => $composableBuilder(
      column: $table.isUploaded, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$LocalMLSamplesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalMLSamplesTable> {
  $$LocalMLSamplesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get localImagePath => $composableBuilder(
      column: $table.localImagePath, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<double> get weightKg =>
      $composableBuilder(column: $table.weightKg, builder: (column) => column);

  GeneratedColumn<double> get price =>
      $composableBuilder(column: $table.price, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<double> get qualityScore => $composableBuilder(
      column: $table.qualityScore, builder: (column) => column);

  GeneratedColumn<bool> get isUploaded => $composableBuilder(
      column: $table.isUploaded, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$LocalMLSamplesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LocalMLSamplesTable,
    LocalMLSample,
    $$LocalMLSamplesTableFilterComposer,
    $$LocalMLSamplesTableOrderingComposer,
    $$LocalMLSamplesTableAnnotationComposer,
    $$LocalMLSamplesTableCreateCompanionBuilder,
    $$LocalMLSamplesTableUpdateCompanionBuilder,
    (
      LocalMLSample,
      BaseReferences<_$AppDatabase, $LocalMLSamplesTable, LocalMLSample>
    ),
    LocalMLSample,
    PrefetchHooks Function()> {
  $$LocalMLSamplesTableTableManager(
      _$AppDatabase db, $LocalMLSamplesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalMLSamplesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalMLSamplesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalMLSamplesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> localImagePath = const Value.absent(),
            Value<String> label = const Value.absent(),
            Value<double?> weightKg = const Value.absent(),
            Value<double?> price = const Value.absent(),
            Value<double?> latitude = const Value.absent(),
            Value<double?> longitude = const Value.absent(),
            Value<String> source = const Value.absent(),
            Value<double> qualityScore = const Value.absent(),
            Value<bool> isUploaded = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalMLSamplesCompanion(
            id: id,
            localImagePath: localImagePath,
            label: label,
            weightKg: weightKg,
            price: price,
            latitude: latitude,
            longitude: longitude,
            source: source,
            qualityScore: qualityScore,
            isUploaded: isUploaded,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String localImagePath,
            required String label,
            Value<double?> weightKg = const Value.absent(),
            Value<double?> price = const Value.absent(),
            Value<double?> latitude = const Value.absent(),
            Value<double?> longitude = const Value.absent(),
            Value<String> source = const Value.absent(),
            Value<double> qualityScore = const Value.absent(),
            Value<bool> isUploaded = const Value.absent(),
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalMLSamplesCompanion.insert(
            id: id,
            localImagePath: localImagePath,
            label: label,
            weightKg: weightKg,
            price: price,
            latitude: latitude,
            longitude: longitude,
            source: source,
            qualityScore: qualityScore,
            isUploaded: isUploaded,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$LocalMLSamplesTable, LocalMLSample>(table),
                    BaseReferences<_$AppDatabase, $LocalMLSamplesTable,
                        LocalMLSample>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LocalMLSamplesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LocalMLSamplesTable,
    LocalMLSample,
    $$LocalMLSamplesTableFilterComposer,
    $$LocalMLSamplesTableOrderingComposer,
    $$LocalMLSamplesTableAnnotationComposer,
    $$LocalMLSamplesTableCreateCompanionBuilder,
    $$LocalMLSamplesTableUpdateCompanionBuilder,
    (
      LocalMLSample,
      BaseReferences<_$AppDatabase, $LocalMLSamplesTable, LocalMLSample>
    ),
    LocalMLSample,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LocalMaterialsTableTableManager get localMaterials =>
      $$LocalMaterialsTableTableManager(_db, _db.localMaterials);
  $$CachedPricesTableTableManager get cachedPrices =>
      $$CachedPricesTableTableManager(_db, _db.cachedPrices);
  $$CachedRecyclersTableTableManager get cachedRecyclers =>
      $$CachedRecyclersTableTableManager(_db, _db.cachedRecyclers);
  $$LocalTransactionsTableTableManager get localTransactions =>
      $$LocalTransactionsTableTableManager(_db, _db.localTransactions);
  $$LocalTraceabilityTableTableManager get localTraceability =>
      $$LocalTraceabilityTableTableManager(_db, _db.localTraceability);
  $$CollectorProfileTableTableManager get collectorProfile =>
      $$CollectorProfileTableTableManager(_db, _db.collectorProfile);
  $$LocalLedgerTableTableManager get localLedger =>
      $$LocalLedgerTableTableManager(_db, _db.localLedger);
  $$CachedSafetyContentTableTableManager get cachedSafetyContent =>
      $$CachedSafetyContentTableTableManager(_db, _db.cachedSafetyContent);
  $$SyncQueueEntriesTableTableManager get syncQueueEntries =>
      $$SyncQueueEntriesTableTableManager(_db, _db.syncQueueEntries);
  $$LocalMLSamplesTableTableManager get localMLSamples =>
      $$LocalMLSamplesTableTableManager(_db, _db.localMLSamples);
}
