import 'package:bloc_enhancer_gen/gen/settings.dart';
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
