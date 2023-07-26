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

        var fileResolved = possiblePaths
            .map((p) => File(p))
            .firstWhereOrNull((f) => f.existsSync());

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
