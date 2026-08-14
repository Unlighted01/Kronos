export type EnvironmentId =
  | 'room_bedroom'
  | 'room_library'
  | 'room_kitchen'
  | 'room_greenhouse'
  | 'biome_sakura'
  | 'biome_campfire'
  | 'biome_autumn';

export type TimeOfDay = 'dawn' | 'day' | 'sunset' | 'night';

export interface BaseParticle {
  x: number;
  y: number;
  speedX: number;
  speedY: number;
  opacity: number;
  size: number;
}

export interface PetalParticle extends BaseParticle {
  rotation: number;
  rotationSpeed: number;
  swayOffset: number;
}

export interface EmberParticle extends BaseParticle {
  life: number;
  maxLife: number;
  color: string;
}

export interface LeafParticle extends BaseParticle {
  rotation: number;
  rotationSpeed: number;
  color: string;
}
