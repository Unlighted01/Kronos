import { RoomDoor, drawRoomDoors } from '../doorRenderer';
import {
  PALETTES,
  drawPixelRect,
  drawWoodGrain,
  drawPseudo3DBox,
  drawPixelSphere,
  drawFabric,
} from '../pixelArtEngine';

export interface LibraryObjectStates {
  globeSpinBoost?: number;
  isCandleLit?: boolean;
}

export function renderAtticLibrary(
  ctx: CanvasRenderingContext2D,
  width: number,
  height: number,
  frame: number,
  _mode?: string,
  _status?: string,
  doors: RoomDoor[] = [],
  hoveredDoorId?: string | null,
  objectStates: LibraryObjectStates = {}
): { platformY: number; deskX: number; deskY: number } {
  const platformY = height - 28;
  const deskX = width - 65;
  const deskY = platformY - 24;

  // Wall
  drawWoodGrain(ctx, 0, 0, width, platformY, PALETTES.darkWalnut, 14);

  // Ceiling beams
  ctx.fillStyle = PALETTES.darkWalnut.shadow;
  ctx.beginPath();
  ctx.moveTo(0, 0);
  ctx.lineTo(width / 2, 30);
  ctx.lineTo(width, 0);
  ctx.fill();
  drawWoodGrain(ctx, 0, 0, width, 10, PALETTES.darkWalnut, 4);

  // Floor
  drawWoodGrain(ctx, 0, platformY, width, 28, PALETTES.oakWood, 7);

  // Stained glass window
  const winX = width / 2 - 20;
  const winY = 40;
  drawPixelRect(ctx, winX, winY, 40, 60, PALETTES.iron);
  ctx.fillStyle = '#1e3a8a'; ctx.fillRect(winX + 2, winY + 2, 17, 27);
  ctx.fillStyle = '#9f1239'; ctx.fillRect(winX + 21, winY + 2, 17, 27);
  ctx.fillStyle = '#ca8a04'; ctx.fillRect(winX + 2, winY + 31, 17, 27);
  ctx.fillStyle = '#065f46'; ctx.fillRect(winX + 21, winY + 31, 17, 27);

  // Light shafts
  ctx.fillStyle = 'rgba(253, 224, 71, 0.1)';
  ctx.beginPath();
  ctx.moveTo(winX, winY + 60);
  ctx.lineTo(winX - 30, platformY + 10);
  ctx.lineTo(winX + 70, platformY + 10);
  ctx.lineTo(winX + 40, winY + 60);
  ctx.fill();

  // Bookshelves (left wall)
  const shelfW = 60;
  drawPixelRect(ctx, 10, 20, shelfW, platformY - 20, PALETTES.darkWalnut);
  const bookColors = ['#7f1d1d', '#1e3a8a', '#064e3b', '#78350f', '#4c1d95', '#9f1239'];
  for (let sy = 30; sy < platformY; sy += 20) {
    drawPixelRect(ctx, 10, sy, shelfW, 4, PALETTES.darkWalnut); // shelf board
    let bx = 12;
    while (bx < 10 + shelfW - 4) {
      const bw = 3 + (Math.floor(bx * 7.3) % 3);
      const bh = 10 + (Math.floor(bx * 3.1) % 5);
      const cIdx = Math.floor(bx * 1.7) % bookColors.length;
      drawPixelRect(ctx, bx, sy - bh, bw, bh, { highlight: '#d1d5db', mid: bookColors[cIdx], shadow: '#000', outline: '#000' });
      bx += bw + 1;
    }
  }

  // Globe
  const glX = 80;
  const glY = platformY - 20;
  drawPixelRect(ctx, glX - 4, glY + 10, 8, 10, PALETTES.cream); // stand
  drawPixelSphere(ctx, glX, glY, 10, { highlight: '#93c5fd', mid: '#3b82f6', shadow: '#1d4ed8', outline: '#1e3a8a' });
  ctx.strokeStyle = '#10b981'; // landmass mock
  ctx.beginPath();
  ctx.arc(glX - 2, glY - 2, 4, 0, Math.PI);
  ctx.stroke();
  ctx.strokeStyle = 'rgba(255,255,255,0.2)'; // lat/lon
  ctx.beginPath();
  ctx.arc(glX, glY, 10, 0, Math.PI, false);
  ctx.stroke();

  // Candle
  const cx = glX + 20;
  const cy = platformY - 10;
  drawPixelRect(ctx, cx, cy, 6, 10, { highlight: '#fef9c3', mid: '#fef08a', shadow: '#ca8a04', outline: '#92400e' });
  ctx.fillStyle = '#000'; ctx.fillRect(cx + 2, cy - 2, 1, 2); // wick
  if (objectStates.isCandleLit) {
    const fH = 4 + Math.sin(frame * 0.2) * 2;
    ctx.fillStyle = '#ea580c';
    ctx.fillRect(cx + 2, cy - 2 - fH, 2, fH);
    ctx.fillStyle = '#fbbf24';
    ctx.fillRect(cx + 2, cy - 2 - fH + 1, 1, fH - 1);
  } else {
    ctx.fillStyle = 'rgba(156, 163, 175, 0.5)';
    ctx.fillRect(cx + 2 + Math.sin(frame*0.1)*2, cy - 6 - (frame%20)*0.5, 1, 2);
  }

  // Armchair & Desk
  drawPseudo3DBox(ctx, deskX, deskY, 40, 24, 4, PALETTES.darkWalnut); // desk
  const chairX = deskX + 44;
  const chairY = deskY + 4;
  drawFabric(ctx, chairX, chairY, 20, 16, { highlight: '#fb7185', mid: '#e11d48', shadow: '#9f1239', outline: '#4c0519' }, 4);
  drawPseudo3DBox(ctx, chairX - 2, chairY + 6, 4, 10, 2, PALETTES.darkWalnut); // armrest

  // Dust motes
  ctx.fillStyle = 'rgba(255, 255, 255, 0.4)';
  for (let i = 0; i < 8; i++) {
    const mx = (frame * 0.2 + i * 30) % width;
    const my = (Math.sin(frame * 0.02 + i) * 20) + platformY - 40;
    ctx.fillRect(mx, my, 1, 1);
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
