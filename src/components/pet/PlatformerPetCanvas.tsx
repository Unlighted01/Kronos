import React, { useEffect, useRef, useState } from 'react';
import { TimerMode, TimerStatus } from '../../stores/useTimerStore';
import { getRandomThought } from '../../utils/petDialogues';

interface PlatformerPetCanvasProps {
  mode: TimerMode;
  status: TimerStatus;
  width?: number;
  height?: number;
}

type FocusAction = 'typing_laptop' | 'drinking_coffee' | 'stretching' | 'reading_book' | 'micro_dance';
type IdleAction = 'walking' | 'looking_at_user' | 'napping' | 'sitting' | 'afk_hiding';
type PetAction = FocusAction | IdleAction;

export const PlatformerPetCanvas: React.FC<PlatformerPetCanvasProps> = ({
  mode,
  status,
  width = 240,
  height = 140,
}) => {
  const canvasRef = useRef<HTMLCanvasElement | null>(null);
  const frameRef = useRef<number>(0);
  const petXRef = useRef<number>(60);
  const petDirectionRef = useRef<number>(1);
  const currentActionRef = useRef<PetAction>('typing_laptop');
  const actionTimerRef = useRef<number>(0);

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
        petXRef.current = 20; // Walk back onto screen
      }
    };

    window.addEventListener('mousemove', handleActivity);
    window.addEventListener('keydown', handleActivity);

    // AFK Check Interval (20 seconds inactivity while timer is idle)
    const afkInterval = setInterval(() => {
      if (status === 'idle' && Date.now() - lastActivityRef.current > 20000) {
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
      if (Math.random() > 0.4) {
        setCurrentThought(getRandomThought(mode, status, isAfk));
        setTimeout(() => setCurrentThought(''), 4000);
      }
    }, 7000);

    return () => clearInterval(bubbleInterval);
  }, [mode, status, isAfk]);

  useEffect(() => {
    const canvas = canvasRef.current;
    if (!canvas) return;
    const ctx = canvas.getContext('2d');
    if (!ctx) return;

    ctx.imageSmoothingEnabled = false;

    let lastTime = performance.now();
    const frameInterval = 1000 / 12; // 12 FPS throttled for retro look & <0.1% CPU

    let animationId: number;

    // Smart Non-Repeating Behavior Engine Selection
    const selectNextAction = () => {
      const memory = actionMemoryRef.current;

      // 1. Decrement active cooldown counters
      memory.cooldowns.forEach((ticks, act) => {
        if (ticks > 1) {
          memory.cooldowns.set(act, ticks - 1);
        } else {
          memory.cooldowns.delete(act);
        }
      });

      // 2. Base action pool for current mode
      const rawPool: PetAction[] = (status === 'running' && mode === 'work')
        ? ['typing_laptop', 'drinking_coffee', 'stretching', 'reading_book', 'micro_dance']
        : ['walking', 'looking_at_user', 'napping', 'sitting'];

      // 3. Filter candidates (no consecutive duplicates, no actions on cooldown)
      let candidates = rawPool.filter((act) => {
        if (act === memory.currentState) return false; // Prevent consecutive duplicates!
        if (memory.cooldowns.has(act)) return false;   // In active cooldown!
        return true;
      });

      // 4. Fallback if candidate pool is empty
      if (candidates.length === 0) {
        candidates = rawPool.filter((act) => act !== memory.currentState);
      }
      if (candidates.length === 0) {
        candidates = rawPool;
      }

      // 5. Select next action
      const nextAction = candidates[Math.floor(Math.random() * candidates.length)];

      // 6. Apply state cooldown rules (e.g. napping cannot repeat for 4 cycles)
      if (nextAction === 'napping') memory.cooldowns.set('napping', 4);
      if (nextAction === 'drinking_coffee') memory.cooldowns.set('drinking_coffee', 3);
      if (nextAction === 'stretching') memory.cooldowns.set('stretching', 2);
      if (nextAction === 'afk_hiding') memory.cooldowns.set('afk_hiding', 5);

      // 7. Update behavior memory
      memory.lastState = memory.currentState;
      memory.currentState = nextAction;
      memory.historyQueue.push(nextAction);
      if (memory.historyQueue.length > 4) memory.historyQueue.shift();

      currentActionRef.current = nextAction;
      actionTimerRef.current = Math.floor(Math.random() * 40) + 30; // 3-7 seconds
    };

    const render = (now: number) => {
      animationId = requestAnimationFrame(render);

      const elapsed = now - lastTime;
      if (elapsed < frameInterval) return;
      lastTime = now - (elapsed % frameInterval);

      frameRef.current = (frameRef.current + 1) % 60;
      const frame = frameRef.current;

      // Update Action Timer
      actionTimerRef.current -= 1;
      if (actionTimerRef.current <= 0 && !isAfk) {
        selectNextAction();
      }

      const action = isAfk ? 'afk_hiding' : currentActionRef.current;

      // --- CLEAR CANVAS ---
      ctx.clearRect(0, 0, width, height);

      // --- 1. ROOM WALLPAPER & STARS ---
      ctx.fillStyle = '#0f172a';
      ctx.fillRect(0, 0, width, height);

      ctx.fillStyle = '#1e293b';
      for (let i = 10; i < width; i += 30) {
        for (let j = 10; j < height - 30; j += 30) {
          ctx.fillRect(i, j, 2, 2);
        }
      }

      // --- 2. 2D PIXEL PLATFORM FLOOR ---
      const platformY = height - 28;
      ctx.fillStyle = '#1e1b4b';
      ctx.fillRect(0, platformY, width, 28);
      ctx.fillStyle = '#4f46e5';
      ctx.fillRect(0, platformY, width, 4);
      ctx.fillStyle = '#818cf8';
      for (let x = 0; x < width; x += 8) {
        ctx.fillRect(x, platformY, 4, 2);
      }

      // --- 3. WORKSTATION FURNITURE ---
      const deskX = width - 70;
      const deskY = platformY - 24;

      ctx.fillStyle = '#312e81';
      ctx.fillRect(deskX, deskY, 45, 24);
      ctx.fillStyle = '#4338ca';
      ctx.fillRect(deskX, deskY, 45, 4);

      ctx.fillStyle = '#64748b';
      ctx.fillRect(deskX + 12, deskY - 18, 22, 18);
      ctx.fillStyle = status === 'running' && mode === 'work' ? '#38bdf8' : '#0284c7';
      ctx.fillRect(deskX + 14, deskY - 16, 18, 14);

      if (status === 'running' && mode === 'work') {
        ctx.fillStyle = '#ffffff';
        const lineOffset = (frame % 3) * 3;
        ctx.fillRect(deskX + 16, deskY - 14 + lineOffset, 8, 2);
        ctx.fillRect(deskX + 16, deskY - 10 + lineOffset, 12, 2);
      }

      ctx.fillStyle = '#475569';
      ctx.fillRect(deskX - 14, deskY + 6, 12, 18);
      ctx.fillRect(deskX - 16, deskY - 6, 4, 20);

      // --- 4. ORGANIC UNPREDICTABLE PET RENDERER ---
      let drawX = petXRef.current;
      let drawY = platformY - 16;

      if (action === 'afk_hiding') {
        if (petXRef.current > -20) {
          petXRef.current -= 1.5;
        }
        drawX = petXRef.current;
        drawY = platformY - 16 - Math.abs(Math.sin(frame * 0.4) * 3);

        ctx.fillStyle = '#64748b';
        ctx.fillRect(drawX, drawY, 16, 14);
      } else if (action === 'typing_laptop') {
        drawX = deskX - 10;
        drawY = deskY + 2 + (frame % 2 === 0 ? 0 : -1);

        ctx.fillStyle = '#a855f7';
        ctx.fillRect(drawX, drawY, 16, 14);
        ctx.fillStyle = '#c084fc';
        ctx.fillRect(drawX + 2, drawY + 2, 12, 4);

        ctx.fillStyle = '#fbbf24';
        ctx.fillRect(drawX + 8, drawY + 3, 6, 5);
        ctx.fillStyle = '#38bdf8';
        ctx.fillRect(drawX + 9, drawY + 4, 4, 3);

        ctx.fillStyle = '#c084fc';
        ctx.fillRect(drawX + 14, drawY + (frame % 2 === 0 ? 10 : 9), 4, 3);
      } else if (action === 'drinking_coffee') {
        drawX = deskX - 10;
        drawY = deskY + 2;

        ctx.fillStyle = '#a855f7';
        ctx.fillRect(drawX, drawY, 16, 14);

        ctx.fillStyle = '#f59e0b';
        ctx.fillRect(drawX + 12, drawY + 4, 5, 7);
        ctx.fillStyle = '#ffffff';
        ctx.fillRect(drawX + 13, drawY + 2, 3, 2);
      } else if (action === 'micro_dance') {
        drawX = 50 + (frame % 4 === 0 ? 2 : -2);
        drawY = platformY - 18 - Math.abs(Math.sin(frame * 0.5) * 4);

        ctx.fillStyle = '#ec4899';
        ctx.fillRect(drawX, drawY, 16, 14);
        ctx.fillStyle = '#f472b6';
        ctx.fillRect(drawX + 2, drawY + 2, 12, 4);

        ctx.fillStyle = '#fbbf24';
        ctx.font = '9px monospace';
        ctx.fillText('♪', drawX + 16, drawY - 4);
      } else if (action === 'reading_book') {
        drawX = 60;
        drawY = platformY - 16;

        ctx.fillStyle = '#8b5cf6';
        ctx.fillRect(drawX, drawY, 16, 14);

        ctx.fillStyle = '#38bdf8';
        ctx.fillRect(drawX + 10, drawY + 4, 8, 8);
        ctx.fillStyle = '#ffffff';
        ctx.fillRect(drawX + 12, drawY + 5, 4, 6);
      } else if (action === 'walking') {
        petXRef.current += petDirectionRef.current * 0.8;
        if (petXRef.current > deskX - 30) petDirectionRef.current = -1;
        if (petXRef.current < 20) petDirectionRef.current = 1;

        drawX = petXRef.current;
        drawY = platformY - 16 - Math.abs(Math.sin(frame * 0.3) * 3);

        ctx.fillStyle = '#ec4899';
        ctx.fillRect(drawX, drawY, 16, 14);
      } else if (action === 'napping') {
        drawX = 50;
        drawY = platformY - 12;

        ctx.fillStyle = '#8b5cf6';
        ctx.fillRect(drawX, drawY, 18, 10);

        ctx.fillStyle = '#94a3b8';
        ctx.font = '8px monospace';
        ctx.fillText('z', drawX + 18, drawY - (frame % 8));
      } else {
        drawX = 60;
        drawY = platformY - 16 + (Math.floor(frame / 6) % 2 === 0 ? 0 : 1);

        ctx.fillStyle = '#8b5cf6';
        ctx.fillRect(drawX, drawY, 16, 14);
        ctx.fillStyle = '#a78bfa';
        ctx.fillRect(drawX + 2, drawY + 2, 12, 4);

        ctx.fillStyle = '#ffffff';
        ctx.fillRect(drawX + 3, drawY + 4, 4, 4);
        ctx.fillRect(drawX + 9, drawY + 4, 4, 4);
        ctx.fillStyle = '#0f172a';
        ctx.fillRect(drawX + 4, drawY + 5, 2, 2);
        ctx.fillRect(drawX + 10, drawY + 5, 2, 2);
      }

      // --- 5. RENDER PIXEL SPEECH THOUGHT BUBBLE ---
      if (currentThought && action !== 'afk_hiding') {
        const bubbleX = Math.max(10, Math.min(width - 110, drawX - 30));
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
    };

    animationId = requestAnimationFrame(render);

    return () => {
      cancelAnimationFrame(animationId);
    };
  }, [mode, status, isAfk, width, height, currentThought]);

  return (
    <div className="relative rounded-xl overflow-hidden border border-indigo-500/20 shadow-inner">
      <canvas
        ref={canvasRef}
        width={width}
        height={height}
        style={{
          imageRendering: 'pixelated',
          width: `${width}px`,
          height: `${height}px`,
        }}
      />
    </div>
  );
};
