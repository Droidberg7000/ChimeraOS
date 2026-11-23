from html.parser import HTMLParser
from pathlib import Path
import json
import sys
import xml.etree.ElementTree as ET

root = Path(__file__).resolve().parents[1]
web = root / 'www'
class Assets(HTMLParser):
    def __init__(self):
        super().__init__()
        self.paths = []
    def handle_starttag(self, tag, attrs):
        attrs = dict(attrs)
        if tag == 'script' and attrs.get('src'):
            self.paths.append(attrs['src'])
        if tag == 'link' and attrs.get('rel') == 'stylesheet':
            self.paths.append(attrs.get('href', ''))
p = Assets()
p.feed((web / 'index.html').read_text(encoding='utf-8'))
missing = [v for v in p.paths if '://' not in v and not (web / v).is_file()]
ET.parse(root / 'config.xml')
json.loads((root / 'package.json').read_text(encoding='utf-8'))
if missing:
    sys.exit('Missing assets: ' + ', '.join(missing))
print('Static asset, XML, and JSON checks passed. Not a runtime or device test.')
