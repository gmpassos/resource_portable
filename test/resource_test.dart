// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@TestOn('vm')
library;

import 'dart:async' show Future, Stream;
import 'dart:convert' show Encoding, ascii;
import 'dart:io';
import 'dart:isolate';
import 'package:resource_portable/resource.dart';
import 'package:resource_portable/src/resolve_io.dart' as resolver;
import 'package:resource_portable/src/resource_loader.dart';
import 'package:test/test.dart';

void main() {
  Uri pkguri(path) => Uri(scheme: 'package', path: path);

  group('loading', () {
    Future testLoad(Uri uri, {bool fileExists = false}) async {
      var loader = LogLoader();
      var resource = Resource(uri, loader: loader);
      var resolved = await resolveTestUri(uri);

      expect(resolved.path, isNotEmpty);

      var expectedBytes = loadUriBytes(fileExists ? resolved : uri);

      expect(
        expectedBytes,
        fileExists ? isNot([0, 0, 0]) : equals([0, 0, 0]),
      );

      var res = await resource.openRead().toList();
      expect(res, [expectedBytes]);

      var res1 = await resource.readAsBytes();
      expect(res1, expectedBytes);

      var res2 = await resource.readAsString(encoding: ascii);
      expect(res2, String.fromCharCodes(expectedBytes));

      expect(loader.requests, [
        ['Stream', resolved],
        ['Bytes', resolved],
        ['String', resolved, ascii]
      ]);
    }

    test('load package: URIs (file exists)', () async {
      await testLoad(pkguri('resource_portable/resource/file-sample.txt'),
          fileExists: true);
    });

    test('load package: URIs (non-existent file)', () async {
      await testLoad(pkguri('test/foo/baz'));
    });

    test('load non-pkgUri', () async {
      await testLoad(Uri.parse('file://localhost/something?x#y'));
      await testLoad(Uri.parse('http://auth/something?x#y'));
      await testLoad(Uri.parse('https://auth/something?x#y'));
      await testLoad(Uri.parse('data:,something?x'));
      await testLoad(Uri.parse('unknown:/something'));
    });
  });

  group('resolveUriWith', () {
    // Simulates Flutter, where `Isolate.resolvePackageUri` isn't supported:
    Future<Uri?> unsupported(Uri uri) =>
        throw UnsupportedError('Isolate.resolvePackageUriSync');

    Future<Uri?> unsupportedAsync(Uri uri) async =>
        throw UnsupportedError('Isolate.resolvePackageUriSync');

    Future<Uri?> notFound(Uri uri) async => null;

    test('UnsupportedError: falls back to a file search', () async {
      for (var packageUriResolver in [unsupported, unsupportedAsync]) {
        var resolved = await resolver.resolveUriWith(
            pkguri('resource_portable/resource/file-sample.txt'),
            packageUriResolver);

        expect(resolved.scheme, equals('file'));
        expect(File(resolved.toFilePath()).readAsStringSync(),
            contains('file sample'));
      }
    });

    test('UnsupportedError: no file found', () async {
      for (var packageUriResolver in [unsupported, unsupportedAsync]) {
        await expectLater(
            resolver.resolveUriWith(
                pkguri('resource_portable/no-such-file.txt'),
                packageUriResolver),
            throwsA(isA<UnsupportedError>().having((e) => e.message, 'message',
                contains("can't be resolved on this platform"))));
      }
    });

    test('unknown package URI', () async {
      await expectLater(
          resolver.resolveUriWith(
              pkguri('resource_portable/no-such-file.txt'), notFound),
          throwsArgumentError);
    });
  });
}

class LogLoader implements ResourceLoader {
  final List requests = [];

  void reset() {
    requests.clear();
  }

  @override
  Stream<List<int>> openRead(Uri uri) async* {
    requests.add(['Stream', uri]);
    yield loadUriBytes(uri);
  }

  @override
  Future<List<int>> readAsBytes(Uri uri) async {
    requests.add(['Bytes', uri]);
    return loadUriBytes(uri);
  }

  @override
  Future<String> readAsString(Uri uri, {Encoding? encoding}) async {
    requests.add(['String', uri, encoding]);
    return String.fromCharCodes(loadUriBytes(uri));
  }

  @override
  Uri parseUri(String s) => ResourceURIResolver.defaultParseUri(s);

  @override
  Future<Uri> resolveUri(Uri uri) => resolveTestUri(uri);
}

Future<Uri> resolveTestUri(Uri source) async {
  if (source.scheme == 'package') {
    var fileExists = source.path.startsWith('resource_portable/');

    if (fileExists) {
      return resolver.resolveUri(source);
    } else {
      var resolved = await Isolate.resolvePackageUri(source);
      resolved ??= source;
      return resolved;
    }
  }
  return Uri.base.resolveUri(source);
}

List<int> loadUriBytes(Uri uri) {
  if (uri.scheme == 'file') {
    try {
      var file = File(uri.toFilePath());
      if (file.existsSync()) {
        return file.readAsBytesSync();
      }
    } catch (_) {}
  }

  // no existent files:
  return [0x00, 0x00, 0x00];
}
