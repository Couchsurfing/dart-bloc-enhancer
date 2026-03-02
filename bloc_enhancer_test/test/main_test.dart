import 'package:_/lib.dart';
import 'package:test/test.dart';

void main() {
  group('$SealedBloc (sealed intermediate)', () {
    test('generates isReady/asReady/asIfReady for sealed _Ready', () async {
      final bloc = SealedBloc();
      final state = bloc.state;

      // Loading state: isReady is false, asIfReady is null
      expect(state.isLoading, isTrue);
      expect(state.isReady, isFalse);
      expect(state.asIfReady, isNull);

      // Load transitions to Idle (extends _Ready) - asIfReady gives access to shared fields
      bloc.events.load();
      await bloc.stream.first;

      final readyState = bloc.state;
      expect(readyState.isReady, isTrue);
      expect(readyState.asIfReady, isNotNull);
      expect(readyState.asIfReady!.data, equals('test'));
    });
  });

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
