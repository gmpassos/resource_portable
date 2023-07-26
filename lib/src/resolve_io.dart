// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async' show Future;
import 'dart:io';
import 'dart:isolate' show Isolate;
import 'package:path/path.dart' as pack_path;
import 'package:collection/collection.dart';

/// Helper function for resolving to a non-relative, non-package URI.
Future<Uri> resolveUri(Uri uri) {
  if (uri.scheme == 'package') {
    return Isolate.resolvePackageUri(uri).then((resolvedUri) {
      if (resolvedUri == null) {
        var path = uri.path;
        var pathParts = pack_path.split(uri.path);
        var pathParts2 =
            pathParts.length > 1 ? pathParts.sublist(1) : pathParts;

        var path2 = pack_path.joinAll(pathParts2);

        var pathSeparator = pack_path.separator;

        var prefixes = ['packages$pathSeparator', 'lib$pathSeparator', ''];

        var possiblePaths = [
          ...prefixes.map((p) => '$p$path'),
          if (path2 != path) ...prefixes.map((p) => '$p$path2'),
        ];

        var possibleFiles = possiblePaths.map((p) => File(p)).toList();

        var fileResolved =
            possibleFiles.firstWhereOrNull((f) => f.existsSync());

        if (fileResolved == null) {
          var entryPointDir = _entryPointDirectory();
          var currentDir = Directory.current;

          var possibleFiles = [
            if (entryPointDir != null)
              ...possiblePaths
                  .map((p) => File(pack_path.join(entryPointDir.path, p))),
            ...possiblePaths
                .map((p) => File(pack_path.join(currentDir.path, p))),
          ];

          fileResolved = possibleFiles.firstWhereOrNull((f) => f.existsSync());
        }

        if (fileResolved != null) {
          resolvedUri = fileResolved.absolute.uri;
        }
      }

      if (resolvedUri == null) {
        throw ArgumentError.value(uri.toString(), 'uri', 'Unknown package URI');
      }

      return resolvedUri;
    });
  }

  var resolvedUri = Uri.base.resolveUri(uri);
  return Future<Uri>.value(resolvedUri);
}

/// Returns the [Platform.script] or [Platform.resolvedExecutable] (if compiled).
Directory? _entryPointDirectory() {
  var script = Platform.script;
  var executable = Platform.resolvedExecutable;

  var scriptFile = _absoluteFile(script.toFilePath());
  var executableFile = _absoluteFile(executable);

  if (scriptFile == null && executableFile == null) {
    return null;
  } else if (scriptFile == null) {
    return executableFile!.parent;
  } else if (executableFile == null) {
    return scriptFile.parent;
  } else {
    var scriptDir = scriptFile.parent;
    var executableDir = executableFile.parent;

    if (executableDir.path == scriptDir.path) {
      return executableDir;
    } else {
      return scriptDir;
    }
  }
}

File? _absoluteFile(String filePath) {
  try {
    var file = File(filePath).absolute;
    if (file.existsSync()) {
      return file;
    }
  } catch (_) {}

  return null;
}
