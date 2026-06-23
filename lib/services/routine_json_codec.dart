import 'dart:convert';

import '../models/routine.dart';

enum RoutineJsonError {
  empty,
  notObject,
  invalidRoutine,
}

class RoutineJsonException implements Exception {
  const RoutineJsonException(this.error);

  final RoutineJsonError error;
}

abstract final class RoutineJsonCodec {
  static const _encoder = JsonEncoder.withIndent('  ');

  static String encode(Routine routine) => _encoder.convert(routine.toJson());

  static Routine decode(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      throw const RoutineJsonException(RoutineJsonError.empty);
    }

    final dynamic decoded;
    try {
      decoded = jsonDecode(trimmed);
    } on FormatException {
      throw const RoutineJsonException(RoutineJsonError.invalidRoutine);
    }

    if (decoded is! Map<String, dynamic>) {
      throw const RoutineJsonException(RoutineJsonError.notObject);
    }

    try {
      return Routine.fromJson(decoded);
    } on FormatException {
      throw const RoutineJsonException(RoutineJsonError.invalidRoutine);
    }
  }
}
