import os
from PIL import Image

SHEET_PATH = r"C:\Users\netne\.gemini\antigravity\brain\c16bf1a4-3954-476f-975d-a5a59e385b63\shiba_actions_sheet_1790337922544.jpg"
OUT_DIR = r"c:\Users\netne\Kronos\Kronos Project\kronos-godot\assets\sprites\pets\shiba"
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

# Row configurations (each row in 4x4 grid of 256x256 cells)
# We define unified crop boxes relative to each cell so registration is rock-solid.
ROWS = {
    "eat": {
        "row_idx": 0,
        "box_in_cell": (10, 35, 246, 255), # height 220, bottom 255
        "target_w": 28,
        "target_h": 26,
        "paste_y": 4 # bottom at 30 in 32x32
    },
    "loaf": {
        "row_idx": 1,
        "box_in_cell": (10, 25, 250, 235), # height 210, bottom 235
        "target_w": 28,
        "target_h": 22,
        "paste_y": 8 # bottom at 30 in 32x32
    },
    "warm_paws": {
        "row_idx": 2,
        "box_in_cell": (15, 20, 240, 250), # height 230, bottom 250
        "target_w": 26,
        "target_h": 26,
        "paste_y": 4 # bottom at 30 in 32x32
    },
    "gaze": {
        "row_idx": 3,
        "box_in_cell": (10, 15, 236, 256), # height 241, bottom 256
        "target_w": 26,
        "target_h": 28,
        "paste_y": 2 # bottom at 30 in 32x32
    }
}

cw, ch = 256, 256
all_action_frames = {}

print("--- Slicing Shiba Action Frames (Option B: Modular Pet Action Rig) ---")

for action_name, config in ROWS.items():
    r = config["row_idx"]
    bx0, by0, bx1, by1 = config["box_in_cell"]
    tw, th = config["target_w"], config["target_h"]
    py = config["paste_y"]
    frames = []
    
    for c in range(4):
        # 1. Crop cell from sheet
        cell_box = (c * cw, r * ch, (c + 1) * cw, (r + 1) * ch)
        cell = img.crop(cell_box)
        
        # 2. Clean solid white background
        cleaned_cell = clean_white_bg(cell)
        
        # 3. Subcrop with unified bounding box
        subcrop = cleaned_cell.crop((bx0, by0, bx1, by1))
        
        # 4. Proportional pixel downscale
        scaled = subcrop.resize((tw, th), Image.Resampling.LANCZOS)
        
        # Clean alpha threshold from resampling
        p_data = list(scaled.getdata())
        clean_p = []
        for pr, pg, pb, pa in p_data:
            if pa < 30:
                clean_p.append((0, 0, 0, 0))
            else:
                clean_p.append((pr, pg, pb, pa))
        scaled.putdata(clean_p)
        
        # 5. Fit onto standard 32x32 pet canvas
        canvas = Image.new("RGBA", (32, 32), (0, 0, 0, 0))
        # Center horizontally
        px = max(0, (32 - tw) // 2)
        canvas.paste(scaled, (px, py), scaled)
        
        # 6. Save to pet asset directory
        out_filename = f"{action_name}_{c}.png"
        out_path = os.path.join(OUT_DIR, out_filename)
        canvas.save(out_path, "PNG")
        frames.append(canvas)
        print(f"  [OK] Saved {out_filename} -> {out_path}")
        
    all_action_frames[action_name] = frames
    
    # Save animated GIF preview (scale 4x for crystal clear pixel review)
    gif_frames = [f.resize((128, 128), Image.Resampling.NEAREST) for f in frames]
    gif_out = os.path.join(ARTIFACT_DIR, f"shiba_{action_name}_preview.gif")
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
showcase_w = 32 * 4 * 4 # 4 frames * 4x scale
showcase_h = 32 * 4 * 4 # 4 actions * 4x scale
showcase = Image.new("RGBA", (showcase_w, showcase_h), (24, 26, 34, 255)) # Dark theme background

row_keys = ["eat", "loaf", "warm_paws", "gaze"]
for r_i, rk in enumerate(row_keys):
    for c_i, frame in enumerate(all_action_frames[rk]):
        scaled_frame = frame.resize((128, 128), Image.Resampling.NEAREST)
        showcase.paste(scaled_frame, (c_i * 128, r_i * 128), scaled_frame)

showcase_path = os.path.join(ARTIFACT_DIR, "shiba_modular_actions_showcase.png")
showcase.save(showcase_path, "PNG")
print(f"[SHOWCASE] Saved master showcase strip -> {showcase_path}")
print("Option B Shiba actions slicing finished successfully!")
