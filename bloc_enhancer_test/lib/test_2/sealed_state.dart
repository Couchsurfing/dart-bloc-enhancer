// --- LICENSE ---
/**
Copyright 2026 CouchSurfing International Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/
// --- LICENSE ---
part of 'sealed_bloc.dart';

sealed class SealedBlocState {
  const SealedBlocState();
}

final class _Loading extends SealedBlocState {
  const _Loading();
}

final class _Error extends SealedBlocState {
  const _Error({required this.message});
  final String message;
}

/// Sealed intermediate — shared for all "ready" sub-states.
sealed class _Ready extends SealedBlocState {
  const _Ready({required this.data});
  final String data;
}

final class _Idle extends _Ready {
  const _Idle({required super.data});
}

final class _Editing extends _Ready {
  const _Editing({required super.data, required this.editingId});
  final String editingId;
}
