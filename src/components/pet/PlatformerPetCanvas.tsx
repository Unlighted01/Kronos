import React, { useEffect, useRef, useState } from 'react';
import { TimerMode, TimerStatus } from '../../stores/useTimerStore';
import { getRandomThought } from '../../utils/petDialogues';
import { db } from '../../db/kronosDb';
import { audioSynth } from '../../utils/audioSynth';
import {
  PetalParticle,
  EmberParticle,
  LeafParticle,
} from './types/biomeTypes';
import { renderStudyBedroom } from './renderers/rooms/bedroomRenderer';
import { renderAtticLibrary } from './renderers/rooms/libraryRenderer';
import { renderWarmKitchen } from './renderers/rooms/kitchenRenderer';
import { renderGreenhouse } from './renderers/rooms/greenhouseRenderer';
import { renderSakuraGarden } from './renderers/biomes/sakuraBiomeRenderer';
import { renderStarryCampfire } from './renderers/biomes/campfireBiomeRenderer';
import { renderAutumnGrove } from './renderers/biomes/autumnBiomeRenderer';
import { drawEnhancedPet } from './renderers/petSpriteRenderer';
import { useHouseStore } from '../../stores/useHouseStore';
import { HOUSE_TOPOLOGY } from './types/houseMapTypes';
import { renderLivingRoom } from './renderers/rooms/livingRoomRenderer';
import { drawRoomDoors } from './renderers/doorRenderer';

interface PlatformerPetCanvasProps {
  mode: TimerMode;
  status: TimerStatus;
  width?: number;
  height?: number;
}

export type FocusAction =
  | 'typing_laptop'
  | 'drinking_coffee'
  | 'stretching'
  | 'reading_book'
  | 'micro_dance'
  | 'baking_croissant'
  | 'watering_plants'
  | 'relaxing_sofa';

export type IdleAction = 'walking' | 'looking_at_user' | 'napping' | 'sitting' | 'afk_hiding' | 'petted';
export type PetAction = FocusAction | IdleAction | string;

interface HeartParticle {
  id: number;
  x: number;
  y: number;
  opacity: number;
  scale: number;
}

export const PlatformerPetCanvas: React.FC<PlatformerPetCanvasProps> = ({
  mode,
  status,
  width = 240,
  height = 140,
}) => {
  const LOGICAL_WIDTH = 240;
  const LOGICAL_HEIGHT = 140;

  const canvasRef = useRef<HTMLCanvasElement | null>(null);
  const frameRef = useRef<number>(0);
  const petXRef = useRef<number>(60);
  const petDirectionRef = useRef<number>(1);
  const currentActionRef = useRef<PetAction>('typing_laptop');
  const actionTimerRef = useRef<number>(0);

  const [hearts, setHearts] = useState<HeartParticle[]>([]);
  const [hoveredDoorId, setHoveredDoorId] = useState<string | null>(null);

  const { petCurrentRoom, activeViewRoom, petActivity, setViewRoom, jumpToPet, wanderRoutine } = useHouseStore();

  const currentRoomDef = HOUSE_TOPOLOGY[activeViewRoom];
  const doors = currentRoomDef?.doors || [];

  // Dynamic particle pools
  const petalsRef = useRef<PetalParticle[]>([]);
  const embersRef = useRef<EmberParticle[]>([]);
  const leavesRef = useRef<LeafParticle[]>([]);

  // Initialize Particle Pools
  useEffect(() => {
    // Sakura Petals
    petalsRef.current = Array.from({ length: 22 }).map(() => ({
      x: Math.random() * LOGICAL_WIDTH,
      y: Math.random() * LOGICAL_HEIGHT,
      speedX: 0.4 + Math.random() * 0.6,
      speedY: 0.6 + Math.random() * 0.8,
      rotation: Math.random() * Math.PI * 2,
      rotationSpeed: (Math.random() - 0.5) * 0.05,
      swayOffset: Math.random() * 10,
      opacity: 0.7 + Math.random() * 0.3,
      size: 3 + Math.random() * 2,
    }));

    // Campfire Embers
    embersRef.current = Array.from({ length: 18 }).map(() => ({
      x: 45 + (Math.random() - 0.5) * 14,
      y: LOGICAL_HEIGHT - 32 - Math.random() * 20,
      speedX: (Math.random() - 0.5) * 0.6,
      speedY: -(0.5 + Math.random() * 1.0),
      opacity: 1,
      size: 1.5 + Math.random() * 1.5,
      life: Math.random() * 30,
      maxLife: 30 + Math.random() * 20,
      color: Math.random() > 0.4 ? '#fbbf24' : '#f97316',
    }));

    // Autumn Leaves
    const leafColors = ['#ea580c', '#f59e0b', '#dc2626', '#b45309'];
    leavesRef.current = Array.from({ length: 18 }).map(() => ({
      x: Math.random() * LOGICAL_WIDTH,
      y: Math.random() * LOGICAL_HEIGHT,
      speedX: 0.3 + Math.random() * 0.5,
      speedY: 0.5 + Math.random() * 0.7,
      rotation: Math.random() * Math.PI * 2,
      rotationSpeed: (Math.random() - 0.5) * 0.04,
      opacity: 0.8 + Math.random() * 0.2,
      size: 3.5 + Math.random() * 2.5,
      color: leafColors[Math.floor(Math.random() * leafColors.length)],
    }));
  }, [LOGICAL_HEIGHT, LOGICAL_WIDTH]);

  // Behavior Anti-Repetition & Cooldown Memory Engine
  const actionMemoryRef = useRef<{
    currentState: PetAction;
    lastState: PetAction | null;
    historyQueue: PetAction[];
    cooldowns: Map<PetAction, number>;
  }>({
    currentState: 'typing_laptop',
    lastState: null,
    historyQueue: [],
    cooldowns: new Map<PetAction, number>(),
  });

  const [currentThought, setCurrentThought] = useState<string>('');
  const [isAfk, setIsAfk] = useState<boolean>(false);
  const lastActivityRef = useRef<number>(Date.now());

  // Mouse activity tracker for AFK hiding
  useEffect(() => {
    const handleActivity = () => {
      lastActivityRef.current = Date.now();
      if (isAfk) {
        setIsAfk(false);
        petXRef.current = 60;
      }
    };

    window.addEventListener('mousemove', handleActivity);
    window.addEventListener('keydown', handleActivity);

    const afkInterval = setInterval(() => {
      if (status === 'idle' && Date.now() - lastActivityRef.current > 25000) {
        if (!isAfk && Math.random() > 0.3) {
          setIsAfk(true);
          currentActionRef.current = 'afk_hiding';
          setCurrentThought(getRandomThought(mode, status, true));
        }
      }
    }, 5000);

    return () => {
      window.removeEventListener('mousemove', handleActivity);
      window.removeEventListener('keydown', handleActivity);
      clearInterval(afkInterval);
    };
  }, [status, isAfk, mode]);

  // Periodic Random Speech Bubble Generator
  useEffect(() => {
    const bubbleInterval = setInterval(() => {
      if (Math.random() > 0.4 && currentActionRef.current !== 'petted' && activeViewRoom === petCurrentRoom) {
        setCurrentThought(getRandomThought(mode, status, isAfk));
        setTimeout(() => setCurrentThought(''), 4000);
      }
    }, 7000);

    return () => clearInterval(bubbleInterval);
  }, [mode, status, isAfk, activeViewRoom, petCurrentRoom]);

  // Mouse move handler for door hover effects
  const handleMouseMove = (e: React.MouseEvent<HTMLDivElement>) => {
    const canvas = canvasRef.current;
    if (!canvas) return;
    const rect = canvas.getBoundingClientRect();
    const scaleX = LOGICAL_WIDTH / rect.width;
    const scaleY = LOGICAL_HEIGHT / rect.height;
    const mouseX = (e.clientX - rect.left) * scaleX;
    const mouseY = (e.clientY - rect.top) * scaleY;

    const hitDoor = doors.find(
      (d) =>
        mouseX >= d.x &&
        mouseX <= d.x + d.width &&
        mouseY >= d.y &&
        mouseY <= d.y + d.height
    );

    setHoveredDoorId(hitDoor ? hitDoor.id : null);
  };

  // Click handler (Door Navigation vs Petting)
  const handleCanvasClick = (e: React.MouseEvent<HTMLDivElement>) => {
    const canvas = canvasRef.current;
    if (!canvas) return;
    const rect = canvas.getBoundingClientRect();
    const scaleX = LOGICAL_WIDTH / rect.width;
    const scaleY = LOGICAL_HEIGHT / rect.height;
    const clickX = (e.clientX - rect.left) * scaleX;
    const clickY = (e.clientY - rect.top) * scaleY;

    // Check if a door was clicked
    const clickedDoor = doors.find(
      (d) =>
        clickX >= d.x &&
        clickX <= d.x + d.width &&
        clickY >= d.y &&
        clickY <= d.y + d.height
    );

    if (clickedDoor) {
      audioSynth.playClick();
      setViewRoom(clickedDoor.targetRoom);
      return;
    }

    // Check if Pet was clicked (only if pet is in current room)
    if (activeViewRoom === petCurrentRoom) {
      const petX = petXRef.current;
      const platformY = LOGICAL_HEIGHT - 28;
      const petY = platformY - 20;

      if (clickX >= petX - 25 && clickX <= petX + 45 && clickY >= petY - 20 && clickY <= petY + 40) {
        audioSynth.playChime();
        currentActionRef.current = 'petted';
        actionTimerRef.current = 18;
        setCurrentThought('I love you! ❤️ ✨');

        const newHearts: HeartParticle[] = Array.from({ length: 4 }).map((_, i) => ({
          id: Date.now() + i,
          x: petX + Math.random() * 20 - 5,
          y: petY - Math.random() * 10,
          opacity: 1,
          scale: 0.8 + Math.random() * 0.4,
        }));
        setHearts((prev) => [...prev, ...newHearts]);

        db.petStats.get('primary').then((stats) => {
          if (stats) {
            const newHappiness = Math.min(100, stats.happiness + 5);
            db.petStats.update('primary', { happiness: newHappiness });
          }
        }).catch(() => {});
      }
    }
  };

  // Heart Particles Animation Loop
  useEffect(() => {
    if (hearts.length === 0) return;
    const interval = setInterval(() => {
      setHearts((prev) =>
        prev
          .map((h) => ({ ...h, y: h.y - 1.5, opacity: h.opacity - 0.05 }))
          .filter((h) => h.opacity > 0)
      );
    }, 50);
    return () => clearInterval(interval);
  }, [hearts]);

  // Main Canvas Render Loop
  useEffect(() => {
    const canvas = canvasRef.current;
    if (!canvas) return;
    const ctx = canvas.getContext('2d');
    if (!ctx) return;

    ctx.imageSmoothingEnabled = false;

    let lastTime = performance.now();
    const frameInterval = 1000 / 12;

    let animationId: number;

    const selectNextAction = () => {
      const memory = actionMemoryRef.current;

      memory.cooldowns.forEach((ticks, act) => {
        if (ticks > 1) {
          memory.cooldowns.set(act, ticks - 1);
        } else {
          memory.cooldowns.delete(act);
        }
      });

      const rawPool: PetAction[] = (status === 'running' && mode === 'work')
        ? ['typing_laptop', 'drinking_coffee', 'stretching', 'reading_book', 'micro_dance']
        : ['walking', 'looking_at_user', 'napping', 'sitting'];

      let candidates = rawPool.filter((act) => {
        if (act === memory.currentState) return false;
        if (memory.cooldowns.has(act)) return false;
        return true;
      });

      if (candidates.length === 0) {
        candidates = rawPool.filter((act) => act !== memory.currentState);
      }
      if (candidates.length === 0) {
        candidates = rawPool;
      }

      const nextAction = candidates[Math.floor(Math.random() * candidates.length)];

      if (nextAction === 'napping') memory.cooldowns.set('napping', 4);
      if (nextAction === 'drinking_coffee') memory.cooldowns.set('drinking_coffee', 3);
      if (nextAction === 'stretching') memory.cooldowns.set('stretching', 2);
      if (nextAction === 'afk_hiding') memory.cooldowns.set('afk_hiding', 5);

      memory.lastState = memory.currentState;
      memory.currentState = nextAction;
      memory.historyQueue.push(nextAction);
      if (memory.historyQueue.length > 4) memory.historyQueue.shift();

      currentActionRef.current = nextAction;
      actionTimerRef.current = Math.floor(Math.random() * 40) + 30;
    };

    const updateParticles = () => {
      // Update Sakura Petals
      petalsRef.current.forEach((p) => {
        p.x += p.speedX + Math.sin(frameRef.current * 0.05 + p.swayOffset) * 0.5;
        p.y += p.speedY;
        p.rotation += p.rotationSpeed;
        if (p.y > LOGICAL_HEIGHT) {
          p.y = -5;
          p.x = Math.random() * LOGICAL_WIDTH;
        }
        if (p.x > LOGICAL_WIDTH) p.x = -5;
      });

      // Update Campfire Embers
      embersRef.current.forEach((e) => {
        e.y += e.speedY;
        e.x += e.speedX + Math.sin(frameRef.current * 0.2 + e.life) * 0.3;
        e.life++;
        e.opacity = Math.max(0, 1 - e.life / e.maxLife);
        if (e.life >= e.maxLife) {
          e.x = 45 + (Math.random() - 0.5) * 14;
          e.y = LOGICAL_HEIGHT - 32;
          e.life = 0;
          e.opacity = 1;
        }
      });

      // Update Autumn Leaves
      leavesRef.current.forEach((l) => {
        l.x += l.speedX + Math.cos(frameRef.current * 0.04) * 0.6;
        l.y += l.speedY;
        l.rotation += l.rotationSpeed;
        if (l.y > LOGICAL_HEIGHT) {
          l.y = -5;
          l.x = Math.random() * LOGICAL_WIDTH;
        }
        if (l.x > LOGICAL_WIDTH) l.x = -5;
      });
    };

    const render = (now: number) => {
      animationId = requestAnimationFrame(render);

      const elapsed = now - lastTime;
      if (elapsed < frameInterval) return;
      lastTime = now - (elapsed % frameInterval);

      frameRef.current = (frameRef.current + 1) % 60;
      const frame = frameRef.current;

      actionTimerRef.current -= 1;
      if (actionTimerRef.current <= 0 && !isAfk) {
        selectNextAction();
      }

      updateParticles();

      const action = isAfk ? 'afk_hiding' : (activeViewRoom === petCurrentRoom ? (petActivity || currentActionRef.current) : currentActionRef.current);

      ctx.clearRect(0, 0, LOGICAL_WIDTH, LOGICAL_HEIGHT);

      // --- 1. DYNAMIC ENVIRONMENT RENDERER ---
      let envData = { platformY: LOGICAL_HEIGHT - 28, deskX: LOGICAL_WIDTH - 70, deskY: LOGICAL_HEIGHT - 52 };

      if (activeViewRoom === 'room_library') {
        envData = renderAtticLibrary(ctx, LOGICAL_WIDTH, LOGICAL_HEIGHT, frame, mode, status, doors, hoveredDoorId);
      } else if (activeViewRoom === 'room_living') {
        envData = renderLivingRoom(ctx, LOGICAL_WIDTH, LOGICAL_HEIGHT, frame, mode, status, doors, hoveredDoorId);
      } else if (activeViewRoom === 'room_kitchen') {
        envData = renderWarmKitchen(ctx, LOGICAL_WIDTH, LOGICAL_HEIGHT, frame, mode, status, doors, hoveredDoorId);
      } else if (activeViewRoom === 'room_greenhouse') {
        envData = renderGreenhouse(ctx, LOGICAL_WIDTH, LOGICAL_HEIGHT, frame, mode, status, doors, hoveredDoorId);
      } else if (activeViewRoom === 'biome_sakura') {
        envData = renderSakuraGarden(ctx, LOGICAL_WIDTH, LOGICAL_HEIGHT, frame, petalsRef.current, mode, status);
      } else if (activeViewRoom === 'biome_campfire') {
        envData = renderStarryCampfire(ctx, LOGICAL_WIDTH, LOGICAL_HEIGHT, frame, embersRef.current, mode, status);
      } else if (activeViewRoom === 'biome_autumn') {
        envData = renderAutumnGrove(ctx, LOGICAL_WIDTH, LOGICAL_HEIGHT, frame, leavesRef.current, mode, status);
      } else {
        // Default: Study Bedroom
        envData = renderStudyBedroom(ctx, LOGICAL_WIDTH, LOGICAL_HEIGHT, frame, mode, status, doors, hoveredDoorId);
      }

      if (activeViewRoom === 'biome_sakura' || activeViewRoom === 'biome_campfire' || activeViewRoom === 'biome_autumn') {
        drawRoomDoors(ctx, doors, frame, hoveredDoorId);
      }

      const { platformY, deskX } = envData;

      // --- 2. PET ANIMATION RENDERER ---
      if (activeViewRoom === petCurrentRoom) {
        let drawX = petXRef.current;
        const drawY = platformY - 16;

        if (action === 'typing_laptop' || action === 'drinking_coffee' || action === 'reading_book' || action === 'baking_croissant') {
          drawX = deskX - 10;
        } else if (action === 'walking') {
          petXRef.current += petDirectionRef.current * 0.8;
          if (petXRef.current > deskX - 30) petDirectionRef.current = -1;
          if (petXRef.current < 55) petDirectionRef.current = 1;
          drawX = petXRef.current;
        } else if (action === 'afk_hiding') {
          if (petXRef.current > -20) petXRef.current -= 1.5;
          drawX = petXRef.current;
        }

        // Render High-Detail Enhanced Pixel Pet Sprite
        drawEnhancedPet({
          ctx,
          drawX,
          drawY,
          action,
          frame,
          direction: petDirectionRef.current,
          status,
          mode,
        });

        // --- 3. SPEECH THOUGHT BUBBLE ---
        if (currentThought && action !== 'afk_hiding') {
          const bubbleX = Math.max(10, Math.min(LOGICAL_WIDTH - 110, drawX - 30));
          const bubbleY = Math.max(10, drawY - 26);

          ctx.fillStyle = 'rgba(15, 23, 42, 0.95)';
          ctx.fillRect(bubbleX, bubbleY, 105, 20);
          ctx.strokeStyle = '#818cf8';
          ctx.lineWidth = 1;
          ctx.strokeRect(bubbleX, bubbleY, 105, 20);

          ctx.fillStyle = '#818cf8';
          ctx.fillRect(drawX + 6, bubbleY + 20, 3, 3);

          ctx.fillStyle = '#f8fafc';
          ctx.font = '9px "Plus Jakarta Sans", sans-serif';
          ctx.fillText(currentThought, bubbleX + 6, bubbleY + 13);
        }
      }
    };

    animationId = requestAnimationFrame(render);

    return () => {
      cancelAnimationFrame(animationId);
    };
  }, [mode, status, isAfk, currentThought, activeViewRoom, petCurrentRoom, petActivity, doors, hoveredDoorId]);

  // Wandering Routine
  useEffect(() => {
    const wanderInterval = setInterval(() => {
      wanderRoutine(mode, status);
    }, 45000);

    return () => clearInterval(wanderInterval);
  }, [mode, status, wanderRoutine]);

  const isPetHere = activeViewRoom === petCurrentRoom;
  const petLocationDef = HOUSE_TOPOLOGY[petCurrentRoom];

  return (
    <div className="flex flex-col items-center">
      {/* "Where is My Pet?" Locator HUD Banner */}
      <div className="w-full flex items-center justify-between px-1 mb-1 text-[8px] font-semibold select-none">
        <div className="flex items-center space-x-1 text-slate-300">
          <span>{currentRoomDef?.icon || '🏠'}</span>
          <span className="font-bold text-slate-200">{currentRoomDef?.name}</span>
          <span className="text-[7px] text-slate-500 font-mono">({currentRoomDef?.floor})</span>
        </div>

        {isPetHere ? (
          <span className="text-[7.5px] text-emerald-400 bg-emerald-500/10 border border-emerald-500/20 px-1.5 py-0.5 rounded-full flex items-center gap-1">
            <span className="w-1 h-1 rounded-full bg-emerald-400 animate-pulse" />
            Here ({petActivity.replace('_', ' ')})
          </span>
        ) : (
          <button
            onClick={() => {
              audioSynth.playChime();
              jumpToPet();
            }}
            className="text-[7.5px] text-indigo-300 bg-indigo-600/30 hover:bg-indigo-600/50 border border-indigo-500/40 px-1.5 py-0.5 rounded-full flex items-center gap-1 transition-all active:scale-95 shadow-sm animate-bounce"
            title="Click to find pet!"
          >
            <span>🐾 In {petLocationDef?.name}</span>
            <span>🔍</span>
          </button>
        )}
      </div>

      {/* 2D Platformer Canvas Wrapper */}
      <div
        className="relative rounded-xl overflow-hidden border border-white/10 shadow-inner cursor-pointer"
        onClick={handleCanvasClick}
        onMouseMove={handleMouseMove}
        onMouseLeave={() => setHoveredDoorId(null)}
        style={{ width: `${width}px`, height: `${height}px` }}
      >
        <canvas
          ref={canvasRef}
          width={LOGICAL_WIDTH}
          height={LOGICAL_HEIGHT}
          style={{
            imageRendering: 'pixelated',
            width: '100%',
            height: '100%',
          }}
        />
        {/* Floating Heart Particles */}
        {hearts.map((h) => (
          <span
            key={h.id}
            className="absolute text-rose-400 font-bold pointer-events-none select-none transition-all duration-75 text-xs"
            style={{
              left: `${h.x * (width / LOGICAL_WIDTH)}px`,
              top: `${h.y * (height / LOGICAL_HEIGHT)}px`,
              opacity: h.opacity,
              transform: `scale(${h.scale * (width / LOGICAL_WIDTH)})`,
            }}
          >
            ❤️
          </span>
        ))}
      </div>
    </div>
  );
};
