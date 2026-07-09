import '../models/description_block.dart';
import '../models/routine.dart';

/// First remote image URL in a catalog routine (description or exercise blocks).
String? pickCatalogThumbnailImageUrl(Routine routine) {
  for (final block in routine.effectiveDescriptionBlocks) {
    if (block is ImageDescriptionBlock && block.hasRemoteUrl) {
      return block.url;
    }
  }
  for (final exercise in routine.orderedExercises) {
    for (final block in exercise.effectiveInstructionBlocks) {
      if (block is ImageDescriptionBlock && block.hasRemoteUrl) {
        return block.url;
      }
    }
  }
  return null;
}
