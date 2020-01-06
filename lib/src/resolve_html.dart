// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import "dart:async" show Future;

/// Helper function for resolving to a non-relative, non-package URI.
Future<Uri> resolveUri(Uri uri) {
  //print("resolveUri(html)>>>>>>>> $uri") ;

  if (uri.scheme == "package") {

    String resolvedPath = "packages/${ uri.path }" ;

    var basePath = Uri.base.path;

    if ( basePath.isNotEmpty ) {
      if ( !basePath.endsWith("/") ) {
        int idx = basePath.lastIndexOf('/') ;

        if (idx >= 0) {
          basePath = basePath.substring(0, idx);
        }
      }

      if (basePath.endsWith('/')) {
        basePath = basePath.substring(0, basePath.length-1) ;
      }

      if (basePath.isNotEmpty) {
        resolvedPath = "$basePath/packages/${ uri.path }";
      }
    }

    Uri resolvedUri = Uri(
      scheme: Uri.base.scheme,
      host: Uri.base.host,
      port: Uri.base.port,
      path: resolvedPath ,
    ) ;

    //print("resolvedUri>> $resolvedUri") ;

    return Future.value(resolvedUri) ;
  }

  return Future<Uri>.value(Uri.base.resolveUri(uri));
}
