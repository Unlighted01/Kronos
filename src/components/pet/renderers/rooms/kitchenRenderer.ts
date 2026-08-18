import { RoomDoor, drawRoomDoors } from '../doorRenderer';
import {
  PALETTES,
  drawPixelRect,
  drawWoodGrain,
  drawTileFloor,
  drawPseudo3DBox,
  drawPixelSphere
} from '../pixelArtEngine';

export function renderWarmKitchen(
  ctx: CanvasRenderingContext2D,
  width: number,
  height: number,
  frame: number,
  _mode?: string,
  _status?: string,
  doors: RoomDoor[] = [],
  hoveredDoorId?: string | null
): { platformY: number; deskX: number; deskY: number } {
  const platformY = height - 28;
  const deskX = width - 70;
  const deskY = platformY - 24;

  // Wall
  drawTileFloor(ctx, 0, 0, width, platformY, '#fef9c3', '#fef08a', '#d97706', 8);

  // Floor
  drawTileFloor(ctx, 0, platformY, width, 28, '#ea580c', '#fef9c3', '#451a03', 8);

  // Oven (left)
  const ovenX = 20;
  const ovenY = platformY - 30;
  const ovenW = 36;
  const ovenH = 30;
  drawPixelRect(ctx, ovenX, ovenY, ovenW, ovenH, PALETTES.iron);
  // Oven door
  drawPixelRect(ctx, ovenX + 4, ovenY + 6, ovenW - 8, 16, PALETTES.slate);
  ctx.fillStyle = '#0f172a'; // inner glow rect
  ctx.fillRect(ovenX + 6, ovenY + 8, ovenW - 12, 12);
  // Hearth fire
  const fH = 6 + Math.sin(frame * 0.3) * 2;
  ctx.fillStyle = '#ea580c';
  ctx.fillRect(ovenX + 10, ovenY + 20 - fH, 12, fH);
  ctx.fillStyle = '#fbbf24';
  ctx.fillRect(ovenX + 12, ovenY + 20 - fH + 2, 8, fH - 2);
  // Burner grates
  drawPixelRect(ctx, ovenX + 6, ovenY - 2, 8, 2, PALETTES.iron);
  drawPixelRect(ctx, ovenX + 22, ovenY - 2, 8, 2, PALETTES.iron);

  // Hanging pans
  const rackY = 10;
  drawPixelRect(ctx, 10, rackY, 60, 2, PALETTES.darkWalnut); // beam
  const copper = { highlight: '#fcd34d', mid: '#d97706', shadow: '#92400e', outline: '#451a03' };
  for (let i = 0; i < 3; i++) {
    const px = 20 + i * 16;
    ctx.fillStyle = PALETTES.iron.mid;
    ctx.fillRect(px, rackY + 2, 1, 6); // chain
    drawPixelSphere(ctx, px, rackY + 12, 5, copper);
    ctx.fillStyle = '#451a03'; ctx.fillRect(px + 5, rackY + 10, 4, 1); // handle
  }

  // Counter
  drawPseudo3DBox(ctx, deskX, deskY, 50, 24, 3, PALETTES.stone);
  drawWoodGrain(ctx, deskX, deskY + 3, 50, 21, PALETTES.oakWood, 7);

  // Coffee mug
  const mugX = deskX + 10;
  const mugY = deskY - 6;
  drawPixelRect(ctx, mugX, mugY, 6, 6, { highlight: '#bfdbfe', mid: '#3b82f6', shadow: '#1d4ed8', outline: '#1e3a8a' });
  ctx.strokeStyle = '#3b82f6';
  ctx.beginPath(); ctx.arc(mugX + 6, mugY + 3, 2, -Math.PI/2, Math.PI/2); ctx.stroke(); // handle
  // Steam
  ctx.strokeStyle = 'rgba(255,255,255,0.6)';
  ctx.beginPath();
  ctx.moveTo(mugX + 3, mugY);
  ctx.quadraticCurveTo(mugX + 1 + Math.sin(frame*0.1)*2, mugY - 4, mugX + 3, mugY - 8);
  ctx.stroke();

  // Pastry display
  const pdX = deskX + 24;
  const pdY = deskY - 8;
  drawPixelRect(ctx, pdX, pdY, 20, 8, PALETTES.glass);
  // Croissant
  ctx.fillStyle = '#d97706';
  ctx.beginPath(); ctx.arc(pdX + 6, pdY + 4, 3, Math.PI, 0); ctx.fill();
  // Baguette
  ctx.fillStyle = '#b45309';
  ctx.fillRect(pdX + 12, pdY + 4, 6, 2);

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
