import { drawWindowSky, getTimeOfDay } from '../dayNightEngine';

export function renderStudyBedroom(
  ctx: CanvasRenderingContext2D,
  width: number,
  height: number,
  frame: number,
  mode: string,
  status: string
): { platformY: number; deskX: number; deskY: number } {
  const timeOfDay = getTimeOfDay();
  const platformY = height - 28;

  // 1. Wallpaper (Warm Indigo Diamond Motif with High Contrast)
  ctx.fillStyle = '#312e81';
  ctx.fillRect(0, 0, width, platformY);

  // Wallpaper Diamond Pattern
  ctx.fillStyle = '#4338ca';
  for (let x = 8; x < width; x += 24) {
    for (let y = 8; y < platformY; y += 24) {
      ctx.fillRect(x + 2, y, 4, 4);
      ctx.fillRect(x, y + 2, 8, 2);
    }
  }

  // 2. Real-Time Day/Night Window (Left Side)
  const winW = 36;
  const winH = 42;
  const winX = 14;
  const winY = 12;
  drawWindowSky(ctx, winX, winY, winW, winH, timeOfDay, frame);

  // 3. Cozy Pixel Wall Painting (Center)
  const artX = 64;
  const artY = 14;
  ctx.fillStyle = '#78350f'; // Wood frame
  ctx.fillRect(artX, artY, 26, 20);
  ctx.fillStyle = '#0f172a'; // Canvas
  ctx.fillRect(artX + 2, artY + 2, 22, 16);

  // Mountain Sunset Mini Pixel Painting
  ctx.fillStyle = '#f97316';
  ctx.fillRect(artX + 2, artY + 2, 22, 8);
  ctx.fillStyle = '#fbbf24';
  ctx.fillRect(artX + 11, artY + 4, 4, 4); // Sun
  ctx.fillStyle = '#4f46e5';
  ctx.beginPath();
  ctx.moveTo(artX + 2, artY + 18);
  ctx.lineTo(artX + 10, artY + 8);
  ctx.lineTo(artX + 18, artY + 18);
  ctx.fill();

  // 4. Cozy Bed with Patchwork Quilt (Far Left Corner)
  const bedX = 8;
  const bedY = platformY - 20;

  // Bed Frame
  ctx.fillStyle = '#78350f';
  ctx.fillRect(bedX, bedY, 44, 20);
  ctx.fillStyle = '#92400e';
  ctx.fillRect(bedX, bedY - 8, 6, 28); // Headboard

  // Pillow
  ctx.fillStyle = '#f8fafc';
  ctx.fillRect(bedX + 8, bedY + 2, 12, 8);
  ctx.fillStyle = '#e2e8f0';
  ctx.fillRect(bedX + 10, bedY + 4, 8, 4);

  // Patchwork Quilt (Pink/Rose/Burgundy blocks)
  ctx.fillStyle = '#f43f5e';
  ctx.fillRect(bedX + 20, bedY + 2, 24, 18);
  ctx.fillStyle = '#fb7185';
  ctx.fillRect(bedX + 24, bedY + 4, 8, 7);
  ctx.fillRect(bedX + 34, bedY + 11, 8, 7);

  // 5. Cozy Floor Rug (Walking Path)
  const rugX = 72;
  const rugY = platformY - 5;
  ctx.fillStyle = '#be123c';
  ctx.beginPath();
  ctx.ellipse(rugX + 25, rugY + 2, 28, 6, 0, 0, Math.PI * 2);
  ctx.fill();

  ctx.fillStyle = '#fb7185';
  ctx.beginPath();
  ctx.ellipse(rugX + 25, rugY + 2, 22, 4, 0, 0, Math.PI * 2);
  ctx.fill();

  // 6. Vibrant Golden Oak Hardwood Floorboards
  ctx.fillStyle = '#92400e';
  ctx.fillRect(0, platformY, width, 28);
  ctx.fillStyle = '#d97706';
  ctx.fillRect(0, platformY, width, 2.5); // Top highlight line

  // Horizontal plank seams
  ctx.fillStyle = '#451a03';
  ctx.fillRect(0, platformY + 9, width, 1);
  ctx.fillRect(0, platformY + 18, width, 1);

  // Vertical plank joints
  for (let x = 0; x < width; x += 38) {
    ctx.fillRect(x, platformY, 1, 9);
    ctx.fillRect(x + 19, platformY + 9, 1, 9);
    ctx.fillRect(x + 9, platformY + 18, 1, 10);
  }

  // 7. Workstation Oak Desk & Glowing Lamp (Right)
  const deskX = width - 70;
  const deskY = platformY - 24;

  ctx.fillStyle = '#b45309';
  ctx.fillRect(deskX, deskY, 45, 24);
  ctx.fillStyle = '#f59e0b';
  ctx.fillRect(deskX, deskY, 45, 3);

  // Mini Potted Succulent Plant on Desk
  ctx.fillStyle = '#ea580c';
  ctx.fillRect(deskX + 3, deskY - 8, 6, 8); // Pot
  ctx.fillStyle = '#22c55e';
  ctx.fillRect(deskX + 4, deskY - 12, 4, 4); // Succulent

  // Laptop
  ctx.fillStyle = '#94a3b8';
  ctx.fillRect(deskX + 12, deskY - 18, 22, 18);
  ctx.fillStyle = status === 'running' && mode === 'work' ? '#38bdf8' : '#0284c7';
  ctx.fillRect(deskX + 14, deskY - 16, 18, 14);

  if (status === 'running' && mode === 'work') {
    ctx.fillStyle = '#ffffff';
    const lineOffset = (frame % 3) * 3;
    ctx.fillRect(deskX + 16, deskY - 14 + lineOffset, 8, 2);
    ctx.fillRect(deskX + 16, deskY - 10 + lineOffset, 12, 2);
  }

  // Desk Chair
  ctx.fillStyle = '#64748b';
  ctx.fillRect(deskX - 14, deskY + 6, 12, 18);
  ctx.fillRect(deskX - 16, deskY - 6, 4, 20);

  // Desk Lamp Glow Cone
  ctx.fillStyle = 'rgba(251, 191, 36, 0.18)';
  ctx.beginPath();
  ctx.moveTo(deskX + 40, deskY - 14);
  ctx.lineTo(deskX + 10, platformY);
  ctx.lineTo(deskX + 48, platformY);
  ctx.closePath();
  ctx.fill();

  // Lamp Body
  ctx.fillStyle = '#fbbf24';
  ctx.fillRect(deskX + 38, deskY - 16, 6, 6);
  ctx.fillStyle = '#92400e';
  ctx.fillRect(deskX + 40, deskY - 10, 2, 10);

  return { platformY, deskX, deskY };
}
