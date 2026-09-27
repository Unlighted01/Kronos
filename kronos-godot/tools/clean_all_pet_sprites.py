import os
from collections import deque
from PIL import Image

BRAIN_DIR = r"C:\Users\netne\.gemini\antigravity\brain\c16bf1a4-3954-476f-975d-a5a59e385b63"
BASE_PET_DIR = r"c:\Users\netne\Kronos\Kronos Project\kronos-godot\assets\sprites\pets"

def flood_remove_bg(crop, is_bg_pixel_func, filter_components=False):
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
        if is_bg_pixel_func(r, g, b, a):
            pix[x, y] = (0, 0, 0, 0)
            for dx, dy in [(-1, 0), (1, 0), (0, -1), (0, 1)]:
                nx, ny = x + dx, y + dy
                if 0 <= nx < w and 0 <= ny < h and not visited[ny][nx]:
                    q.append((nx, ny))
                    
    if filter_components:
        fg_visited = [[False] * w for _ in range(h)]
        components = []
        for y in range(h):
            for x in range(w):
                if pix[x, y][3] > 0 and not fg_visited[y][x]:
                    comp = []
                    cq = deque([(x, y)])
                    fg_visited[y][x] = True
                    while cq:
                        cx, cy = cq.popleft()
                        comp.append((cx, cy))
                        for dx, dy in [(-1,0), (1,0), (0,-1), (0,1)]:
                            nx, ny = cx + dx, cy + dy
                            if 0 <= nx < w and 0 <= ny < h and pix[nx, ny][3] > 0 and not fg_visited[ny][nx]:
                                fg_visited[ny][nx] = True
                                cq.append((nx, ny))
                    components.append(comp)
                    
        if components:
            components.sort(key=lambda c: len(c), reverse=True)
            for comp in components[1:]:
                if len(comp) < 15:
                    for cx, cy in comp:
                        pix[cx, cy] = (0, 0, 0, 0)
                        
    bbox = crop.getbbox()
    return crop.crop(bbox) if bbox else crop

def fit_pet_frame(crop, max_dim=26.0, target_y=30):
    cw, ch = crop.size
    scale = min(max_dim / max(1, cw), max_dim / max(1, ch))
    nw = max(1, int(round(cw * scale)))
    nh = max(1, int(round(ch * scale)))
    resized = crop.resize((nw, nh), Image.Resampling.NEAREST)
    
    frame = Image.new("RGBA", (32, 32), (0, 0, 0, 0))
    dest_x = (32 - nw) // 2
    dest_y = target_y - nh
    frame.paste(resized, (dest_x, dest_y), resized)
    return frame

def clean_bunny():
    src_path = os.path.join(BRAIN_DIR, "bunny_pixel_spritesheet_1790255476547.jpg")
    out_dir = os.path.join(BASE_PET_DIR, "bunny")
    os.makedirs(out_dir, exist_ok=True)
    full_img = Image.open(src_path).convert("RGB")
    
    cells = {
        "idle": [
            (4, 60, 253, 256),
            (258, 60, 509, 256),
            (514, 60, 765, 256),
            (770, 60, 1021, 256)
        ],
        "walk": [
            (4, 318, 189, 512),
            (194, 318, 397, 512),
            (402, 318, 621, 512),
            (626, 318, 829, 512),
            (834, 318, 1021, 512),
            (194, 318, 397, 512)
        ],
        "nap": [
            (4, 575, 253, 768),
            (258, 575, 509, 768),
            (514, 575, 765, 768),
            (770, 575, 1021, 768)
        ],
        "victory": [
            (4, 814, 253, 1024),
            (258, 814, 509, 1024),
            (514, 814, 765, 1024),
            (770, 814, 1021, 1024)
        ]
    }
    
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
            
        is_bg = lambda r, g, b: (r > 210 and g > 210 and b > 210)
        while q:
            x, y = q.popleft()
            if visited[y][x]: continue
            visited[y][x] = True
            r, g, b, a = pix[x, y]
            if is_bg(r, g, b):
                pix[x, y] = (0, 0, 0, 0)
                for dx, dy in [(-1,0),(1,0),(0,-1),(0,1)]:
                    nx, ny = x+dx, y+dy
                    if 0 <= nx < w and 0 <= ny < h and not visited[ny][nx]:
                        q.append((nx, ny))
                        
        for y in range(h - 3, h):
            for x in range(w):
                pix[x, y] = (0, 0, 0, 0)
                
        fg_visited = [[False] * w for _ in range(h)]
        for y in range(h):
            for x in range(w):
                if pix[x, y][3] > 0 and not fg_visited[y][x]:
                    comp = []
                    cq = deque([(x, y)])
                    fg_visited[y][x] = True
                    while cq:
                        cx, cy = cq.popleft()
                        comp.append((cx, cy))
                        for dx in [-1, 0, 1]:
                            for dy in [-1, 0, 1]:
                                if dx == 0 and dy == 0: continue
                                nx, ny = cx + dx, cy + dy
                                if 0 <= nx < w and 0 <= ny < h and pix[nx, ny][3] > 0 and not fg_visited[ny][nx]:
                                    fg_visited[ny][nx] = True
                                    cq.append((nx, ny))
                    if len(comp) < 30:
                        for cx, cy in comp:
                            pix[cx, cy] = (0, 0, 0, 0)
                            
        bbox = crop.getbbox()
        return crop.crop(bbox) if bbox else crop

    for action_name, boxes in cells.items():
        for f_idx, box in enumerate(boxes):
            crop = full_img.crop(box)
            cleaned = clean_cell(crop)
            frame = fit_pet_frame(cleaned, max_dim=26.0, target_y=30)
            out_file = os.path.join(out_dir, f"{action_name}_{f_idx}.png")
            frame.save(out_file)
    print("Cleaned Bunny sprites (idle, walk, nap, victory - 100% white fur preserved)")

def clean_owl():
    src_path = os.path.join(BRAIN_DIR, "owl_pixel_spritesheet_1790259156262.jpg")
    out_dir = os.path.join(BASE_PET_DIR, "owl")
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
    
    # Grid paper and white background detector
    is_bg = lambda r, g, b, a: (r > 210 and g > 210 and b > 210) or (abs(r - g) < 18 and abs(g - b) < 18 and r > 105)
    
    for action_name, boxes in cells.items():
        for f_idx, box in enumerate(boxes):
            crop = full_img.crop(box)
            cleaned = flood_remove_bg(crop, is_bg, filter_components=True)
            frame = fit_pet_frame(cleaned, max_dim=26.0, target_y=30)
            out_file = os.path.join(out_dir, f"{action_name}_{f_idx}.png")
            frame.save(out_file)
    print("Cleaned Owl sprites (idle, walk, nap, victory - grid removed)")

def clean_penguin():
    src_path = os.path.join(BRAIN_DIR, "penguin_pixel_spritesheet_1790256024938.jpg")
    out_dir = os.path.join(BASE_PET_DIR, "penguin")
    os.makedirs(out_dir, exist_ok=True)
    full_img = Image.open(src_path).convert("RGB")
    
    actions = {
        "idle": [
            (41, 40, 216, 240),
            (297, 40, 472, 240),
            (552, 40, 728, 240),
            (808, 40, 984, 240)
        ],
        "walk": [
            (30, 280, 175, 490),
            (199, 280, 349, 490),
            (363, 280, 502, 490),
            (527, 280, 666, 490),
            (686, 280, 830, 490),
            (849, 280, 984, 490)
        ],
        "nap": [
            (30, 540, 236, 710),
            (281, 540, 497, 710),
            (537, 540, 758, 710),
            (788, 540, 999, 710)
        ],
        "victory": [
            (40, 750, 205, 990),
            (230, 750, 395, 990),
            (430, 750, 600, 990),
            (624, 750, 794, 990)
        ]
    }
    
    is_bg = lambda r, g, b, a: (r > 205 and g > 205 and b > 205)
    
    for action_name, boxes in actions.items():
        for f_idx, box in enumerate(boxes):
            crop = full_img.crop(box)
            cleaned = flood_remove_bg(crop, is_bg, filter_components=True)
            frame = fit_pet_frame(cleaned, max_dim=25.0, target_y=30)
            out_file = os.path.join(out_dir, f"{action_name}_{f_idx}.png")
            frame.save(out_file)
    print("Cleaned Penguin sprites (idle, walk, nap, victory - halos removed)")

def main():
    clean_bunny()
    clean_owl()
    clean_penguin()

if __name__ == "__main__":
    main()
