from pathlib import Path

env_path = Path(r"C:\VS Code\Microsoft\Yodeck\Python\.env")

# Les rå innhold
with open(env_path, 'rb') as f:
    raw_bytes = f.read()
    print("=== RÅ BYTES (første 200) ===")
    print(raw_bytes[:200])
    print()

# Les som text
with open(env_path, 'r', encoding='utf-8') as f:
    content = f.read()
    print("=== INNHOLD SOM TEXT ===")
    print(repr(content))  # repr viser skjulte tegn
    print()
    print("=== VISUELT ===")
    print(content)