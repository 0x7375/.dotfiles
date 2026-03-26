{ pkgs, ... }:

pkgs.writers.writePython3 "check" { } ''
  import json
  import os
  import sys
  import tempfile
  from datetime import datetime

  if len(sys.argv) < 2:
      print("Usage: check <file>")

  fossify_file = sys.argv[1]
  data = json.load(open(fossify_file))
  items_by_title = {i['title']: i for i in data}

  with tempfile.NamedTemporaryFile('w', suffix='.txt', delete=False) as f:
      tmp = f.name
      for item in data:
          prefix = 'x ' if item['isDone'] else '''
          f.write(f"{prefix}{item['title']}\n")

  os.system(f"$EDITOR {tmp}")

  new_items = []
  next_id = max((i['id'] for i in data), default=0) + 1

  for line in open(tmp):
      line = line.strip()
      if not line:
          continue
      if line.startswith('x '):
          done, title = True, line[2:]
      else:
          done, title = False, line

      if title in items_by_title:
          item = items_by_title[title]
          item['isDone'] = done
      else:
          item = {'id': next_id, 'title': title, 'isDone': done,
                  'dateCreated': int(datetime.now().timestamp() * 1000)}
          next_id += 1
      new_items.append(item)

  json.dump(new_items, open(fossify_file, 'w'), indent=2)
  os.unlink(tmp)
''
