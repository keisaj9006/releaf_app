from pathlib import Path
import re

path = Path('lib/features/sleep/presentation/sleep_screen.dart')
text = path.read_text(encoding='utf-8')
pattern = re.compile(
    r'\nclass _ContentRail extends StatelessWidget \{.*?'
    r'(?=\nclass _ContentWrap extends StatelessWidget)',
    re.S,
)
updated, count = pattern.subn('\n', text, count=1)
if count != 1:
    raise SystemExit(
        f'Expected exactly one _ContentRail declaration, found {count}.'
    )
path.write_text(updated, encoding='utf-8')
