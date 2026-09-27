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
        # Background is white or neutral grey grid line: abs(r-g)<20, abs(g-b)<20, and r > 90
        is_bg = (abs(r - g) < 22 and abs(g - b) < 22 and r > 85)
        if is_bg:
            pix[x, y] = (0, 0, 0, 0)
            for dx, dy in [(-1, 0), (1, 0), (0, -1), (0, 1)]:
                nx, ny = x + dx, y + dy
                if 0 <= nx < w and 0 <= ny < h and not visited[ny][nx]:
                    q.append((nx, ny))
    return img

def main():
    src_path = r"C:\Users\netne\.gemini\antigravity\brain\c16bf1a4-3954-476f-975d-a5a59e385b63\fox_pixel_spritesheet_1790256574522.jpg"
    out_dir = r"c:\Users\netne\Kronos\Kronos Project\kronos-godot\assets\sprites\pets\fox"
    os.makedirs(out_dir, exist_ok=True)
    
    full_img = Image.open(src_path).convert("RGB")
    cleaned_img = remove_background_and_grid(full_img)
    
    actions = {
        "idle": [
            (13, 30, 160, 230),
            (160, 30, 310, 230),
            (320, 30, 490, 230),
            (525, 30, 690, 230)
        ],
        "walk": [
            (13, 270, 205, 490),
            (220, 270, 425, 490),
            (440, 270, 615, 490),
            (615, 270, 785, 490),
            (795, 270, 1005, 490),
            (220, 270, 425, 490) # 6th loop frame
        ],
        "nap": [
            (13, 520, 192, 700),
            (218, 520, 392, 700),
            (423, 520, 597, 700),
            (627, 520, 802, 700)
        ],
        "victory": [
            (17, 740, 205, 990),
            (218, 740, 397, 990),
            (422, 740, 623, 990),
            (652, 740, 820, 990)
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
            print(f"Extracted Amber Fox {action_name}_{f_idx}.png ({nw}x{nh}) -> {out_file}")

if __name__ == "__main__":
    main()
