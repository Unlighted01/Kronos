import os
from PIL import Image

PROPS_PATH = r"C:\Users\netne\.gemini\antigravity\brain\c16bf1a4-3954-476f-975d-a5a59e385b63\elysian_props_sheet_1790341800571.jpg"
ARCH_PATH = r"C:\Users\netne\.gemini\antigravity\brain\c16bf1a4-3954-476f-975d-a5a59e385b63\elysian_arch_sheet_1790341867432.jpg"
VISTA_PATH = r"C:\Users\netne\.gemini\antigravity\brain\c16bf1a4-3954-476f-975d-a5a59e385b63\elysian_vista_day_1790341892595.jpg"

OUT_DIR = r"c:\Users\netne\Kronos\Kronos Project\kronos-godot\assets\sprites\rooms\greenhouse"
os.makedirs(OUT_DIR, exist_ok=True)

def clean_bg(cropped_img, bg_color, thresh=34, feather=14):
    rgba = cropped_img.convert("RGBA")
    data = list(rgba.getdata())
    new_data = []
    bg_r, bg_g, bg_b = bg_color
    
    for r, g, b, a in data:
        dist = ((r - bg_r)**2 + (g - bg_g)**2 + (b - bg_b)**2)**0.5
        if dist <= thresh:
            new_data.append((0, 0, 0, 0))
        elif dist <= thresh + feather:
            alpha = int(255 * (float(dist - thresh) / float(feather)))
            new_data.append((r, g, b, alpha))
        else:
            new_data.append((r, g, b, 255))
    rgba.putdata(new_data)
    return rgba

def process_and_save(img, box, target_size, filename, bg_color, pad=2):
    crop = img.crop(box)
    clean = clean_bg(crop, bg_color)
    tw, th = target_size
    scaled = clean.resize((tw, th), Image.Resampling.LANCZOS)
    
    # Clean semi-transparent fringing
    p_data = list(scaled.getdata())
    clean_p = []
    for r, g, b, a in p_data:
        if a < 25:
            clean_p.append((0, 0, 0, 0))
        else:
            clean_p.append((r, g, b, a))
    scaled.putdata(clean_p)
    
    fw, fh = tw + pad * 2, th + pad * 2
    canvas = Image.new("RGBA", (fw, fh), (0, 0, 0, 0))
    canvas.paste(scaled, (pad, pad), scaled)
    
    out_path = os.path.join(OUT_DIR, filename)
    canvas.save(out_path, "PNG")
    print(f"  [OK] Saved {filename} ({fw}x{fh}) -> {out_path}")

print("=== Slicing Elysian Fields (Zen Greenhouse) Asset Suite ===")

# 1. Props Sheet (bg: 64, 2, 43)
p_img = Image.open(PROPS_PATH).convert("RGB")
BG_PROPS = (64, 2, 43)

PROPS_MAP = [
    # Potting Bench: box=(32, 20, 400, 364), target ~ (72, 60)
    ("potting_bench.png", (32, 20, 400, 364), (72, 60)),
    # Marble Sunbench / Daybed: box=(468, 28, 992, 360), target ~ (84, 52)
    ("marble_sunbench.png", (468, 28, 992, 360), (84, 52)),
    # Birdbath Fountain Basin: box=(40, 368, 332, 708), target ~ (46, 52)
    ("fountain_basin.png", (40, 368, 332, 708), (46, 52)),
    # Garden Scarecrow: box=(368, 328, 692, 724), target ~ (52, 62)
    ("garden_scarecrow.png", (368, 328, 692, 724), (52, 62)),
    # Watering Can: box=(716, 400, 992, 640), target ~ (34, 28)
    ("watering_can.png", (716, 400, 992, 640), (34, 28)),
    # Wheelbarrow Harvest: box=(28, 700, 350, 1004), target ~ (54, 40)
    ("wheelbarrow_harvest.png", (28, 700, 350, 1004), (54, 40)),
    # Asphodel Terracotta Pots: box=(320, 640, 545, 1004), target ~ (36, 48)
    ("asphodel_pots.png", (320, 640, 545, 1004), (36, 48)),
    # Hanging Ceramic Planter: box=(572, 624, 804, 1008), target ~ (32, 54)
    ("hanging_planter.png", (572, 624, 804, 1008), (32, 54)),
    # Wind Chimes: box=(805, 650, 980, 1004), target ~ (26, 48)
    ("wind_chimes.png", (805, 650, 980, 1004), (26, 48)),
]

for fname, box, sz in PROPS_MAP:
    process_and_save(p_img, box, sz, fname, BG_PROPS)

# 2. Architecture & Environment Sheet (bg: 79, 1, 56)
a_img = Image.open(ARCH_PATH).convert("RGB")
BG_ARCH = (79, 1, 56)

ARCH_MAP = [
    # Pergola Canopy with Wisteria: box=(24, 28, 516, 380), target ~ (96, 64)
    ("pergola_canopy.png", (24, 28, 516, 380), (96, 64)),
    # Ivy Doric Column: box=(532, 24, 636, 384), target ~ (24, 88)
    ("ivy_column.png", (532, 24, 636, 384), (24, 88)),
    # Ivy Column Capital: box=(700, 428, 844, 696), target ~ (24, 48)
    ("ivy_column_capital.png", (700, 428, 844, 696), (24, 48)),
    # Sandstone Wall Tile: box=(760, 24, 888, 176), target ~ (32, 32)
    ("sandstone_wall_tile.png", (760, 24, 888, 176), (32, 32)),
    # Sandstone Garden Wall: box=(760, 204, 1000, 376), target ~ (64, 40)
    ("sandstone_wall.png", (760, 204, 1000, 376), (64, 40)),
    # Flagstone Path Tile: box=(204, 428, 456, 680), target ~ (48, 48)
    ("flagstone_tile.png", (204, 428, 456, 680), (48, 48)),
    # Flagstone Small Tile: box=(24, 428, 180, 584), target ~ (32, 32)
    ("flagstone_small.png", (24, 428, 180, 584), (32, 32)),
    # Golden Wheat Stalks: box=(488, 456, 676, 724), target ~ (34, 48)
    ("wheat_stalks.png", (488, 456, 676, 724), (34, 48)),
    # Purple Lavender Bush: box=(484, 796, 676, 1000), target ~ (36, 34)
    ("lavender_bush.png", (484, 796, 676, 1000), (36, 34)),
    # Wild Asphodel Cluster: box=(692, 720, 844, 1000), target ~ (32, 50)
    ("asphodel_wild.png", (692, 720, 844, 1000), (32, 50)),
    # Hanging Clay Lantern: box=(864, 468, 992, 696), target ~ (24, 40)
    ("clay_lantern.png", (864, 468, 992, 696), (24, 40)),
    # Mossy Stone Terrace Lip: box=(24, 660, 184, 816), target ~ (64, 24)
    ("terrace_steps_lip.png", (24, 660, 184, 816), (64, 24)),
    # Mossy Garden Steps Plinth: box=(204, 760, 476, 1000), target ~ (48, 40)
    ("terrace_corner_steps.png", (204, 760, 476, 1000), (48, 40)),
]

for fname, box, sz in ARCH_MAP:
    process_and_save(a_img, box, sz, fname, BG_ARCH)

# 3. Vista Panorama
v_img = Image.open(VISTA_PATH).convert("RGBA")
# Target panorama size: 720x160 (or 520x140 for the garden vista opening)
vw, vh = 560, 140
v_scaled = v_img.resize((vw, vh), Image.Resampling.LANCZOS)
v_out = os.path.join(OUT_DIR, "elysian_vista.png")
v_scaled.save(v_out, "PNG")
print(f"  [OK] Saved elysian_vista.png ({vw}x{vh}) -> {v_out}")

print("=== Elysian Fields Slicing Complete! ===")
