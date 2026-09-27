import os
from PIL import Image

SHEET_EXPANSION = r"C:\Users\netne\.gemini\antigravity\brain\c16bf1a4-3954-476f-975d-a5a59e385b63\hestia_props_expansion_1790324034026.jpg"
SHEET_PROPS = r"C:\Users\netne\.gemini\antigravity\brain\c16bf1a4-3954-476f-975d-a5a59e385b63\hestia_props_sheet_1790316897529.jpg"
SHEET_ARCH = r"C:\Users\netne\.gemini\antigravity\brain\c16bf1a4-3954-476f-975d-a5a59e385b63\hestia_architectural_tiles_1790323139573.jpg"

OUT_DIR = r"c:\Users\netne\Kronos\Kronos Project\kronos-godot\assets\sprites\rooms\livingroom"
os.makedirs(OUT_DIR, exist_ok=True)

# -------------------------------------------------------------------------
# Helper: Clean black background to transparent RGBA
# -------------------------------------------------------------------------
def clean_black_background(cropped_img, threshold=12, feather=18):
    rgba = cropped_img.convert("RGBA")
    data = list(rgba.getdata())
    new_data = []
    
    for r, g, b, a in data:
        brightness = max(r, g, b)
        if brightness < threshold:
            new_data.append((0, 0, 0, 0))
        elif brightness < threshold + feather:
            alpha = int(255 * (float(brightness - threshold) / float(feather)))
            new_data.append((r, g, b, alpha))
        else:
            new_data.append((r, g, b, 255))
            
    rgba.putdata(new_data)
    return rgba

# -------------------------------------------------------------------------
# Helper: Scale preserving aspect ratio and place onto canvas with padding
# -------------------------------------------------------------------------
def scale_and_pad(clean_rgba, max_content_size, canvas_size, pad_bottom=True):
    # Downscale content to fit within max_content_size while preserving aspect ratio
    src_w, src_h = clean_rgba.size
    scale_w = float(max_content_size[0]) / float(src_w)
    scale_h = float(max_content_size[1]) / float(src_h)
    scale = min(scale_w, scale_h)
    
    new_w = max(1, int(round(src_w * scale)))
    new_h = max(1, int(round(src_h * scale)))
    
    scaled = clean_rgba.resize((new_w, new_h), Image.Resampling.LANCZOS)
    
    # Alpha threshold cleanup to keep pixel art crisp
    p_data = list(scaled.getdata())
    clean_p = []
    for r, g, b, a in p_data:
        if a < 25:
            clean_p.append((0, 0, 0, 0))
        else:
            clean_p.append((r, g, b, a))
    scaled.putdata(clean_p)
    
    # Create target canvas (fully transparent)
    canvas = Image.new("RGBA", canvas_size, (0, 0, 0, 0))
    
    # Center horizontally
    offset_x = (canvas_size[0] - new_w) // 2
    # Vertically align: if pad_bottom, align to bottom with bottom margin
    if pad_bottom:
        bottom_margin = max(1, (canvas_size[1] - new_h) // 2)
        offset_y = canvas_size[1] - new_h - bottom_margin
    else:
        offset_y = (canvas_size[1] - new_h) // 2
        
    canvas.paste(scaled, (offset_x, offset_y), scaled)
    return canvas

# -------------------------------------------------------------------------
# 1. PROCESS CORE PROPS (from hestia_props_sheet)
# -------------------------------------------------------------------------
print("--- Processing Core Living Room Props ---")
img_props = Image.open(SHEET_PROPS).convert("RGBA")

CORE_PROPS = {
    "hearth": {
        "box": (41, 14, 450, 424),
        "content_size": (64, 64),
        "canvas_size": (68, 68),
        "pad_bottom": True
    },
    "couch": {
        "box": (500, 26, 1013, 352),
        "content_size": (72, 46),
        "canvas_size": (76, 50),
        "pad_bottom": True
    },
    "table": {
        "box": (11, 510, 508, 737),
        "content_size": (84, 38),
        "canvas_size": (88, 42),
        "pad_bottom": True
    },
    "amphora": {
        "box": (559, 495, 745, 737),
        "content_size": (16, 22),
        "canvas_size": (20, 26),
        "pad_bottom": True
    },
    "column": {
        "box": (811, 384, 929, 760),
        "content_size": (24, 84),
        "canvas_size": (28, 88),
        "pad_bottom": False
    },
    "floor_tile": {
        "box": (986, 384, 1359, 760),
        "content_size": (32, 32),
        "canvas_size": (32, 32),
        "is_tile": True
    }
}

for name, cfg in CORE_PROPS.items():
    crop = img_props.crop(cfg["box"])
    clean = clean_black_background(crop)
    
    # Save hires crop
    clean.save(os.path.join(OUT_DIR, f"{name}_hires.png"), "PNG")
    
    if cfg.get("is_tile", False):
        # Repeating tile: scale directly
        scaled = clean.resize(cfg["canvas_size"], Image.Resampling.LANCZOS)
        out = scaled.convert("RGBA")
    else:
        out = scale_and_pad(clean, cfg["content_size"], cfg["canvas_size"], cfg["pad_bottom"])
        
    out_path = os.path.join(OUT_DIR, f"{name}.png")
    out.save(out_path, "PNG")
    print(f"  [OK] Saved {name:16s} ({out.size[0]}x{out.size[1]})")

# -------------------------------------------------------------------------
# 2. PROCESS EXPANSION PROPS (from hestia_props_expansion)
# -------------------------------------------------------------------------
print("\n--- Processing Expansion Props ---")
img_exp = Image.open(SHEET_EXPANSION).convert("RGBA")

EXP_PROPS = {
    "lyre": {
        # Strictly lyre only - spear tips start at y=444
        "box": (71, 30, 218, 416),
        "content_size": (18, 46),
        "canvas_size": (22, 50),
        "pad_bottom": True
    },
    "brazier": {
        # Strictly brazier - bottom ends at y=334
        "box": (317, 24, 533, 334),
        "content_size": (26, 38),
        "canvas_size": (30, 42),
        "pad_bottom": True
    },
    "cornucopia": {
        # Strictly cornucopia - ends at y=267
        "box": (605, 51, 840, 267),
        "content_size": (24, 22),
        "canvas_size": (28, 26),
        "pad_bottom": True
    },
    "rug": {
        # Strictly tapestry rug - ends at y=254, zero plant leaves
        "box": (904, 56, 1314, 254),
        "content_size": (84, 40),
        "canvas_size": (88, 44),
        "pad_bottom": False
    },
    "olive_planter": {
        # Athena's Olive Tree in Terracotta Urn
        "box": (601, 286, 869, 516),
        "content_size": (32, 28),
        "canvas_size": (36, 32),
        "pad_bottom": True
    },
    "shield": {
        # Full shield with crossed spears and full intact tips
        "box": (29, 444, 289, 728),
        "content_size": (30, 32),
        "canvas_size": (34, 36),
        "pad_bottom": False
    },
    "scroll_shelf": {
        # Full wooden scroll bookcase niche
        "box": (320, 501, 580, 714),
        "content_size": (32, 26),
        "canvas_size": (36, 30),
        "pad_bottom": True
    },
    "sconces": {
        # Single clean brass wall sconce torch
        "box": (619, 563, 715, 697),
        "content_size": (14, 20),
        "canvas_size": (18, 24),
        "pad_bottom": True
    },
    "pillar_pedestal": {
        # Full corner Doric pillar with capital and pedestal base
        "box": (1178, 328, 1336, 748),
        "content_size": (24, 64),
        "canvas_size": (28, 68),
        "pad_bottom": True
    },
    "ceiling_tile": {
        # Rich coffered ceiling woodwork panel
        "box": (866, 522, 1160, 717),
        "content_size": (32, 32),
        "canvas_size": (32, 32),
        "is_tile": True
    }
}

for name, cfg in EXP_PROPS.items():
    crop = img_exp.crop(cfg["box"])
    clean = clean_black_background(crop)
    
    clean.save(os.path.join(OUT_DIR, f"{name}_hires.png"), "PNG")
    
    if cfg.get("is_tile", False):
        scaled = clean.resize(cfg["canvas_size"], Image.Resampling.LANCZOS)
        out = scaled.convert("RGBA")
    else:
        out = scale_and_pad(clean, cfg["content_size"], cfg["canvas_size"], cfg["pad_bottom"])
        
    out_path = os.path.join(OUT_DIR, f"{name}.png")
    out.save(out_path, "PNG")
    print(f"  [OK] Saved {name:16s} ({out.size[0]}x{out.size[1]})")

# -------------------------------------------------------------------------
# 3. PROCESS ARCHITECTURAL ELEMENTS (from hestia_architectural_tiles)
# -------------------------------------------------------------------------
print("\n--- Processing Architectural Tiles & Vista ---")
img_arch = Image.open(SHEET_ARCH).convert("RGBA")

# A. Seamless Greek Ashlar Stone Wall (32x32)
# Crop from middle of stone block region
wall_crop = img_arch.crop((70, 90, 300, 320))
wall_scaled = wall_crop.resize((32, 32), Image.Resampling.LANCZOS)
wall_scaled.save(os.path.join(OUT_DIR, "wall_stone.png"), "PNG")
print("  [OK] Saved wall_stone.png (32x32)")

# B. Seamless Carved Doric Wall Frieze Architrave (260x20)
# Clean inner crop of straight frieze: (410, 65, 890, 200)
frieze_crop = img_arch.crop((410, 65, 890, 200))
frieze_scaled = frieze_crop.resize((260, 20), Image.Resampling.LANCZOS).convert("RGBA")
# Seamless horizontal blend on edges (left 4 columns blended with right 4 columns)
fw, fh = frieze_scaled.size
frieze_data = frieze_scaled.load()
for y in range(fh):
    for i in range(4):
        t = (i + 1) / 5.0
        # Blend left edge and right edge
        l_col = frieze_data[i, y]
        r_col = frieze_data[fw - 1 - i, y]
        # Mix them smoothly
        avg_r = int((1.0 - t) * r_col[0] + t * l_col[0])
        avg_g = int((1.0 - t) * r_col[1] + t * l_col[1])
        avg_b = int((1.0 - t) * r_col[2] + t * l_col[2])
        frieze_data[i, y] = (avg_r, avg_g, avg_b, 255)
        frieze_data[fw - 1 - i, y] = (avg_r, avg_g, avg_b, 255)

frieze_scaled.save(os.path.join(OUT_DIR, "wall_frieze.png"), "PNG")
print("  [OK] Saved wall_frieze.png (260x20, seamless edge-blended)")

# C. Seamless Stepped Foundation Floor Lip with Dentils (64x24)
# Clean straight dentil section: (420, 360, 740, 466) - completely avoids 3D angled corner!
lip_crop = img_arch.crop((420, 360, 740, 466))
lip_scaled = lip_crop.resize((64, 24), Image.Resampling.LANCZOS).convert("RGBA")
lw, lh = lip_scaled.size
lip_data = lip_scaled.load()
for y in range(lh):
    for i in range(3):
        t = (i + 1) / 4.0
        l_col = lip_data[i, y]
        r_col = lip_data[lw - 1 - i, y]
        avg_r = int((1.0 - t) * r_col[0] + t * l_col[0])
        avg_g = int((1.0 - t) * r_col[1] + t * l_col[1])
        avg_b = int((1.0 - t) * r_col[2] + t * l_col[2])
        lip_data[i, y] = (avg_r, avg_g, avg_b, 255)
        lip_data[lw - 1 - i, y] = (avg_r, avg_g, avg_b, 255)

lip_scaled.save(os.path.join(OUT_DIR, "floor_lip.png"), "PNG")
print("  [OK] Saved floor_lip.png (64x24, seamless edge-blended straight foundation)")

# D. Seamless Mount Olympus Sunset Vista (380x88)
# Exact non-black crop of vista: (954, 66, 1338, 256) - zero black pixels!
vista_crop = img_arch.crop((954, 66, 1338, 256))
vista_scaled = vista_crop.resize((380, 88), Image.Resampling.LANCZOS).convert("RGBA")
vw, vh = vista_scaled.size
vista_data = vista_scaled.load()
for y in range(vh):
    for i in range(6):
        t = (i + 1) / 7.0
        l_col = vista_data[i, y]
        r_col = vista_data[vw - 1 - i, y]
        avg_r = int((1.0 - t) * r_col[0] + t * l_col[0])
        avg_g = int((1.0 - t) * r_col[1] + t * l_col[1])
        avg_b = int((1.0 - t) * r_col[2] + t * l_col[2])
        vista_data[i, y] = (avg_r, avg_g, avg_b, 255)
        vista_data[vw - 1 - i, y] = (avg_r, avg_g, avg_b, 255)

vista_scaled.save(os.path.join(OUT_DIR, "vista_olympus.png"), "PNG")
print("  [OK] Saved vista_olympus.png (380x88, seamless edge-blended, 0 black pixels)")

print("\n--- ALL ASSETS SLICED AND BLENDED SUCCESSFULLY ---")
