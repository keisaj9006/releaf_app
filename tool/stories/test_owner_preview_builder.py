"""Shell-flow regressions using synthetic files, not production audio or Flutter.

The real builder, unzip, grep and filesystem run; Flutter, metadata probing and
pinned-input hashing are isolated test doubles. These tests do not certify an
Android build, media decoding, production hashes or device playback.
"""

import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest
import zipfile


SCRIPT = Path(__file__).with_name("build_owner_preview_with_local_audio.sh")
MASTERS = {
    "ST_TS01_BEYOND_THE_GATE_v01_128k.m4a": (
        "e060325cab7eb37128430e33103688f288b24208463f8dd1efb36cc3d87961cf",
        "1970.666667",
    ),
    "ST_TS02_KRYSTYNA_SKARBEK_v01_128k.m4a": (
        "b2f549476bab0e948ceb82ba886a873ac43497ef723753db5a736cc1bb36cbb8",
        "2198.291667",
    ),
    "ST_L05_COMPUTER_v01_128k.m4a": (
        "3b9801a65c76d9052624135a430cf26369842d586d50737b21fe49cbf0341982",
        "1245.000000",
    ),
}
ASSET_PREFIX = "assets/flutter_assets/assets/audio/stories/"


@unittest.skipUnless(shutil.which("bash") and shutil.which("unzip"), "bash/unzip required")
class OwnerPreviewBuilderTest(unittest.TestCase):
    def setUp(self):
        temporary = tempfile.TemporaryDirectory(prefix="relief-builder-test-")
        self.addCleanup(temporary.cleanup)
        self.root = Path(temporary.name)
        self.repo = self.root / "project"
        self.builder = self.repo / "tool/stories" / SCRIPT.name
        self.builder.parent.mkdir(parents=True)
        shutil.copyfile(SCRIPT, self.builder)
        self.input = self.root / "APP_DELIVERY"
        self.input.mkdir()
        for name in MASTERS:
            (self.input / name).write_bytes(b"SYNTHETIC TEST FIXTURE, NOT AUDIO")
        self.assets = self.repo / "assets/audio/stories"
        self.assets.mkdir(parents=True)
        self.first = next(iter(MASTERS))
        (self.assets / self.first).write_bytes(b"existing local asset")
        self.output = self.repo / "build/qa-apks/Relief-Stories-Owner-Preview.apk"
        self.output.parent.mkdir(parents=True)
        self.output.write_bytes(b"previous verified output")
        self.fixture = self.root / "synthetic-build.zip"
        self.marker = self.root / "flutter-called"
        self.bin = self.root / "bin"
        self.bin.mkdir()
        self.env = {
            **os.environ,
            "PATH": str(self.bin) + os.pathsep + os.environ.get("PATH", ""),
            "RELIEF_TEST_MASTERS": json.dumps(MASTERS),
            "RELIEF_TEST_APK": str(self.fixture),
            "RELIEF_TEST_MARKER": str(self.marker),
            "RELIEF_TEST_BAD_HASH": "",
            "RELIEF_TEST_BUILD_FAILURE": "0",
        }
        self._mock("sha256sum", """import json, os, pathlib, sys
name = pathlib.Path(sys.argv[-1]).name
sha = json.loads(os.environ['RELIEF_TEST_MASTERS'])[name][0]
if name == os.environ['RELIEF_TEST_BAD_HASH']:
    sha = '0' * 64
print(sha + '  ' + sys.argv[-1])
""")
        self._mock("ffprobe", """import json, os, pathlib, sys
name = pathlib.Path(sys.argv[-1]).name
if 'format=duration' in sys.argv:
    print(json.loads(os.environ['RELIEF_TEST_MASTERS'])[name][1])
elif 'stream=sample_rate' in sys.argv:
    print('48000')
elif 'stream=channels' in sys.argv:
    print('2')
else:
    sys.exit(2)
""")
        self._mock("flutter", """import os, pathlib, shutil, sys
pathlib.Path(os.environ['RELIEF_TEST_MARKER']).touch()
if sys.argv[1:3] == ['build', 'apk']:
    if os.environ['RELIEF_TEST_BUILD_FAILURE'] == '1':
        sys.exit(42)
    output = pathlib.Path('build/app/outputs/flutter-apk/app-debug.apk')
    output.parent.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(os.environ['RELIEF_TEST_APK'], output)
""")

    def _mock(self, name, body):
        path = self.bin / name
        path.write_text(f"#!{sys.executable} -S\n" + body, encoding="utf-8")
        path.chmod(0o755)

    def _archive(self, names):
        with zipfile.ZipFile(self.fixture, "w") as archive:
            for name in names:
                archive.writestr(ASSET_PREFIX + name, b"SYNTHETIC, NOT AUDIO")
            # Exceeds the pipe buffer with the matched entries near the start.
            for index in range(4000):
                archive.writestr(f"assets/fixture_{index:05d}.txt", b"fixture")

    def _run(self):
        return subprocess.run(
            ["bash", str(self.builder), str(self.input)],
            cwd=self.repo,
            env=self.env,
            capture_output=True,
            text=True,
            timeout=30,
        )

    def _assert_cleanup(self):
        self.assertEqual((self.assets / self.first).read_bytes(), b"existing local asset")
        for name in list(MASTERS)[1:]:
            self.assertFalse((self.assets / name).exists(), name)

    def _assert_previous_output(self):
        self.assertEqual(self.output.read_bytes(), b"previous verified output")

    def test_large_apk_listing_accepts_present_entries(self):
        self._archive(MASTERS)
        result = self._run()
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        with zipfile.ZipFile(self.output) as archive:
            for name in MASTERS:
                self.assertIn(ASSET_PREFIX + name, archive.namelist())
        self._assert_cleanup()

    def test_missing_entry_rejects_build_and_preserves_previous_output(self):
        self._archive(list(MASTERS)[:-1])
        result = self._run()
        self.assertEqual(result.returncode, 70, result.stdout + result.stderr)
        self.assertIn("Built APK is missing bundled Story audio", result.stderr)
        self._assert_previous_output()
        self._assert_cleanup()

    def test_input_hash_mismatch_stops_before_flutter(self):
        self.env["RELIEF_TEST_BAD_HASH"] = list(MASTERS)[1]
        result = self._run()
        self.assertEqual(result.returncode, 65, result.stdout + result.stderr)
        self.assertIn("SHA-256 mismatch", result.stderr)
        self.assertFalse(self.marker.exists())
        self._assert_previous_output()
        self._assert_cleanup()

    def test_flutter_failure_restores_assets_and_previous_output(self):
        self.env["RELIEF_TEST_BUILD_FAILURE"] = "1"
        result = self._run()
        self.assertEqual(result.returncode, 42, result.stdout + result.stderr)
        self._assert_previous_output()
        self._assert_cleanup()

    def test_invalid_apk_does_not_replace_previous_output(self):
        self.fixture.write_bytes(b"not a ZIP archive")
        result = self._run()
        self.assertNotEqual(result.returncode, 0)
        self._assert_previous_output()
        self._assert_cleanup()


if __name__ == "__main__":
    unittest.main()
