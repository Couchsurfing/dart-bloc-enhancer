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

import 'package:analyzer/dart/element/type.dart';
import 'package:code_builder/code_builder.dart';

/// Returns a [Reference] for use in generated code.
///
/// When [type] is a [TypeParameterType] (e.g. `E` from `class Foo<E>`),
/// the type parameter is not in scope in the generated file. We substitute
/// its bound (or `Object` if the bound is dynamic) so the generated code compiles.
Reference typeToReference(DartType type) {
  if (type is TypeParameterType) {
    final bound = type.bound;
    if (bound is DynamicType) {
      return refer('Object');
    }
    return refer(bound.getDisplayString());
  }
  return refer(type.getDisplayString());
}
