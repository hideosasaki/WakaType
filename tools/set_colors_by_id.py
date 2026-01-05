#!/usr/bin/env python3
"""
Set `color` fields in WakaType/Resources/cards.json according to five-color grouping:
1-20 -> blue
21-40 -> pink
41-60 -> yellow
61-80 -> green
81-100 -> orange

This script uses only the Python standard library.
"""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CARDS = ROOT / 'WakaType' / 'Resources' / 'cards.json'

def color_for_id(i: int) -> str:
    if 1 <= i <= 20:
        return 'blue'
    if 21 <= i <= 40:
        return 'pink'
    if 41 <= i <= 60:
        return 'yellow'
    if 61 <= i <= 80:
        return 'green'
    return 'orange'

def main():
    data = json.loads(CARDS.read_text(encoding='utf-8'))
    changed = []
    for card in data:
        i = int(card.get('id'))
        expected = color_for_id(i)
        if card.get('color') != expected:
            changed.append((i, card.get('color'), expected))
            card['color'] = expected

    out = CARDS.with_suffix('.fixed.json')
    out.write_text(json.dumps(data, ensure_ascii=False, indent=2), encoding='utf-8')
    report = ROOT / 'WakaType' / 'Resources' / 'fivecolor_changes.txt'
    report.write_text('\n'.join([f'id {i}: {old} -> {new}' for i, old, new in changed]), encoding='utf-8')
    print('Wrote', out)
    print('Wrote report', report)
    print('Changes:', len(changed))

if __name__ == '__main__':
    main()
