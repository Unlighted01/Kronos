from PIL import Image
from clean_helper import find_exact_bbox, clean_black_background
import os

EXPANSION_SHEET = r"C:\Users\netne\.gemini\antigravity\brain\c16bf1a4-3954-476f-975d-a5a59e385b63\hestia_props_expansion_1790324034026.jpg"
SCRATCH = r"C:\Users\netne\.gemini\antigravity\brain\c16bf1a4-3954-476f-975d-a5a59e385b63\scratch"

img = Image.open(EXPANSION_SHEET).convert("RGB")
w, h = img.size

# Let's inspect rough areas and get exact bboxes
ROUGH = {
    "lyre": (10, 10, 280, 580),
    "brazier": (280, 10, 580, 480),
    "cornucopia": (580, 20, 880, 380),
    "rug": (880, 40, 1360, 360),
    "olive_planter": (580, 360, 890, 690),
    "shield": (10, 550, 300, 768),
    "scroll_shelf": (300, 620, 590, 768),
    "sconces": (600, 700, 840, 768),
    "ceiling_tile": (840, 650, 1160, 768),
    "pillar_pedestal": (1150, 370, 1360, 768)
}

print("=== EXACT BOUNDING BOXES FOR EXPANSION SHEET ===")
for name, rough in ROUGH.items():
    exact = find_exact_bbox(img, rough, threshold=12)
    # Add 4px margin around exact, clamped to sheet
    m_box = (
        max(0, exact[0] - 4),
        max(0, exact[1] - 4),
        min(w, exact[2] + 4),
        min(h, exact[3] + 4)
    )
    cropped = img.crop(m_box)
    cleaned = clean_black_background(cropped)
    
    # Save preview in scratch
    out_p = os.path.join(SCRATCH, f"inspect_{name}.png")
    cleaned.save(out_p)
    bw = exact[2] - exact[0]
    bh = exact[3] - exact[1]
    aspect = bw / float(bh)
    print(f"{name:16s}: exact={exact}, size={bw}x{bh}, aspect={aspect:.2f}")
