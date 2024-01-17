[![Pub Package](https://img.shields.io/pub/v/bloc_enhancer_gen.svg)](https://pub.dev/packages/bloc_enhancer_gen)

# `bloc_enhancer`

`bloc_enhancer_gen` is a code generator package that complements [`bloc_enhancer`](https://pub.dev/packages/bloc_enhancer) by automating the generation of streamlined Bloc event and state classes. This generator simplifies and enhances the development process, allowing for more intuitive and efficient state management.

## Why `bloc_enhancer_gen`?

For reals, I needed it.

### The Problem

My biggest (prior) complaint for using bloc was naming. Generally, you have to prepend all public states and events with the bloc's name to avoid naming conflicts with other blocs (You can't have 2 `Ready` states 🙄), then the names started to get long.

You'd also have to remember what the name of your event is to invoke `bloc.add(YourBlocEven())`. You'd also have to remember what the name of your state is to check `bloc.state is YourBlocState`. This is all fine and dandy for small projects, but as your project grows, it becomes a pain to manage.

There are packages that help you with mapping out your states... but dart only allows 80 characters per line, so nesting all of your (UI) code within a `bloc.state.map` is not ideal.

### The Solution

`bloc_enhancer_gen` is a code generator that generates a set of extensions that allow you to invoke events and check states intuitively.

```dart
// Simplified events (you can use intellisense! 🙌)
bloc.events.createUser(name: 'John');

// Intuitive state type check and retrieval
if (bloc.state.isReady) {
final readyState = bloc.state.asReady;
// Handle the ready state
}
```

## Getting Started

1. Add the `bloc_enhancer`, `bloc_enhancer_gen`, `build_runner` packages to your `pubspec.yaml` file:

    ```yaml
    dependencies:
        bloc_enhancer: # latest version

    dev_dependencies:
        bloc_enhancer_gen: # latest version
        build_runner: # latest version
    ```

2. Configure the build runner to use `bloc_enhancer_gen` in your `build.yaml` file:

    ```yaml
    targets:
        $default:
            builders:
                bloc_enhancer_gen:
                    generate_for:
                        - lib/blocs/*.dart
                    options:
                        auto_enhance: false # set to true to automatically enhance all Blocs
    ```

3. Feed Bloc to the generator using `@enhance` or the config in `build.yaml`.

### Using `@enhance`

```dart
 import 'package:bloc_enhancer/bloc_enhancer.dart';

@enhance
class UserBloc extends Bloc<UserEvent, UserState> {
     ...
}
```

### Using `build.yaml`

```yaml
targets:
    $default:
        builders:
            bloc_enhancer_gen:
                generate_for:
                    - lib/**.dart
                options:
                    auto_enhance: true
```

`bloc_enhancer_gen` will read your events and your states.

```dart
// user_event.dart
class UserEvent {}
class _Create extends UserEvent {}
class _UpdateUser extends UserEvent {
    const _Update.name(String this.name): email = null;
    const UpdateUser.email(String this.email): name = null;

    final String? name;
    final String? email;
}

// user_state.dart
class UserState {}
class _Ready extends UserState {
    const Ready(this.user);

    final User user;
}
class _Loading extends UserState {}
class _Error extends UserState {
    const Error(this.message);

    final String message;
}
```

1. Run the build command to generate the enhanced Bloc classes:

    ```bash
    # using flutter
    flutter pub run build_runner build --delete-conflicting-outputs

     # using dart
     pub run build_runner build --delete-conflicting-outputs
    ```

## A note about `build_runner`

The build runner can be slow if you have a large project. It really starts to slow down with **nested folders**. To get the optimal performance, I recommend flattening your files that require generation as much as possible. This will allow the build runner to only scan the files that are necessary.

Slow 🚶

```tree
lib
└── blocs
    ├── user
    │   ├── user_bloc.dart
    │   ├── user_event.dart
    │   └── user_state.dart
    └── post
        ├── post_bloc.dart
        ├── post_event.dart
        └── post_state.dart
```

Fast 🏃

```tree
lib
├── user_bloc.dart
├── user_event.dart
├── user_state.dart
├── post_bloc.dart
├── post_event.dart
└── post_state.dart
```

You can also use the `exclude` option in `build.yaml` to exclude folders that don't need to be scanned.

```yaml
targets:
    $default:
        builders:
            bloc_enhancer_gen:
                generate_for:
                    include:
                        - lib/blocs/*.dart
                    exclude:
                        - lib/ui/**
```

_`generate_for.include` & `generate_for.exclude` are not bound to this package. They are part of the `build.yaml` format. You can read more [here](https://github.com/dart-lang/build/blob/master/docs/build_yaml_format.md)_
