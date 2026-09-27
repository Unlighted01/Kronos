import os
from collections import deque
from PIL import Image

def remove_background_and_grid(img):
    img = img.convert("RGBA")
    w, h = img.size
    pix = img.load()
    visited = [[False] * w for _ in range(h)]
    q = deque()
    
    # Enqueue borders
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
        # Background is white or neutral grey grid line: abs(r-g)<22, abs(g-b)<22, and r > 80
        is_bg = (abs(r - g) < 22 and abs(g - b) < 22 and r > 80)
        if is_bg:
            pix[x, y] = (0, 0, 0, 0)
            for dx, dy in [(-1, 0), (1, 0), (0, -1), (0, 1)]:
                nx, ny = x + dx, y + dy
                if 0 <= nx < w and 0 <= ny < h and not visited[ny][nx]:
                    q.append((nx, ny))
    return img

def main():
    src_path = r"C:\Users\netne\.gemini\antigravity\brain\c16bf1a4-3954-476f-975d-a5a59e385b63\redpanda_pixel_spritesheet_1790258050076.jpg"
    out_dir = r"c:\Users\netne\Kronos\Kronos Project\kronos-godot\assets\sprites\pets\redpanda"
    os.makedirs(out_dir, exist_ok=True)
    
    full_img = Image.open(src_path).convert("RGB")
    cleaned_img = remove_background_and_grid(full_img)
    
    actions = {
        "idle": [
            (10, 60, 245, 230),
            (265, 60, 500, 230),
            (520, 60, 755, 230),
            (775, 60, 1010, 230)
        ],
        "walk": [
            (0, 310, 252, 520),
            (255, 310, 508, 520),
            (510, 310, 765, 520),
            (766, 310, 1020, 520),
            (510, 310, 765, 520), # Frame 4 = loop frame 2
            (255, 310, 508, 520)  # Frame 5 = loop frame 1
        ],
        "nap": [
            (30, 570, 250, 750),
            (285, 570, 508, 750),
            (540, 570, 765, 750),
            (795, 570, 1000, 750)
        ],
        "victory": [
            (15, 800, 220, 1024),
            (270, 800, 485, 1024),
            (525, 800, 725, 1024),
            (775, 800, 985, 1024)
        ]
    }
    
    for action_name, boxes in actions.items():
        for f_idx, box in enumerate(boxes):
            crop = cleaned_img.crop(box)
            bbox = crop.getbbox()
            if bbox:
                crop = crop.crop(bbox)
            
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
            print(f"Extracted Red Panda {action_name}_{f_idx}.png ({nw}x{nh}) -> {out_file}")

if __name__ == "__main__":
    main()
