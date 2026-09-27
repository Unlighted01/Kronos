import os
from PIL import Image

SHEET_PATH = r"C:\Users\netne\.gemini\antigravity\brain\c16bf1a4-3954-476f-975d-a5a59e385b63\hestia_props_sheet_1790316897529.jpg"
OUT_DIR = r"c:\Users\netne\Kronos\Kronos Project\kronos-godot\assets\sprites\rooms\livingroom"
os.makedirs(OUT_DIR, exist_ok=True)

img = Image.open(SHEET_PATH).convert("RGBA")

# Bounding boxes measured from the sheet with safety margins
PROPS = {
    "hearth": {
        "box": (41, 14, 449, 423),
        "target_size": (80, 80)
    },
    "couch": {
        "box": (500, 26, 1012, 351),
        "target_size": (84, 54)
    },
    "table": {
        "box": (11, 510, 507, 736),
        "target_size": (104, 48)
    },
    "amphora": {
        "box": (559, 495, 744, 736),
        "target_size": (20, 26)
    },
    "column": {
        "box": (811, 384, 928, 759),
        "target_size": (28, 92)
    },
    "floor_tile": {
        "box": (986, 384, 1358, 756),
        "target_size": (32, 32)
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

print("--- Slicing Living Room Props ---")
for name, info in PROPS.items():
    box = info["box"]
    target_size = info["target_size"]
    
    # 1. Crop
    crop = img.crop(box)
    
    # 2. Transparent BG
    clean_crop = remove_black_bg(crop)
    
    # 3. Save raw high-res crop
    hires_path = os.path.join(OUT_DIR, f"{name}_hires.png")
    clean_crop.save(hires_path, "PNG")
    
    # 4. Pixel-perfect downscale with LANCZOS / NEAREST hybrid
    # We do a LANCZOS downscale then ensure crisp alpha
    pixel_prop = clean_crop.resize(target_size, Image.Resampling.LANCZOS)
    
    # Clean up alpha threshold on downscaled image
    p_data = pixel_prop.getdata()
    clean_p_data = []
    for item in p_data:
        r, g, b, a = item
        if a < 30:
            clean_p_data.append((0, 0, 0, 0))
        else:
            clean_p_data.append((r, g, b, a))
    pixel_prop.putdata(clean_p_data)
    
    out_path = os.path.join(OUT_DIR, f"{name}.png")
    pixel_prop.save(out_path, "PNG")
    
    # Also save a 2x preview for inspection
    preview_path = os.path.join(OUT_DIR, f"{name}_preview.png")
    clean_crop.resize((target_size[0] * 3, target_size[1] * 3), Image.Resampling.NEAREST).save(preview_path)
    
    print(f"  [OK] Sliced {name}: {target_size[0]}x{target_size[1]} -> {out_path}")

print("All living room props sliced successfully!")
