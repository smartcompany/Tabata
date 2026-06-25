abstract final class JsonField {
  static String requiredString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is! String) {
      throw FormatException('Required string field missing: $key');
    }
    return value;
  }

  static String optionalString(Map<String, dynamic> json, String key) {
    if (!json.containsKey(key) || json[key] == null) {
      return '';
    }
    return requiredString(json, key);
  }

  static int requiredInt(
    Map<String, dynamic> json,
    String key, {
    int? min,
    int? max,
  }) {
    final value = json[key];
    if (value is! num) {
      throw FormatException('Required int field missing: $key');
    }
    final intValue = value.toInt();
    if (min != null && intValue < min) {
      throw FormatException('Field $key must be >= $min');
    }
    if (max != null && intValue > max) {
      throw FormatException('Field $key must be <= $max');
    }
    return intValue;
  }

  static Map<String, dynamic> requiredMap(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is! Map<String, dynamic>) {
      throw FormatException('Required object field missing: $key');
    }
    return value;
  }

  static List<dynamic> requiredList(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is! List<dynamic>) {
      throw FormatException('Required list field missing: $key');
    }
    return value;
  }

  static int? optionalInt(
    Map<String, dynamic> json,
    String key, {
    int? min,
    int? max,
  }) {
    if (!json.containsKey(key) || json[key] == null) return null;
    return requiredInt(json, key, min: min, max: max);
  }
}
