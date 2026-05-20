import json

with open("data.json") as f:
    data = json.load(f)

def scan(obj, path=""):
    if isinstance(obj, dict):
        # Check widget type
        if obj.get("type") and "power" in str(obj.get("type")).lower():
            print("Found by type:", obj)

        # Check content_data (important)
        if obj.get("content_data"):
            if "powerbi" in str(obj["content_data"]).lower():
                print("Found in content_data:", obj["content_data"])

        for k, v in obj.items():
            scan(v, path + f".{k}")

    elif isinstance(obj, list):
        for item in obj:
            scan(item, path)

scan(data)

print("Done scanning")