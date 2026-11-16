enum DiffKind { context, addition, removal }

class DiffLine {
  const DiffLine(this.kind, this.text, this.oldLine, this.newLine);
  final DiffKind kind;
  final String text;
  final int? oldLine;
  final int? newLine;
}

class DiffHunk {
  const DiffHunk(this.header, this.lines);
  final String header;
  final List<DiffLine> lines;
}

/// A bounded unified-diff parser. Omitted counts mean one; zero counts stay zero.
List<DiffHunk> parseUnifiedPatch(String patch) {
  final source = patch.replaceAll('\r\n', '\n').split('\n');
  if (source.length > 10000) throw const FormatException('Patch too large');
  final result = <DiffHunk>[];
  final header = RegExp(r'^@@ -(\d+)(?:,(\d+))? \+(\d+)(?:,(\d+))? @@.*$');
  String? current;
  var lines = <DiffLine>[];
  var oldLine = 0, newLine = 0, oldLeft = 0, newLeft = 0;
  void finish() {
    if (current == null) return;
    if (oldLeft != 0 || newLeft != 0) {
      throw const FormatException('Truncated hunk');
    }
    result.add(DiffHunk(current, List.unmodifiable(lines)));
  }

  for (var index = 0; index < source.length; index++) {
    final line = source[index];
    if (line.startsWith('@@')) {
      finish();
      final match = header.firstMatch(line);
      if (match == null) throw const FormatException('Invalid hunk header');
      current = line;
      lines = [];
      oldLine = int.parse(match[1]!);
      newLine = int.parse(match[3]!);
      oldLeft = int.parse(match[2] ?? '1');
      newLeft = int.parse(match[4] ?? '1');
      continue;
    }
    if (current == null || line == r'\ No newline at end of file') continue;
    if (index == source.length - 1 && line.isEmpty) continue;
    if (oldLeft == 0 && newLeft == 0) {
      if (line.startsWith('diff ') ||
          line.startsWith('index ') ||
          line.startsWith('--- ') ||
          line.startsWith('+++ ')) {
        continue;
      }
      throw const FormatException('Unexpected hunk data');
    }
    if (line.startsWith('+')) {
      lines.add(
        DiffLine(DiffKind.addition, line.substring(1), null, newLine++),
      );
      newLeft--;
    } else if (line.startsWith('-')) {
      lines.add(DiffLine(DiffKind.removal, line.substring(1), oldLine++, null));
      oldLeft--;
    } else if (line.startsWith(' ')) {
      lines.add(
        DiffLine(DiffKind.context, line.substring(1), oldLine++, newLine++),
      );
      oldLeft--;
      newLeft--;
    } else {
      throw const FormatException('Invalid hunk line');
    }
    if (oldLeft < 0 || newLeft < 0) {
      throw const FormatException('Hunk count mismatch');
    }
  }
  finish();
  return List.unmodifiable(result);
}

class ReviewFile {
  const ReviewFile(this.id, this.path, this.patch);
  final String id, path, patch;
  Map<String, dynamic> toJson() => {'id': id, 'path': path, 'patch': patch};
  factory ReviewFile.fromJson(Map data) {
    if (data['id'] is! String ||
        data['path'] is! String ||
        data['patch'] is! String ||
        (data['patch'] as String).length > 100000) {
      throw const FormatException('File');
    }
    parseUnifiedPatch(data['patch']);
    return ReviewFile(data['id'], data['path'], data['patch']);
  }
}

class ReviewThread {
  const ReviewThread(
    this.id,
    this.fileId,
    this.bodyKey, {
    this.line,
    this.oldSide = false,
    this.resolved = false,
  });
  final String id, fileId, bodyKey;
  final int? line;
  final bool oldSide, resolved;
  ReviewThread toggle() => ReviewThread(
    id,
    fileId,
    bodyKey,
    line: line,
    oldSide: oldSide,
    resolved: !resolved,
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'file': fileId,
    'body': bodyKey,
    'line': line,
    'old': oldSide,
    'resolved': resolved,
  };
  factory ReviewThread.fromJson(Map data) {
    if (data['id'] is! String ||
        data['file'] is! String ||
        data['body'] is! String ||
        data['old'] is! bool ||
        data['resolved'] is! bool ||
        (data['line'] != null && (data['line'] is! int || data['line'] <= 0))) {
      throw const FormatException('Thread');
    }
    return ReviewThread(
      data['id'],
      data['file'],
      data['body'],
      line: data['line'],
      oldSide: data['old'],
      resolved: data['resolved'],
    );
  }
}

class ReviewBoard {
  const ReviewBoard(this.files, this.threads, this.revision);
  final List<ReviewFile> files;
  final List<ReviewThread> threads;
  final int revision;
  ReviewBoard toggle(String id) => ReviewBoard(files, [
    for (final thread in threads)
      if (thread.id == id) thread.toggle() else thread,
  ], revision + 1);
  List<ReviewThread> inlineFor(String file, DiffLine line) => threads
      .where(
        (t) =>
            t.fileId == file &&
            t.line != null &&
            t.line == (t.oldSide ? line.oldLine : line.newLine),
      )
      .toList();
  List<ReviewThread> outdatedFor(String file) {
    final patches = files
        .where((f) => f.id == file)
        .expand((f) => parseUnifiedPatch(f.patch))
        .expand((h) => h.lines)
        .toList();
    return threads
        .where(
          (t) =>
              t.fileId == file &&
              (t.line == null ||
                  !patches.any(
                    (l) => t.line == (t.oldSide ? l.oldLine : l.newLine),
                  )),
        )
        .toList();
  }

  Map<String, dynamic> toJson() => {
    'files': files.map((f) => f.toJson()).toList(),
    'threads': threads.map((t) => t.toJson()).toList(),
    'revision': revision,
  };
  factory ReviewBoard.fromJson(Map data) {
    if (data['files'] is! List ||
        data['threads'] is! List ||
        data['revision'] is! int ||
        (data['files'] as List).length > 100 ||
        (data['threads'] as List).length > 500) {
      throw const FormatException('Board');
    }
    final files = (data['files'] as List)
        .map((v) => ReviewFile.fromJson(v as Map))
        .toList();
    final threads = (data['threads'] as List)
        .map((v) => ReviewThread.fromJson(v as Map))
        .toList();
    if (files.map((f) => f.id).toSet().length != files.length ||
        threads.map((t) => t.id).toSet().length != threads.length ||
        threads.any((t) => !files.any((f) => f.id == t.fileId))) {
      throw const FormatException('Reference');
    }
    return ReviewBoard(files, threads, data['revision']);
  }
  static bool accepts(Map<String, dynamic> data) {
    try {
      ReviewBoard.fromJson(data);
      return true;
    } catch (_) {
      return false;
    }
  }

  static const sample = ReviewBoard(
    [
      ReviewFile(
        'price',
        'lib/price.dart',
        '@@ -1,4 +1,5 @@\n int total(int price, int count) {\n-  return price + count;\n+  if (count < 0) return 0;\n+  return price * count;\n }\n // cents\n',
      ),
      ReviewFile(
        'cache',
        'lib/cache.dart',
        '@@ -0,0 +1,3 @@\n+final cache = <String, int>{};\n+int? read(String key) => cache[key];\n+void clear() => cache.clear();\n',
      ),
      ReviewFile('binary', 'assets/sample.bin', ''),
    ],
    [
      ReviewThread('t1', 'price', '负数需要边界测试', line: 2),
      ReviewThread(
        't2',
        'price',
        '旧实现混淆了单价和数量',
        line: 2,
        oldSide: true,
        resolved: true,
      ),
      ReviewThread('t3', 'price', '此讨论属于旧版本'),
      ReviewThread('t4', 'cache', '缓存清除后应可重新加载', line: 3),
    ],
    1,
  );
}
