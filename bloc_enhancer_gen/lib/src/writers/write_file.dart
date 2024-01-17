import 'package:bloc_enhancer_gen/src/models/bloc_element.dart';
import 'package:bloc_enhancer_gen/src/writers/write_events.dart';
import 'package:bloc_enhancer_gen/src/writers/write_states.dart';
import 'package:code_builder/code_builder.dart';

List<Spec> writeFile(List<BlocElement> blocs) {
  final events = writeEvents(blocs);
  final states = writeStates(blocs);

  return [
    ...events,
    ...states,
  ];
}
