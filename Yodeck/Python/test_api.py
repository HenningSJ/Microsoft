
import requests
import os
from dotenv import load_dotenv

# Last .env
load_dotenv()
token = os.getenv('API_TOKEN')

# API-kall
headers = {'Authorization': f'Token {token}'}
response = requests.get('https://app.yodeck.com/api/v2/screens/', headers=headers)

# Vis resultat
if response.status_code == 200:
    screens = response.json()
    print(f"✅ Hentet {len(screens)} spillere")
    
    # Vis første 3
    for screen in screens[:3]:
        name = screen.get('name', 'Ukjent')
        online = '🟢 Online' if screen.get('player_status', {}).get('online') else '🔴 Offline'
        print(f"  • {name}: {online}")
else:
    print(f"❌ Feil {response.status_code}: {response.text}")
