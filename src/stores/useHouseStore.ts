import { create } from 'zustand';
import { RoomId, HOUSE_TOPOLOGY } from '../components/pet/types/houseMapTypes';
import { TimerMode, TimerStatus } from './useTimerStore';

interface HouseStoreState {
  petCurrentRoom: RoomId;
  activeViewRoom: RoomId;
  petActivity: string;
  setViewRoom: (roomId: RoomId) => void;
  setPetRoom: (roomId: RoomId, activity?: string) => void;
  jumpToPet: () => void;
  wanderRoutine: (mode: TimerMode, status: TimerStatus) => void;
}

export const useHouseStore = create<HouseStoreState>((set, get) => ({
  petCurrentRoom: 'room_bedroom',
  activeViewRoom: 'room_bedroom',
  petActivity: 'typing_laptop',

  setViewRoom: (roomId) => set({ activeViewRoom: roomId }),

  setPetRoom: (roomId, activity) => {
    const defaultActivity = HOUSE_TOPOLOGY[roomId]?.defaultActivity || 'typing_laptop';
    set({ petCurrentRoom: roomId, petActivity: activity || defaultActivity });
  },

  jumpToPet: () => {
    const { petCurrentRoom } = get();
    set({ activeViewRoom: petCurrentRoom });
  },

  wanderRoutine: (mode, status) => {
    const { petCurrentRoom } = get();

    const getNextRoomInPath = (start: RoomId, target: RoomId): RoomId | null => {
      if (start === target) return null;
      const queue: RoomId[] = [start];
      const cameFrom: Partial<Record<RoomId, RoomId>> = {};
      const visited = new Set<RoomId>([start]);
      
      while (queue.length > 0) {
        const current = queue.shift()!;
        if (current === target) break;
        const currentDef = HOUSE_TOPOLOGY[current];
        if (currentDef) {
          for (const door of currentDef.doors) {
            if (!visited.has(door.targetRoom)) {
              visited.add(door.targetRoom);
              cameFrom[door.targetRoom] = current;
              queue.push(door.targetRoom);
            }
          }
        }
      }
      
      if (!cameFrom[target]) return null;
      
      let curr = target;
      while (cameFrom[curr] !== start) {
        curr = cameFrom[curr]!;
      }
      return curr;
    };

    let targetRoom: RoomId | null = null;
    let targetActivity = '';

    if (status === 'running') {
      if (mode === 'work') {
        const focusRooms: RoomId[] = ['room_bedroom', 'room_library'];
        targetRoom = focusRooms[Math.floor(Math.random() * focusRooms.length)];
        targetActivity = targetRoom === 'room_bedroom' ? 'typing_laptop' : 'reading_book';
      } else {
        const breakRooms: { id: RoomId; act: string }[] = [
          { id: 'room_kitchen', act: 'drinking_coffee' },
          { id: 'room_kitchen', act: 'baking_croissant' },
          { id: 'room_living', act: 'relaxing_sofa' },
          { id: 'room_greenhouse', act: 'watering_plants' },
        ];
        const target = breakRooms[Math.floor(Math.random() * breakRooms.length)];
        targetRoom = target.id;
        targetActivity = target.act;
      }
    } else if (status === 'idle') {
      const currentRoomDef = HOUSE_TOPOLOGY[petCurrentRoom];
      if (currentRoomDef && currentRoomDef.doors.length > 0) {
        if (Math.random() > 0.5) {
          const randomDoor = currentRoomDef.doors[Math.floor(Math.random() * currentRoomDef.doors.length)];
          targetRoom = randomDoor.targetRoom;
          const newRoomDef = HOUSE_TOPOLOGY[targetRoom];
          targetActivity =
            newRoomDef?.idleActivities?.[Math.floor(Math.random() * newRoomDef.idleActivities.length)] ||
            newRoomDef?.defaultActivity ||
            'sitting';
        }
      }
    }

    if (targetRoom) {
      if (targetRoom === petCurrentRoom) {
        set({ petActivity: targetActivity });
      } else {
        const nextRoom = getNextRoomInPath(petCurrentRoom, targetRoom);
        if (nextRoom) {
          if (nextRoom === targetRoom) {
            set({ petCurrentRoom: nextRoom, petActivity: targetActivity });
          } else {
            const nextDef = HOUSE_TOPOLOGY[nextRoom];
            set({ petCurrentRoom: nextRoom, petActivity: nextDef?.defaultActivity || 'walking' });
          }
        } else {
          set({ petCurrentRoom: targetRoom, petActivity: targetActivity });
        }
      }
    }
  },
}));
