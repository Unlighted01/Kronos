import Dexie, { Table } from 'dexie';
import { EnvironmentId } from '../components/pet/types/biomeTypes';

export interface DtrSession {
  id?: number;
  taskName: string;
  category: string;
  notes?: string;
  startTime: string; // ISO string
  endTime: string; // ISO string
  durationMinutes: number;
  status: 'completed' | 'skipped';
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
  activeEnvironment: EnvironmentId;
  activeWallpaper?: string;
  lastUpdated: string;
}

export interface InventoryItem {
  id?: number;
  itemId: string;
  name: string;
  category: 'snack' | 'furniture' | 'environment';
  icon: string;
  environmentId?: EnvironmentId;
  statBoost?: { energy?: number; happiness?: number };
  purchasedAt: string;
}

export interface ShopCatalogItem {
  id: string;
  name: string;
  category: 'snack' | 'furniture' | 'environment';
  price: number;
  icon: string;
  description: string;
  environmentId?: EnvironmentId;
  statBoost?: { energy?: number; happiness?: number };
}

export const SHOP_ITEMS: ShopCatalogItem[] = [
  // --- Snacks & Treats ---
  {
    id: 'snack_coffee',
    name: 'Pixel Espresso',
    category: 'snack',
    price: 40,
    icon: '☕',
    description: 'Restores +25 Energy for focus sessions.',
    statBoost: { energy: 25 },
  },
  {
    id: 'snack_croissant',
    name: 'Butter Croissant',
    category: 'snack',
    price: 60,
    icon: '🥐',
    description: 'Restores +35 Energy & +15 Joy.',
    statBoost: { energy: 35, happiness: 15 },
  },
  {
    id: 'snack_matcha',
    name: 'Ceremonial Matcha',
    category: 'snack',
    price: 80,
    icon: '🍵',
    description: 'Restores +45 Energy & +25 Joy.',
    statBoost: { energy: 45, happiness: 25 },
  },
  {
    id: 'snack_donut',
    name: 'Star Donut',
    category: 'snack',
    price: 100,
    icon: '🍩',
    description: 'Restores +60 Joy & +20 Energy.',
    statBoost: { happiness: 60, energy: 20 },
  },
];

export class KronosDatabase extends Dexie {
  dtrSessions!: Table<DtrSession>;
  petStats!: Table<PetStats>;
  inventory!: Table<InventoryItem>;

  constructor() {
    super('KronosDatabase');
    this.version(3).stores({
      dtrSessions: '++id, dateKey, category, status',
      petStats: 'id',
      inventory: '++id, itemId, category',
    });
  }
}

export const db = new KronosDatabase();

// Sync, unlock all shop items, and ensure max coins & stats
export async function syncAndUnlockAllItems(): Promise<void> {
  try {
    const existingStats = await db.petStats.get('primary');
    const statsToSave: PetStats = {
      id: 'primary',
      level: Math.max(5, existingStats?.level ?? 5),
      exp: existingStats?.exp ?? 0,
      coins: 9999,
      happiness: 100,
      energy: 100,
      activeEnvironment: existingStats?.activeEnvironment ?? 'room_bedroom',
      activeWallpaper: existingStats?.activeWallpaper ?? 'room_bedroom',
      lastUpdated: new Date().toISOString(),
    };
    await db.petStats.put(statsToSave);

    const existingInventory = await db.inventory.toArray();
    
    // Clean up legacy environment/room items
    const legacyItems = existingInventory.filter(item => item.category === 'environment');
    const legacyIds = legacyItems.map(item => item.id).filter((id): id is number => id !== undefined);
    if (legacyIds.length > 0) {
      await db.inventory.bulkDelete(legacyIds);
    }

    const existingItemIds = new Set(existingInventory.map((item) => item.itemId));

    const itemsToAdd: InventoryItem[] = [];
    for (const item of SHOP_ITEMS) {
      if (!existingItemIds.has(item.id)) {
        itemsToAdd.push({
          itemId: item.id,
          name: item.name,
          category: item.category,
          icon: item.icon,
          environmentId: item.environmentId,
          statBoost: item.statBoost,
          purchasedAt: new Date().toISOString(),
        });
      }
    }

    if (itemsToAdd.length > 0) {
      await db.inventory.bulkAdd(itemsToAdd);
    }
  } catch {
    // Graceful error recovery
  }
}

// Seed initial pet stats and unlock items
export async function initPetStats(): Promise<PetStats> {
  await syncAndUnlockAllItems();
  const existing = await db.petStats.get('primary');
  if (existing) return existing;

  const defaultStats: PetStats = {
    id: 'primary',
    level: 5,
    exp: 0,
    coins: 9999,
    happiness: 100,
    energy: 100,
    activeEnvironment: 'room_bedroom',
    activeWallpaper: 'room_bedroom',
    lastUpdated: new Date().toISOString(),
  };

  await db.petStats.put(defaultStats);
  return defaultStats;
}
