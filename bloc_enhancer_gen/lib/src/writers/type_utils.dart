// --- LICENSE ---
/**
Copyright 2026 CouchSurfing International Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/
// --- LICENSE ---

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:code_builder/code_builder.dart';

/// Raw [refer(type)] fails for type params — e.g. `E` is not in scope in the
/// generated `.g.dart` file. If we propagate the type param to the method
/// ([inScopeTypeParams]), use it; otherwise substitute the bound.
Reference typeToReference(
  DartType type, {
  Set<String> inScopeTypeParams = const {},
}) {
  if (type is TypeParameterType) {
    if (type.element.name case final name? when inScopeTypeParams.contains(name)) {
      return refer(name);
    }
    final bound = type.bound;
    if (bound is DynamicType) {
      return refer('Object');
    }
    return refer(bound.getDisplayString());
  }
  return refer(type.getDisplayString());
}

/// Method must declare the type param so it's in scope for parameter types.
Reference typeParameterToReference(TypeParameterElement tp) {
  final bound = tp.bound;
  return TypeReference((b) {
    b.symbol = tp.name ?? '';
    b.bound = switch (bound) {
      null => refer('Object'),
      final b when b is DynamicType => refer('Object'),
      final b => refer(b.getDisplayString()),
    };
  });
}
