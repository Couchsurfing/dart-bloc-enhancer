import 'package:analyzer/dart/element/element.dart';

abstract interface class FactoryElement {
  const FactoryElement();

  ClassElement get element;
  bool get createFactory;
  String get name;
}
