import { drawWindowSky, getTimeOfDay } from '../dayNightEngine';
import { RoomDoor, drawRoomDoors } from '../doorRenderer';
import {
  PALETTES,
  drawPixelRect,
  drawWoodGrain,
  drawBrickWall,
  drawPseudo3DBox,
  drawPixelSphere,
  drawFabric,
  drawLeaf,
  dither
} from '../pixelArtEngine';

export interface BedroomObjectStates {
  isDeskLampOn?: boolean;
  clockChimeTimer?: number;
}

export function renderStudyBedroom(
  ctx: CanvasRenderingContext2D,
  width: number,
  height: number,
  frame: number,
  _mode?: string,
  _status?: string,
  doors: RoomDoor[] = [],
  hoveredDoorId?: string | null,
  objectStates: BedroomObjectStates = {}
): { platformY: number; deskX: number; deskY: number } {
  const timeOfDay = getTimeOfDay();
  const platformY = height - 28;
  const deskX = width - 80;
  const deskY = platformY - 24;

  // Wall
  drawBrickWall(ctx, 0, 0, width, platformY, {
    highlight: '#312e81',
    mid: '#1e1b4b',
    shadow: '#171438',
    outline: '#0f0d23'
  }, 6, 16);

  // Floor
  drawWoodGrain(ctx, 0, platformY, width, 28, PALETTES.oakWood, 9);

  // Window
  const winW = 36;
  const winH = 42;
  const winX = 14;
  const winY = 12;
  drawWindowSky(ctx, winX, winY, winW, winH, timeOfDay, frame);
  // Architectural frame
  drawPixelRect(ctx, winX - 2, winY - 2, winW + 4, 2, PALETTES.darkWalnut); // top
  drawPixelRect(ctx, winX - 2, winY + winH, winW + 4, 2, PALETTES.darkWalnut); // bottom
  drawPixelRect(ctx, winX - 2, winY, 2, winH, PALETTES.darkWalnut); // left
  drawPixelRect(ctx, winX + winW, winY, 2, winH, PALETTES.darkWalnut); // right
  drawPixelRect(ctx, winX + winW / 2 - 1, winY, 2, winH, PALETTES.darkWalnut); // mullion v
  drawPixelRect(ctx, winX, winY + winH / 2 - 1, winW, 2, PALETTES.darkWalnut); // mullion h

  // Hanging Ivy Vines
  for (let i = 0; i < 3; i++) {
    const sway = Math.sin(frame * 0.05 + i) * 1.5;
    const ivyX = winX + winW + 10 + i * 12 + sway;
    ctx.fillStyle = '#14532d';
    ctx.fillRect(ivyX, 0, 1, 25 - i * 5); // vine stem
    for(let l = 0; l < 5 - i; l++) {
      drawLeaf(ctx, ivyX - 2 + (l%2)*4, 4 + l*5, '#16a34a', '#14532d', 4);
    }
  }

  // Bed (left side)
  const bedX = 8;
  const bedW = 54;
  const bedH = 14;
  const bedY = platformY - bedH;
  // Frame
  drawPseudo3DBox(ctx, bedX, bedY, bedW, bedH, 4, PALETTES.darkWalnut);
  // Headboard
  drawPixelRect(ctx, bedX, platformY - 24, 6, 24, PALETTES.darkWalnut);
  // Pillow
  drawPixelRect(ctx, bedX + 4, bedY - 4, 12, 6, PALETTES.plaster);
  // Quilt
  drawFabric(ctx, bedX + 18, bedY - 3, bedW - 18, bedH + 3, { highlight: '#e11d48', mid: '#be123c', shadow: '#9f1239', outline: '#4c0519' }, 6);

  // Wall Clock
  const clockX = 80;
  const clockY = 16;
  drawPixelRect(ctx, clockX, clockY, 12, 16, PALETTES.oakWood);
  drawPixelSphere(ctx, clockX + 6, clockY + 6, 4, PALETTES.plaster);
  // hands
  ctx.fillStyle = '#000';
  ctx.fillRect(clockX + 6, clockY + 6, 1, 2);
  ctx.fillRect(clockX + 6, clockY + 5, 2, 1);
  // Pendulum
  const pSway = Math.sin(frame * 0.1) * 3;
  ctx.fillStyle = '#ca8a04';
  ctx.fillRect(clockX + 5 + pSway, clockY + 12, 1, 6);
  drawPixelSphere(ctx, clockX + 5 + pSway, clockY + 18, 2, {highlight:'#fef08a', mid:'#ca8a04', shadow:'#713f12', outline:'#422006'});

  // Bedside rug
  const rugX = 40;
  const rugY = platformY + 6;
  ctx.fillStyle = '#64748b';
  ctx.beginPath();
  ctx.ellipse(rugX, rugY, 24, 6, 0, 0, Math.PI * 2);
  ctx.fill();
  dither(ctx, rugX - 18, rugY - 4, 36, 8, '#475569', 0.5);

  // Desk
  drawPseudo3DBox(ctx, deskX, deskY, 50, 24, 3, PALETTES.oakWood);
  
  // Laptop
  drawPixelRect(ctx, deskX + 10, deskY - 8, 14, 10, PALETTES.slate);
  ctx.fillStyle = '#38bdf8'; // screen inner
  ctx.fillRect(deskX + 11, deskY - 7, 12, 8);
  // Typing lines
  ctx.fillStyle = '#e0f2fe';
  const typeLine = (frame % 40) < 20 ? 4 : 8;
  ctx.fillRect(deskX + 12, deskY - 5, typeLine, 1);

  // Desk Lamp
  ctx.fillStyle = '#64748b';
  ctx.fillRect(deskX + 34, deskY - 2, 4, 2);
  ctx.fillRect(deskX + 35, deskY - 10, 2, 8);
  drawPixelRect(ctx, deskX + 31, deskY - 14, 8, 4, PALETTES.iron);
  if (objectStates.isDeskLampOn) {
    dither(ctx, deskX + 26, deskY - 10, 18, 10, 'rgba(253, 224, 71, 0.4)', 0.5);
  }

  // Chair
  const chairX = deskX + 24;
  const chairY = deskY + 6;
  drawPixelRect(ctx, chairX, chairY, 12, 4, PALETTES.slate);
  drawPixelRect(ctx, chairX + 2, chairY - 8, 8, 8, PALETTES.slate);
  ctx.fillStyle = PALETTES.iron.outline;
  ctx.fillRect(chairX + 4, chairY + 4, 1, 14);
  ctx.fillRect(chairX + 7, chairY + 4, 1, 14);

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
