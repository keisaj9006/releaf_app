from pathlib import Path
import subprocess

# This helper is intentionally self-retiring. The L50 gameplay migration has
# already been validated and committed; this final run removes the temporary
# CI machinery while preserving the permanent L50 regression test in P0.
game_path = Path('lib/games/labyrinth/labyrinth_game_screen.dart')
game_text = game_path.read_text(encoding='utf-8')

required_markers = (
    'rawTrainingLevel.clamp(1, 50)',
    'static const int _maxTrainingLevel = 50;',
    'final level = rawLevel.clamp(1, 50).toInt();',
)
if not all(marker in game_text for marker in required_markers):
    raise SystemExit('Refusing CI cleanup: validated Labyrinth L50 gameplay is not present.')

p0_path = Path('.github/workflows/flutter_p0.yml')
p0 = p0_path.read_text(encoding='utf-8')

permissions_block = """permissions:
  contents: write

"""
apply_block = """      - name: Apply pending Labyrinth L50 gameplay patch
        if: github.event_name == 'push'
        run: |
          python tool/patch_labyrinth_l50.py
          dart format lib/games/labyrinth/labyrinth_game_screen.dart

"""
commit_block = """      - name: Commit validated Labyrinth L50 gameplay patch
        if: github.event_name == 'push'
        run: |
          if git diff --quiet -- lib/games/labyrinth/labyrinth_game_screen.dart; then
            echo \"Labyrinth L50 gameplay patch already committed.\"
            exit 0
          fi
          git config user.name \"Releaf CI\"
          git config user.email \"actions@users.noreply.github.com\"
          git add lib/games/labyrinth/labyrinth_game_screen.dart
          git diff --cached --check
          git commit -m \"feat: scale Labyrinth gameplay through level 50\"
          git push origin HEAD:releaf-development
"""

for label, block in (
    ('temporary contents permission', permissions_block),
    ('temporary apply step', apply_block),
    ('temporary commit step', commit_block),
):
    count = p0.count(block)
    if count != 1:
        raise SystemExit(f'Refusing CI cleanup: {label} expected once, found {count}.')
    p0 = p0.replace(block, '', 1)

if 'test/labyrinth_level_50_progression_test.dart' not in p0:
    raise SystemExit('Refusing CI cleanup: permanent Labyrinth L50 P0 test is missing.')

p0_path.write_text(p0, encoding='utf-8')

for temporary_path in (
    Path('.github/workflows/labyrinth_l50_once.yml'),
    Path('tool/labyrinth_l50_trigger.txt'),
    Path('tool/patch_labyrinth_l50.py'),
):
    if temporary_path.exists():
        temporary_path.unlink()

subprocess.run(['git', 'config', 'user.name', 'Releaf CI'], check=True)
subprocess.run(['git', 'config', 'user.email', 'actions@users.noreply.github.com'], check=True)
subprocess.run(['git', 'add', '-A'], check=True)
subprocess.run(['git', 'diff', '--cached', '--check'], check=True)

staged = subprocess.run(
    ['git', 'diff', '--cached', '--quiet'],
    check=False,
).returncode
if staged == 0:
    print('Labyrinth L50 migration tooling is already clean.')
    raise SystemExit(0)

subprocess.run(
    ['git', 'commit', '-m', 'chore: clean Labyrinth L50 migration tooling'],
    check=True,
)
subprocess.run(['git', 'push', 'origin', 'HEAD:releaf-development'], check=True)
print('Committed and pushed Labyrinth L50 CI cleanup.')
