import { RoomId } from './houseMapTypes';

export interface InteractiveObject {
  id: string;
  roomId: RoomId;
  name: string;
  x: number;
  y: number;
  width: number;
  height: number;
  cursor?: string;
  tooltip: string;
}

export const INTERACTIVE_OBJECTS: Record<RoomId, InteractiveObject[]> = {
  room_bedroom: [
    { id: 'lamp', roomId: 'room_bedroom', name: 'Desk Lamp', x: 200, y: 70, width: 14, height: 18, tooltip: 'Desk Lamp' },
    { id: 'laptop', roomId: 'room_bedroom', name: 'Laptop', x: 172, y: 80, width: 18, height: 14, tooltip: 'Laptop' },
    { id: 'clock', roomId: 'room_bedroom', name: 'Wall Clock', x: 100, y: 20, width: 16, height: 26, tooltip: 'Wall Clock' },
    { id: 'bed', roomId: 'room_bedroom', name: 'Cozy Bed', x: 8, y: 78, width: 44, height: 34, tooltip: 'Cozy Bed' },
    { id: 'ivy', roomId: 'room_bedroom', name: 'Hanging Ivy', x: 58, y: 16, width: 22, height: 20, tooltip: 'Hanging Ivy' }
  ],
  room_living: [
    { id: 'turntable', roomId: 'room_living', name: 'Vinyl Player', x: 176, y: 82, width: 26, height: 16, tooltip: 'Vinyl Player' },
    { id: 'fireplace', roomId: 'room_living', name: 'Fireplace', x: 96, y: 62, width: 48, height: 50, tooltip: 'Fireplace' },
    { id: 'arc_lamp', roomId: 'room_living', name: 'Arc Lamp', x: 4, y: 52, width: 34, height: 60, tooltip: 'Arc Lamp' },
    { id: 'painting', roomId: 'room_living', name: 'Framed Painting', x: 148, y: 22, width: 22, height: 18, tooltip: 'Framed Painting' }
  ],
  room_library: [
    { id: 'globe', roomId: 'room_library', name: 'Antique Globe', x: 172, y: 78, width: 16, height: 18, tooltip: 'Antique Globe' },
    { id: 'candlestick', roomId: 'room_library', name: 'Beeswax Candle', x: 60, y: 50, width: 10, height: 16, tooltip: 'Beeswax Candle' },
    { id: 'bookshelf', roomId: 'room_library', name: 'Ancient Bookshelf', x: 14, y: 20, width: 50, height: 92, tooltip: 'Ancient Bookshelf' }
  ],
  room_kitchen: [
    { id: 'coffee_mug', roomId: 'room_kitchen', name: 'Coffee Mug', x: 185, y: 72, width: 12, height: 14, tooltip: 'Coffee Mug' },
    { id: 'oven', roomId: 'room_kitchen', name: 'Bakery Oven', x: 12, y: 54, width: 44, height: 58, tooltip: 'Bakery Oven' },
    { id: 'copper_pans', roomId: 'room_kitchen', name: 'Hanging Copper Pans', x: 90, y: 18, width: 34, height: 18, tooltip: 'Hanging Copper Pans' }
  ],
  room_greenhouse: [
    { id: 'watering_can', roomId: 'room_greenhouse', name: 'Watering Can', x: 180, y: 82, width: 16, height: 16, tooltip: 'Watering Can' },
    { id: 'monstera', roomId: 'room_greenhouse', name: 'Monstera Planter', x: 12, y: 56, width: 26, height: 56, tooltip: 'Monstera Planter' },
    { id: 'butterflies', roomId: 'room_greenhouse', name: 'Butterflies', x: 120, y: 35, width: 30, height: 30, tooltip: 'Butterflies' }
  ],
  biome_sakura: [],
  biome_campfire: [],
  biome_autumn: []
};
