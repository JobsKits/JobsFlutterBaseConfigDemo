import 'dart:js_interop';

import 'package:web/web.dart' as web;

Future<bool> shareBrowserLink(String url) async {
  try {
    await web.window.navigator
        .share(web.ShareData(url: url, text: 'SwiftUI'))
        .toDart;
    return true;
  } catch (_) {
    return false;
  }
}
