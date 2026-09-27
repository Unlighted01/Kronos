import os
from PIL import Image

SHEET_PATH = r"C:\Users\netne\.gemini\antigravity\brain\c16bf1a4-3954-476f-975d-a5a59e385b63\hestia_temple_decor_1790330498970.jpg"
OUT_DIR = r"c:\Users\netne\Kronos\Kronos Project\kronos-godot\assets\sprites\rooms\livingroom"
os.makedirs(OUT_DIR, exist_ok=True)

img = Image.open(SHEET_PATH).convert("RGBA")

# Helper: clean white background to transparent RGBA
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

def scale_and_pad(clean_rgba, max_content_size, canvas_size, pad_bottom=True):
    src_w, src_h = clean_rgba.size
    scale_w = float(max_content_size[0]) / float(src_w)
    scale_h = float(max_content_size[1]) / float(src_h)
    scale = min(scale_w, scale_h)
    
    new_w = max(1, int(round(src_w * scale)))
    new_h = max(1, int(round(src_h * scale)))
    
    scaled = clean_rgba.resize((new_w, new_h), Image.Resampling.LANCZOS)
    
    p_data = list(scaled.getdata())
    clean_p = []
    for r, g, b, a in p_data:
        if a < 25:
            clean_p.append((0, 0, 0, 0))
        else:
            clean_p.append((r, g, b, a))
    scaled.putdata(clean_p)
    
    canvas = Image.new("RGBA", canvas_size, (0, 0, 0, 0))
    offset_x = (canvas_size[0] - new_w) // 2
    if pad_bottom:
        bottom_margin = max(1, (canvas_size[1] - new_h) // 2)
        offset_y = canvas_size[1] - new_h - bottom_margin
    else:
        offset_y = (canvas_size[1] - new_h) // 2
        
    canvas.paste(scaled, (offset_x, offset_y), scaled)
    return canvas

NEW_DECOR = {
    "chandelier": {
        "box": (45, 10, 168, 290),
        "content_size": (16, 36),
        "canvas_size": (20, 40),
        "pad_bottom": False
    },
    "hanging_herbs": {
        "box": (271, 24, 500, 280),
        "content_size": (22, 24),
        "canvas_size": (26, 28),
        "pad_bottom": False
    },
    "firewood": {
        "box": (542, 45, 745, 285),
        "content_size": (24, 28),
        "canvas_size": (28, 32),
        "pad_bottom": True
    },
    "tapestry": {
        "box": (760, 25, 990, 380),
        "content_size": (24, 38),
        "canvas_size": (28, 42),
        "pad_bottom": False
    },
    "column_drapes": {
        "box": (25, 316, 135, 675),
        "content_size": (16, 56),
        "canvas_size": (20, 60),
        "pad_bottom": True
    },
    "floor_amphora": {
        "box": (302, 393, 495, 665),
        "content_size": (20, 28),
        "canvas_size": (24, 32),
        "pad_bottom": True
    },
    "thurible": {
        "box": (557, 425, 715, 665),
        "content_size": (18, 26),
        "canvas_size": (22, 30),
        "pad_bottom": True
    },
    "mosaic_medallion": {
        "box": (767, 446, 995, 685),
        "content_size": (34, 34),
        "canvas_size": (38, 38),
        "pad_bottom": False
    },
    "ivy_vines": {
        "box": (20, 716, 290, 975),
        "content_size": (26, 26),
        "canvas_size": (30, 30),
        "pad_bottom": False
    },
    "white_dove": {
        "box": (342, 804, 485, 920),
        "content_size": (16, 14),
        "canvas_size": (20, 18),
        "pad_bottom": True
    },
    "marble_bust": {
        "box": (583, 716, 685, 975),
        "content_size": (14, 34),
        "canvas_size": (18, 38),
        "pad_bottom": True
    },
    "food_platter": {
        "box": (773, 808, 985, 945),
        "content_size": (24, 16),
        "canvas_size": (28, 20),
        "pad_bottom": True
    }
}

print("--- Slicing 12 New Temple Decor Sprites ---")
for name, cfg in NEW_DECOR.items():
    crop = img.crop(cfg["box"])
    clean = clean_white_bg(crop)
    
    hires_path = os.path.join(OUT_DIR, f"{name}_hires.png")
    clean.save(hires_path, "PNG")
    
    padded = scale_and_pad(clean, cfg["content_size"], cfg["canvas_size"], cfg["pad_bottom"])
    out_path = os.path.join(OUT_DIR, f"{name}.png")
    padded.save(out_path, "PNG")
    print(f"  [OK] Saved {name:18s} ({padded.size[0]}x{padded.size[1]}) -> {out_path}")

print("All 12 new decor sprites sliced successfully!")
