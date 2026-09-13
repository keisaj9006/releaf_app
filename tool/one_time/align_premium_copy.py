from pathlib import Path

path = Path('lib/core/paywall/presentation/paywall_sheet.dart')
text = path.read_text(encoding='utf-8')
old = """                          _PremiumBenefit(
                            icon: Icons.spa_outlined,
                            title: 'Premium meditation sessions',
                            description:
                                'Continue beyond the free foundations into the wider meditation library.',
                          ),
"""
new = """                          _PremiumBenefit(
                            icon: Icons.extension_outlined,
                            title: 'Advanced Brain training',
                            description:
                                'Unlock deeper progressive cognitive training across Releaf Brain.',
                          ),
"""
count = text.count(old)
if count != 1:
    raise SystemExit(f'expected exactly one Premium meditation benefit, found {count}')
path.write_text(text.replace(old, new, 1), encoding='utf-8')
print('Premium copy aligned to active Releaf 1.0 pillars.')
