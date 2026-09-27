from PIL import Image
import os

OUT_DIR = r"c:\Users\netne\Kronos\Kronos Project\kronos-godot\assets\sprites\rooms\livingroom"

for f in sorted(os.listdir(OUT_DIR)):
    if f.endswith('.png') and not f.endswith('_hires.png') and not f.endswith('_preview.png'):
        p = os.path.join(OUT_DIR, f)
        im = Image.open(p).convert('RGBA')
        w, h = im.size
        
        left = [im.getpixel((0, y))[3] for y in range(h)]
        right = [im.getpixel((w-1, y))[3] for y in range(h)]
        top = [im.getpixel((x, 0))[3] for x in range(w)]
        bottom = [im.getpixel((x, h-1))[3] for x in range(w)]
        
        cuts = []
        if any(a > 30 for a in left): cuts.append("LEFT")
        if any(a > 30 for a in right): cuts.append("RIGHT")
        if any(a > 30 for a in top): cuts.append("TOP")
        if any(a > 30 for a in bottom): cuts.append("BOTTOM")
        
        cuts_str = ", ".join(cuts) if cuts else "Clean padding"
        print(f"{f:20s}: touches -> {cuts_str}")
