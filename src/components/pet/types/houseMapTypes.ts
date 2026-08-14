export type RoomId =
  | 'room_bedroom'
  | 'room_living'
  | 'room_library'
  | 'room_kitchen'
  | 'room_greenhouse'
  | 'biome_sakura'
  | 'biome_campfire'
  | 'biome_autumn';

export interface RoomDoor {
  id: string;
  targetRoom: RoomId;
  label: string;
  direction: 'left' | 'right' | 'up' | 'down';
  x: number; // 240x140 logical canvas coordinates
  y: number;
  width: number;
  height: number;
  icon: string;
}

export interface RoomDefinition {
  id: RoomId;
  name: string;
  floor: string;
  icon: string;
  doors: RoomDoor[];
  defaultActivity: string;
  focusActivities: string[];
  breakActivities: string[];
  idleActivities: string[];
}

export const HOUSE_TOPOLOGY: Record<RoomId, RoomDefinition> = {
  room_bedroom: {
    id: 'room_bedroom',
    name: 'Study Bedroom',
    floor: '2F',
    icon: '🛋️',
    defaultActivity: 'typing_laptop',
    focusActivities: ['typing_laptop', 'reading_book'],
    breakActivities: ['relaxing_sofa', 'stretching'],
    idleActivities: ['sleeping', 'looking_around'],
    doors: [
      { id: 'door_living', targetRoom: 'room_living', label: 'Living Room', direction: 'right', x: 220, y: 64, width: 16, height: 48, icon: '🛋️' }
    ]
  },
  room_living: {
    id: 'room_living',
    name: 'Living Room Lounge',
    floor: '2F',
    icon: '🛋️',
    defaultActivity: 'relaxing_sofa',
    focusActivities: ['reading_book'],
    breakActivities: ['relaxing_sofa', 'watching_tv', 'listening_music'],
    idleActivities: ['sleeping_sofa', 'stretching'],
    doors: [
      { id: 'door_bedroom', targetRoom: 'room_bedroom', label: 'Bedroom', direction: 'left', x: 2, y: 64, width: 16, height: 48, icon: '🛋️' },
      { id: 'door_attic', targetRoom: 'room_library', label: 'Attic', direction: 'up', x: 64, y: 44, width: 14, height: 68, icon: '🪜' },
      { id: 'door_kitchen', targetRoom: 'room_kitchen', label: 'Kitchen', direction: 'right', x: 220, y: 64, width: 16, height: 48, icon: '🥐' }
    ]
  },
  room_library: {
    id: 'room_library',
    name: 'Attic Library',
    floor: 'Attic',
    icon: '📚',
    defaultActivity: 'reading_book',
    focusActivities: ['reading_book', 'studying'],
    breakActivities: ['organizing_books'],
    idleActivities: ['sleeping', 'dusting'],
    doors: [
      { id: 'door_living', targetRoom: 'room_living', label: 'Living Room', direction: 'down', x: 95, y: 44, width: 14, height: 68, icon: '🪜' }
    ]
  },
  room_kitchen: {
    id: 'room_kitchen',
    name: 'Warm Bakery Kitchen',
    floor: '1F',
    icon: '🥐',
    defaultActivity: 'drinking_coffee',
    focusActivities: ['reading_recipe'],
    breakActivities: ['drinking_coffee', 'baking_croissant', 'eating_snack'],
    idleActivities: ['cleaning_counter', 'looking_out_window'],
    doors: [
      { id: 'door_living', targetRoom: 'room_living', label: 'Living Room', direction: 'left', x: 2, y: 64, width: 16, height: 48, icon: '🛋️' },
      { id: 'door_backyard', targetRoom: 'room_greenhouse', label: 'Backyard', direction: 'right', x: 220, y: 64, width: 16, height: 48, icon: '🌿' }
    ]
  },
  room_greenhouse: {
    id: 'room_greenhouse',
    name: 'Plant Conservatory',
    floor: '1F/Garden',
    icon: '🌿',
    defaultActivity: 'watering_plants',
    focusActivities: ['botany_research'],
    breakActivities: ['watering_plants', 'relaxing_bench'],
    idleActivities: ['sleeping_bench', 'looking_at_flowers'],
    doors: [
      { id: 'door_kitchen', targetRoom: 'room_kitchen', label: 'Kitchen', direction: 'left', x: 2, y: 64, width: 16, height: 48, icon: '🥐' }
    ]
  },
  biome_sakura: {
    id: 'biome_sakura',
    name: 'Sakura Garden',
    floor: 'Outdoors',
    icon: '🌸',
    defaultActivity: 'watching_petals',
    focusActivities: ['meditating'],
    breakActivities: ['picnic', 'watching_petals'],
    idleActivities: ['sleeping_grass', 'chasing_butterflies'],
    doors: []
  },
  biome_campfire: {
    id: 'biome_campfire',
    name: 'Starry Campfire',
    floor: 'Outdoors',
    icon: '🔥',
    defaultActivity: 'warming_hands',
    focusActivities: ['stargazing'],
    breakActivities: ['warming_hands', 'roasting_marshmallows'],
    idleActivities: ['sleeping_tent', 'listening_fire'],
    doors: []
  },
  biome_autumn: {
    id: 'biome_autumn',
    name: 'Autumn Maple Grove',
    floor: 'Outdoors',
    icon: '🍂',
    defaultActivity: 'raking_leaves',
    focusActivities: ['reading_under_tree'],
    breakActivities: ['raking_leaves', 'drinking_cider'],
    idleActivities: ['sleeping_leaves', 'watching_squirrels'],
    doors: []
  }
};
