import 'package:bloc_enhancer/bloc_enhancer.dart';

import 'package:bloc_enhancer_gen/src/checkers/type_checker.dart';

const TypeChecker blocChecker =
    TypeChecker.fromName('Bloc', packageName: 'bloc');
final TypeChecker enhanceChecker =
    TypeChecker.fromName('$Enhance', packageName: 'bloc_enhancer');
final TypeChecker ignoreChecker =
    TypeChecker.fromName('$Ignore', packageName: 'bloc_enhancer');
final TypeChecker stateFactoryChecker =
    TypeChecker.fromName('$StateFactory', packageName: 'bloc_enhancer');
