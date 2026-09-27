from PIL import Image
import os

OUT_DIR = r"c:\Users\netne\Kronos\Kronos Project\kronos-godot\assets\sprites\rooms\livingroom"
SCRATCH = r"C:\Users\netne\.gemini\antigravity\brain\c16bf1a4-3954-476f-975d-a5a59e385b63\scratch"
os.makedirs(SCRATCH, exist_ok=True)

# Helper to find exact bounding box of non-black pixels with threshold
def find_exact_bbox(img, rough_box, threshold=10):
    min_x, min_y, max_x, max_y = rough_box
    t_min_x, t_min_y = max_x, max_y
    t_max_x, t_max_y = min_x, min_y
    found = False
    
    for y in range(min_y, max_y):
        for x in range(min_x, max_x):
            r, g, b = img.getpixel((x, y))[:3]
            if max(r, g, b) > threshold:
                found = True
                if x < t_min_x: t_min_x = x
                if x > t_max_x: t_max_x = x
                if y < t_min_y: t_min_y = y
                if y > t_max_y: t_max_y = y
                
    if not found:
        return rough_box
    return (t_min_x, t_min_y, t_max_x + 1, t_max_y + 1)

# Helper to remove black background cleanly
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

print("Helper ready")
