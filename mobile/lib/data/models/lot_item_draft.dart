import '../../core/hardware/image_processor.dart';

enum ItemCondition {
  working,
  broken,
  damaged,
  burnt,
}

extension ItemConditionExtension on ItemCondition {
  String get nameKey {
    switch (this) {
      case ItemCondition.working:
        return 'condWorking';
      case ItemCondition.broken:
        return 'condBroken';
      case ItemCondition.damaged:
        return 'condDamaged';
      case ItemCondition.burnt:
        return 'condBurnt';
    }
  }

  String get dbValue {
    switch (this) {
      case ItemCondition.working:
        return 'working';
      case ItemCondition.broken:
        return 'broken';
      case ItemCondition.damaged:
        return 'damaged';
      case ItemCondition.burnt:
        return 'burnt';
    }
  }

  String get vernacularLabelMr {
    switch (this) {
      case ItemCondition.working:
        return 'चालू स्थिति';
      case ItemCondition.broken:
        return 'फुटलेला';
      case ItemCondition.damaged:
        return 'खराब / नादुरुस्त';
      case ItemCondition.burnt:
        return 'जळालेला / काळा';
    }
  }

  String get vernacularLabelHi {
    switch (this) {
      case ItemCondition.working:
        return 'चालू स्थिति';
      case ItemCondition.broken:
        return 'टूटा हुआ';
      case ItemCondition.damaged:
        return 'खराब';
      case ItemCondition.burnt:
        return 'जला हुआ';
    }
  }
}

/// Represents an individual item within an e-waste collection lot.
class LotItemDraft {
  LotItemDraft({
    required this.id,
    required this.category,
    this.subCategory,
    this.condition = ItemCondition.broken,
    this.weightKg = 0.0,
    this.weightUnit = 'kg',
    this.unitPrice = 0.0,
    this.minPricePerKg = 0.0,
    this.maxPricePerKg = 0.0,
    List<ProcessedPhoto>? photos,
  }) : photos = photos ?? [];

  final String id;
  String category;
  String? subCategory;
  ItemCondition condition;
  double weightKg;
  String weightUnit; // 'kg' or 'gram'
  double unitPrice; // price per kg
  double minPricePerKg;
  double maxPricePerKg;
  final List<ProcessedPhoto> photos;

  double get estimatedTotalValue => (weightKg * unitPrice).roundToDouble();
  double get minTotalValue => (weightKg * minPricePerKg).roundToDouble();
  double get maxTotalValue => (weightKg * maxPricePerKg).roundToDouble();

  List<String> get photoHashes => photos.map((p) => p.sha256Hash).toList();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'sub_category': subCategory,
      'condition': condition.dbValue,
      'weight_kg': weightKg,
      'weight_unit': weightUnit,
      'unit_price': unitPrice,
      'estimated_total_value': estimatedTotalValue,
      'photo_hashes': photoHashes,
    };
  }
}
