import { RoomDoor, drawRoomDoors } from '../doorRenderer';
import {
  PALETTES,
  drawPixelRect,
  drawWoodGrain,
  drawTileFloor,
  drawPseudo3DBox,
  drawLeaf
} from '../pixelArtEngine';

export interface GreenhouseObjectStates {
  plantBloomStage?: number;
}

export function renderGreenhouse(
  ctx: CanvasRenderingContext2D,
  width: number,
  height: number,
  frame: number,
  _mode?: string,
  _status?: string,
  doors: RoomDoor[] = [],
  hoveredDoorId?: string | null,
  objectStates: GreenhouseObjectStates = {}
): { platformY: number; deskX: number; deskY: number } {
  const platformY = height - 28;
  const deskX = width - 68;
  const deskY = platformY - 24;

  // Ceiling/walls
  ctx.fillStyle = 'rgba(186, 230, 253, 0.15)';
  ctx.fillRect(0, 0, width, platformY);
  for (let px = 0; px < width; px += 30) {
    drawPixelRect(ctx, px, 0, 4, platformY, PALETTES.glass);
  }
  for (let py = 0; py < platformY; py += 30) {
    drawPixelRect(ctx, 0, py, width, 4, PALETTES.glass);
  }

  // Sunbeam shafts
  ctx.fillStyle = 'rgba(253, 224, 71, 0.1)';
  ctx.beginPath();
  ctx.moveTo(20, 0); ctx.lineTo(width / 2 + 20, platformY);
  ctx.lineTo(width / 2 - 20, platformY); ctx.lineTo(0, 0);
  ctx.fill();

  // Floor
  drawTileFloor(ctx, 0, platformY, width, 28, '#6b7280', '#9ca3af', '#374151', 8);

  // Large Monstera
  const mx = 30;
  const my = platformY;
  ctx.fillStyle = '#14532d'; // stems
  ctx.fillRect(mx, my - 60, 2, 60);
  ctx.fillRect(mx - 10, my - 40, 10, 2);
  ctx.fillRect(mx + 2, my - 30, 12, 2);
  drawLeaf(ctx, mx - 16, my - 46, '#15803d', '#14532d', 10);
  drawLeaf(ctx, mx - 8, my - 66, '#16a34a', '#14532d', 12);
  drawLeaf(ctx, mx + 8, my - 38, '#4ade80', '#14532d', 14);

  // Potting bench
  drawPseudo3DBox(ctx, deskX, deskY, 50, 24, 4, PALETTES.oakWood);
  drawWoodGrain(ctx, deskX, deskY, 50, 4, PALETTES.oakWood, 4);

  // Small flowering pots
  const potX = deskX + 4;
  const potY = deskY - 8;
  for(let i=0; i<3; i++) {
    const px = potX + i * 14;
    drawPixelRect(ctx, px, potY + 2, 8, 6, PALETTES.terracotta);
    drawPixelRect(ctx, px - 1, potY, 10, 2, PALETTES.terracotta); // rim
    
    // Plant stages
    const stage = objectStates.plantBloomStage || 0;
    if (stage >= 1) {
      ctx.fillStyle = '#16a34a'; ctx.fillRect(px + 3, potY - 4, 2, 4); // sprout
    }
    if (stage >= 2) {
      ctx.beginPath(); ctx.arc(px + 4, potY - 6, 2, 0, Math.PI*2); ctx.fill(); // bud
    }
    if (stage >= 3 && i === 1) { // bloom one specifically
      ctx.fillStyle = '#f472b6'; // pink petal
      ctx.fillRect(px + 2, potY - 8, 4, 4);
      ctx.fillStyle = '#fef08a'; // yellow center
      ctx.fillRect(px + 3, potY - 7, 2, 2);
    }
  }

  // Watering can
  const wcX = deskX + 40;
  const wcY = deskY - 10;
  drawPixelRect(ctx, wcX, wcY, 8, 10, { highlight: '#4ade80', mid: '#16a34a', shadow: '#14532d', outline: '#064e3b' }); // body
  ctx.fillStyle = '#16a34a'; ctx.fillRect(wcX - 6, wcY + 2, 6, 2); // spout
  ctx.strokeStyle = '#16a34a'; ctx.beginPath(); ctx.arc(wcX + 8, wcY + 4, 3, -Math.PI/2, Math.PI/2); ctx.stroke(); // handle

  // Butterflies
  for (let i = 0; i < 2; i++) {
    const bx = 60 + i * 40 + Math.sin(frame * 0.05 + i) * 20;
    const by = 40 + Math.cos(frame * 0.03 + i) * 15;
    const wingFlap = Math.sin(frame * 0.5 + i) > 0;
    
    ctx.fillStyle = i === 0 ? '#38bdf8' : '#fbbf24'; // blue or yellow
    if (wingFlap) {
      ctx.fillRect(bx, by, 4, 3); // upper
      ctx.fillRect(bx + 1, by + 3, 3, 2); // lower
    } else {
      ctx.fillRect(bx, by + 1, 2, 4); // closed wing
    }
  }

  // Fairy lights
  ctx.strokeStyle = '#1e293b';
  ctx.lineWidth = 1;
  ctx.beginPath();
  ctx.moveTo(0, 5);
  ctx.quadraticCurveTo(width / 4, 15, width / 2, 5);
  ctx.quadraticCurveTo((width * 3) / 4, 15, width, 5);
  ctx.stroke();

  const pulse = Math.sin(frame * 0.05) * 0.5 + 0.5;
  for (let i = 0; i <= 12; i++) {
    const lx = (width / 12) * i;
    const progress = (i % 6) / 6;
    const ly = 5 + Math.sin(progress * Math.PI) * 10;
    
    drawPixelRect(ctx, lx - 1, ly - 2, 3, 2, PALETTES.iron);
    ctx.fillStyle = `rgba(251, 191, 36, ${0.15 + pulse * 0.15})`;
    ctx.beginPath();
    ctx.arc(lx, ly + 1, 4, 0, Math.PI * 2);
    ctx.fill();
    ctx.fillStyle = '#fbbf24';
    ctx.fillRect(lx, ly, 1, 1);
  }

  drawRoomDoors(ctx, doors, frame, hoveredDoorId);

  return { platformY, deskX, deskY };
}
