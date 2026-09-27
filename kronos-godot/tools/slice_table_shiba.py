import os
from PIL import Image

SHEET_PATH = r"C:\Users\netne\.gemini\antigravity\brain\c16bf1a4-3954-476f-975d-a5a59e385b63\table_shiba_anim_1790334803598.jpg"
OUT_DIR = r"c:\Users\netne\Kronos\Kronos Project\kronos-godot\assets\sprites\rooms\livingroom\interactions"
os.makedirs(OUT_DIR, exist_ok=True)

img = Image.open(SHEET_PATH).convert("RGBA")

# Clean white background to transparent RGBA
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

# Unified crop boxes for exact registration:
# Width is 452 for all frames (left frames: 30..482, right frames: 542..994)
# Max height is 422 (top frames: y=70..492, bottom frames: y=562..984)
# By using consistent box dimensions, the table stays rock-solid between frames!
FRAMES = [
    ("shiba_table_0", (30, 70, 482, 492)),
    ("shiba_table_1", (542, 70, 994, 492)),
    ("shiba_table_2", (30, 562, 482, 984)),
    ("shiba_table_3", (542, 562, 994, 984))
]

TARGET_SIZE = (88, 70) # Perfectly matches table width (88px) + Shiba height

print("--- Slicing Shiba Table Feast Animation Frames ---")
for name, box in FRAMES:
    crop = img.crop(box)
    clean = clean_white_bg(crop)
    
    # Save hires
    clean.save(os.path.join(OUT_DIR, f"{name}_hires.png"), "PNG")
    
    # Proportional pixel downscale
    scaled = clean.resize(TARGET_SIZE, Image.Resampling.LANCZOS)
    p_data = list(scaled.getdata())
    clean_p = []
    for r, g, b, a in p_data:
        if a < 25:
            clean_p.append((0, 0, 0, 0))
        else:
            clean_p.append((r, g, b, a))
    scaled.putdata(clean_p)
    
    # Add 2px transparent padding around canvas (92x74) for safety
    canvas = Image.new("RGBA", (92, 74), (0, 0, 0, 0))
    canvas.paste(scaled, (2, 2), scaled)
    
    out_path = os.path.join(OUT_DIR, f"{name}.png")
    canvas.save(out_path, "PNG")
    print(f"  [OK] Saved {name} (92x74) -> {out_path}")

print("All 4 Shiba table animation frames sliced successfully!")
