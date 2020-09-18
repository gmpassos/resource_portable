# Resource (portable)

- Note: This package is a portable (Web compatible) fork from original [resource](https://pub.dev/packages/resource) package.
- The usage of this package should be the same of original `resource` package, beside import line.

---

[![pub package](https://img.shields.io/pub/v/resource_portable.svg?logo=dart&logoColor=00b9fc)](https://pub.dartlang.org/packages/resource_portable)
[![CI](https://img.shields.io/github/workflow/status/gmpassos/resource_portable/Dart%20CI/master?logo=github-actions&logoColor=white)](https://github.com/gmpassos/resource_portable/actions)
[![GitHub Tag](https://img.shields.io/github/v/tag/gmpassos/resource_portable?logo=git&logoColor=white)](https://github.com/gmpassos/resource_portable/releases)
[![New Commits](https://img.shields.io/github/commits-since/gmpassos/resource_portable/latest?logo=git&logoColor=white)](https://github.com/gmpassos/resource_portable/network)
[![Last Commits](https://img.shields.io/github/last-commit/gmpassos/resource_portable?logo=git&logoColor=white)](https://github.com/gmpassos/resource_portable/commits/master)
[![Pull Requests](https://img.shields.io/github/issues-pr/gmpassos/resource_portable?logo=github&logoColor=white)](https://github.com/gmpassos/resource_portable/pulls)
[![Code size](https://img.shields.io/github/languages/code-size/gmpassos/resource_portable?logo=github&logoColor=white)](https://github.com/gmpassos/resource_portable)
[![License](https://img.shields.io/github/license/gmpassos/resource_portable?logo=open-source-initiative&logoColor=green)](https://github.com/gmpassos/resource_portable/blob/master/LICENSE)

Reading data from package contents and files.

A resource is data that can be read into a Dart program at runtime.
A resource is identified by a URI. It can be loaded as bytes or data.
The resource URI may be a package: URI.

Example:

```dart
import 'package:resource_portable/resource.dart' show Resource;
import 'dart:convert' show utf8;

main() async {
  var resource = new Resource("package:foo/foo_data.txt");
  var string = await resource.readAsString(encoding: utf8);
  print(string);
}
```

## Learning more

Please check out the [API docs](https://www.dartdocs.org/documentation/resource/latest).

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/gmpassos/resource_portable/issues

## Author

Graciliano M. Passos: [gmpassos@GitHub][github].

[github]: https://github.com/gmpassos

## License

Dart free & open-source [license](https://github.com/dart-lang/stagehand/blob/master/LICENSE).
