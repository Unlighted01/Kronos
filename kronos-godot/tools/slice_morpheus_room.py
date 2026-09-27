import os
from PIL import Image

PROPS_PATH = r"C:\Users\netne\.gemini\antigravity\brain\c16bf1a4-3954-476f-975d-a5a59e385b63\morpheus_props_sheet_1790339083578.jpg"
ARCH_PATH = r"C:\Users\netne\.gemini\antigravity\brain\c16bf1a4-3954-476f-975d-a5a59e385b63\morpheus_arch_sheet_1790339119570.jpg"
VISTA_PATH = r"C:\Users\netne\.gemini\antigravity\brain\c16bf1a4-3954-476f-975d-a5a59e385b63\morpheus_vista_night_1790339148846.jpg"

OUT_DIR = r"c:\Users\netne\Kronos\Kronos Project\kronos-godot\assets\sprites\rooms\bedroom"
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
    
    # Clean alpha threshold
    p_data = list(scaled.getdata())
    clean_p = []
    for r, g, b, a in p_data:
        if a < 25:
            clean_p.append((0, 0, 0, 0))
        else:
            clean_p.append((r, g, b, a))
    scaled.putdata(clean_p)
    
    # Add padding
    fw, fh = tw + pad * 2, th + pad * 2
    canvas = Image.new("RGBA", (fw, fh), (0, 0, 0, 0))
    canvas.paste(scaled, (pad, pad), scaled)
    
    out_path = os.path.join(OUT_DIR, filename)
    canvas.save(out_path, "PNG")
    print(f"  [OK] Saved {filename} ({fw}x{fh}) -> {out_path}")

print("=== Slicing Temple of Morpheus (Study Bedroom) Asset Suite ===")

# 1. Props Sheet
p_img = Image.open(PROPS_PATH).convert("RGB")

PROPS_MAP = [
    # Canopy Bed: bbox (36, 24, 525, 427)
    ("canopy_bed.png", (36, 24, 525, 427), (88, 68)),
    # Study Altar: bbox (588, 118, 971, 353)
    ("study_altar.png", (588, 118, 971, 353), (80, 42)),
    # Dream Hourglass: bbox (52, 456, 211, 727)
    ("dream_hourglass.png", (52, 456, 211, 727), (24, 44)),
    # Silver Candelabra: bbox (284, 486, 445, 727)
    ("candelabra.png", (284, 486, 445, 727), (22, 34)),
    # Font of Lethe Fountain Basin: bbox (512, 502, 777, 729)
    ("lethe_fountain.png", (512, 502, 777, 729), (52, 44)),
    # Dreamcatcher Wind Chimes: bbox (850, 456, 959, 727)
    ("wind_chimes.png", (850, 456, 959, 727), (20, 46)),
    # Embroidered Moon Phase Rug: bbox (56, 778, 771, 999)
    ("moon_rug.png", (56, 778, 771, 999), (92, 30)),
    # Moonflower Urn: bbox (822, 760, 981, 999)
    ("moonflower_urn.png", (822, 760, 981, 999), (22, 32))
]

for filename, box, size in PROPS_MAP:
    process_and_save(p_img, box, size, filename)

# 2. Architectural Sheet
a_img = Image.open(ARCH_PATH).convert("RGB")

ARCH_MAP = [
    # Obsidian Floor Tile: bbox (26, 26, 231, 231)
    ("floor_tile.png", (26, 26, 231, 231), (32, 32)),
    # Stepped Foundation Lip: bbox (264, 26, 707, 231)
    ("floor_lip.png", (264, 26, 707, 231), (64, 24)),
    # Moon Phase Wall Frieze & Stone: bbox (728, 26, 997, 231)
    ("wall_stone.png", (770, 150, 970, 230), (32, 32)),
    ("wall_frieze.png", (728, 60, 997, 160), (48, 16)),
    # Corinthian Moonstone Column: bbox (68, 256, 193, 743)
    ("column.png", (68, 256, 193, 743), (26, 96)),
    # Cedar Ceiling Beam: bbox (298, 266, 611, 373)
    ("ceiling_tile.png", (298, 266, 611, 373), (48, 16)),
    # Hanging Star Lantern: bbox (676, 270, 817, 499)
    ("star_lantern.png", (676, 270, 817, 499), (20, 36)),
    # Blue Flame Wall Sconce: bbox (888, 298, 961, 473)
    ("sconce_blue.png", (888, 298, 961, 473), (16, 34)),
    # Marble Balustrade: bbox (256, 422, 651, 587)
    ("balustrade.png", (256, 422, 651, 587), (64, 28)),
    # Armillary Astrolabe on Pedestal: bbox (842, 522, 981, 769)
    ("astrolabe.png", (842, 522, 981, 769), (22, 38)),
    # Midnight Column Drapes: bbox (328, 640, 469, 1013)
    ("column_drapes.png", (328, 640, 469, 1013), (20, 60)),
    # Grimoire Bookstand & Scrolls: bbox (64, 788, 257, 1007)
    ("grimoire_stand.png", (64, 788, 257, 1007), (28, 30)),
    # Moonflower Vines with Bioluminescent Spores: bbox (550, 778, 765, 1017)
    ("moonflower_vines.png", (550, 778, 765, 1017), (28, 32)),
    # Starlight Luna Moth: bbox (816, 820, 999, 977)
    ("starlight_moth.png", (816, 820, 999, 977), (24, 20))
]

for filename, box, size in ARCH_MAP:
    process_and_save(a_img, box, size, filename)

# 3. Midnight Olympus Vista
v_img = Image.open(VISTA_PATH).convert("RGB")
vw, vh = 380, 88
# Crop focal region (moon, constellations, acropolis, clouds)
v_crop = v_img.crop((100, 0, v_img.width - 100, int(v_img.height * 0.75)))
v_scaled = v_crop.resize((vw, vh), Image.Resampling.LANCZOS)
vista_out = os.path.join(OUT_DIR, "vista_olympus_night.png")
v_scaled.save(vista_out, "PNG")
print(f"  [OK] Saved vista_olympus_night.png ({vw}x{vh}) -> {vista_out}")

print("All Temple of Morpheus sprites sliced and exported successfully!")
