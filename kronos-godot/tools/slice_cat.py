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
    src_path = r"C:\Users\netne\.gemini\antigravity\brain\c16bf1a4-3954-476f-975d-a5a59e385b63\cat_pixel_spritesheet_1790254904986.jpg"
    out_dir = r"c:\Users\netne\Kronos\Kronos Project\kronos-godot\assets\sprites\pets\cat"
    os.makedirs(out_dir, exist_ok=True)
    
    full_img = Image.open(src_path).convert("RGB")
    cleaned_img = remove_background_flood(full_img, tolerance=35)
    
    actions = {
        "idle": [
            (66, 71, 252, 231),
            (312, 71, 487, 231),
            (537, 71, 717, 231),
            (772, 71, 953, 231)
        ],
        "walk": [
            (61, 286, 262, 436),
            (291, 286, 492, 436),
            (527, 286, 728, 436),
            (762, 286, 963, 436),
            (71, 455, 272, 605),
            (399, 455, 615, 605)
        ],
        "nap": [
            (117, 655, 318, 799),
            (419, 655, 627, 799),
            (701, 655, 907, 799),
            (419, 655, 627, 799) # 4th loop frame
        ],
        "victory": [
            (132, 855, 287, 1009),
            (424, 855, 626, 1009),
            (711, 855, 887, 1009),
            (424, 855, 626, 1009) # 4th loop frame
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
            print(f"Extracted Calico Cat {action_name}_{f_idx}.png ({nw}x{nh}) -> {out_file}")

if __name__ == "__main__":
    main()
