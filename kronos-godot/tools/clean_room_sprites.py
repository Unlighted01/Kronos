"""
clean_room_sprites.py
Kronos Project - Room Sprite Asset Cleaning & Grid Line Removal Suite
Cleans prop slice contaminations, unpads architectural tiles to prevent transparent seam gaps,
and refines livingroom floor tile for seamless marble tiling.
"""

import os
from PIL import Image

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.dirname(SCRIPT_DIR)
ROOMS_BASE = os.path.join(PROJECT_ROOT, "assets", "sprites", "rooms")

def clean_prop_artifacts():
    print("--- 1. Cleaning Prop Slice Artifacts ---")
    
    # 1. Observatory Telescope (Library): remove slice contamination from adjacent wooden cabinet
    tel_path = os.path.join(ROOMS_BASE, "library", "observatory_telescope.png")
    if os.path.exists(tel_path):
        img = Image.open(tel_path).convert("RGBA")
        for y in range(img.height):
            for x in range(51, img.width):
                img.putpixel((x, y), (0, 0, 0, 0))
        img.save(tel_path, "PNG")
        print(f"  [OK] Cleaned {tel_path}")

    # 2. Scholar Desk (Library): remove top-left detached artifact
    desk_path = os.path.join(ROOMS_BASE, "library", "scholar_desk.png")
    if os.path.exists(desk_path):
        img = Image.open(desk_path).convert("RGBA")
        for y in range(0, 6):
            for x in range(0, 13):
                img.putpixel((x, y), (0, 0, 0, 0))
        img.save(desk_path, "PNG")
        print(f"  [OK] Cleaned {desk_path}")

    # 3. Garden Scarecrow (Greenhouse): remove bottom floor specks and dangling vertical lines
    scare_path = os.path.join(ROOMS_BASE, "greenhouse", "garden_scarecrow.png")
    if os.path.exists(scare_path):
        img = Image.open(scare_path).convert("RGBA")
        for y in range(52, img.height):
            for x in range(0, 16):
                img.putpixel((x, y), (0, 0, 0, 0))
        for y in range(48, img.height):
            for x in range(48, img.width):
                img.putpixel((x, y), (0, 0, 0, 0))
        for y in range(61, img.height):
            for x in range(16, 22):
                img.putpixel((x, y), (0, 0, 0, 0))
        img.save(scare_path, "PNG")
        print(f"  [OK] Cleaned {scare_path}")

    # 4. Asphodel Pots (Greenhouse): remove floating top-right stick
    pot_path = os.path.join(ROOMS_BASE, "greenhouse", "asphodel_pots.png")
    if os.path.exists(pot_path):
        img = Image.open(pot_path).convert("RGBA")
        for y in range(0, 14):
            for x in range(31, img.width):
                img.putpixel((x, y), (0, 0, 0, 0))
        img.save(pot_path, "PNG")
        print(f"  [OK] Cleaned {pot_path}")

    # 5. Wheelbarrow Harvest (Greenhouse): remove right-edge slivers
    wb_path = os.path.join(ROOMS_BASE, "greenhouse", "wheelbarrow_harvest.png")
    if os.path.exists(wb_path):
        img = Image.open(wb_path).convert("RGBA")
        for y in range(0, 20):
            for x in range(52, img.width):
                img.putpixel((x, y), (0, 0, 0, 0))
        img.save(wb_path, "PNG")
        print(f"  [OK] Cleaned {wb_path}")

    # 6. Hanging Planter (Greenhouse): remove top-left speck
    hp_path = os.path.join(ROOMS_BASE, "greenhouse", "hanging_planter.png")
    if os.path.exists(hp_path):
        img = Image.open(hp_path).convert("RGBA")
        img.putpixel((2, 2), (0, 0, 0, 0))
        img.putpixel((3, 2), (0, 0, 0, 0))
        img.save(hp_path, "PNG")
        print(f"  [OK] Cleaned {hp_path}")

    # 7. Livingroom sconces & tapestry
    sc_path = os.path.join(ROOMS_BASE, "livingroom", "sconces.png")
    if os.path.exists(sc_path):
        img = Image.open(sc_path).convert("RGBA")
        img.putpixel((14, 2), (0, 0, 0, 0))
        img.save(sc_path, "PNG")
        print(f"  [OK] Cleaned {sc_path}")

    tap_path = os.path.join(ROOMS_BASE, "livingroom", "tapestry.png")
    if os.path.exists(tap_path):
        img = Image.open(tap_path).convert("RGBA")
        for y in range(36, 40):
            for x in range(21, 25):
                img.putpixel((x, y), (0, 0, 0, 0))
        img.save(tap_path, "PNG")
        print(f"  [OK] Cleaned {tap_path}")

def unpad_architectural_tiles():
    print("\n--- 2. Unpadding Repeating Architectural Tiles (Seamless Seams) ---")
    padded_tiles = [
        ("bedroom", "wall_stone.png", (32, 32)),
        ("bedroom", "floor_tile.png", (32, 32)),
        ("bedroom", "ceiling_tile.png", (48, 16)),
        ("bedroom", "wall_frieze.png", (48, 16)),
        ("bedroom", "floor_lip.png", (64, 24)),
        ("library", "wall_stone.png", (32, 32)),
        ("library", "floor_tile.png", (32, 32)),
        ("library", "ceiling_beam.png", (48, 16)),
        ("library", "wall_frieze.png", (48, 16)),
        ("library", "floor_lip.png", (64, 24)),
        ("greenhouse", "sandstone_wall.png", (64, 40)),
        ("greenhouse", "sandstone_wall_tile.png", (32, 32)),
        ("greenhouse", "flagstone_tile.png", (48, 48)),
        ("greenhouse", "flagstone_small.png", (32, 32)),
        ("greenhouse", "terrace_steps_lip.png", (64, 24)),
        ("greenhouse", "terrace_corner_steps.png", (48, 40)),
    ]

    for room, filename, target_size in padded_tiles:
        path = os.path.join(ROOMS_BASE, room, filename)
        if not os.path.exists(path):
            continue
        img = Image.open(path).convert("RGBA")
        w, h = img.size
        tw, th = target_size
        if w > tw or h > th:
            pad_x = (w - tw) // 2
            pad_y = (h - th) // 2
            cropped = img.crop((pad_x, pad_y, pad_x + tw, pad_y + th))
            cropped.save(path, "PNG")
            print(f"  [OK] Unpadded {room}/{filename}: ({w}x{h}) -> ({tw}x{th})")

    # Seamless Morpheus Wall Tile
    bed_wall_path = os.path.join(ROOMS_BASE, "bedroom", "wall_stone.png")
    lib_wall_path = os.path.join(ROOMS_BASE, "library", "wall_stone.png")
    if os.path.exists(bed_wall_path) and os.path.exists(lib_wall_path):
        lib_img = Image.open(lib_wall_path).convert("RGBA")
        bed_tile = Image.new("RGBA", (32, 32))
        for y in range(32):
            for x in range(32):
                lr, lg, lb, _ = lib_img.getpixel((x, y))
                lum = (lr + lg + lb) / (3.0 * 255.0)
                factor = max(0.0, min(1.0, (lum - 0.55) / 0.35))
                r = int(28 + factor * 16)
                g = int(33 + factor * 19)
                b = int(48 + factor * 22)
                bed_tile.putpixel((x, y), (r, g, b, 255))
        bed_tile.save(bed_wall_path, "PNG")
        print(f"  [OK] Generated seamless nocturnal ashlar stone for Bedroom")

    # Livingroom Floor Tile: remove box border frame, expand seamless marble
    lv_floor_path = os.path.join(ROOMS_BASE, "livingroom", "floor_tile.png")
    if os.path.exists(lv_floor_path):
        lv_img = Image.open(lv_floor_path).convert("RGBA")
        inner_marble = lv_img.crop((4, 4, 28, 28))
        seamless_marble = inner_marble.resize((32, 32), Image.Resampling.LANCZOS)
        marble_pixels = []
        for y in range(32):
            for x in range(32):
                r, g, b, _ = seamless_marble.getpixel((x, y))
                nr = min(255, int(r * 0.96 + 10))
                ng = min(255, int(g * 0.95 + 10))
                nb = min(255, int(b * 0.93 + 8))
                marble_pixels.append((nr, ng, nb, 255))
        seamless_tile = Image.new("RGBA", (32, 32))
        seamless_tile.putdata(marble_pixels)
        seamless_tile.save(lv_floor_path, "PNG")
        print(f"  [OK] Refined livingroom/floor_tile.png to seamless marble (32x32)")

if __name__ == "__main__":
    print("=== Cleaning Kronos Room Sprite Assets & Eliminating Grid Lines ===")
    clean_prop_artifacts()
    unpad_architectural_tiles()
    print("=== All Room Sprites Cleaned & Synchronized Successfully ===")
