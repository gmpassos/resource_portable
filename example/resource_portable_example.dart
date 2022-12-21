import 'dart:convert' show utf8;

import 'package:resource_portable/resource.dart' show Resource;

main() async {
  var resource = Resource("package:foo/foo_data.txt");
  var content = await resource.readAsString(encoding: utf8);
  print(content);
}
