import re

with open('analyze_report_2.txt', 'r', encoding='utf-16le') as f:
    content = f.read()

errors = re.findall(r'(\s+error - .*)', content)

with open('errors_only.txt', 'w', encoding='utf-8') as f:
    for err in errors:
        f.write(err + '\n')
