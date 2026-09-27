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
        # Pure white background
        if r > 225 and g > 225 and b > 225:
            pix[x, y] = (0, 0, 0, 0)
            for dx, dy in [(-1, 0), (1, 0), (0, -1), (0, 1)]:
                nx, ny = x + dx, y + dy
                if 0 <= nx < w and 0 <= ny < h and not visited[ny][nx]:
                    q.append((nx, ny))
                    
    bbox = crop.getbbox()
    return crop.crop(bbox) if bbox else crop

def fit_to_box(crop, target_w, target_h, max_w, max_h, align_bottom=True):
    cw, ch = crop.size
    scale = min(float(max_w) / max(1, cw), float(max_h) / max(1, ch))
    nw = max(1, int(round(cw * scale)))
    nh = max(1, int(round(ch * scale)))
    resized = crop.resize((nw, nh), Image.Resampling.NEAREST)
    
    canvas = Image.new("RGBA", (target_w, target_h), (0, 0, 0, 0))
    dest_x = (target_w - nw) // 2
    dest_y = (target_h - nh - 2) if align_bottom else (target_h - nh) // 2
    canvas.paste(resized, (dest_x, dest_y), resized)
    return canvas

def main():
    src_path = r"C:\Users\netne\.gemini\antigravity\brain\c16bf1a4-3954-476f-975d-a5a59e385b63\kronos_plants_spritesheet_1790310996052.jpg"
    out_dir = r"c:\Users\netne\Kronos\Kronos Project\kronos-godot\assets\sprites\plants"
    os.makedirs(out_dir, exist_ok=True)
    
    full_img = Image.open(src_path).convert("RGB")
    
    # Botanical crops
    flowers = {
        "flower_rose": (30, 80, 235, 440),
        "flower_sunflower": (290, 60, 475, 445),
        "flower_bluebell": (535, 90, 735, 445),
        "flower_orchid": (765, 60, 985, 445)
    }
    
    props = {
        "pot_normal": (40, 535, 215, 712),
        "pot_glow": (270, 485, 485, 725),
        "watering_can": (500, 510, 745, 712),
        "pot_sprout": (805, 505, 975, 715)
    }
    
    # Flowers: 32x48 canvas (tall for full stems & blooms)
    for name, box in flowers.items():
        cropped = clean_and_crop(full_img, box)
        canvas = fit_to_box(cropped, 32, 48, 30, 46, align_bottom=True)
        out_file = os.path.join(out_dir, f"{name}.png")
        canvas.save(out_file)
        print(f"Saved {name}.png ({canvas.size}) -> {out_file}")
        
    # Props: 32x32 canvas
    for name, box in props.items():
        cropped = clean_and_crop(full_img, box)
        canvas = fit_to_box(cropped, 32, 32, 30, 30, align_bottom=True)
        out_file = os.path.join(out_dir, f"{name}.png")
        canvas.save(out_file)
        print(f"Saved {name}.png ({canvas.size}) -> {out_file}")

if __name__ == "__main__":
    main()
