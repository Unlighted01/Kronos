from PIL import Image

src_path = r"C:\Users\netne\.gemini\antigravity\brain\c16bf1a4-3954-476f-975d-a5a59e385b63\bunny_pixel_spritesheet_1790255476547.jpg"
img = Image.open(src_path).convert("RGB")
w, h = img.size
pixels = img.load()

# Find row spans
row_has_content = [False] * h
for y in range(h):
    for x in range(w):
        r, g, b = pixels[x, y]
        # Ignore horizontal grid dividing lines if they are pure black/grey across full row
        if r < 235 or g < 235 or b < 235:
            row_has_content[y] = True
            break

# The 4 rows of interest:
# Row 0: y ~ 60 to 240 (Idle)
# Row 1: y ~ 310 to 490 (Walk)
# Row 2: y ~ 560 to 740 (Sleep)
# Row 3: y ~ 800 to 1000 (Happy)
print("Inspecting Bunny sprite rows:")
for r_name, (y1, y2) in [("idle", (60, 245)), ("walk", (305, 495)), ("nap", (555, 745)), ("happy", (795, 1000))]:
    col_has_content = [False] * w
    for x in range(w):
        for y in range(y1, y2):
            r, g, b = pixels[x, y]
            if r < 220 or g < 220 or b < 220:
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
