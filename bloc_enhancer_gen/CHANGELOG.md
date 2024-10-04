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
