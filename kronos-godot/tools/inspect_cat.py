from PIL import Image

src_path = r"C:\Users\netne\.gemini\antigravity\brain\c16bf1a4-3954-476f-975d-a5a59e385b63\cat_pixel_spritesheet_1790254904986.jpg"
img = Image.open(src_path).convert("RGB")
w, h = img.size
pixels = img.load()

# Find row spans (ignore top 100 pixels if it's text header, or inspect all)
row_has_content = [False] * h
for y in range(h):
    for x in range(w):
        r, g, b = pixels[x, y]
        if r < 235 or g < 235 or b < 235:
            row_has_content[y] = True
            break

rows = []
in_row = False
start_y = 0
for y, has_pixel in enumerate(row_has_content):
    if has_pixel and not in_row:
        in_row = True
        start_y = y
    elif not has_pixel and in_row:
        in_row = False
        if y - start_y > 15:
            rows.append((start_y, y))
if in_row:
    rows.append((start_y, h))

print(f"Found {len(rows)} rows:")
for idx, (y1, y2) in enumerate(rows):
    print(f"Row {idx}: y=[{y1}, {y2}], height={y2-y1}")
    
    col_has_content = [False] * w
    for x in range(w):
        for y in range(y1, y2):
            r, g, b = pixels[x, y]
            if r < 235 or g < 235 or b < 235:
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
            if x - start_x > 20:
                cols.append((start_x, x))
    if in_col:
        cols.append((start_x, w))
        
    print(f"  Found {len(cols)} items in Row {idx}:")
    for c_idx, (x1, x2) in enumerate(cols):
        print(f"    Item {c_idx}: x=[{x1}, {x2}], width={x2-x1}")
