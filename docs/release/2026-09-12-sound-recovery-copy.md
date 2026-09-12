# Sound recovery message

Parent `a5cdcc3`, branch `releaf-development`.

The shared playback-error state now includes timer/native transport failures,
so the previous message "Sound could not start" was too narrow. The player now
says "There was a playback problem. Try again." Existing Retry sound semantics,
icon and action were inspected and already match recovery behavior. No controller,
audio, timing or access changes.

The existing retry widget regression failed against the old copy and passed
after the change, including clearing the error after successful retry and not
exposing native details. Focused loading/recovery and Sound experience suite:
59 passed, exit 0. Formatting and diff checks passed.

- `flutter analyze`: no issues, exit 0 (14.9 seconds).
- `flutter build apk --debug --dart-define-from-file=tool/local/revenuecat-test-store.json`:
  exit 0, Gradle 35.1 seconds. Local configuration was not printed.
- APK: `build/app/outputs/flutter-apk/app-debug.apk`.
- `adb devices -l`: exit 0, empty device list; no installation performed.

The complete 525-test controller checkpoint immediately precedes this copy-only
change; no redundant full-suite run. Physical listening, background timer and
owner acceptance gates remain open. No installation or production action claimed.
