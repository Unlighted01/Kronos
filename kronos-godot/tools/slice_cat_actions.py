import os
from PIL import Image

SHEET_PATH = r"C:\Users\netne\.gemini\antigravity\brain\c16bf1a4-3954-476f-975d-a5a59e385b63\cat_actions_sheet_1790339750108.jpg"
OUT_DIR = r"c:\Users\netne\Kronos\Kronos Project\kronos-godot\assets\sprites\pets\cat"
ARTIFACT_DIR = r"C:\Users\netne\.gemini\antigravity\brain\c16bf1a4-3954-476f-975d-a5a59e385b63"
os.makedirs(OUT_DIR, exist_ok=True)

img = Image.open(SHEET_PATH).convert("RGBA")

def clean_white_bg(crop_im, thresh=242, feather=15):
    rgba = crop_im.convert("RGBA")
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

# Unified crop definitions across columns for each action row
ROWS = {
    "eat": {
        "boxes": [
            (35, 65, 255, 248),
            (280, 65, 510, 248),
            (540, 65, 735, 248),
            (800, 65, 985, 248)
        ],
        "target_w": 26,
        "target_h": 22,
        "paste_y": 8 # bottom at 30
    },
    "loaf": {
        "boxes": [
            (45, 340, 240, 484),
            (290, 340, 485, 484),
            (535, 340, 735, 484),
            (780, 340, 985, 484)
        ],
        "target_w": 26,
        "target_h": 18,
        "paste_y": 12 # bottom at 30
    },
    "warm_paws": {
        "boxes": [
            (50, 568, 220, 737),
            (290, 568, 490, 737),
            (535, 568, 745, 737),
            (795, 568, 950, 737)
        ],
        "target_w": 24,
        "target_h": 24,
        "paste_y": 6 # bottom at 30
    },
    "gaze": {
        "boxes": [
            (30, 808, 240, 1016),
            (270, 808, 485, 1016),
            (515, 808, 770, 1016),
            (760, 808, 965, 1016)
        ],
        "target_w": 24,
        "target_h": 26,
        "paste_y": 4 # bottom at 30
    }
}

all_action_frames = {}

print("=== Slicing Calico Cat Modular Action Frames ===")

for action_name, config in ROWS.items():
    boxes = config["boxes"]
    tw, th = config["target_w"], config["target_h"]
    py = config["paste_y"]
    frames = []
    
    for c, box in enumerate(boxes):
        crop = img.crop(box)
        cleaned = clean_white_bg(crop)
        scaled = cleaned.resize((tw, th), Image.Resampling.LANCZOS)
        
        # Clean alpha threshold
        p_data = list(scaled.getdata())
        clean_p = []
        for pr, pg, pb, pa in p_data:
            if pa < 30:
                clean_p.append((0, 0, 0, 0))
            else:
                clean_p.append((pr, pg, pb, pa))
        scaled.putdata(clean_p)
        
        # Fit into standard 32x32 pet canvas
        canvas = Image.new("RGBA", (32, 32), (0, 0, 0, 0))
        px = max(0, (32 - tw) // 2)
        canvas.paste(scaled, (px, py), scaled)
        
        out_filename = f"{action_name}_{c}.png"
        out_path = os.path.join(OUT_DIR, out_filename)
        canvas.save(out_path, "PNG")
        frames.append(canvas)
        print(f"  [OK] Saved {out_filename} -> {out_path}")
        
    all_action_frames[action_name] = frames
    
    # Save animated GIF preview (scale 4x for crystal clear review)
    gif_frames = [f.resize((128, 128), Image.Resampling.NEAREST) for f in frames]
    gif_out = os.path.join(ARTIFACT_DIR, f"cat_{action_name}_preview.gif")
    gif_frames[0].save(
        gif_out,
        save_all=True,
        append_images=gif_frames[1:],
        duration=240,
        loop=0,
        disposal=2
    )
    print(f"  [GIF] Created {gif_out}")

# Build a comprehensive 4x4 master showcase strip
showcase_w = 32 * 4 * 4
showcase_h = 32 * 4 * 4
showcase = Image.new("RGBA", (showcase_w, showcase_h), (24, 26, 34, 255))

row_keys = ["eat", "loaf", "warm_paws", "gaze"]
for r_i, rk in enumerate(row_keys):
    for c_i, frame in enumerate(all_action_frames[rk]):
        scaled_frame = frame.resize((128, 128), Image.Resampling.NEAREST)
        showcase.paste(scaled_frame, (c_i * 128, r_i * 128), scaled_frame)

showcase_path = os.path.join(ARTIFACT_DIR, "cat_modular_actions_showcase.png")
showcase.save(showcase_path, "PNG")
print(f"[SHOWCASE] Saved master showcase strip -> {showcase_path}")
print("Calico Cat actions slicing finished successfully!")
