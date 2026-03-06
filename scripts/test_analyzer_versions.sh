#!/usr/bin/env bash
# Test bloc_enhancer_gen with each major analyzer version (7, 8, 9, 10, 11).
# Ensures code generation and compilation work across analyzer releases.

set -e

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
GEN_DIR="$ROOT/bloc_enhancer_gen"
TEST_DIR="$ROOT/bloc_enhancer_test"
GEN_OVERRIDES="$GEN_DIR/pubspec_overrides.yaml"
TEST_OVERRIDES="$TEST_DIR/pubspec_overrides.yaml"
GEN_OVERRIDES_BAK="$GEN_DIR/pubspec_overrides.yaml.bak"
TEST_OVERRIDES_BAK="$TEST_DIR/pubspec_overrides.yaml.bak"

# One version per major branch supported by build/build_runner (>=8.0.0 <11.0.0).
# Using later minors for compatibility with build_runner 2.10.5.
VERSIONS=(8.4.1 9.0.0 10.0.0)

restore_overrides() {
  if [[ -f "$GEN_OVERRIDES_BAK" ]]; then
    mv "$GEN_OVERRIDES_BAK" "$GEN_OVERRIDES"
  fi
  if [[ -f "$TEST_OVERRIDES_BAK" ]]; then
    mv "$TEST_OVERRIDES_BAK" "$TEST_OVERRIDES"
  fi
}

trap restore_overrides EXIT

run_test() {
  local version=$1
  echo ""
  echo "========================================"
  echo "Testing analyzer $version"
  echo "========================================"

  # Write overrides with analyzer pin (both packages must use same version)
  cat > "$GEN_OVERRIDES" << EOF
dependency_overrides:
    bloc_enhancer:
        path: ../bloc_enhancer
    analyzer: "$version"
EOF
  cat > "$TEST_OVERRIDES" << EOF
dependency_overrides:
    bloc_enhancer:
        path: ../bloc_enhancer
    bloc_enhancer_gen:
        path: ../bloc_enhancer_gen
    analyzer: "$version"
EOF

  # Resolve dependencies (sip used in scripts.yaml)
  if command -v sip &>/dev/null; then
    cd "$ROOT" && sip pub get -r
  else
    cd "$GEN_DIR" && dart pub get
    cd "$TEST_DIR" && dart pub get
  fi

  # Build generator and run codegen on test package
  cd "$TEST_DIR" && dart run build_runner build --delete-conflicting-outputs

  # Run tests
  if command -v sip &>/dev/null; then
    cd "$ROOT" && sip test --recursive --concurrent
  else
    cd "$GEN_DIR" && dart test
    cd "$TEST_DIR" && dart test
  fi

  echo "✓ analyzer $version: build and tests passed"
}

# Backup original overrides
cp "$GEN_OVERRIDES" "$GEN_OVERRIDES_BAK"
cp "$TEST_OVERRIDES" "$TEST_OVERRIDES_BAK"

echo "Testing bloc_enhancer_gen with analyzer versions: ${VERSIONS[*]}"
for v in "${VERSIONS[@]}"; do
  run_test "$v"
done

restore_overrides
trap - EXIT

echo ""
echo "All analyzer versions passed!"
