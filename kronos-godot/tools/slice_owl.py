import os
from collections import deque
from PIL import Image

def clean_cell(crop):
    crop = crop.convert("RGBA")
    w, h = crop.size
    pix = crop.load()
    visited = [[False] * w for _ in range(h)]
    q = deque()
    for x in range(w):
        q.append((x, 0))
        q.append((x, h - 1))
    for y in range(h):
        q.append((0, y))
        q.append((w - 1, y))
        
    while q:
        x, y = q.popleft()
        if visited[y][x]:
            continue
        visited[y][x] = True
        r, g, b, a = pix[x, y]
        # White background and light borders
        if (r > 215 and g > 215 and b > 215) or (abs(r - g) < 20 and abs(g - b) < 20 and r > 180):
            pix[x, y] = (0, 0, 0, 0)
            for dx, dy in [(-1, 0), (1, 0), (0, -1), (0, 1)]:
                nx, ny = x + dx, y + dy
                if 0 <= nx < w and 0 <= ny < h and not visited[ny][nx]:
                    q.append((nx, ny))
                    
    bbox = crop.getbbox()
    return crop.crop(bbox) if bbox else crop

def main():
    src_path = r"C:\Users\netne\.gemini\antigravity\brain\c16bf1a4-3954-476f-975d-a5a59e385b63\owl_pixel_spritesheet_1790259156262.jpg"
    out_dir = r"c:\Users\netne\Kronos\Kronos Project\kronos-godot\assets\sprites\pets\owl"
    os.makedirs(out_dir, exist_ok=True)
    
    full_img = Image.open(src_path).convert("RGB")
    
    cells = {
        "idle": [
            (50, 48, 205, 246),
            (255, 40, 460, 246),
            (560, 48, 715, 246),
            (810, 45, 965, 246)
        ],
        "walk": [
            (12, 280, 180, 502),
            (178, 280, 340, 502),
            (348, 300, 510, 502),
            (514, 300, 665, 502),
            (680, 300, 840, 502),
            (850, 300, 1005, 502)
        ],
        "nap": [
            (25, 535, 220, 745),
            (285, 550, 480, 745),
            (545, 545, 745, 745),
            (800, 545, 995, 745)
        ],
        "victory": [
            (25, 775, 245, 1020),
            (248, 775, 485, 1020),
            (520, 800, 755, 1020),
            (805, 800, 985, 1020)
        ]
    }
    
    for action_name, boxes in cells.items():
        for f_idx, box in enumerate(boxes):
            cr = full_img.crop(box)
            crop = clean_cell(cr)
            
            cw, ch = crop.size
            frame = Image.new("RGBA", (32, 32), (0, 0, 0, 0))
            
            max_dim = 26.0
            scale = min(max_dim / max(1, cw), max_dim / max(1, ch))
            nw = max(1, int(round(cw * scale)))
            nh = max(1, int(round(ch * scale)))
            
            resized = crop.resize((nw, nh), Image.Resampling.NEAREST)
            
            dest_x = (32 - nw) // 2
            dest_y = 30 - nh
            frame.paste(resized, (dest_x, dest_y), resized)
            
            out_file = os.path.join(out_dir, f"{action_name}_{f_idx}.png")
            frame.save(out_file)
            print(f"Extracted Scholar Owl {action_name}_{f_idx}.png ({nw}x{nh}) -> {out_file}")

if __name__ == "__main__":
    main()
