// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async' show Future, Stream;
import 'dart:convert' show Encoding;

import 'package:path/path.dart' as pack_path;

import 'io_none.dart'
    if (dart.library.io) 'io_io.dart'
    if (dart.library.js_interop) 'io_web.dart' as io;
import 'package_loader.dart';
import 'resolve_none.dart'
    if (dart.library.io) 'resolve_io.dart'
    if (dart.library.js_interop) 'resolve_web.dart' as uri_resolver;

/// A [Resource] [Uri] resolver with an internal cache.
/// - The default [uriResolver] can resolve package files.
class ResourceURIResolver {
  static final ResourceURIResolver defaultResolver = ResourceURIResolver();

  /// The [Uri] parsers.
  /// - Default: [defaultParseUri]
  final Uri Function(String s) uriParser;

  /// The implementation of the [uri] resolver.
  final Future<Uri> Function(Uri uri) uriResolver;

  ResourceURIResolver({
    this.uriParser = defaultParseUri,
    this.uriResolver = uri_resolver.resolveUri,
  });

  /// Parses [s] to [Uri].
  /// - See [parseUriCached].
  Uri parseUri(String s) => uriParser(s);

  final Map<String, Uri> _parseUriCache = {};

  /// Parses [s] to [Uri] and caches the result.
  /// - Calls [parseUri].
  Uri parseUriCached(String s) => _parseUriCache[s] ??= parseUri(s);

  /// Clears the cache for [parseUriCached].
  void clearParseUriCache() {
    _parseUriCache.clear();
  }

  /// The amount of cached entries from [parseUriCached].
  int get parseUriCacheSize => _parseUriCache.length;

  static Uri defaultParseUri(String s) {
    Uri uri;
    if (!s.startsWith('package:')) {
      uri = pack_path.toUri(s);
    } else {
      uri = Uri.parse(s);
    }
    return uri;
  }

  /// Resolves [uri] WITHOUT caching the result.
  /// - Calls [uriResolver].
  /// - See [resolveUriCached].
  Future<Uri> resolveUri(Uri uri) => uriResolver(uri);

  final Map<Uri, Uri> _resolveCache = {};

  /// Resolves [uri] and caches the result.
  /// - Calls [resolveUri].
  Future<Uri> resolveUriCached(Uri uri) async {
    var resolvedURI = _resolveCache[uri];
    if (resolvedURI != null) return resolvedURI;

    resolvedURI = await resolveUri(uri);
    _resolveCache[uri] = resolvedURI;

    return resolvedURI;
  }

  /// Clears the cache for [resolveUriCached].
  void clearResolveUriCache() {
    _resolveCache.clear();
  }

  /// The amount of cached entries from [resolveUriCached].
  int get resolveUriCacheSize => _resolveCache.length;

  /// Clears all caches.
  void clearCache() {
    clearResolveUriCache();
    clearParseUriCache();
  }
}

/// Resource loading strategy.
///
/// An abstraction of the functionality needed to load resources.
///
/// Implementations of this interface decide which URI schemes they support.
abstract class ResourceLoader {
  /// A resource loader that can load as many of the following URI
  /// schemes as are supported by the platform:
  /// * file
  /// * http
  /// * https
  /// * data
  /// * package
  ///
  /// For example, `file:` URIs are not supported in the browser.
  /// Relative URI references are accepted - they are resolved against
  /// [Uri.base] before being loaded.
  ///
  /// This loader is automatically used by the `Resource` class
  /// if no other loader is specified.
  static ResourceLoader get defaultLoader => const PackageLoader();

  /// Parses [s] to [Uri].
  Uri parseUri(String s);

  /// Resolved [uri] to the actual [Uri] to load.
  Future<Uri> resolveUri(Uri uri);

  /// Reads the file located by [uri] as a stream of bytes.
  Stream<List<int>> openRead(Uri uri);

  /// Reads the file located by [uri] as a list of bytes.
  Future<List<int>> readAsBytes(Uri uri);

  /// Reads the file located by [uri] as a [String].
  ///
  /// The file bytes are decoded using [encoding], if provided.
  ///
  /// If [encoding] is omitted, the default for the `file:` scheme is UTF-8.
  /// For `http`, `https` and `data` URIs, the Content-Type header's charset
  /// is used, if available and recognized by [Encoding.getByName],
  /// otherwise it defaults to Latin-1 for `http` and `https`
  /// and to ASCII for `data` URIs.
  Future<String> readAsString(Uri uri, {Encoding? encoding});
}

/// Default implementation of [ResourceLoader].
///
/// Uses the system's available loading functionality to implement the
/// loading functions.
///
/// Supports as many of `http:`, `https:`, `file:` and `data:` URIs as
/// possible.
///
/// [resolveUri] won't resolve package files.
class DefaultLoader implements ResourceLoader {
  /// The [Uri] resolver, used by [resolveUri].
  /// - If not defined the [Uri] won't be changed/resolved.
  final ResourceURIResolver? uriResolver;

  const DefaultLoader({this.uriResolver});

  @override
  Uri parseUri(String s) {
    final uriResolver = this.uriResolver;
    if (uriResolver != null) {
      return uriResolver.parseUri(s);
    }
    return ResourceURIResolver.defaultParseUri(s);
  }

  @override
  Future<Uri> resolveUri(Uri uri) {
    final uriResolver = this.uriResolver;
    if (uriResolver != null) {
      return uriResolver.resolveUriCached(uri);
    }
    return Future.value(uri);
  }

  @override
  Stream<List<int>> openRead(Uri uri) async* {
    yield* io.readAsStream(await resolveUri(uri));
  }

  @override
  Future<List<int>> readAsBytes(Uri uri) async =>
      io.readAsBytes(await resolveUri(uri));

  @override
  Future<String> readAsString(Uri uri, {Encoding? encoding}) async =>
      io.readAsString(await resolveUri(uri), encoding);
}
