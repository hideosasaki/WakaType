#!/usr/bin/env python3
"""
Fetch the provided five-color 百人一首 page, parse the lists for each color,
match them against WakaType/Resources/cards.json by `kamiNoKu` and suggest/apply
color corrections. Produces a report and writes `cards.json.fixed` if changes
are applied.

Usage: python tools/verify_and_fix_colors.py
"""
import json
import re
from pathlib import Path

import requests
from bs4 import BeautifulSoup

ROOT = Path(__file__).resolve().parents[1]
CARDS_PATH = ROOT / 'WakaType' / 'Resources' / 'cards.json'
URL = 'https://honda-n2.com/gosyokuhyakuninisshu-ichiran'

COLOR_MAP = {
    '青': 'blue',
    '桃': 'pink', '赤': 'pink', 'ピンク': 'pink',
    '黄': 'yellow',
    '緑': 'green',
    '橙': 'orange', 'オレンジ': 'orange'
}

def normalize_text(s: str) -> str:
    # simple normalization: remove whitespace, punctuation, iteration marks
    s = s.strip()
    s = re.sub(r'[\s　]', '', s)
    s = re.sub(r'[。、・「」『』（）()〈〉〈〉…─—〜~―]', '', s)
    return s

def parse_color_sections(html: str):
    soup = BeautifulSoup(html, 'html.parser')
    sections = {}
    # find headings that mention '札' (cards) or color names
    for h in soup.find_all(['h2', 'h3', 'h4']):
        txt = h.get_text() or ''
        if any(k in txt for k in ['青札', '桃札', '黄札', '緑札', '橙札', 'オレンジ']):
            # determine color key
            if '青' in txt:
                key = 'blue'
            elif '桃' in txt or '赤' in txt or 'ピンク' in txt:
                key = 'pink'
            elif '黄' in txt:
                key = 'yellow'
            elif '緑' in txt:
                key = 'green'
            elif '橙' in txt or 'オレンジ' in txt:
                key = 'orange'
            else:
                continue
            # collect textual lines until the next heading of same level
            lines = []
            for sib in h.next_siblings:
                if getattr(sib, 'name', None) in ['h2', 'h3', 'h4']:
                    break
                txt2 = ''
                if hasattr(sib, 'get_text'):
                    txt2 = sib.get_text()
                elif isinstance(sib, str):
                    txt2 = sib
                if txt2 and txt2.strip():
                    lines.append(txt2.strip())
            raw = '\n'.join(lines)
            # split lines by linebreaks and numbers like '1.'
            items = []
            for part in re.split(r'\n+', raw):
                # find numbered list occurrences inside the part
                for m in re.finditer(r'\d+\.\s*([^\d]+)', part):
                    items.append(m.group(1).strip())
                # fallback: if the entire part looks like a poem phrase
                if not items and len(part) > 0:
                    items.extend([l.strip() for l in re.split(r'\s{2,}|\t', part) if l.strip()])
            # normalize
            items_norm = [normalize_text(re.sub(r'^[0-9]+\.', '', it)) for it in items if it]
            sections[key] = items_norm
    return sections

def main():
    print('Fetching Honda five-color page...')
    r = requests.get(URL, timeout=20)
    r.raise_for_status()
    html = r.text

    print('Parsing color sections...')
    sections = parse_color_sections(html)

    if not sections:
        print('No sections parsed. Aborting.')
        return

    print('Loading cards.json...')
    cards = json.loads(CARDS_PATH.read_text(encoding='utf-8'))
    id_by_norm = {}
    for c in cards:
        id_by_norm[normalize_text(c.get('kamiNoKu',''))] = c['id']

    corrections = []
    report_lines = []
    for color, poems in sections.items():
        for p in poems:
            # try direct match
            if p in id_by_norm:
                cid = id_by_norm[p]
                # find card
                card = next((x for x in cards if x['id']==cid), None)
                if card:
                    current = card.get('color')
                    if current != color:
                        corrections.append((cid, current, color))
                        card['color'] = color
                        report_lines.append(f"id {cid}: {current} -> {color} (matched by kamiNoKu)")
                    else:
                        report_lines.append(f"id {cid}: {current} (OK)")
            else:
                # try partial match: find any card whose normalized kamiNoKu startswith poem snippet
                matched = None
                for norm, cid in id_by_norm.items():
                    if norm.startswith(p[:10]):
                        matched = cid
                        break
                if matched:
                    card = next((x for x in cards if x['id']==matched), None)
                    if card:
                        current = card.get('color')
                        if current != color:
                            corrections.append((matched, current, color))
                            card['color'] = color
                            report_lines.append(f"id {matched}: {current} -> {color} (matched by prefix)")
                        else:
                            report_lines.append(f"id {matched}: {current} (OK, prefix)")
                else:
                    report_lines.append(f"No match found for poem snippet: {p[:30]}...")

    report_path = ROOT / 'WakaType' / 'Resources' / 'fivecolor_report.txt'
    out_json = ROOT / 'WakaType' / 'Resources' / 'cards.json.fixed'
    report_path.write_text('\n'.join(report_lines), encoding='utf-8')
    out_json.write_text(json.dumps(cards, ensure_ascii=False, indent=2), encoding='utf-8')

    print('Report written to', report_path)
    print('Proposed updated cards written to', out_json)
    print('Corrections count:', len(corrections))

if __name__ == '__main__':
    main()
