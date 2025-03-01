## 3.1.2

- Renamed `io_html.dart` to `io_web.dart`.
  - Remove use of `dart:html` (deprecated) and use package `http`.

- http: ^1.3.0

## 3.1.1

- sdk: '>=3.5.0 <4.0.0'

- collection: ^1.18.0
- path: ^1.9.1
- typed_data: ^1.4.0

- test: ^1.25.15
- lints: ^5.0.0
- dependency_validator: ^3.2.3

## 3.1.0

- `ResourceLoader`:
  - Added method `resolveUri`.
- `Resource.uriResolved` now respects `ResourceLoader` (calls `_loader.resolveUri`).
- `PackageLoader`:
  - All constructor parameters are named parameters now.
    - `loader` is optional.
- `resolve_io.dart`
  - Fix path resolution on Windows.
  - Also checks for package files in the entry point directory (script or executable directory).
- `dart_test.yaml`
  - Added `exe` compiler to tests:
    - `compilers: [source, exe]`
- `resource_test.dart`:
  - Added test with existent file, to check a real URI resolution in VM (source and exe compilers).

- sdk: '>=2.18.0 <4.0.0'
- collection: ^1.17.1
- typed_data: ^1.3.2
- test: ^1.24.3

## 3.0.2

- `resolve_io.dart`:
  - `resolveUri`: allow working dir path resolution (useful for compiled/native execution).
- collection: ^1.17.0
- path: ^1.8.3

## 3.0.1

- Added `example/resource_portable_example.dart`.
- Improved Dart CI.
- typed_data: ^1.3.1
- test: ^1.22.1
- lints: ^2.0.1
- dependency_validator: ^3.2.2

## 3.0.0

- Dart 2.12.0:
  - Sound null safety compatibility.
  - Update CI dart commands.
- typed_data: ^1.3.0
- test: ^1.16.5
- pedantic: ^1.11.0

## 2.1.8
- dartfmt
- sdk: '>=2.7.0 <3.0.0'
- typed_data: ^1.2.0
- test: ^1.15.4
- pedantic: ^1.9.2
- CI: vm and firefox tests.

## 2.1.7
- Resource.uriResolved

## 2.1.6
- Cast stream to `List<int>` in 'readAsString', this is in preparation for
  `HttpClientResponse` implementing `Stream<Uint8List>` (forward compatible
  change, should be a no-op for existing usages)

## 2.1.5
- Require at least Dart 2.0.0-dev.61.

## 2.1.4
- Require at least Dart 2.0.0.

## 2.1.3
- Fix bug in `readAsBytes` which returned twice as much data as expected.

## 2.1.2
- Fix bug in `readAsString` when charset is LATIN-1 and content-length is set.

## 2.1.1
- Reduce max concurrent connections to the same host to 6 when using `dart:io`.
  That's the same limit that many browsers use.
- Trying to load a resource from a non-existing package now gives a better
  error message.

## 2.1.0
- Make failing HTTP requests throw an `HttpException`.

## 2.0.2
- Update README.md.

## 2.0.1
- Fix type warnings.

## 2.0.0
- Use configuration dependent imports to avoid having separate implementations
  for `dart:io` and `dart:html`.
- Remove `browser_resource.dart`.

## 1.1.0

- Added browser-compatible version as `browser_resource.dart` library.
  Only needed because configurable imports are not available yet.

## 1.0.0

- Initial version
