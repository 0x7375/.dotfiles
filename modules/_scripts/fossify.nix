{ pkgs, ... }:

pkgs.writers.writePython3Bin "fossify" { }
  # python
  ''
    import json
    import sys
    from datetime import datetime


    def decode(path, out=sys.stdout):
        data = json.load(open(path))
        for item in sorted(data, key=lambda i: i["isDone"]):
            prefix = "x " if item["isDone"] else ""
            out.write(f"{prefix}{item['title']}\n")


    def encode(path, text_in=sys.stdin, out=sys.stdout):
        data = json.load(open(path))
        items_by_title = {i["title"]: i for i in data}
        next_id = max((i["id"] for i in data), default=0) + 1
        new_items = []
        for line in text_in:
            line = line.rstrip("\n")
            if not line.strip():
                continue
            if line.startswith("x "):
                done, title = True, line[2:]
            else:
                done, title = False, line
            if title in items_by_title:
                item = items_by_title[title]
                item["isDone"] = done
            else:
                item = {
                    "id": next_id, "title": title, "isDone": done,
                    "dateCreated": int(datetime.now().timestamp() * 1000),
                }
                next_id += 1
            new_items.append(item)
        json.dump(new_items, out, indent=2)


    if __name__ == "__main__":
        if len(sys.argv) < 3 or sys.argv[1] not in ("decode", "encode"):
            print("Usage: fossify decode|encode <file>")
            sys.exit(1)
        mode, path = sys.argv[1], sys.argv[2]
        (decode if mode == "decode" else encode)(path)
  ''
