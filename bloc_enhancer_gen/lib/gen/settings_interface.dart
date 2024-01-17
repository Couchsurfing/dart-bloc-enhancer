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
}
