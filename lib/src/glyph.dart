import 'dart:typed_data';

import 'package:esc_pos_utils/src/code_pages.dart';

GlyphBytes? getGlyphBytes(String glyph) {
  mainLoop: for (var entry in codePagesCharacterMappings.entries) {
    final codePage = entry.key;

    // (1) check if the glyph in it's entirety can be found in the mapping
    final byte = entry.value[glyph];
    if (byte != null) {
      return GlyphBytes(
        glyph: glyph,
        codePage: codePage,
        bytes: Uint8List.fromList([byte]),
      );
    }

    // (2) Check if each individual character of the glyph can be found in the
    // mapping. This can happen if a glyph is made of multiple characters like
    // "นั". All characters must be in the same code page, otherwise the
    // characters may not combine correctly.
    final List<int> bytes = [];
    for (var index = 0; index < glyph.length; index++) {
      String character = glyph[index];
      final byte = entry.value[character];
      if (byte == null) {
        continue mainLoop;
      } else {
        bytes.add(byte);
      }
    }
    return GlyphBytes(
      glyph: glyph,
      codePage: codePage,
      bytes: Uint8List.fromList(bytes),
    );
  }
  return null;
}

class GlyphBytes {
  final String glyph;
  final String codePage;
  final Uint8List bytes;

  GlyphBytes({
    required this.glyph,
    required this.codePage,
    required this.bytes,
  });
}
