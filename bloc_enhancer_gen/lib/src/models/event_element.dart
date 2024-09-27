import 'package:analyzer/dart/element/element.dart';
import 'package:bloc_enhancer_gen/src/models/factory_element.dart';

class EventElement implements FactoryElement {
  EventElement({
    required this.element,
    required this.createFactory,
  });

  @override
  final ClassElement element;

  @override
  bool createFactory;

  @override
  String get name => element.name;
}
