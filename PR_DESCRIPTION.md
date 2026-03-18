# Support generic type parameters in event and state classes

## Problem

Event and state classes with generic type parameters (e.g. `class _AddTokenFailed<E extends Object>`) caused build failures. The generator emitted `refer('E')` for parameter types, but `E` is not in scope in the generated `.g.dart` file, producing:

```
Undefined class 'E'. Try changing the name to the name of an existing class.
```

## Solution

Propagate type parameters to the generated methods and constructor calls:

- Add the class's type parameters to the generated method signature (e.g. `void addTokenFailed<E extends Object>({required E error, ...})`)
- Pass type arguments when instantiating the event (e.g. `_AddTokenFailed<E>(error: error, ...)`)
- Parameter types that are type parameters use the in-scope name; others use `typeToReference()` (substitutes bound for out-of-scope type params)

## Changes

- **New:** `type_utils.dart` — `typeToReference()` with `inScopeTypeParams` for propagation, `typeParameterToReference()` for method type params
- **Updated:** `write_events.dart` — add method type params, pass type args to `newInstance`, use in-scope type refs for params
- **Updated:** `write_factory.dart` — same for factory creator methods
- **Test:** Added `_AddTokenFailed<E extends Object>` event and test coverage
- **Version:** 0.9.1
