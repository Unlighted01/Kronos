import os
from collections import deque
from PIL import Image

def remove_background_flood(img, tolerance=35):
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
        if r >= 255 - tolerance and g >= 255 - tolerance and b >= 255 - tolerance:
            pix[x, y] = (0, 0, 0, 0)
            for dx, dy in [(-1, 0), (1, 0), (0, -1), (0, 1)]:
                nx, ny = x + dx, y + dy
                if 0 <= nx < w and 0 <= ny < h and not visited[ny][nx]:
                    q.append((nx, ny))
    return img

def main():
    src_path = r"C:\Users\netne\.gemini\antigravity\brain\c16bf1a4-3954-476f-975d-a5a59e385b63\shiba_pixel_spritesheet_1790253296306.jpg"
    out_dir = r"c:\Users\netne\Kronos\Kronos Project\kronos-godot\assets\sprites\pets\shiba"
    os.makedirs(out_dir, exist_ok=True)
    
    full_img = Image.open(src_path).convert("RGB")
    cleaned_img = remove_background_flood(full_img, tolerance=35)
    
    # Coordinate definitions from detection
    actions = {
        "idle": [
            (28, 28, 183, 194),
            (284, 28, 444, 194),
            (540, 28, 695, 194),
            (807, 28, 973, 194)
        ],
        "walk": [
            (11, 233, 171, 393),
            (176, 233, 342, 393),
            (347, 233, 513, 393),
            (517, 233, 678, 393),
            (682, 233, 848, 393),
            (853, 233, 1013, 393)
        ],
        "nap": [
            (39, 437, 234, 581),
            (295, 437, 484, 581),
            (546, 437, 740, 581),
            (802, 437, 991, 581)
        ],
        "victory": [
            (39, 625, 211, 814),
            (283, 625, 467, 814),
            (545, 625, 747, 814),
            (789, 625, 997, 814)
        ]
    }
    
    # Process each action
    for action_name, boxes in actions.items():
        for f_idx, box in enumerate(boxes):
            crop = cleaned_img.crop(box)
            
            # Find tight non-transparent bounding box
            bbox = crop.getbbox()
            if bbox:
                crop = crop.crop(bbox)
            
            cw, ch = crop.size
            
            # Target 32x32 frame
            frame = Image.new("RGBA", (32, 32), (0, 0, 0, 0))
            
            # Scale proportionally so it fits naturally in a 32x32 canvas
            max_dim = 26.0
            scale = min(max_dim / max(1, cw), max_dim / max(1, ch))
            nw = max(1, int(round(cw * scale)))
            nh = max(1, int(round(ch * scale)))
            
            resized = crop.resize((nw, nh), Image.Resampling.NEAREST)
            
            # Center horizontally, align feet to y = 30
            dest_x = (32 - nw) // 2
            dest_y = 30 - nh
            frame.paste(resized, (dest_x, dest_y), resized)
            
            out_file = os.path.join(out_dir, f"{action_name}_{f_idx}.png")
            frame.save(out_file)
            print(f"Extracted {action_name}_{f_idx}.png ({nw}x{nh}) -> {out_file}")

if __name__ == "__main__":
    main()
