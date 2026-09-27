from PIL import Image

src_path = r"C:\Users\netne\.gemini\antigravity\brain\c16bf1a4-3954-476f-975d-a5a59e385b63\fox_pixel_spritesheet_1790256574522.jpg"
img = Image.open(src_path).convert("RGB")
w, h = img.size
pixels = img.load()

# Test detecting fox pixels: fox has amber fur where r - b > 50, or dark outline where r < 50
print("Inspecting Fox sprite rows without grey grid:")
for r_name, (y1, y2) in [("idle", (30, 230)), ("walk", (270, 490)), ("nap", (520, 700)), ("happy", (740, 990))]:
    col_has_content = [False] * w
    for x in range(w):
        for y in range(y1, y2):
            r, g, b = pixels[x, y]
            # Fox pixel if colored (r - b > 40) or dark outline (r < 45 and g < 45 and b < 45)
            if (r - b > 40) or (r < 45 and g < 45 and b < 45):
                col_has_content[x] = True
                break
    cols = []
    in_col = False
    start_x = 0
    for x, has_pixel in enumerate(col_has_content):
        if has_pixel and not in_col:
            in_col = True
            start_x = x
        elif not has_pixel and in_col:
            in_col = False
            if x - start_x > 25:
                cols.append((start_x, x))
    if in_col:
        cols.append((start_x, w))
    print(f"{r_name}: found {len(cols)} sprites: {cols}")
