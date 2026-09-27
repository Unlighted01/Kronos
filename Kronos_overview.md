# 🐾 Kronos — Complete Feature Architecture & Overview

> **Kronos** is a lightweight, frameless desktop productivity widget and Tamagotchi companion workspace. It combines a flexible **Flowmodoro focus engine**, an **Active Recall study deck**, and a **Daily Time Record (DTR) tracker** with an autonomous **2D procedural pixel-art pet companion** living in interactive mythological biomes.

---

## 🧭 System Architecture & Interface Layout

Kronos operates as a single-window, frameless desktop widget with a fixed **240×140 virtual pixel canvas** and independent collapsible side drawers:

```
┌─────────────────────────┬─────────────────────────┬─────────────────────────┐
│       LEFT PANEL        │      MIDDLE PANEL       │       RIGHT PANEL       │
│         (220px)         │         (240px)         │         (200px)         │
├─────────────────────────┼─────────────────────────┼─────────────────────────┤
│ 🛍️ SHOP & TASKS         │ 🐾 VIRTUAL ROOM CANVAS  │ 📊 VITALS, BAG & DTR    │
│ • Treats & Snacks       │ • 100% Uncovered Pet    │ • Pet Stats & Vitals    │
│ • Wearable Cosmetics    │ • Digital Focus Timer   │ • Inventory & Equips    │
│ • Real Estate / Pets    │ • Floating Action Dock  │ • DTR Work Session Logs │
│ • Micro-Tasks Checklist │ • Camera Pan & Day/Night│ • Audio & Window Config │
│ • Daily Pet Quests      │ • Interactive Room Props│ • CSV Focus Export      │
└─────────────────────────┴─────────────────────────┴─────────────────────────┘
```

---

## 🐾 1. Autonomous Pet AI & Companion Engine

Kronos features an expressive, non-repetitive pet AI built on a decoupled state machine and procedural animation engine.

### 🐕 Multi-Species Household Roster
Adopt and switch between 8 distinct companion species, powered by Kronos's **Authentic 32×32 PNG Sprite Engine** with frame-by-frame animation, multi-tone shading, and procedural fallback:

| Species | Companion | Visual Architecture | Focus Stance | Status |
| :--- | :--- | :--- | :--- | :---: |
| **Shiba Inu** | *Kronos* | **Authentic 32×32 PNG Sprite Sheets** (`res://assets/sprites/pets/shiba/`): 4-frame breathing idle, 6-frame fluid walk cycle, 4-frame curled sleeping loaf, 4-frame joy wag. | Rapid typing on a glowing laptop terminal with screen reflections. | ✅ Upgraded to 32×32 PNG |
| **Calico Cat** | *Mochi* | **Authentic 32×32 PNG Sprite Sheets** (`res://assets/sprites/pets/cat/`): 4-frame breathing idle, 6-frame fluid walk cycle, 4-frame curled sleeping loaf, 4-frame joy/groom wag. | Attentive screen watcher and rhythmic paw grooming. | ✅ Upgraded to 32×32 PNG |
| **Snowy Bunny** | *Boba* | **Authentic 32×32 PNG Sprite Sheets** (`res://assets/sprites/pets/bunny/`): 4-frame breathing idle with ear bounce, 6-frame hopping walk cycle, 4-frame tucked nap loaf, 4-frame happy jump. | Sits upright holding a tiny mug, ears drooping from steam warmth. | ✅ Upgraded to 32×32 PNG |
| **Chubby Penguin** | *Pippin* | **Authentic 32×32 PNG Sprite Sheets** (`res://assets/sprites/pets/penguin/`): 4-frame breathing idle with flipper sway, 6-frame waddle walk cycle, 4-frame belly slide nap, 4-frame flipper celebration. | Holds mug between flippers; dual flipper keyboard tapping. | ✅ Upgraded to 32×32 PNG |
| **Red Fox** | *Kitsune* | **Authentic 32×32 PNG Sprite Sheets** (`res://assets/sprites/pets/fox/`): 4-frame breathing idle, 6-frame fluid walk cycle, 4-frame curled sleeping loaf, 4-frame brush tail victory wag. | Deep study posture with open scrolls & celestial grimoires. | ✅ Upgraded to 32×32 PNG |
| **Red Panda** | *Rory* | **Authentic 32×32 PNG Sprite Sheets** (`res://assets/sprites/pets/redpanda/`): 4-frame breathing idle, 6-frame fluid walk cycle, 4-frame curled sleeping loaf, 4-frame bamboo snack/joy. | Bamboo snacking & focused study terminal. | ✅ Upgraded to 32×32 PNG |
| **Zen Capybara** | *Cappy* | **Authentic 32×32 PNG Sprite Sheets** (`res://assets/sprites/pets/capybara/`): 4-frame breathing idle with yuzu fruit on head, 6-frame relaxed waddle, 4-frame onsen hot-spring soak, 4-frame matcha tea sip. | Serene meditation & tea cup sipping. | ✅ Upgraded to 32×32 PNG |
| **Scholar Owl** | *Barnaby* | **Authentic 32×32 PNG Sprite Sheets** (`res://assets/sprites/pets/owl/`): 4-frame breathing idle with head swivel, 6-frame wing flutter hop, 4-frame tucked ball nap, 4-frame illuminated grimoire study. | Perched reading of illuminated grimoires. | ✅ Upgraded to 32×32 PNG |

---

### 🧠 Weighted-Random Idle Interaction System
While idle, pets organically trigger special room-aware moments based on a **rarity weight system** (Common: 60, Uncommon: 30, Rare: 10) with multi-stage reactions:

```
[Cooldown: 25s–50s] ──> [Weighted Selection] ──> [Navigate to Anchor] ──> [Primary Action] ──> [Reaction / Tween] ──> [Return to Idle]
```

#### Universal Behaviors (All Rooms)
- **Common**: Sleepy yawn with floating `zzz` particles; rhythmic paw grooming (`heart` particles).
- **Uncommon**: Turning directly to gaze into the camera (`"Looking right at you! 👀✨"`); watching the timer during active sprints.
- **Reactive Hooks**: Joyful hop on coin gain (`+Coins! 🪙`); victory celebration dance on session completion.

#### Multi-Stage Reactions & Procedural Tweens
- `startle_hop`: Quick vertical jump + recoil bounce when startled.
- `wobble`: Drowsy rotational tilt (`0.22` rad) followed by a sharp snap-awake recoil when nodding off standing up.
- `head_shake`: Rapid rotational head shake when spitting out bitter wheat in the greenhouse.
- `happy_hop`: Cheerful mini-bounce on discovering secret stars or sweet berries.

---

## 🏛️ 2. Procedural Mythological Biomes (Rooms)

All rooms are drawn using pure mathematical GDScript `_draw()` calls (no external static PNG textures for environments), allowing live diurnal day/night cycles, ambient lighting, and particle effects.

```
                    ┌─────────────────────────┐
                    │ 🔭 Tower of Urania      │
                    │    (Attic Observatory)  │
                    └────────────┬────────────┘
                                 │
  ┌─────────────────────────┐    │    ┌─────────────────────────┐
  │ 🌙 Temple of Morpheus   ├────┼────┤ 🌾 Elysian Fields       │
  │    (Study Bedroom)      │    │    │    (Golden Plains)      │
  └─────────────────────────┘    │    └────────────┬────────────┘
                                 │                 │
                    ┌────────────┴────────────┐    │
                    │ 🔥 Hearth of Hestia     │    │
                    │    (Living Room Lounge) │    │
                    └────────────┬────────────┘    │
                                 │                 │
                    ┌────────────┴─────────────────┴┐
                    │ 🛶 Banks of the Styx          │
                    │    (Underworld Ferry Dock)    │
                    └───────────────────────────────┘
```

| Room / Biome | Theme & Geometry | Special Idle Behaviors | Status |
| :--- | :--- | :--- | :---: |
| **🌙 Temple of Morpheus** *(Bedroom)* | **Ultra-Dense 120+ Sprite Suite & Nocturnal Architecture** (`res://assets/sprites/rooms/bedroom/`):<br>• **Ceiling Layer (26 sprites)**: Cedar beams with silver studs (`y = -14..2`), 4 hanging silver star lanterns with ethereal blue glow, midnight sky gradient with twinkling stars.<br>• **Wall Layer (36 sprites)**: Dark ashlar temple wall stone, carved silver moon phase frieze, blue flame wall sconces, trailing moonflower vines with bioluminescent spores, 5 fluted moonstone Corinthian columns with midnight silk drapery.<br>• **Floor Layer (48 sprites)**: Obsidian moonstone floor tiles, stepped foundation with silver dentils, solid bedrock plinth (zero zoom-out voids), grand embroidered Moon Phase velvet rug under the canopy bed.<br>• **Furniture & Interactive Props (30+ sprites)**: Royal Greek Canopy Bed of Dreams (`x = 230`), Celestial Study Altar (`x = 110`) with 3-branch candelabra & blue spirit flames, Enchanted Dream Sand Hourglass with flowing cyan sand (`x = 145`), Dreamcatcher Wind Chimes with crescent moon pendants (`x = 390`), Font of Lethe water basin with floating lotus (`x = 490`), Astrolabe on pedestal, Grimoire bookstand with scrolls, Potted Moonflower Urn, classical marble balustrade overlooking Mount Olympus midnight vista (`x = 520..740`).<br>• **Dynamic Particles (30+ systems)**: Floating dream orbs, falling luminescent dream sand, water ripples, musical chords, shooting stars, and fluttering Starlight Luna Moth.<br>• **Modular Pet Action Rig (Option B)**: Shiba and companions dock seamlessly into the Canopy Bed (`LOAF`), Study Altar (`EAT`), and Balustrade Terrace (`GAZE`). | • Stargazing by the Lethe pool<br>• Sleeping loaf in canopy bed<br>• Reading grimoire at the altar<br>• Dipping paws in the Font of Lethe<br>• Watching shooting stars from the balustrade | ✅ Over 120+ Active Sprites & Living Decor |
| **🔥 Hearth of Hestia** *(Living Room)* | **Ultra-Dense 120+ Sprite Suite & 2D Tilemap Architecture** (`res://assets/sprites/rooms/livingroom/`):<br>• **Ceiling Layer (28 sprites)**: Solid cedar wood backing + 15 coffered panels (`y = -80..16`), 3 hanging bronze chain chandeliers with flame light halos, 6 hanging dried herb & bay laurel bundles, 4 trailing ivy garlands along terrace ceiling.<br>• **Wall Layer (28 sprites)**: 15 Ashlar wall tiles, 4 Carved Doric frieze architraves (seamless edge-blended), 2 crimson & gold Greek meander tapestries, Hoplite shield with intact spear tips, 4 brass wall sconces with animated fire, classical marble wall bust above hearth, papyrus scroll bookcase.<br>• **Terrace & Columns (20 sprites)**: 3 Fluted Doric marble columns, 3 flowing silk column drapes billowing in breeze, 6 climbing green ivy clusters wrapping shafts, 2 Doric pedestals, classical marble bust sculpture, 2 perched white temple doves with wing rustle animations.<br>• **Floor & Furniture Layer (66 sprites)**: Circular sunburst marble mosaic medallion, crimson & gold wool daybed rug, Klinē daybed with sleeping companion, monumental ashlar fireplace, rustic firewood log rack with chopped birch logs, cozy hearth floor cushion, Athena's olive tree, 2 large floor amphorae, potted rose & bluebell urns, glowing sprout pot, feasting table with food platter (bread, cheese, wine kylix), golden amphora, overflowing cornucopia, Apollo's golden lyre, golden incense thurible, sacred tripod brazier, scattered marble step petals & leaves.<br>• **Dynamic Live Particles (30+ systems)**: Rising hearth embers, fragrant purple incense smoke rings, food steam wisps, dancing sunset dust motes, coo hearts, and Hestia's orbiting Ember.<br>• **Interactive Systems (10 clickables)**: Hearth, firewood rack (adds log & crackle pop), amphora, cornucopia, food platter, lyre, thurible, brazier, doves, chandeliers.<br>• **Camera Zoom Engine**: Dynamic mouse wheel zoom (`0.50x` to `1.60x`) with zero voids. | • Toasting paws by the hearth<br>• Curled cushion nap inside the chaise couch<br>• Batting at floating golden sparks<br>• Fire yelp jump-back<br>• Table study & amphora drinks<br>• Listening to Apollo's lyre chords | ✅ Over 120+ Active Sprites & Living Decor |
| **🔭 Tower of Urania** *(Attic Library)* | **Ultra-Dense 120+ Sprite Suite & Celestial Observatory Architecture** (`res://assets/sprites/rooms/library/`):<br>• **Ceiling Layer (28 sprites)**: Coffered walnut ceiling panels with brass studs (`y = -70..14`), 3 hanging brass chain star lanterns with warm golden flame halos, midnight deep-sky gradient with galaxy dust.<br>• **Wall & Observatory Terrace Layer (34 sprites)**: Dark ashlar stone walls with carved brass constellation friezes, illuminated papyrus star chart frames, brass wall sconces with animated flames, 4 classical fluted Corinthian columns, brass balustrade terrace opening onto panoramic Milky Way galaxy vista.<br>• **Floor Layer (48 sprites)**: Polished walnut parquet floor tiles, stepped foundation edge lip with brass inlay, solid bedrock plinth (zero zoom-out voids), grand embroidered Navy Velvet Zodiac Astrolabe rug.<br>• **Furniture & Interactive Props (35+ sprites)**: Giant interactive spinning brass Celestial Globe (`x = 355`), Grand Brass Observatory Telescope pointed at cosmos (`x = 590`), Scholar Study Desk with star maps & brass lamp (`x = 420`), Plush Tufted Leather Reading Armchair (`x = 220`), Antique Brass Tea Samovar with rising herbal steam (`x = 310`), Planetary Orrery on marble pedestal (`x = 515`), floor-to-ceiling walnut bookshelves, rolling library ladder, stacked grimoires and parchment scrolls.<br>• **Dynamic Live Particles (30+ systems)**: Floating golden celestial dust motes, fragrant herbal tea steam wisps, streaking cosmic shooting stars, and lens gleams.<br>• **Modular Pet Action Rig (Option B)**: Shiba studying / snacking at the Scholar Desk (`STUDY`), Calico Cat curled in sleeping loaf on the Reading Armchair (`LOAF`), Cat batting at the spinning Celestial Globe (`WARM_PAWS`), and gazing at the galaxy vista from the terrace (`GAZE`). | • Spinning the celestial globe<br>• Telescope deep-sky galaxy observation<br>• Reading scrolls at scholar desk<br>• Sleeping loaf in reading armchair<br>• Sipping herbal tea at the samovar<br>• Watching shooting stars from the balustrade | ✅ Over 120+ Active Sprites & Living Decor |
| **🌾 Elysian Fields** *(Zen Greenhouse / Plains)* | **Ultra-Dense 120+ Sprite Suite & Mythological Pastoral Paradise** (`res://assets/sprites/rooms/greenhouse/`):<br>• **Sky & Vista Layer (Far Background)**: Rolling sunlit Mount Olympus hills, distant circular Tholos temple on hill, sacred cypress & olive groves, winding stream, drifting cumulus clouds, radiant golden sun god rays.<br>• **Pergola Canopy & Ceiling (30+ sprites)**: Weathered cedar pergola crossbeams (`y = -14..12`), cascading purple wisteria flower canopies, 3 hanging ceramic planters with trailing ivy, 3 hanging terracotta clay oil lanterns with animated amber flame, interactive bamboo & brass wind chimes with swing physics.<br>• **Colonnade & Garden Walls (40+ sprites)**: Warm sandstone courtyard garden wall with carved coping tiles, 5 fluted Greek Doric columns wrapped in climbing green ivy, carved ivy capitals.<br>• **Flagstone Ground & Foundation (50+ sprites)**: Deep emerald grass turf foundation, rich loamy garden soil, overlapping rustic flagstone garden path tiles with moss inlays, mossy stepped stone terrace lips, corner step plinths, solid bedrock foundation (zero zoom-out voids).<br>• **Crops & Interactive Props (35+ sprites)**: Classical Carved Marble Sunbench / Daybed with green leaf cushion (`x = 210`), Rustic 2-tier Potting Workbench with seedling pots and gardening trowel (`x = 430`), Stone Birdbath Fountain Basin with water lilies (`x = 315`), Friendly Garden Scarecrow with straw hat, laurel wreath & perched animated bluebird (`x = 90`), Wooden Wheelbarrow of wheat & lavender harvest (`x = 148`), Antique green olive watering can (`x = 375`), Terracotta pots of blooming asphodels, multi-layered wind-swayed golden wheat fields, and purple lavender bushes.<br>• **Dynamic Live Particles (35+ systems)**: Fluttering golden Elysian butterflies, drifting wisteria flower petals, floating sunlit dust motes, and fountain splashing water droplets.<br>• **Modular Pet Action Rig (Option B)**: Calico Cat sleeping loaf on Marble Sunbench (`LOAF`), Shiba potting herbs / snacking at Potting Bench (`STUDY`), Shiba drinking at Birdbath Fountain (`DRINK`), Cat batting at golden butterflies (`WARM_PAWS`), and gazing out over wheat meadows (`GAZE`). | • Sleeping loaf on marble sunbench<br>• Potting seedlings at garden workbench<br>• Drinking fresh spring water at fountain<br>• Chasing & batting at golden butterflies<br>• Poking scarecrow & watching bluebird hop<br>• Gazing across golden wheat fields | ✅ Over 120+ Active Sprites & Living Decor |
| **🛶 Banks of the Styx** *(Underworld Ferry Dock)* | **Ultra-Dense 120+ Element Living Underworld & Cavern Architecture**: <br>• **Cavern Vault & Sky Layer (30+ elements)**: Deep abyssal cavern ceiling (`y = -80..102`), hanging basalt stalactites across cavern vault, distant murky cavern depth gradient with ethereal teal horizon glow.<br>• **The River Styx & Volumetric Fog (35+ elements)**: Murky luminescent River Styx water body, glowing shoreline horizon, dynamic undulating river currents with sine-wave displacement, 18 rolling volumetric fog banks drifting across water.<br>• **Basalt Quay Stone Dock & Foundation (40+ elements)**: Ashlar basalt stone paving slabs with mortar seams and emerald moss inlays (`x = -120..400, y = 98..120`), stepped quay edge lips down to y = 144, timber quay pilings driving into river, heavy iron mooring bollards with coiled hemp rope tied to Charon's boat, solid bedrock foundation (zero zoom-out voids).<br>• **Charon's Ferry Skiff (Signature Vessel)**: Weathered timber planked hull with tall swept prow, carved Greek underworld eye glyph, resting timber oar with bronze paddle blade, piled cargo crates & burlap sacks of glinting gold obols on deck, hanging iron lantern bracket with swinging spectral soul lantern (pulsing cyan soul core & dual-layer glow aura), live sine-wave boat bobbing physics (`bob_y`, `bob_rot`) synced to companion footing.<br>• **Underworld Furniture & Props**: Ancient Obsidian Sarcophagus Daybed lined with royal purple velvet cushion (`x = 110`), Altar of Obols Ferry Ledger Desk with brass balance scales, ledger book & gold coins (`x = 220`), Bronze Tripod Soulfire Brazier Cauldron with animated flickering cyan spirit flames (`x = 340`).<br>• **Foreground Chains & Prison Bars**: 10 hanging rusted iron chains with links and terminal hooks/skulls swaying in cavern drafts, heavy dungeon portcullis bars framing the scene with eerie green metallic sheen highlights and riveted studs.<br>• **Dynamic Live Particles (40+ systems)**: Rising cyan soul motes / ghost embers, expanding water splash ripples, ghostly spectral hands reaching up from River Styx on click, and soulfire embers.<br>• **Modular Pet Action Rig (Option B)**: Calico Cat curled in sleeping loaf in Obsidian Sarcophagus (`LOAF`), Shiba studying ledger & weighing obols at Altar of Obols (`STUDY`), Shiba warming paws at Soulfire Brazier (`WARM_PAWS`), Cat perched on Charon's Skiff gazing across the River Styx (`GAZE`). | • Curled loaf nap in velvet sarcophagus<br>• Weighing obols & inspecting ledger of souls<br>• Warming paws by cyan soulfire brazier<br>• Gazing into the River Styx from Charon's boat<br>• Rapping on iron prison bars<br>• Reaching for spectral hand ripples | ✅ Over 120+ Active Elements & Living Underworld Decor |

---

## ⏱️ 3. Productivity & Focus Suite

### 1. Flowmodoro & Pomodoro Timer Engines
- **Flowmodoro Mode (Count-Up)**: Track uninterrupted focus flow without artificial alarms. When you stop, your earned break time is dynamically calculated based on your focus ratio (e.g., 5:1 ratio).
- **Classic Pomodoro (Count-Down)**: Configurable sprint intervals (e.g. 25 min work, 5 min short break, 15 min long break) with retro sound chimes.
- **Dynamic Energy Buff**: Maintaining your pet's Energy above 70% grants a **+50% Focus Coin Speed Buff** during active sessions.

### 2. Active Recall Flashcards & Learning Engine
- Create, manage, and review flashcard decks during focus breaks.
- Self-grade answers (Hard / Good / Easy) to earn **Knowledge Points (KP)**, linking companion progression to real-world study mastery.

### 3. Daily Time Record (DTR) & Focus History
- Automatic session logging with duration, timestamp, task name, category, and coins earned.
- Reverse-chronological session feed with date filtering (`Today` vs `All`).
- **1-Click CSV Export**: Exports session logs to `user://kronos_dtr_export.csv` for timesheet tracking and analytics.

---

## 🛍️ 4. Inventory, Economy & Customization

### 1. Multi-Tier Item Catalog & Minigame Visual Assets
- **Authentic 16×16 & 32×32 Treats & Snacks** (`res://assets/sprites/items/`):
  - 🥐 **Butter Croissant** (16×16 & 32×32) — Golden flaky layered crescent pastry with butter glaze.
  - 🧋 **Brown Sugar Boba** (16×16 & 32×32) — Clear dome cup, thick straw, brown sugar tiger swirls, dark pearls.
  - 🍣 **Salmon Nigiri** (16×16 & 32×32) — Marbled pink-orange salmon grain on seasoned white rice with nori belt.
  - ☕ **Pixel Espresso** (16×16 & 32×32) — Porcelain white cup with heart-shaped crema latte art.
  - 🍜 **Midnight Ramen** (16×16 & 32×32) — Steaming ceramic bowl with ajitsuke egg, narutomaki fish cake, scallions.
  - 🍵 **Ceremonial Matcha** (16×16 & 32×32) — Traditional chawan bowl with vibrant whisked jade froth.
  - 🍩 **Star Donut** (16×16 & 32×32) — Pastel pink strawberry glaze with rainbow sprinkles.
  - 🥞 **Souffle Pancakes** (16×16 & 32×32) — Triple-stacked golden fluffy soufflé pancakes with melting butter pat and amber maple syrup drizzle.
  - 🍱 **Deluxe Bento** (16×16 & 32×32) — Traditional lacquerware partitioned bento box with tamagoyaki, crisp tempura shrimp, and umeboshi rice.
  - ⚡ **Neon Energy Drink** (16×16 & 32×32) — Chilled aluminum can with glowing neon cyan/magenta lightning energy charge.
  - 🎁 **Mystery Treat Box** (16×16 & 32×32) — Polished walnut treasure chest banded in iron and golden ribbon bow.
  - ⭐ **Gold Star & ⏰ Alarm Clock** (16×16 & 32×32) — Sparkling victory stars and retro twin-bell timer.
- **Pixel-Art UI Integration (Shop & Inventory Bag)**:
  - **LeftPanel (Shop)**: All item and treat cards display sharp 32×32 pixel art textures via `TextureRect` with nearest-neighbor filtering (`CanvasItem.TEXTURE_FILTER_NEAREST`); adoptable pets display their authentic 32×32 companion idle sprites.
  - **RightPanel (Inventory Bag & Pet Picker)**: Bag items display handcrafted 16×16 / 20×20 sprites next to item names; modal item preview and pet selection rows render authentic 24×24 companion idle and treat sprites.
  - **Zero OS Emoji Fallback in Main UI**: Eliminates Windows default vector emoji glyphs (`🥐`, `☕`, `🍩`, etc.) in favor of Stardew Valley-level craftsmanship.
- **Cozy Minigame Sprite Integrations**:
  - **Snack Catch 2.0**: Falling handcrafted 16×16 treats (Croissant, Boba, Sushi, Star, Clock) with full 32×32 Shiba companion basket player.
  - **Memory Match 2.0**: Ornate astrological gold-filigree card backs (`card_back.png`) and 3D flipped 32×32 study item pairs.
  - **Plant Bloom 2.0**: Carved terracotta pots (`pot_normal.png`, `pot_glow.png`, `pot_sprout.png`) with 4 distinct blooming flower species (Rose, Sunflower, Bluebell, Orchid) on 32×48 canvases.
- **Wearable Cosmetics**: Multi-slot cosmetic rendering system supporting **Head** (Crown, Wizard Hat, Beanie, Chef Hat, Cap), **Face** (Sunglasses, Wireframe Glasses, Monocle), and **Neck** (Red Bowtie, Plaid Scarf, Bell Collar).
- **Room Decor**: Mini Bonsai, Lava Lamp, Retro Boombox, Terrarium, Fairy Lantern.

### 2. Micro-Tasks & Daily Quests
- **Checklist Task Engine**: Add, check off, select active focus sprint target, or delete micro-tasks.
- **Daily Pet Quests**: Automatically generated daily objectives (e.g., *"Complete 2 Work Sprints"*, *"Feed 3 Treats"*, *"Pet Companion 5 Times"*) awarding bonus Coins and EXP.

---

## ⚙️ 5. Technical Specifications & Desktop Utility

- **Engine**: Godot Engine 4.7.1 (GDScript).
- **Window Management**: Frameless window dragging, scale presets (`1.0x`, `1.25x`, `1.5x`), and **Always-on-Top desktop pinning** via native background helper binary (`kronos_pinner.exe`).
- **Data Persistence**: Safe JSON serialization with automated backup rotation (`kronos_save.json` and `kronos_dtr.json` in OS `user://` storage).
- **Performance**: Lightweight CPU footprint, pixel-perfect 60 FPS viewport rendering, zero heavy asset loading.
