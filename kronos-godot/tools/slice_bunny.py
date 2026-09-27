import os
from collections import deque
from PIL import Image

def remove_background_flood(img, tolerance=35):
    img = img.convert("RGBA")
    w, h = img.size
    pix = img.load()
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
        if r >= 255 - tolerance and g >= 255 - tolerance and b >= 255 - tolerance:
            pix[x, y] = (0, 0, 0, 0)
            for dx, dy in [(-1, 0), (1, 0), (0, -1), (0, 1)]:
                nx, ny = x + dx, y + dy
                if 0 <= nx < w and 0 <= ny < h and not visited[ny][nx]:
                    q.append((nx, ny))
    return img

def main():
    src_path = r"C:\Users\netne\.gemini\antigravity\brain\c16bf1a4-3954-476f-975d-a5a59e385b63\bunny_pixel_spritesheet_1790255476547.jpg"
    out_dir = r"c:\Users\netne\Kronos\Kronos Project\kronos-godot\assets\sprites\pets\bunny"
    os.makedirs(out_dir, exist_ok=True)
    
    full_img = Image.open(src_path).convert("RGB")
    cleaned_img = remove_background_flood(full_img, tolerance=35)
    
    actions = {
        "idle": [
            (45, 60, 205, 245),
            (302, 60, 461, 245),
            (558, 60, 717, 245),
            (814, 60, 973, 245)
        ],
        "walk": [
            (16, 305, 184, 495),
            (219, 305, 396, 495),
            (428, 305, 609, 495),
            (639, 305, 814, 495),
            (842, 305, 1007, 495),
            (219, 305, 396, 495) # 6th loop frame
        ],
        "nap": [
            (18, 555, 229, 745),
            (284, 555, 485, 745),
            (540, 555, 740, 745),
            (795, 555, 996, 745)
        ],
        "victory": [
            (44, 795, 220, 1000),
            (294, 795, 486, 1000),
            (557, 795, 740, 1000),
            (810, 795, 983, 1000)
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
            print(f"Extracted Snowy Bunny {action_name}_{f_idx}.png ({nw}x{nh}) -> {out_file}")

if __name__ == "__main__":
    main()
