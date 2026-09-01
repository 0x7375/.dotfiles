pkgs:
pkgs.writers.writePython3 "list-firefox-tabs"
  {
    libraries = with pkgs.python3Packages; [ lz4 ];
  }
  # python
  ''
    import json
    import os
    import lz4.block
    from pathlib import Path

    home = os.getenv("HOME")
    file_path = Path(home + "/.zen/nix/sessionstore-backups/recovery.jsonlz4")
    with open(file_path, "rb") as f:
        # skip header
        f.read(8)
        data = f.read()

    session = json.loads(lz4.block.decompress(data))
    for window in session.get("windows", []):
        for tab in window.get("tabs", []):
            index = tab.get("index", 1) - 1
            if entries := tab.get("entries", []):
                print(f"{entries[index].get('title')};{entries[index].get('url')}")
  ''
