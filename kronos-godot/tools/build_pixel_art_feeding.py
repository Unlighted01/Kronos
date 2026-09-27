import os
from PIL import Image

feeding_dir = r"assets/sprites/items/feeding"
item_dir = r"assets/sprites/items"
os.makedirs(feeding_dir, exist_ok=True)

def load_base(name):
    return Image.open(os.path.join(item_dir, f"{name}.png")).convert("RGBA")

# Helper to draw a clean little ceramic saucer/plate at bottom
def draw_saucer(canvas, saucer_col, rim_col, crumbs=[]):
    pix = canvas.load()
    # Plate base y=11..13, x=3..12
    for x in range(3, 13):
        pix[x, 12] = saucer_col
        pix[x, 13] = rim_col
    for x in range(4, 12):
        pix[x, 11] = saucer_col
    # Rim edges
    pix[2, 11] = rim_col
    pix[13, 11] = rim_col
    # Add crumbs
    for cx, cy, col in crumbs:
        pix[cx, cy] = col

def make_croissant():
    s0 = load_base("croissant")
    
    # Stage 1: bite on right
    s1 = s0.copy()
    p1 = s1.load()
    for y in range(16):
        for x in range(16):
            if x >= 9 and 4 <= y <= 10:
                dx = x - 11
                dy = y - 7
                if dx*dx + dy*dy <= 14:
                    p1[x, y] = (0, 0, 0, 0)
    # Flakes near bite
    p1[12, 11] = (220, 140, 40, 255)
    p1[10, 12] = (240, 180, 70, 255)

    # Stage 2: clean plate with golden flaky crumbs
    s2 = Image.new("RGBA", (16, 16), (0, 0, 0, 0))
    crumbs = [
        (6, 10, (230, 150, 45, 255)),
        (7, 10, (245, 185, 75, 255)),
        (9, 10, (220, 140, 40, 255)),
        (10, 9, (200, 120, 35, 255)),
        (5, 11, (245, 185, 75, 255)),
    ]
    draw_saucer(s2, (235, 235, 240, 255), (180, 185, 195, 255), crumbs)
    
    return s0, s1, s2

def make_donut():
    s0 = load_base("donut")
    
    # Stage 1: bite on top-right
    s1 = s0.copy()
    p1 = s1.load()
    for y in range(16):
        for x in range(16):
            if x >= 8 and y <= 8:
                dx = x - 11
                dy = y - 4
                if dx*dx + dy*dy <= 18:
                    p1[x, y] = (0, 0, 0, 0)
    # Crumbs
    p1[12, 9] = (240, 120, 160, 255)
    p1[13, 10] = (230, 160, 80, 255)

    # Stage 2: plate with pink sprinkles
    s2 = Image.new("RGBA", (16, 16), (0, 0, 0, 0))
    crumbs = [
        (6, 10, (245, 120, 165, 255)),
        (8, 10, (240, 210, 60, 255)),
        (9, 10, (100, 210, 240, 255)),
        (7, 11, (220, 150, 70, 255)),
    ]
    draw_saucer(s2, (245, 240, 235, 255), (190, 180, 175, 255), crumbs)
    return s0, s1, s2

def make_sushi():
    s0 = load_base("sushi")
    
    # Stage 1: one sushi piece eaten, one remains
    s1 = s0.copy()
    p1 = s1.load()
    for y in range(16):
        for x in range(8, 16):
            p1[x, y] = (0, 0, 0, 0)
    # A few rice grains
    p1[8, 11] = (240, 240, 245, 255)
    p1[9, 12] = (230, 230, 235, 255)

    # Stage 2: wooden geta board with green leaf & soy dip
    s2 = Image.new("RGBA", (16, 16), (0, 0, 0, 0))
    p2 = s2.load()
    # Wooden geta slab
    for x in range(2, 14):
        p2[x, 11] = (195, 145, 95, 255)
        p2[x, 12] = (165, 115, 70, 255)
    # Geta feet
    p2[4, 13] = (140, 95, 55, 255)
    p2[11, 13] = (140, 95, 55, 255)
    # Green bamboo leaf
    p2[5, 10] = (70, 160, 80, 255)
    p2[6, 10] = (80, 180, 90, 255)
    p2[7, 10] = (60, 145, 70, 255)
    # Soy sauce drop & wasabi
    p2[10, 10] = (50, 30, 25, 255)
    p2[11, 10] = (140, 200, 70, 255)
    return s0, s1, s2

def make_coffee():
    s0 = load_base("coffee")
    
    # Stage 1: half coffee
    s1 = s0.copy()
    p1 = s1.load()
    # Clear upper coffee froth inside mug (x: 4..10, y: 3..6)
    for y in range(3, 7):
        for x in range(5, 11):
            if p1[x, y][3] > 0 and p1[x, y][0] > 60:
                p1[x, y] = (230, 225, 220, 255) # white ceramic inside cup
    # Coffee surface at y=7
    for x in range(5, 11):
        if p1[x, 7][3] > 0:
            p1[x, 7] = (85, 45, 25, 255)

    # Stage 2: empty cup with coffee ring
    s2 = s0.copy()
    p2 = s2.load()
    for y in range(3, 10):
        for x in range(4, 12):
            if p2[x, y][3] > 0 and p2[x, y][0] > 50:
                p2[x, y] = (235, 230, 225, 255) # ceramic inside
    # Thin coffee ring at bottom of mug
    for x in range(6, 10):
        p2[x, 9] = (110, 60, 35, 255)
    return s0, s1, s2

def make_matcha():
    s0 = load_base("matcha")
    
    # Stage 1: half matcha
    s1 = s0.copy()
    p1 = s1.load()
    for y in range(3, 7):
        for x in range(4, 12):
            if p1[x, y][3] > 0 and p1[x, y][1] > 100:
                p1[x, y] = (195, 175, 150, 255) # ceramic bowl interior
    # Matcha line
    for x in range(5, 11):
        if p1[x, 7][3] > 0:
            p1[x, 7] = (60, 130, 45, 255)

    # Stage 2: empty ceramic bowl with green residue
    s2 = s0.copy()
    p2 = s2.load()
    for y in range(3, 10):
        for x in range(3, 13):
            if p2[x, y][3] > 0 and p2[x, y][1] > 80:
                p2[x, y] = (195, 175, 150, 255)
    # Swirl of green matcha tea residue
    p2[6, 9] = (80, 155, 60, 255)
    p2[7, 9] = (70, 140, 50, 255)
    p2[8, 9] = (90, 170, 70, 255)
    return s0, s1, s2

def make_boba():
    s0 = load_base("boba")
    
    # Stage 1: half tea
    s1 = s0.copy()
    p1 = s1.load()
    for y in range(4, 9):
        for x in range(4, 12):
            if x == 7 or x == 8:
                continue # keep straw
            if p1[x, y][3] > 0 and not (p1[x, y][0] < 50 and p1[x, y][1] < 50 and p1[x, y][2] < 50):
                p1[x, y] = (230, 235, 245, 100) # clear plastic cup

    # Stage 2: empty cup with straw & tapioca
    s2 = s0.copy()
    p2 = s2.load()
    for y in range(4, 12):
        for x in range(4, 12):
            if x == 7 or x == 8:
                continue # keep straw
            if p2[x, y][3] > 0 and not (p2[x, y][0] < 45 and p2[x, y][1] < 45 and p2[x, y][2] < 45):
                p2[x, y] = (230, 235, 245, 90) # empty clear cup
    # Keep tapioca pearls at bottom (y=12..14)
    return s0, s1, s2

def make_energy_drink():
    s0 = load_base("energy_drink")
    
    s1 = s0.copy()
    p1 = s1.load()
    # Opened top tab with fizz
    p1[7, 2] = (255, 255, 255, 255)
    p1[8, 2] = (100, 230, 255, 255)
    p1[6, 1] = (150, 240, 255, 255)

    # Stage 2: empty can
    s2 = s0.copy()
    p2 = s2.load()
    p2[7, 2] = (40, 50, 60, 255) # open hole
    p2[8, 2] = (30, 40, 50, 255)
    # Slight dent in can
    for y in range(6, 10):
        p2[4, y] = (0, 0, 0, 0)
    return s0, s1, s2

def make_pancake():
    s0 = load_base("pancake")
    
    # Stage 1: top pancake eaten, cut slice
    s1 = s0.copy()
    p1 = s1.load()
    for y in range(3, 8):
        for x in range(7, 15):
            p1[x, y] = (0, 0, 0, 0)
    # Butter cube dropped to 2nd pancake
    p1[6, 7] = (255, 240, 110, 255)
    p1[7, 7] = (245, 220, 80, 255)

    # Stage 2: empty plate with fork & syrup drip
    s2 = Image.new("RGBA", (16, 16), (0, 0, 0, 0))
    p2 = s2.load()
    # Ceramic plate
    for x in range(2, 14):
        p2[x, 11] = (245, 245, 250, 255)
        p2[x, 12] = (210, 215, 225, 255)
    p2[1, 11] = (210, 215, 225, 255)
    p2[14, 11] = (210, 215, 225, 255)
    # Syrup drip
    p2[6, 10] = (205, 125, 45, 255)
    p2[7, 10] = (215, 140, 55, 255)
    p2[8, 10] = (195, 115, 35, 255)
    # Fork
    for y in range(8, 12):
        p2[11, y] = (190, 195, 205, 255)
    p2[10, 7] = (190, 195, 205, 255)
    p2[11, 7] = (190, 195, 205, 255)
    p2[12, 7] = (190, 195, 205, 255)
    return s0, s1, s2

def make_ramen():
    s0 = load_base("ramen")
    
    # Stage 1: half noodles eaten
    s1 = s0.copy()
    p1 = s1.load()
    for y in range(4, 9):
        for x in range(7, 14):
            if p1[x, y][3] > 0 and p1[x, y][0] > 70:
                p1[x, y] = (180, 110, 60, 255) # rich broth remaining

    # Stage 2: empty bowl with chopsticks resting across rim!
    s2 = s0.copy()
    p2 = s2.load()
    # Empty bowl interior
    for y in range(4, 9):
        for x in range(3, 13):
            if p2[x, y][3] > 0 and p2[x, y][0] > 60:
                p2[x, y] = (90, 55, 35, 255) # dark broth puddle
    # Chopsticks laid across top rim
    for x in range(2, 14):
        p2[x, 4] = (220, 175, 115, 255)
        p2[x, 5] = (180, 135, 85, 255)
    return s0, s1, s2

def make_bento():
    s0 = load_base("bento")
    
    # Stage 1: main dish eaten
    s1 = s0.copy()
    p1 = s1.load()
    for y in range(5, 11):
        for x in range(2, 7):
            if p1[x, y][3] > 0 and p1[x, y][0] > 70:
                p1[x, y] = (80, 50, 35, 255) # empty compartment floor

    # Stage 2: empty wooden bento box with clean dividers
    s2 = s0.copy()
    p2 = s2.load()
    for y in range(5, 11):
        for x in range(2, 14):
            if p2[x, y][3] > 0 and not (x == 7 or y == 8): # keep dividers
                p2[x, y] = (95, 60, 40, 255) # lacquered wood inside
    # Dividers
    for y in range(4, 12):
        p2[7, y] = (180, 120, 70, 255)
    for x in range(2, 14):
        p2[x, 8] = (180, 120, 70, 255)
    return s0, s1, s2

def make_mystery_box():
    s0 = load_base("mystery_box")
    
    # Stage 1: box popped open, golden glow
    s1 = s0.copy()
    p1 = s1.load()
    for y in range(4, 7):
        for x in range(3, 13):
            p1[x, y] = (255, 235, 130, 255) # golden light burst
    # Ribbon undone
    p1[8, 1] = (255, 220, 90, 255)
    p1[8, 2] = (255, 240, 140, 255)

    # Stage 2: open gift box with golden star treat inside!
    s2 = s0.copy()
    p2 = s2.load()
    # Box bottom open
    for y in range(7, 13):
        for x in range(3, 13):
            p2[x, y] = (90, 120, 180, 255)
    # Golden star treat floating above
    p2[8, 3] = (255, 245, 120, 255)
    p2[8, 4] = (255, 225, 70, 255)
    p2[7, 4] = (255, 235, 90, 255)
    p2[9, 4] = (255, 235, 90, 255)
    p2[8, 5] = (245, 210, 50, 255)
    return s0, s1, s2

makers = {
    'croissant': make_croissant,
    'donut': make_donut,
    'sushi': make_sushi,
    'coffee': make_coffee,
    'matcha': make_matcha,
    'boba': make_boba,
    'energy_drink': make_energy_drink,
    'pancake': make_pancake,
    'ramen': make_ramen,
    'bento': make_bento,
    'mystery_box': make_mystery_box,
}

for name, fn in makers.items():
    s0, s1, s2 = fn()
    s0.save(os.path.join(feeding_dir, f"{name}_stage_0.png"))
    s1.save(os.path.join(feeding_dir, f"{name}_stage_1.png"))
    s2.save(os.path.join(feeding_dir, f"{name}_stage_2.png"))
    if name == 'sushi':
        s0.save(os.path.join(feeding_dir, "onigiri_stage_0.png"))
        s1.save(os.path.join(feeding_dir, "onigiri_stage_1.png"))
        s2.save(os.path.join(feeding_dir, "onigiri_stage_2.png"))
    print(f"Generated clean stages for {name}")

print("All 33 feeding stage sprites built successfully!")
