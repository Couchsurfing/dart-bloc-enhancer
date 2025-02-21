// --- LICENSE ---
/**
Copyright 2025 CouchSurfing International Inc.

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
abstract interface class SettingsInterface {
  /// Whether to automatically include all blocs in the project.
  bool get autoEnhance;

  /// A list of class name regex patterns (case sensitive) to use to determine
  /// which event classes should not be enhanced.
  List<String> get avoidEvents;

  /// A list of class name regex patterns (case sensitive) to use to determine
  /// which state classes should not be enhanced.
  List<String> get avoidStates;

  /// A list of class name regex patterns (case sensitive) to use to determine
  /// which blocs should be enhanced.
  ///
  /// If [autoEnhance] is true, this list is ignored.
  List<String> get enhance;

  /// Whether to create a class where all states can be accessed statically.
  ///
  /// This is useful for when you want to access (private) states during tests.
  bool get createStateFactory;

  /// Whether to create a class where all states can be accessed statically.
  ///
  /// This is useful for when you want to access (private) states during tests.
  bool get createEventFactory;
}
