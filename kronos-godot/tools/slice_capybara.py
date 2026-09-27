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
        if (r > 220 and g > 220 and b > 220):
            pix[x, y] = (0, 0, 0, 0)
            for dx, dy in [(-1, 0), (1, 0), (0, -1), (0, 1)]:
                nx, ny = x + dx, y + dy
                if 0 <= nx < w and 0 <= ny < h and not visited[ny][nx]:
                    q.append((nx, ny))
                    
    bbox = crop.getbbox()
    return crop.crop(bbox) if bbox else crop

def main():
    src_path = r"C:\Users\netne\.gemini\antigravity\brain\c16bf1a4-3954-476f-975d-a5a59e385b63\capybara_pixel_spritesheet_1790258710295.jpg"
    out_dir = r"c:\Users\netne\Kronos\Kronos Project\kronos-godot\assets\sprites\pets\capybara"
    os.makedirs(out_dir, exist_ok=True)
    
    full_img = Image.open(src_path).convert("RGB")
    
    cells = {
        "idle": [
            (4, 4, 252, 252),
            (260, 4, 508, 252),
            (516, 4, 764, 252),
            (772, 4, 1020, 252)
        ],
        "walk": [
            (5, 260, 198, 508),
            (210, 260, 400, 508),
            (415, 260, 600, 508),
            (620, 260, 814, 508),
            (825, 260, 1018, 508),
            (415, 260, 600, 508) # 6th loop frame
        ],
        "nap": [
            (4, 516, 252, 764),
            (260, 516, 508, 764),
            (516, 516, 764, 764),
            (772, 516, 1020, 764)
        ],
        "victory": [
            (4, 772, 252, 1020),
            (260, 772, 508, 1020),
            (516, 772, 764, 1020),
            (772, 772, 1020, 1020)
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
            print(f"Extracted Zen Capybara {action_name}_{f_idx}.png ({nw}x{nh}) -> {out_file}")

if __name__ == "__main__":
    main()
