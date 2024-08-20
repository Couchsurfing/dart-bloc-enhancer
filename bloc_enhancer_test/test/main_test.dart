import 'package:_/lib.dart';
import 'package:test/test.dart';

void main() {
  group('$SimpleBloc', () {
    group('State Typing', () {
      test('has all states', () {
        final bloc = SimpleBloc();

        final state = bloc.state;
        expect(state.isLoading, isA<bool>());
        expect(state.isReady, isA<bool>());
        expect(state.isError, isA<bool>());

        expect(state, isA<SimpleState>());

        expect(state.asLoading, isA<SimpleState>());
        expect(() => state.asReady, throwsA(isA()));
        expect(() => state.asError, throwsA(isA()));
      });
    });

    test('does not add events after bloc is closed', () async {
      final bloc = SimpleBloc();

      await bloc.close();

      expect(bloc.events.init, returnsNormally);
    });
  });
}
