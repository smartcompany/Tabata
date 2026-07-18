import '../models/routine.dart';
import 'routine_list_thumbnail.dart';

export 'routine_list_thumbnail.dart'
    show RoutineListThumbnailRef, pickRoutineListThumbnail, youtubeThumbnailUrl;

/// First remote image or YouTube thumbnail URL for catalog list rows.
String? pickCatalogThumbnailImageUrl(Routine routine) {
  return pickRoutineListThumbnail(routine)?.imageUrl;
}
