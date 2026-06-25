import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../models/routine.dart';
import 'routine_json_codec.dart';

class RoutineShareService {
  String encode(Routine routine) => RoutineJsonCodec.encode(routine);

  Future<void> copyToClipboard(Routine routine) async {
    await Clipboard.setData(ClipboardData(text: encode(routine)));
  }

  Future<void> share(
    Routine routine, {
    Rect? sharePositionOrigin,
  }) async {
    await SharePlus.instance.share(
      ShareParams(
        text: encode(routine),
        subject: routine.title,
        sharePositionOrigin: sharePositionOrigin,
      ),
    );
  }

  Routine parse(String raw) => RoutineJsonCodec.decode(raw);
}
