import os
from PIL import Image

PROPS_PATH = r"C:\Users\netne\.gemini\antigravity\brain\c16bf1a4-3954-476f-975d-a5a59e385b63\urania_props_sheet_1790341053843.jpg"
ARCH_PATH = r"C:\Users\netne\.gemini\antigravity\brain\c16bf1a4-3954-476f-975d-a5a59e385b63\urania_arch_sheet_1790341087218.jpg"
VISTA_PATH = r"C:\Users\netne\.gemini\antigravity\brain\c16bf1a4-3954-476f-975d-a5a59e385b63\urania_vista_night_1790341118106.jpg"

OUT_DIR = r"c:\Users\netne\Kronos\Kronos Project\kronos-godot\assets\sprites\rooms\library"
os.makedirs(OUT_DIR, exist_ok=True)

def clean_white_bg(cropped_img, thresh=242, feather=15):
    rgba = cropped_img.convert("RGBA")
    data = list(rgba.getdata())
    new_data = []
    for r, g, b, a in data:
        lightness = min(r, g, b)
        if lightness >= thresh:
            new_data.append((0, 0, 0, 0))
        elif lightness >= thresh - feather:
            alpha = int(255 * (float(thresh - lightness) / float(feather)))
            new_data.append((r, g, b, alpha))
        else:
            new_data.append((r, g, b, 255))
    rgba.putdata(new_data)
    return rgba

def process_and_save(img, box, target_size, filename, pad=2):
    crop = img.crop(box)
    clean = clean_white_bg(crop)
    tw, th = target_size
    scaled = clean.resize((tw, th), Image.Resampling.LANCZOS)
    
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

print("=== Slicing Tower of Urania (Attic Library) Asset Suite ===")

# 1. Props Sheet
p_img = Image.open(PROPS_PATH).convert("RGB")

PROPS_MAP = [
    # Celestial Globe: bbox (14, 24, 317, 425)
    ("celestial_globe.png", (14, 24, 317, 425), (48, 54)),
    # Observatory Telescope: bbox (338, 14, 675, 427)
    ("observatory_telescope.png", (338, 14, 675, 427), (58, 56)),
    # Scholar Study Desk: bbox (622, 60, 1009, 371)
    ("scholar_desk.png", (622, 60, 1009, 371), (80, 44)),
    # Bookcase Low: bbox (22, 452, 303, 759)
    ("bookcase_low.png", (22, 452, 303, 759), (44, 46)),
    # Reading Armchair: bbox (338, 452, 587, 755)
    ("reading_armchair.png", (338, 452, 587, 755), (46, 50)),
    # Tea Samovar: bbox (614, 414, 775, 751)
    ("tea_samovar.png", (614, 414, 775, 751), (22, 36)),
    # Library Ladder: bbox (802, 392, 1003, 763)
    ("library_ladder.png", (802, 392, 1003, 763), (20, 62)),
    # Zodiac Astrolabe Rug: bbox (46, 776, 507, 1003)
    ("zodiac_rug.png", (46, 776, 507, 1003), (88, 32)),
    # Book Stacks & Scrolls: bbox (568, 768, 975, 1003)
    ("book_stacks.png", (568, 768, 975, 1003), (38, 24))
]

for filename, box, size in PROPS_MAP:
    process_and_save(p_img, box, size, filename)

# 2. Architectural Sheet
a_img = Image.open(ARCH_PATH).convert("RGB")

ARCH_MAP = [
    # Parquet Floor Tile: bbox (0, 16, 257, 257)
    ("floor_tile.png", (0, 16, 257, 257), (32, 32)),
    # Stepped Foundation Lip: bbox (286, 16, 669, 193)
    ("floor_lip.png", (286, 16, 669, 193), (64, 24)),
    # Tall Bookshelf: bbox (698, 16, 993, 419)
    ("bookshelf_tall.png", (698, 16, 993, 419), (48, 64)),
    # Wall Stone: bbox (10, 268, 245, 505)
    ("wall_stone.png", (10, 268, 245, 505), (32, 32)),
    # Column: bbox (432, 270, 569, 757)
    ("column.png", (432, 270, 569, 757), (26, 96)),
    # Wall Frieze: bbox (8, 512, 411, 641)
    ("wall_frieze.png", (8, 512, 411, 641), (48, 16)),
    # Balustrade: bbox (594, 532, 1011, 733)
    ("balustrade.png", (594, 532, 1011, 733), (64, 28)),
    # Ceiling Beam: bbox (8, 656, 409, 747)
    ("ceiling_beam.png", (8, 656, 409, 747), (48, 16)),
    # Hanging Lantern: bbox (70, 768, 189, 1017)
    ("hanging_lantern.png", (70, 768, 189, 1017), (18, 36)),
    # Wall Sconce: bbox (448, 778, 561, 981)
    ("wall_sconce.png", (448, 778, 561, 981), (16, 34)),
    # Orrery Pedestal: bbox (606, 768, 753, 1017)
    ("orrery.png", (606, 768, 753, 1017), (22, 38)),
    # Star Chart Frame: bbox (798, 774, 991, 999)
    ("star_chart.png", (798, 774, 991, 999), (28, 32))
]

for filename, box, size in ARCH_MAP:
    process_and_save(a_img, box, size, filename)

# 3. Galaxy Vista
v_img = Image.open(VISTA_PATH).convert("RGB")
vw, vh = 380, 88
v_crop = v_img.crop((120, 0, v_img.width - 120, int(v_img.height * 0.72)))
v_scaled = v_crop.resize((vw, vh), Image.Resampling.LANCZOS)
vista_out = os.path.join(OUT_DIR, "vista_olympus_galaxy.png")
v_scaled.save(vista_out, "PNG")
print(f"  [OK] Saved vista_olympus_galaxy.png ({vw}x{vh}) -> {vista_out}")

print("All Tower of Urania sprites sliced and exported successfully!")
