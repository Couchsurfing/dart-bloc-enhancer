# 0.7.0 | 2.2.2026

## Chore

- Update Analyzer dependency

# 0.6.0 | 9.19.2025

## Chore

- Update Analyzer dependency

# 0.5.1 | 5.5.2025

## Enhancements

- Ignore abstract classes when generating event & state methods

# 0.5.0 | 2.22.2025

## Chore

- Update Analyzer dependency

# 0.4.0 | 2.21.2025

## Chore

- Update Dart Formatter and Dart Style to latest versions

# 0.3.2+1 | 11.20.2024

## Features

- Create "as if" getters for state retrieval

```dart
if (state.asIfReady case final readyState?) {
    // Handle the ready state
}
```

# 0.3.1 | 10.4.2024

## Fixes

- Do not generate a factory for abstract classes

# 0.3.0 | 9.27.2024

## Features

- Support creating event factories
  - Annotate the base event class with `@createFactory`

## Enhancements

- Check for used names while creating event & state methods
  - If a name conflicts, the method's name will be suffixed with a number
  - This applies to create factories and event methods

## Breaking Changes

- Deprecate `@createStateFactory` in favor of `@createFactory`
  - This will be removed in a future release

# 0.2.0+1 | 8.20.2024

## Features

- Add check for if the bloc is closed before adding a new event

# 0.1.0+1 | 3.25.2024

Initial Release
