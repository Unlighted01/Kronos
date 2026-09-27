from PIL import Image

src_path = r"C:\Users\netne\.gemini\antigravity\brain\c16bf1a4-3954-476f-975d-a5a59e385b63\penguin_pixel_spritesheet_1790256024938.jpg"
img = Image.open(src_path).convert("RGB")
w, h = img.size
pixels = img.load()

# The 4 rows of interest:
# Row 0: y ~ 40 to 240 (Idle)
# Row 1: y ~ 280 to 490 (Walk)
# Row 2: y ~ 540 to 710 (Sleep)
# Row 3: y ~ 750 to 990 (Happy)
print("Inspecting Penguin sprite rows:")
for r_name, (y1, y2) in [("idle", (40, 240)), ("walk", (280, 490)), ("nap", (540, 710)), ("happy", (750, 990))]:
    col_has_content = [False] * w
    for x in range(w):
        for y in range(y1, y2):
            r, g, b = pixels[x, y]
            if r < 225 or g < 225 or b < 225:
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
