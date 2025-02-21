// --- LICENSE ---
/**
Copyright 2025 CouchSurfing International Inc.

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
import 'package:bloc_enhancer_gen/models/settings.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'src/bloc_enhance_generator.dart';

/// The entry point for the bloc_enhancer generator.
Builder blocEnhancerGenerator(BuilderOptions options) {
  final settings = Settings.fromJson(options.config);

  return SharedPartBuilder(
    [
      BlocEnhancerGenerator(settings),
    ],
    'bloc_enhancer_gen',
  );
}
