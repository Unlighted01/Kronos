import { RoomDoor, drawRoomDoors } from '../doorRenderer';
import {
  PALETTES,
  drawPixelRect,
  drawWoodGrain,
  drawBrickWall,
  drawPseudo3DBox,
  drawFabric,
  dither,
} from '../pixelArtEngine';

export interface LivingRoomObjectStates {
  firePokedTimer?: number;
  vinylSpinBoost?: number;
  isArcLampOn?: boolean;
  paintingTilt?: number;
}

export function renderLivingRoom(
  ctx: CanvasRenderingContext2D,
  width: number,
  height: number,
  frame: number,
  _mode?: string,
  _status?: string,
  doors: RoomDoor[] = [],
  hoveredDoorId?: string | null,
  objectStates: LivingRoomObjectStates = {}
): { platformY: number; deskX: number; deskY: number } {
  const platformY = height - 28;
  const deskX = 170;
  const deskY = 88;

  // Wall upper
  drawBrickWall(ctx, 0, 0, width, platformY - 40, PALETTES.plaster, 8, 16);
  // Wall lower wainscoting
  drawWoodGrain(ctx, 0, platformY - 40, width, 40, PALETTES.darkWalnut, 10);
  // Vertical panel joints
  ctx.fillStyle = PALETTES.darkWalnut.shadow;
  for (let px = 0; px < width; px += 20) {
    ctx.fillRect(px, platformY - 40, 1, 40);
  }

  // Floor
  drawWoodGrain(ctx, 0, platformY, width, height - platformY, PALETTES.darkWalnut, 8);

  // Rug
  const rugX = 90;
  const rugY = platformY + 10;
  ctx.fillStyle = '#cbd5e1';
  ctx.beginPath();
  ctx.ellipse(rugX, rugY, 40, 10, 0, 0, Math.PI * 2);
  ctx.fill();
  ctx.fillStyle = '#94a3b8';
  ctx.beginPath();
  ctx.ellipse(rugX, rugY, 30, 7, 0, 0, Math.PI * 2);
  ctx.fill();

  // Fireplace
  const fpX = 120;
  const fpY = platformY - 46;
  const fpW = 44;
  const fpH = 46;
  drawBrickWall(ctx, fpX, fpY, fpW, fpH, PALETTES.brick, 6, 12);
  // Mantlepiece
  drawPixelRect(ctx, fpX - 4, fpY - 6, fpW + 8, 6, PALETTES.stone);
  // Firebox
  const boxX = fpX + 10;
  const boxY = fpY + 20;
  drawPixelRect(ctx, boxX - 2, boxY - 2, 28, 28, PALETTES.iron); // frame
  ctx.fillStyle = '#000';
  ctx.fillRect(boxX, boxY, 24, 26); // inner
  // Fire animation
  const poke = objectStates.firePokedTimer && objectStates.firePokedTimer > 0 ? 1 : 0;
  const fireH = 12 + poke * 6 + Math.sin(frame * 0.3) * 4;
  ctx.fillStyle = '#ea580c';
  ctx.fillRect(boxX + 4, boxY + 26 - fireH, 16, fireH);
  ctx.fillStyle = '#fbbf24';
  ctx.fillRect(boxX + 6, boxY + 26 - fireH + 4, 12, fireH - 4);

  // Sofa (left)
  const sofaX = 20;
  const sofaY = platformY - 18;
  drawFabric(ctx, sofaX, sofaY, 48, 18, { highlight: '#94a3b8', mid: '#64748b', shadow: '#475569', outline: '#1e293b' }, 8);
  drawPseudo3DBox(ctx, sofaX - 4, sofaY + 4, 8, 14, 2, PALETTES.slate); // left arm
  drawPseudo3DBox(ctx, sofaX + 44, sofaY + 4, 8, 14, 2, PALETTES.slate); // right arm
  // Legs
  drawPixelRect(ctx, sofaX + 2, sofaY + 18, 2, 4, PALETTES.darkWalnut);
  drawPixelRect(ctx, sofaX + 44, sofaY + 18, 2, 4, PALETTES.darkWalnut);
  // Pillows
  drawPixelRect(ctx, sofaX + 4, sofaY + 6, 8, 8, { highlight: '#fef08a', mid: '#eab308', shadow: '#a16207', outline: '#422006' });
  drawPixelRect(ctx, sofaX + 36, sofaY + 6, 8, 8, PALETTES.brick);

  // Arc lamp
  ctx.strokeStyle = '#9ca3af';
  ctx.lineWidth = 2;
  ctx.beginPath();
  ctx.moveTo(10, platformY);
  ctx.quadraticCurveTo(10, sofaY - 40, 40, sofaY - 20);
  ctx.stroke();
  drawPixelRect(ctx, 34, sofaY - 22, 12, 6, PALETTES.iron);
  if (objectStates.isArcLampOn) {
    dither(ctx, 20, sofaY - 16, 40, 20, 'rgba(253, 224, 71, 0.3)', 0.5);
  }

  // Credenza (right)
  const credX = deskX;
  const credY = deskY;
  drawPseudo3DBox(ctx, credX, credY, 40, 24, 4, PALETTES.darkWalnut);
  drawWoodGrain(ctx, credX, credY, 40, 4, PALETTES.oakWood, 4); // top surface
  // Drawers
  drawPixelRect(ctx, credX + 2, credY + 6, 17, 8, PALETTES.darkWalnut);
  drawPixelRect(ctx, credX + 21, credY + 6, 17, 8, PALETTES.darkWalnut);
  drawPixelRect(ctx, credX + 2, credY + 15, 17, 8, PALETTES.darkWalnut);
  drawPixelRect(ctx, credX + 21, credY + 15, 17, 8, PALETTES.darkWalnut);
  // Handles
  ctx.fillStyle = '#d1d5db';
  ctx.fillRect(credX + 9, credY + 9, 3, 2);
  ctx.fillRect(credX + 28, credY + 9, 3, 2);
  ctx.fillRect(credX + 9, credY + 18, 3, 2);
  ctx.fillRect(credX + 28, credY + 18, 3, 2);

  // Vinyl turntable
  const ttX = credX + 8;
  const ttY = credY - 4;
  drawPixelRect(ctx, ttX, ttY, 24, 4, PALETTES.slate); // base
  // Platter
  ctx.fillStyle = '#000';
  ctx.beginPath();
  ctx.ellipse(ttX + 12, ttY, 10, 3, 0, 0, Math.PI * 2);
  ctx.fill();
  // Grooves
  ctx.strokeStyle = '#333';
  ctx.lineWidth = 1;
  ctx.beginPath();
  ctx.ellipse(ttX + 12, ttY, 8, 2, 0, 0, Math.PI * 2);
  ctx.stroke();
  ctx.beginPath();
  ctx.ellipse(ttX + 12, ttY, 5, 1.5, 0, 0, Math.PI * 2);
  ctx.stroke();
  // Label
  const spin = ((frame + (objectStates.vinylSpinBoost || 0)) * 0.1) % (Math.PI * 2);
  ctx.fillStyle = '#ef4444';
  ctx.beginPath();
  ctx.ellipse(ttX + 12, ttY, 3, 1, 0, 0, Math.PI * 2);
  ctx.fill();
  ctx.fillStyle = '#fff';
  ctx.fillRect(ttX + 12 + Math.cos(spin)*1, ttY + Math.sin(spin)*0.5, 1, 1);

  // Floating music notes
  if ((frame % 100) < 50) {
    ctx.fillStyle = '#3b82f6';
    ctx.fillText('♫', ttX + 12, ttY - 10 - (frame % 20) * 0.5);
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
