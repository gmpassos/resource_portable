// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async' show Future, Stream;
import 'dart:convert' show Encoding;

import 'resource_loader.dart';

/// Implementation of [ResourceLoader] that accepts relative and package: URIs.
///
/// Acts like the `loader` it is provided with except that it resolves
/// package URIs and relative URI references before loading them.
///
/// This class may be useful when you don't want to bother creating a resource
/// object, and just want to load a package resource directly.
class PackageLoader implements ResourceLoader {
  final ResourceLoader _loader;

  /// The [Uri] resolver, used by [resolveUri].
  /// - If not defined will use [ResourceURIResolver.defaultResolver].
  final ResourceURIResolver? uriResolver;

  const PackageLoader({ResourceLoader? loader, this.uriResolver})
      : _loader = loader ?? const DefaultLoader();

  @override
  Future<Uri> resolveUri(Uri uri) {
    var uriResolver = this.uriResolver ?? ResourceURIResolver.defaultResolver;
    return uriResolver.resolveUri(uri);
  }

  @override
  Stream<List<int>> openRead(Uri uri) async* {
    yield* _loader.openRead(await resolveUri(uri));
  }

  @override
  Future<List<int>> readAsBytes(Uri uri) async =>
      _loader.readAsBytes(await resolveUri(uri));

  @override
  Future<String> readAsString(Uri uri, {Encoding? encoding}) async =>
      _loader.readAsString(await resolveUri(uri), encoding: encoding);
}
