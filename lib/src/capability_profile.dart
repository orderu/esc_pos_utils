/*
 * esc_pos_utils
 * Created by Andrey U.
 * 
 * Copyright (c) 2019-2020. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import 'dart:convert' show json;

import 'package:flutter/services.dart' show rootBundle;

class CodePage {
  final int id;
  final String name;

  const CodePage(this.id, this.name);
}

class CapabilityProfile {
  final String name;
  final List<CodePage> codePages;
  final bool isZywell;

  const CapabilityProfile(this.name, this.codePages, {this.isZywell = false});

  factory CapabilityProfile.createFromCodePageData(Map<int, String> codePage,
      {bool isZywell = false}) {
    List<CodePage> list = [];
    codePage.forEach((k, v) {
      list.add(CodePage(k, v));
    });

    return CapabilityProfile('custom', list, isZywell: isZywell);
  }

  static Future<CapabilityProfile> load({String name = 'default'}) async {
    final content = await rootBundle
        .loadString('packages/esc_pos_utils/resources/capabilities.json');
    Map capabilities = json.decode(content);

    var profile = capabilities['profiles'][name];

    if (profile == null) {
      throw Exception("The CapabilityProfile '$name' does not exist");
    }

    List<CodePage> list = [];
    profile['codePages'].forEach((k, v) {
      list.add(CodePage(int.parse(k), v));
    });

    return CapabilityProfile(name, list);
  }

  bool hasCodePage(String codePage) {
    return codePages.any((cp) => cp.name == codePage);
  }

  int getCodePageId(String? codePage) {
    return codePages
        .firstWhere(
          (cp) => cp.name == codePage,
          orElse: () => throw Exception(
              "Code Page '$codePage' isn't defined for this profile"),
        )
        .id;
  }

  static Future<List<dynamic>> getAvailableProfiles() async {
    final content = await rootBundle
        .loadString('packages/esc_pos_utils/resources/capabilities.json');
    Map capabilities = json.decode(content);

    var profiles = capabilities['profiles'];

    List<dynamic> res = [];

    profiles.forEach((k, v) {
      res.add({
        'key': k,
        'vendor': v['vendor'] is String ? v['vendor'] : '',
        'model': v['model'] is String ? v['model'] : '',
        'description': v['description'] is String ? v['description'] : '',
      });
    });

    return res;
  }
}
