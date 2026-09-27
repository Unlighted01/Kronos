import json
import os
import time

SAVE_PATH = r"C:\Users\netne\AppData\Roaming\Godot\app_userdata\Kronos\kronos_save.json"
BAK_PATH = r"C:\Users\netne\AppData\Roaming\Godot\app_userdata\Kronos\kronos_save.bak"

ALL_ROOMS = [
    "room_bedroom",
    "room_livingroom",
    "room_library",
    "room_greenhouse",
    "room_kitchen"
]

ALL_PETS = [
    "pet_shiba",
    "pet_cat",
    "pet_fox",
    "pet_bunny",
    "pet_penguin",
    "pet_redpanda",
    "pet_capybara",
    "pet_owl"
]

# Read existing save data if present
if os.path.exists(SAVE_PATH):
    with open(SAVE_PATH, "r", encoding="utf-8") as f:
        data = json.load(f)
else:
    data = {}

# 1. Unlock all rooms & all pets
data["unlocked_rooms"] = ALL_ROOMS
data["unlocked_pets"] = ALL_PETS

# 2. Set Max Level & Abundant Focus Coins & Knowledge Points
data["level"] = 25
data["coins"] = 99999
data["knowledge_points"] = 500
data["exp"] = 0
data["energy"] = 100.0
data["joy"] = 100.0

# 3. Active Companions across all 5 rooms
data["active_pets"] = [
    {
        "id": "pet_shiba",
        "name": "Kronos",
        "species": "shiba",
        "room": "room_livingroom",
        "energy": 100.0,
        "joy": 100.0,
        "equipped_cosmetics": {},
        "is_outside": False,
        "expedition_end_unix": 0.0,
        "expedition_destination": "",
        "adopted_at_unix": 0.0
    },
    {
        "id": "pet_cat",
        "name": "Mochi",
        "species": "cat",
        "room": "room_bedroom",
        "energy": 100.0,
        "joy": 100.0,
        "equipped_cosmetics": {},
        "is_outside": False,
        "expedition_end_unix": 0.0,
        "expedition_destination": "",
        "adopted_at_unix": 0.0
    },
    {
        "id": "pet_fox",
        "name": "Kitsune",
        "species": "fox",
        "room": "room_library",
        "energy": 100.0,
        "joy": 100.0,
        "equipped_cosmetics": {},
        "is_outside": False,
        "expedition_end_unix": 0.0,
        "expedition_destination": "",
        "adopted_at_unix": 0.0
    },
    {
        "id": "pet_bunny",
        "name": "Boba",
        "species": "bunny",
        "room": "room_greenhouse",
        "energy": 100.0,
        "joy": 100.0,
        "equipped_cosmetics": {},
        "is_outside": False,
        "expedition_end_unix": 0.0,
        "expedition_destination": "",
        "adopted_at_unix": 0.0
    },
    {
        "id": "pet_capybara",
        "name": "Coconut",
        "species": "capybara",
        "room": "room_kitchen",
        "energy": 100.0,
        "joy": 100.0,
        "equipped_cosmetics": {},
        "is_outside": False,
        "expedition_end_unix": 0.0,
        "expedition_destination": "",
        "adopted_at_unix": 0.0
    },
    {
        "id": "pet_penguin",
        "name": "Pippin",
        "species": "penguin",
        "room": "room_library",
        "energy": 100.0,
        "joy": 100.0,
        "equipped_cosmetics": {},
        "is_outside": False,
        "expedition_end_unix": 0.0,
        "expedition_destination": "",
        "adopted_at_unix": 0.0
    },
    {
        "id": "pet_redpanda",
        "name": "Rusty",
        "species": "redpanda",
        "room": "room_livingroom",
        "energy": 100.0,
        "joy": 100.0,
        "equipped_cosmetics": {},
        "is_outside": False,
        "expedition_end_unix": 0.0,
        "expedition_destination": "",
        "adopted_at_unix": 0.0
    },
    {
        "id": "pet_owl",
        "name": "Archimedes",
        "species": "owl",
        "room": "room_bedroom",
        "energy": 100.0,
        "joy": 100.0,
        "equipped_cosmetics": {},
        "is_outside": False,
        "expedition_end_unix": 0.0,
        "expedition_destination": "",
        "adopted_at_unix": 0.0
    }
]

# Set current active companion to Shiba
data["selected_pet_index"] = 0
data["pet_species"] = "shiba"
data["pet_name"] = "Kronos"
data["pet_room"] = "room_livingroom"
data["active_view_room"] = "room_livingroom"
data["active_room"] = "room_livingroom"

# 4. Friendship with all 8 pets initialized to max
data["pet_friendship"] = {
    p_id: {"level": 5.0, "xp": 100.0} for p_id in ALL_PETS
}

# 5. Inventory with all delicious treats & snacks
data["inventory"] = [
    {"item_id": "snack_croissant", "quantity": 10.0, "metadata": {"name": "Butter Croissant", "icon": "🥐"}},
    {"item_id": "snack_coffee", "quantity": 10.0, "metadata": {"name": "Pixel Espresso", "icon": "☕"}},
    {"item_id": "snack_matcha", "quantity": 10.0, "metadata": {"name": "Ceremonial Matcha", "icon": "🍵"}},
    {"item_id": "snack_donut", "quantity": 10.0, "metadata": {"name": "Star Donut", "icon": "🍩"}},
    {"item_id": "snack_pancake", "quantity": 10.0, "metadata": {"name": "Souffle Pancakes", "icon": "🥞"}},
    {"item_id": "snack_boba", "quantity": 10.0, "metadata": {"name": "Brown Sugar Boba", "icon": "🧋"}},
    {"item_id": "snack_onigiri", "quantity": 10.0, "metadata": {"name": "Salmon Onigiri", "icon": "🍙"}},
    {"item_id": "snack_energy_drink", "quantity": 10.0, "metadata": {"name": "Neon Energy Drink", "icon": "⚡"}},
    {"item_id": "snack_mystery_box", "quantity": 10.0, "metadata": {"name": "Mystery Treat Box", "icon": "🎁"}},
]

data["last_saved_unix"] = time.time()

# Save updated data to both kronos_save.json and kronos_save.bak
with open(SAVE_PATH, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=4)
print(f"[OK] Successfully wrote unlocked state to {SAVE_PATH}")

with open(BAK_PATH, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=4)
print(f"[OK] Successfully wrote backup copy to {BAK_PATH}")
