# Feature Request: Generic Type Parameter Support for Events and States

## Summary

bloc_enhancer_gen previously did not support event or state classes that declare generic type parameters (e.g. `class _AddTokenFailed<E extends Object>`). This caused build failures when such classes were used. This document describes the failure, the root cause, and the implementation.

**Status**: Option A (bound substitution) has been implemented in a local branch. See "Implemented Fix (Option A)" below.

## Motivation

Users may want type-safe error handling in events:

```dart
final class _AddTokenFailed<E extends Object> extends UserEvent {
  const _AddTokenFailed({required this.error, required this.stackTrace});
  final E error;
  final StackTrace stackTrace;
  // ...
}
```

This allows `userBloc.events.userAddTokenFailed(error: myException, stackTrace: st)` to preserve the concrete type of `myException` for consumers. Without generic support, users must use `Object` and lose type information.

## Current Behavior (Failure)

When the generator encounters an event/state with type parameters, it produces invalid code because:

1. **Parameter types**: `p.type.getDisplayString()` returns `E` for a type parameter. The generated code uses `refer('E')`, which produces `E` in the output. But `E` is not in scope in the generated `.g.dart` file—it's a type parameter of the source class in a different library.

2. **Result**: Generated code like `void addTokenFailed({required E error, ...})` fails to compile because `E` is undefined in the generated file's scope.

## Root Cause (Code Locations)

| File | Line | Issue |
|------|------|-------|
| `write_events.dart` | 100 | `..type = refer(p.type.getDisplayString())` — type params render as `E` with no scope |
| `write_factory.dart` | 78 | Same issue for factory creator methods |

## Proposed Implementation

### Implemented Fix (Option A): Use Bound Type

When a parameter's type is a `TypeParameterType`, substitute it with its bound (or `Object` if bound is `dynamic`).

**New file** `bloc_enhancer_gen/lib/src/writers/type_utils.dart`:

```dart
import 'package:analyzer/dart/element/type.dart';
import 'package:code_builder/code_builder.dart';

Reference typeToReference(DartType type) {
  if (type is TypeParameterType) {
    final bound = type.bound;
    if (bound is DynamicType) {
      return refer('Object');
    }
    return refer(bound.getDisplayString());
  }
  return refer(type.getDisplayString());
}
```

**Changes**: Replace `refer(p.type.getDisplayString())` with `typeToReference(p.type)` in `write_events.dart` (line 100) and `write_factory.dart` (line 78).

**Pros**: Minimal changes, works for all cases.  
**Cons**: Loses generic type safety at the call site (everything becomes `Object` or the bound).

### Option B: Propagate Type Parameters to Generated Methods (Full Support)

Add the class's type parameters to the generated method so the signature preserves generics:

```dart
// For class _AddTokenFailed<E extends Object>, generate:
void addTokenFailed<E extends Object>({required E error, required StackTrace stackTrace}) {
  if (_bloc.isClosed) return;
  _bloc.add(_AddTokenFailed<E>(error: error, stackTrace: stackTrace));
}
```

**Implementation outline**:

1. **Detect type parameters**: `event.element.typeParameters` (ClassElement) gives `List<TypeParameterElement>`.
2. **Parameter type resolution**: For `p.type` that is `TypeParameterType`:
   - If `p.type.element` is in the class's `typeParameters`, the generated method needs that type param.
   - Use `refer(p.type.element.name)` for the parameter type (it will be in scope once we add it to the method).
3. **Method type parameters**: Add `Method((b) => b..types.addAll(...))` for each class type parameter used in the constructor. Use `TypeReference((b) => b..symbol = tp.name..bound = ...)`.
4. **Constructor call**: For `_AddTokenFailed<E>`, use `refer('_AddTokenFailed').newInstance(..., typeArguments: [refer('E')])` or the code_builder equivalent.

**Pros**: Full type safety preserved.  
**Cons**: More complex; need to handle `code_builder` API for method type params and constructor type args.

### Option C: Reject with Clear Error (Minimal)

Explicitly skip or error on events/states with type parameters, with a helpful message:

```dart
if (event.element.typeParameters.isNotEmpty) {
  throw InvalidGenerationSourceError(
    'Event ${event.name} has type parameters, which are not supported. '
    'Use a concrete type (e.g. Object) instead.',
  );
}
```

**Pros**: No silent failures; users get clear guidance.  
**Cons**: Does not add the feature.

## Recommendation

- **Short term**: Implement **Option A** (bound substitution) for a quick fix. It unblocks users and is low risk.
- **Medium term**: Implement **Option B** for full generic support if there is demand.
- **Option C** can be added as a build.yaml option (e.g. `reject_generic_events: true`) for teams that want to enforce no-generics policy.

## Test Case

Add to `bloc_enhancer_test`:

```dart
// simple_event.dart
class _AddTokenFailed<E extends Object> extends SimpleEvent {
  const _AddTokenFailed({required this.error, required this.stackTrace});
  final E error;
  final StackTrace stackTrace;
}
```

Run `dart run build_runner build` and verify generated code compiles.

## References

- Analyzer: `TypeParameterType`, `ClassElement.typeParameters`, `DartType.bound`
- code_builder: `TypeReference`, `Method.types`, `refer().newInstance(typeArguments: ...)`
- Original issue: Flyby app `UserAddTokenFailed<E>` event
