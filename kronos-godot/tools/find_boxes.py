from PIL import Image
import os

img = Image.open(r"C:\Users\netne\.gemini\antigravity\brain\c16bf1a4-3954-476f-975d-a5a59e385b63\hestia_props_expansion_1790324034026.jpg").convert("RGB")

def get_tight_bbox(img, rough_box, threshold=15):
    min_x, min_y, max_x, max_y = rough_box
    t_min_x, t_min_y = max_x, max_y
    t_max_x, t_max_y = min_x, min_y
    found = False
    
    for y in range(min_y, max_y):
        for x in range(min_x, max_x):
            r, g, b = img.getpixel((x, y))
            if max(r, g, b) > threshold:
                found = True
                if x < t_min_x: t_min_x = x
                if x > t_max_x: t_max_x = x
                if y < t_min_y: t_min_y = y
                if y > t_max_y: t_max_y = y
                
    if not found:
        return rough_box
    return (t_min_x, t_min_y, t_max_x + 1, t_max_y + 1)

ROUGH_REGIONS = {
    'lyre': (30, 20, 260, 560),
    'brazier': (290, 20, 560, 460),
    'cornucopia': (580, 50, 860, 360),
    'rug': (880, 60, 1340, 350),
    'olive_planter': (590, 370, 880, 680),
    'shield': (20, 570, 300, 768),
    'scroll_shelf': (310, 650, 580, 768),
    'sconces': (610, 720, 840, 768),
    'coffered_ceiling': (850, 670, 1160, 768),
    'pillar_pedestal': (1160, 390, 1350, 768)
}

print("Tight BBoxes:")
for name, r_box in ROUGH_REGIONS.items():
    tight = get_tight_bbox(img, r_box)
    print(f'    "{name}": {tight},')
