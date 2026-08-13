import Dexie, { Table } from "dexie";

export interface DtrSession {
    id?: number;
    taskName: string;
    category: string;
    startTime: string; // ISO string
    endTime: string; // ISO string
    durationMinutes: number;
    status: "completed" | "skipped";
    coinsEarned: number;
    expEarned: number;
    dateKey: string; // YYYY-MM-DD
}

export interface PetStats {
    id: string; // 'primary'
    level: number;
    exp: number;
    coins: number;
    happiness: number;
    energy: number;
    activeWallpaper: string;
    lastUpdated: string;
}

export interface InventoryItem {
    id?: number;
    itemId: string;
    name: string;
    category: "snack" | "furniture" | "wallpaper";
    icon: string;
    statBoost?: { energy?: number; happiness?: number };
    purchasedAt: string;
}

export interface ShopCatalogItem {
    id: string;
    name: string;
    category: "snack" | "furniture" | "wallpaper";
    price: number;
    icon: string;
    description: string;
    statBoost?: { energy?: number; happiness?: number };
}

export const SHOP_ITEMS: ShopCatalogItem[] = [
    // Snacks & Treats
    {
        id: "snack_coffee",
        name: "Pixel Espresso",
        category: "snack",
        price: 40,
        icon: "☕",
        description: "Restores +25 Energy for focus sessions.",
        statBoost: { energy: 25 },
    },
    {
        id: "snack_pizza",
        name: "8-Bit Pizza",
        category: "snack",
        price: 75,
        icon: "🍕",
        description: "Restores +45 Energy & +15 Happiness.",
        statBoost: { energy: 45, happiness: 15 },
    },
    {
        id: "snack_donut",
        name: "Star Donut",
        category: "snack",
        price: 100,
        icon: "🍩",
        description: "Restores +60 Happiness & +20 Energy.",
        statBoost: { happiness: 60, energy: 20 },
    },

    // Furniture
    {
        id: "furn_arcade",
        name: "Arcade Cabinet",
        category: "furniture",
        price: 200,
        icon: "🕹️",
        description: "Retro arcade machine for pet platform room.",
    },
    {
        id: "furn_trampoline",
        name: "Mini Trampoline",
        category: "furniture",
        price: 180,
        icon: "🛏️",
        description: "Fun bounce trampoline for break time.",
    },
    {
        id: "furn_plant",
        name: "Pixel Bonsai",
        category: "furniture",
        price: 120,
        icon: "🪴",
        description: "Peaceful green bonsai plant.",
    },

    // Wallpapers
    {
        id: "wall_cyberpunk",
        name: "Cyberpunk Rooftop",
        category: "wallpaper",
        price: 300,
        icon: "🏙️",
        description: "Neon city sky retro wallpaper.",
    },
    {
        id: "wall_dungeon",
        name: "Dungeon Lab",
        category: "wallpaper",
        price: 250,
        icon: "🏰",
        description: "Mystic stone dungeon workshop.",
    },
    {
        id: "wall_cottage",
        name: "Cozy Cottage",
        category: "wallpaper",
        price: 200,
        icon: "🏡",
        description: "Warm wooden cottage interior.",
    },
];

export class KronosDatabase extends Dexie {
    dtrSessions!: Table<DtrSession>;
    petStats!: Table<PetStats>;
    inventory!: Table<InventoryItem>;

    constructor() {
        super("KronosDatabase");
        this.version(2).stores({
            dtrSessions: "++id, dateKey, category, status",
            petStats: "id",
            inventory: "++id, itemId, category",
        });
    }
}

export const db = new KronosDatabase();

// Seed initial pet stats if empty
export async function initPetStats(): Promise<PetStats> {
    const existing = await db.petStats.get("primary");
    if (existing) return existing;

    const defaultStats: PetStats = {
        id: "primary",
        level: 1,
        exp: 0,
        coins: 150,
        happiness: 80,
        energy: 90,
        activeWallpaper: "default",
        lastUpdated: new Date().toISOString(),
    };

    await db.petStats.put(defaultStats);
    return defaultStats;
}
