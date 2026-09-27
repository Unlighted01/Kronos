import os
from collections import deque
from PIL import Image

def clean_and_extract_item(img, cell_box, mask_rect=None, bg_threshold=225):
    crop = img.crop(cell_box).convert('RGBA')
    w, h = crop.size
    pix = crop.load()
    
    if mask_rect:
        mx1, my1, mx2, my2 = mask_rect
        for my in range(max(0, my1), min(h, my2)):
            for mx in range(max(0, mx1), min(w, mx2)):
                pix[mx, my] = (255, 255, 255, 255)
                
    visited = [[False]*w for _ in range(h)]
    q = deque()
    for x in range(w):
        q.append((x, 0))
        q.append((x, h-1))
    for y in range(h):
        q.append((0, y))
        q.append((w-1, y))
        
    while q:
        x, y = q.popleft()
        if visited[y][x]:
            continue
        visited[y][x] = True
        r, g, b, a = pix[x, y]
        if (r + g + b) / 3.0 > bg_threshold:
            pix[x, y] = (0, 0, 0, 0)
            for dx, dy in [(-1, 0), (1, 0), (0, -1), (0, 1)]:
                nx, ny = x + dx, y + dy
                if 0 <= nx < w and 0 <= ny < h and not visited[ny][nx]:
                    q.append((nx, ny))
                    
    fg_visited = [[False]*w for _ in range(h)]
    components = []
    for y in range(h):
        for x in range(w):
            if pix[x, y][3] > 0 and not fg_visited[y][x]:
                comp_pixels = []
                cq = deque([(x, y)])
                fg_visited[y][x] = True
                while cq:
                    cx, cy = cq.popleft()
                    comp_pixels.append((cx, cy))
                    for dx, dy in [(-1, 0), (1, 0), (0, -1), (0, 1)]:
                        nx, ny = cx + dx, cy + dy
                        if 0 <= nx < w and 0 <= ny < h and pix[nx, ny][3] > 0 and not fg_visited[ny][nx]:
                            fg_visited[ny][nx] = True
                            cq.append((nx, ny))
                components.append(comp_pixels)
                
    if not components:
        return crop
        
    components.sort(key=lambda c: len(c), reverse=True)
    
    # Keep only the largest component (main item)
    for c in components[1:]:
        for cx, cy in c:
            pix[cx, cy] = (0, 0, 0, 0)
            
    bbox = crop.getbbox()
    return crop.crop(bbox) if bbox else crop

def fit_to_canvas(crop, target_size, max_dim):
    cw, ch = crop.size
    scale = min(float(max_dim) / max(1, cw), float(max_dim) / max(1, ch))
    nw = max(1, int(round(cw * scale)))
    nh = max(1, int(round(ch * scale)))
    resized = crop.resize((nw, nh), Image.Resampling.LANCZOS)
    
    r_pix = resized.load()
    rw, rh = resized.size
    for ry in range(rh):
        for rx in range(rw):
            r, g, b, a = r_pix[rx, ry]
            if a < 70:
                r_pix[rx, ry] = (0, 0, 0, 0)
            elif a > 200:
                r_pix[rx, ry] = (r, g, b, 255)
                
    canvas = Image.new('RGBA', (target_size, target_size), (0, 0, 0, 0))
    dest_x = (target_size - nw) // 2
    dest_y = (target_size - nh) // 2
    canvas.paste(resized, (dest_x, dest_y), resized)
    return canvas

def main():
    s1 = r"C:\Users\netne\.gemini\antigravity\brain\c16bf1a4-3954-476f-975d-a5a59e385b63\kronos_treats_spritesheet_1790310602133.jpg"
    s2 = r"C:\Users\netne\.gemini\antigravity\brain\c16bf1a4-3954-476f-975d-a5a59e385b63\kronos_bonus_treats_sheet_1790313039125.jpg"
    out_dir = r"c:\Users\netne\Kronos\Kronos Project\kronos-godot\assets\sprites\items"
    os.makedirs(out_dir, exist_ok=True)
    
    im1 = Image.open(s1)
    im2 = Image.open(s2)

    items_defs = [
        ('croissant', im1, (0, 0, 340, 340), None),
        ('boba', im1, (340, 0, 680, 340), None),
        ('sushi', im1, (680, 0, 1024, 340), None),
        ('coffee', im1, (0, 340, 340, 680), None),
        ('ramen', im1, (340, 340, 680, 680), None),
        ('matcha', im1, (680, 340, 1024, 680), None),
        ('donut', im1, (0, 680, 340, 1024), None),
        ('star', im1, (340, 680, 680, 1024), None),
        ('alarm', im1, (680, 680, 1024, 1024), None),
        ('pancake', im2, (0, 0, 512, 512), (0, 0, 160, 160)),
        ('bento', im2, (512, 0, 1024, 512), (0, 0, 512, 175)),
        ('energy_drink', im2, (0, 512, 512, 1024), (0, 0, 220, 512)),
        ('mystery_box', im2, (512, 512, 1024, 1024), (0, 0, 160, 170)),
    ]

    for name, sheet, cell_box, mask_rect in items_defs:
        cropped = clean_and_extract_item(sheet, cell_box, mask_rect, 225)
        f16 = fit_to_canvas(cropped, 16, 14)
        f32 = fit_to_canvas(cropped, 32, 28)
        
        p16 = os.path.join(out_dir, f"{name}.png")
        p32 = os.path.join(out_dir, f"{name}_32.png")
        f16.save(p16)
        f32.save(p32)
        print(f"Saved {name}.png and {name}_32.png")

if __name__ == "__main__":
    main()
