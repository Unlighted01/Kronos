from PIL import Image
import os

SHEET_PATH = r"C:\Users\netne\.gemini\antigravity\brain\c16bf1a4-3954-476f-975d-a5a59e385b63\hestia_props_expansion_1790324034026.jpg"
OUT_DIR = r"c:\Users\netne\Kronos\Kronos Project\kronos-godot\assets\sprites\rooms\livingroom"
os.makedirs(OUT_DIR, exist_ok=True)

img = Image.open(SHEET_PATH).convert("RGBA")

PROPS = {
    "lyre": {
        "box": (60, 36, 230, 545),
        "target_size": (24, 46)
    },
    "brazier": {
        "box": (317, 24, 533, 440),
        "target_size": (28, 38)
    },
    "cornucopia": {
        "box": (605, 51, 848, 348),
        "target_size": (26, 22)
    },
    "rug": {
        "box": (904, 60, 1336, 335),
        "target_size": (110, 18)
    },
    "olive_planter": {
        "box": (601, 370, 870, 670),
        "target_size": (32, 30)
    },
    "shield": {
        "box": (25, 570, 290, 755),
        "target_size": (28, 28)
    },
    "scroll_shelf": {
        "box": (320, 650, 580, 768),
        "target_size": (28, 26)
    },
    "sconces": {
        "box": (615, 740, 715, 768),
        "target_size": (12, 18)
    },
    "ceiling_tile": {
        "box": (870, 680, 1150, 768),
        "target_size": (32, 32)
    },
    "pillar_pedestal": {
        "box": (1165, 395, 1336, 760),
        "target_size": (24, 64)
    }
}

def remove_black_bg(cropped_img):
    img_rgba = cropped_img.convert("RGBA")
    data = img_rgba.getdata()
    new_data = []
    
    for item in data:
        r, g, b, a = item
        brightness = max(r, g, b)
        if brightness < 12:
            new_data.append((0, 0, 0, 0))
        elif brightness < 30:
            alpha = int(255 * ((brightness - 12) / 18.0))
            new_data.append((r, g, b, alpha))
        else:
            new_data.append((r, g, b, 255))
            
    img_rgba.putdata(new_data)
    return img_rgba

print("--- Slicing Expanded Props ---")
for name, info in PROPS.items():
    box = info["box"]
    target_size = info["target_size"]
    
    crop = img.crop(box)
    clean_crop = remove_black_bg(crop)
    
    # Save hires
    hires_path = os.path.join(OUT_DIR, f"{name}_hires.png")
    clean_crop.save(hires_path, "PNG")
    
    # Pixel scale
    scaled = clean_crop.resize(target_size, Image.Resampling.LANCZOS)
    p_data = scaled.getdata()
    clean = []
    for item in p_data:
        if item[3] < 30:
            clean.append((0, 0, 0, 0))
        else:
            clean.append(item)
    scaled.putdata(clean)
    
    out_path = os.path.join(OUT_DIR, f"{name}.png")
    scaled.save(out_path, "PNG")
    print(f"  [OK] Sliced {name}: {target_size[0]}x{target_size[1]} -> {out_path}")

print("All 10 expansion props sliced successfully!")
