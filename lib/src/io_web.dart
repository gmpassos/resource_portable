// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async' show Future, Stream;
import 'dart:convert' show Encoding, utf8;

import 'package:http/http.dart' as http;

/// Reads the bytes of a URI as a stream of bytes.
Stream<List<int>> readAsStream(Uri uri) async* {
  // TODO(lrn): Should file be run through XmlHTTPRequest too?
  if (uri.scheme == 'http' || uri.scheme == 'https') {
    // TODO: Stream in chunks if DOM has a way to do so.
    var response = await http.readBytes(uri);
    yield response;
    return;
  }
  if (uri.scheme == 'data') {
    yield uri.data!.contentAsBytes();
    return;
  }
  throw UnsupportedError('Unsupported scheme: $uri');
}

/// Reads the bytes of a URI as a list of bytes.
Future<List<int>> readAsBytes(Uri uri) async {
  if (uri.scheme == 'http' || uri.scheme == 'https') {
    return http.readBytes(uri);
  }
  if (uri.scheme == 'data') {
    return uri.data!.contentAsBytes();
  }
  throw UnsupportedError('Unsupported scheme: $uri');
}

/// Reads the bytes of a URI as a string.
Future<String> readAsString(Uri uri, Encoding? encoding) async {
  if (uri.scheme == 'http' || uri.scheme == 'https') {
    // Fetch as string if the encoding is expected to be understood,
    // otherwise fetch as bytes and do decoding using the encoding.
    if (encoding != null) {
      return encoding.decode(await http.readBytes(uri));
    }

    return utf8.decode(await http.readBytes(uri));
  }
  if (uri.scheme == 'data') {
    return uri.data!.contentAsString(encoding: encoding);
  }
  throw UnsupportedError('Unsupported scheme: $uri');
}
