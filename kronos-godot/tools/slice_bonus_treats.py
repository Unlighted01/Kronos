import os
from collections import deque
from PIL import Image

def clean_and_crop(img, box):
    crop = img.crop(box).convert("RGBA")
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
        if r > 225 and g > 225 and b > 225:
            pix[x, y] = (0, 0, 0, 0)
            for dx, dy in [(-1, 0), (1, 0), (0, -1), (0, 1)]:
                nx, ny = x + dx, y + dy
                if 0 <= nx < w and 0 <= ny < h and not visited[ny][nx]:
                    q.append((nx, ny))
                    
    bbox = crop.getbbox()
    return crop.crop(bbox) if bbox else crop

def fit_to_canvas(crop, target_size, max_dim):
    cw, ch = crop.size
    scale = min(float(max_dim) / max(1, cw), float(max_dim) / max(1, ch))
    nw = max(1, int(round(cw * scale)))
    nh = max(1, int(round(ch * scale)))
    resized = crop.resize((nw, nh), Image.Resampling.NEAREST)
    
    canvas = Image.new("RGBA", (target_size, target_size), (0, 0, 0, 0))
    dest_x = (target_size - nw) // 2
    dest_y = (target_size - nh) // 2
    canvas.paste(resized, (dest_x, dest_y), resized)
    return canvas

def main():
    src_path = r"C:\Users\netne\.gemini\antigravity\brain\c16bf1a4-3954-476f-975d-a5a59e385b63\kronos_bonus_treats_sheet_1790313039125.jpg"
    out_dir = r"c:\Users\netne\Kronos\Kronos Project\kronos-godot\assets\sprites\items"
    os.makedirs(out_dir, exist_ok=True)
    
    full_img = Image.open(src_path).convert("RGB")
    
    large_items = {
        "pancake": (40, 70, 470, 480),
        "bento": (550, 150, 980, 480),
        "energy_drink": (250, 540, 480, 990),
        "mystery_box": (550, 550, 970, 990)
    }
    
    mini_items = {
        "pancake": (25, 20, 165, 165),
        "bento": (540, 15, 725, 180),
        "energy_drink": (50, 540, 165, 700),
        "mystery_box": (540, 540, 690, 710)
    }
    
    for name, box in large_items.items():
        cropped = clean_and_crop(full_img, box)
        frame_32 = fit_to_canvas(cropped, 32, 28)
        out_32 = os.path.join(out_dir, f"{name}_32.png")
        frame_32.save(out_32)
        print(f"Saved {name}_32.png ({frame_32.size}) -> {out_32}")
        
    for name, box in mini_items.items():
        cropped = clean_and_crop(full_img, box)
        frame_16 = fit_to_canvas(cropped, 16, 14)
        out_16 = os.path.join(out_dir, f"{name}.png")
        frame_16.save(out_16)
        print(f"Saved {name}.png ({frame_16.size}) -> {out_16}")

if __name__ == "__main__":
    main()
