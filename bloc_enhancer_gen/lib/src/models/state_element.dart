import 'package:analyzer/dart/element/element.dart';

class StateElement {
  StateElement({
    required this.element,
    required this.createFactory,
  });

  final ClassElement element;
  bool createFactory;

  String get name => element.name;
}
