import { RoomDoor, drawRoomDoors } from '../doorRenderer';

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

  // 1. Rustic Exposed Red Brick Wall
  ctx.fillStyle = '#451a03';
  ctx.fillRect(0, 0, width, platformY);

  ctx.fillStyle = '#7c2d12';
  for (let y = 4; y < platformY; y += 10) {
    const isOdd = Math.floor(y / 10) % 2 === 1;
    const offset = isOdd ? 10 : 0;
    for (let x = -10 + offset; x < width; x += 20) {
      ctx.fillRect(x, y, 18, 8);
      ctx.fillStyle = '#9a3412';
      ctx.fillRect(x, y, 18, 2); // Brick highlight
      ctx.fillStyle = '#7c2d12';
    }
  }

  // 2. Hanging Copper Pots & Utensil Rack
  ctx.fillStyle = '#292524';
  ctx.fillRect(16, 12, 60, 2);

  // Copper Pans with Highlights
  ctx.fillStyle = '#ea580c';
  ctx.beginPath();
  ctx.arc(28, 22, 5, 0, Math.PI * 2);
  ctx.fill();
  ctx.fillStyle = '#f97316';
  ctx.fillRect(26, 19, 2, 2); // Shimmer
  ctx.fillStyle = '#ea580c';
  ctx.fillRect(27, 14, 2, 8);

  ctx.beginPath();
  ctx.arc(46, 24, 7, 0, Math.PI * 2);
  ctx.fill();
  ctx.fillStyle = '#f97316';
  ctx.fillRect(43, 20, 3, 2);
  ctx.fillStyle = '#ea580c';
  ctx.fillRect(45, 14, 2, 10);

  ctx.beginPath();
  ctx.arc(64, 20, 4, 0, Math.PI * 2);
  ctx.fill();
  ctx.fillRect(63, 14, 2, 6);

  // 3. Brick Baking Oven / Hearth with Fire Glow & Steam
  const ovenX = 12;
  const ovenY = platformY - 36;
  ctx.fillStyle = '#292524';
  ctx.fillRect(ovenX, ovenY, 44, 36);
  ctx.fillStyle = '#7c2d12';
  ctx.strokeRect(ovenX, ovenY, 44, 36);

  // Fire Chamber Arched Opening
  ctx.fillStyle = '#0f172a';
  ctx.fillRect(ovenX + 8, ovenY + 12, 28, 24);

  // Glowing Iron Grate
  ctx.fillStyle = '#1c1917';
  for(let i=0; i<4; i++) {
    ctx.fillRect(ovenX + 10 + i*6, ovenY + 24, 2, 12);
  }

  // Animated Hearth Fire (Pulsing warm glow)
  const fireFlicker = (frame % 4) * 2;
  ctx.globalCompositeOperation = 'lighten';
  ctx.fillStyle = '#ef4444';
  ctx.fillRect(ovenX + 12, ovenY + 20 - fireFlicker, 20, 14);
  ctx.fillStyle = '#f97316';
  ctx.fillRect(ovenX + 14, ovenY + 22 - fireFlicker, 16, 12);
  ctx.fillStyle = '#fbbf24';
  ctx.fillRect(ovenX + 16, ovenY + 25 - fireFlicker, 12, 9);
  ctx.globalCompositeOperation = 'source-over';

  // Animated Steam Motes rising from chimney
  ctx.fillStyle = 'rgba(255, 255, 255, 0.6)';
  const steamY = ovenY - 6 - (frame % 15);
  ctx.fillRect(ovenX + 20 + Math.sin(frame * 0.2) * 3, steamY, 3, 3);
  ctx.fillRect(ovenX + 24 + Math.cos(frame * 0.2) * 3, steamY - 6, 2, 2);

  // 4. Terracotta Checkered Floor
  ctx.fillStyle = '#9a3412';
  ctx.fillRect(0, platformY, width, 28);

  const tileSize = 14;
  for (let x = 0; x < width; x += tileSize) {
    for (let y = platformY; y < height; y += tileSize) {
      if ((Math.floor(x / tileSize) + Math.floor(y / tileSize)) % 2 === 0) {
        ctx.fillStyle = '#c2410c';
        ctx.fillRect(x, y, tileSize, tileSize);
        ctx.fillStyle = '#ea580c';
        ctx.fillRect(x, y, tileSize, 1.5);
      }
    }
  }

  // 5. Kitchen Counter & Pastry Bar (Right)
  const deskX = width - 70;
  const deskY = platformY - 24;

  ctx.fillStyle = '#78350f';
  ctx.fillRect(deskX, deskY, 45, 24);
  ctx.fillStyle = '#f8fafc';
  ctx.fillRect(deskX, deskY, 45, 3); // White Marble countertop

  // Espresso Coffee Machine
  ctx.fillStyle = '#475569';
  ctx.fillRect(deskX + 22, deskY - 16, 16, 16);
  ctx.fillStyle = '#38bdf8';
  ctx.fillRect(deskX + 26, deskY - 12, 8, 6); // Pressure gauge
  ctx.fillStyle = '#e2e8f0';
  ctx.fillRect(deskX + 20, deskY - 6, 4, 3); // Chrome Portafilter

  // Coffee Mug with animated steam curls
  ctx.fillStyle = '#f8fafc';
  ctx.fillRect(deskX + 22, deskY - 4, 4, 4);
  ctx.fillStyle = 'rgba(255,255,255,0.7)';
  const sOffset = Math.sin(frame * 0.1) * 2;
  const sHeight = (frame % 15) * 0.5;
  ctx.font = '8px sans-serif';
  ctx.fillText('~', deskX + 22 + sOffset, deskY - 6 - sHeight);

  // Detailed Pastry Display (Glass dome)
  ctx.fillStyle = 'rgba(255,255,255,0.2)';
  ctx.beginPath(); ctx.arc(deskX + 10, deskY, 9, Math.PI, 0); ctx.fill();

  // Fresh Golden Croissants & Baguettes
  ctx.fillStyle = '#d97706';
  ctx.fillRect(deskX + 4, deskY - 5, 6, 3); // Croissant
  ctx.fillStyle = '#fbbf24';
  ctx.fillRect(deskX + 5, deskY - 5, 4, 1); // Glaze

  ctx.fillStyle = '#b45309';
  ctx.fillRect(deskX + 11, deskY - 6, 2, 5); // Baguette
  ctx.fillStyle = '#f59e0b';
  ctx.fillRect(deskX + 11, deskY - 5, 1, 1);
  ctx.fillRect(deskX + 11, deskY - 3, 1, 1);

  // Stool
  ctx.fillStyle = '#92400e';
  ctx.fillRect(deskX - 14, deskY + 6, 10, 18);
  ctx.fillStyle = '#b45309';
  ctx.fillRect(deskX - 16, deskY + 4, 14, 3);

  drawRoomDoors(ctx, doors, frame, hoveredDoorId);

  return { platformY, deskX, deskY };
}
