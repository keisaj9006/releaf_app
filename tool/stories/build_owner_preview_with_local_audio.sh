#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'TEXT'
Build the private Relief Stories owner-preview APK from a local audio ZIP or
APP_DELIVERY directory.

Usage:
  ./tool/stories/build_owner_preview_with_local_audio.sh \
    "/path/to/Relief-Stories-Audio-Delivery-Pack-v2.zip"

or:
  ./tool/stories/build_owner_preview_with_local_audio.sh \
    "/path/to/APP_DELIVERY"

The verified M4A masters are copied only for the duration of the build and are
removed from the working tree automatically. The APK remains in build/qa-apks.
TEXT
}

if [[ $# -ne 1 ]]; then
  usage >&2
  exit 64
fi

INPUT=$1
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
ROOT=$(cd "$SCRIPT_DIR/../.." && pwd)
ASSET_DIR="$ROOT/assets/audio/stories"
OUTPUT_DIR="$ROOT/build/qa-apks"
OUTPUT_APK="$OUTPUT_DIR/Relief-Stories-Owner-Preview.apk"
TEMP_DIR=$(mktemp -d "${TMPDIR:-/tmp}/relief-stories.XXXXXX")
BACKUP_DIR="$TEMP_DIR/original-assets"

FILES=(
  ST_TS01_BEYOND_THE_GATE_v01_128k.m4a
  ST_TS02_KRYSTYNA_SKARBEK_v01_128k.m4a
  ST_L05_COMPUTER_v01_128k.m4a
)

expected_sha() {
  case "$1" in
    ST_TS01_BEYOND_THE_GATE_v01_128k.m4a)
      printf '%s' 'e060325cab7eb37128430e33103688f288b24208463f8dd1efb36cc3d87961cf'
      ;;
    ST_TS02_KRYSTYNA_SKARBEK_v01_128k.m4a)
      printf '%s' 'b2f549476bab0e948ceb82ba886a873ac43497ef723753db5a736cc1bb36cbb8'
      ;;
    ST_L05_COMPUTER_v01_128k.m4a)
      printf '%s' '3b9801a65c76d9052624135a430cf26369842d586d50737b21fe49cbf0341982'
      ;;
    *) return 1 ;;
  esac
}

expected_duration() {
  case "$1" in
    ST_TS01_BEYOND_THE_GATE_v01_128k.m4a) printf '%s' '1970.666667' ;;
    ST_TS02_KRYSTYNA_SKARBEK_v01_128k.m4a) printf '%s' '2198.291667' ;;
    ST_L05_COMPUTER_v01_128k.m4a) printf '%s' '1245.000000' ;;
    *) return 1 ;;
  esac
}

sha256_file() {
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$1" | awk '{print $1}'
  elif command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$1" | awk '{print $1}'
  else
    echo 'SHA-256 tool not found (need sha256sum or shasum).' >&2
    return 127
  fi
}

cleanup() {
  for name in "${FILES[@]}"; do
    rm -f "$ASSET_DIR/$name"
    if [[ -f "$BACKUP_DIR/$name" ]]; then
      cp -p "$BACKUP_DIR/$name" "$ASSET_DIR/$name"
    fi
  done
  rm -rf "$TEMP_DIR"
}
trap cleanup EXIT INT TERM

mkdir -p "$ASSET_DIR" "$OUTPUT_DIR" "$BACKUP_DIR"
for name in "${FILES[@]}"; do
  if [[ -f "$ASSET_DIR/$name" ]]; then
    cp -p "$ASSET_DIR/$name" "$BACKUP_DIR/$name"
  fi
done

if [[ -d "$INPUT" ]]; then
  for name in "${FILES[@]}"; do
    cp "$INPUT/$name" "$TEMP_DIR/$name"
  done
elif [[ -f "$INPUT" ]]; then
  command -v unzip >/dev/null 2>&1 || {
    echo 'unzip is required to read the audio delivery ZIP.' >&2
    exit 69
  }
  for name in "${FILES[@]}"; do
    unzip -j -q "$INPUT" "*/$name" -d "$TEMP_DIR" ||
      unzip -j -q "$INPUT" "$name" -d "$TEMP_DIR"
  done
else
  echo "Audio input does not exist: $INPUT" >&2
  exit 66
fi

printf '\nVerifying the three owner-preview masters...\n'
for name in "${FILES[@]}"; do
  file="$TEMP_DIR/$name"
  [[ -f "$file" ]] || {
    echo "Missing required file: $name" >&2
    exit 65
  }

  actual=$(sha256_file "$file")
  expected=$(expected_sha "$name")
  if [[ "$actual" != "$expected" ]]; then
    echo "SHA-256 mismatch for $name" >&2
    echo "Expected: $expected" >&2
    echo "Actual:   $actual" >&2
    exit 65
  fi

  if command -v ffprobe >/dev/null 2>&1; then
    duration=$(ffprobe -v error -show_entries format=duration \
      -of default=noprint_wrappers=1:nokey=1 "$file")
    sample_rate=$(ffprobe -v error -select_streams a:0 \
      -show_entries stream=sample_rate \
      -of default=noprint_wrappers=1:nokey=1 "$file")
    channels=$(ffprobe -v error -select_streams a:0 \
      -show_entries stream=channels \
      -of default=noprint_wrappers=1:nokey=1 "$file")
    target=$(expected_duration "$name")

    awk -v actual="$duration" -v target="$target" \
      'BEGIN { delta=actual-target; if (delta < 0) delta=-delta; exit !(delta <= 0.05) }' || {
        echo "Duration mismatch for $name: $duration seconds" >&2
        exit 65
      }
    [[ "$sample_rate" == '48000' && "$channels" == '2' ]] || {
      echo "Unexpected audio format for $name: ${sample_rate} Hz, ${channels} channel(s)" >&2
      exit 65
    }
  fi

  cp "$file" "$ASSET_DIR/$name"
  printf '  ✓ %s\n' "$name"
done

command -v flutter >/dev/null 2>&1 || {
  echo 'Flutter is not available in PATH.' >&2
  exit 69
}

cd "$ROOT"
flutter pub get
flutter analyze
flutter test \
  test/stories_owner_preview_audio_config_test.dart \
  test/stories_preview_test.dart \
  test/sleep_stories_redesign_test.dart \
  test/story_player_route_test.dart \
  --dart-define=RELIEF_STORIES_AUDIO_BUNDLED=true \
  --dart-define=RELEAF_PREMIUM_PREVIEW=true \
  --reporter expanded

flutter build apk --debug \
  --dart-define=RELIEF_STORIES_AUDIO_BUNDLED=true \
  --dart-define=RELIEF_STORIES_PREVIEW=true \
  --dart-define=RELEAF_PREMIUM_PREVIEW=true \
  --dart-define=REVENUECAT_ANDROID_API_KEY="${REVENUECAT_ANDROID_API_KEY:-}"

cp "$ROOT/build/app/outputs/flutter-apk/app-debug.apk" "$OUTPUT_APK"

for name in "${FILES[@]}"; do
  unzip -l "$OUTPUT_APK" | grep -q \
    "assets/flutter_assets/assets/audio/stories/$name" || {
      echo "Built APK is missing bundled Story audio: $name" >&2
      exit 70
    }
done

printf '\nOwner-preview APK created successfully:\n%s\n' "$OUTPUT_APK"
