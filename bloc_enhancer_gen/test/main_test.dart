import 'package:bloc_enhancer_gen/bloc_enhancer_gen.dart';
import 'package:bloc_enhancer_gen/models/settings.dart';
import 'package:generator_test/generator_test.dart';
import 'package:test/scaffolding.dart';

void main() {
  group('Generator', () {
    const files = {
      [
        'basic_bloc.dart',
        'basic_event.dart',
        'basic_state.dart',
      ]: ['basic_bloc.dart'],
    };

    for (final file in files.entries) {
      test('runs', () async {
        final tester = SuccessGenerator.fromBuilder(
          file.key,
          file.value,
          blocEnhancerGenerator,
          onLog: print,
          logLevel: Level.ALL,
          options: Settings.defaults().toJson(),
          partOfFile: 'basic_bloc.bloc_enhancer_gen.g.part',
        );

        await tester.test();
      });
    }
  });
}
