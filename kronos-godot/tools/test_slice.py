import os
from PIL import Image

src_path = r"C:\Users\netne\.gemini\antigravity\brain\c16bf1a4-3954-476f-975d-a5a59e385b63\shiba_pixel_spritesheet_1790253296306.jpg"
img = Image.open(src_path).convert("RGBA")
pixels = img.load()

# Test Row 0, Sprite 0 (Idle 0)
x1, x2 = 28, 183
y1, y2 = 28, 194

sprite_crop = img.crop((x1, y1, x2, y2))
sw, sh = sprite_crop.size

# Make transparent: any pixel close to white (R>230, G>230, B>230) becomes alpha=0
crop_pixels = sprite_crop.load()
for y in range(sh):
    for x in range(sw):
        r, g, b, a = crop_pixels[x, y]
        if r > 235 and g > 235 and b > 235:
            crop_pixels[x, y] = (0, 0, 0, 0)

# Target 32x32 frame
frame_32 = Image.new("RGBA", (32, 32), (0, 0, 0, 0))

# Rescale sprite to fit nicely within ~24-28 pixels high while keeping aspect ratio
scale = min(28.0 / sw, 28.0 / sh)
nw = int(sw * scale)
nh = int(sh * scale)
scaled_sprite = sprite_crop.resize((nw, nh), Image.Resampling.NEAREST)

# Position with bottom aligned around y=30 (so feet touch floor)
dest_x = (32 - nw) // 2
dest_y = 30 - nh
frame_32.paste(scaled_sprite, (dest_x, dest_y), scaled_sprite)

out_dir = r"c:\Users\netne\Kronos\Kronos Project\kronos-godot\assets\sprites\pets\shiba"
os.makedirs(out_dir, exist_ok=True)
test_out = os.path.join(out_dir, "test_idle_0.png")
frame_32.save(test_out)
print(f"Saved test 32x32 frame to {test_out}")
