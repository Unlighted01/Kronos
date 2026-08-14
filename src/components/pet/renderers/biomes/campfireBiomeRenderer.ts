import { EmberParticle } from '../../types/biomeTypes';

export function renderStarryCampfire(
  ctx: CanvasRenderingContext2D,
  width: number,
  height: number,
  frame: number,
  embers: EmberParticle[],
  mode: string,
  status: string
): { platformY: number; deskX: number; deskY: number } {
  const platformY = height - 28;

  // 1. Deep Space Galaxy Nebula Sky
  const skyGrad = ctx.createLinearGradient(0, 0, 0, platformY);
  skyGrad.addColorStop(0, '#050515');
  skyGrad.addColorStop(0.5, '#1e1b4b');
  skyGrad.addColorStop(1, '#311042');
  ctx.fillStyle = skyGrad;
  ctx.fillRect(0, 0, width, platformY);

  // Animated Twinkling Star Clusters
  ctx.fillStyle = '#ffffff';
  for (let i = 12; i < width; i += 28) {
    const starY = (i * 7) % (platformY - 35) + 6;
    const isBlinking = (frame + i) % 30 < 15;
    ctx.fillStyle = isBlinking ? '#ffffff' : '#94a3b8';
    ctx.fillRect(i, starY, 1.5, 1.5);
  }

  // Shooting Star Animation
  if (frame % 45 < 10) {
    const shootProgress = (frame % 45) * 6;
    ctx.strokeStyle = 'rgba(254, 240, 138, 0.8)';
    ctx.lineWidth = 1.5;
    ctx.beginPath();
    ctx.moveTo(width * 0.7 - shootProgress, 8 + shootProgress * 0.5);
    ctx.lineTo(width * 0.7 - shootProgress - 12, 8 + shootProgress * 0.5 - 6);
    ctx.stroke();
  }

  // 2. Pine Tree Silhouettes (Left & Center)
  ctx.fillStyle = '#090a1a';
  for (let tx of [16, 48, 80]) {
    // Pine Tree
    ctx.beginPath();
    ctx.moveTo(tx, platformY - 50);
    ctx.lineTo(tx + 14, platformY);
    ctx.lineTo(tx - 14, platformY);
    ctx.closePath();
    ctx.fill();
  }

  // 3. Campsite Earthy Ground with Pebbles
  ctx.fillStyle = '#1c1917';
  ctx.fillRect(0, platformY, width, 28);
  ctx.fillStyle = '#44403c';
  ctx.fillRect(0, platformY, width, 2.5);

  ctx.fillStyle = '#78716c';
  for (let x = 8; x < width; x += 32) {
    ctx.fillRect(x, platformY + 8, 3, 2);
    ctx.fillRect(x + 12, platformY + 16, 2, 2);
  }

  // 4. Crackling Campfire with Stone Ring (Center-Left)
  const fireX = 45;
  const fireY = platformY - 4;

  // Campfire Stone Ring
  ctx.fillStyle = '#78716c';
  ctx.beginPath();
  ctx.ellipse(fireX, fireY, 16, 6, 0, 0, Math.PI * 2);
  ctx.fill();

  // Glowing Coal Bed
  ctx.fillStyle = '#ea580c';
  ctx.beginPath();
  ctx.ellipse(fireX, fireY - 1, 10, 3, 0, 0, Math.PI * 2);
  ctx.fill();

  // Fire Logs
  ctx.fillStyle = '#451a03';
  ctx.fillRect(fireX - 8, fireY - 3, 16, 3);
  ctx.fillRect(fireX - 6, fireY - 5, 12, 3);

  // 3-Stage Animated Campfire Flames
  const flicker = Math.sin(frame * 0.4) * 3;
  ctx.fillStyle = '#ef4444';
  ctx.beginPath();
  ctx.moveTo(fireX - 7, fireY - 2);
  ctx.lineTo(fireX, fireY - 18 + flicker);
  ctx.lineTo(fireX + 7, fireY - 2);
  ctx.closePath();
  ctx.fill();

  ctx.fillStyle = '#f97316';
  ctx.beginPath();
  ctx.moveTo(fireX - 5, fireY - 2);
  ctx.lineTo(fireX, fireY - 14 + flicker);
  ctx.lineTo(fireX + 5, fireY - 2);
  ctx.closePath();
  ctx.fill();

  ctx.fillStyle = '#fbbf24';
  ctx.beginPath();
  ctx.moveTo(fireX - 3, fireY - 2);
  ctx.lineTo(fireX, fireY - 8 + flicker);
  ctx.lineTo(fireX + 3, fireY - 2);
  ctx.closePath();
  ctx.fill();

  // Warm Campfire Radial Glow
  ctx.fillStyle = 'rgba(249, 115, 22, 0.16)';
  ctx.beginPath();
  ctx.arc(fireX, fireY - 6, 34, 0, Math.PI * 2);
  ctx.fill();

  // 5. Campsite Log Workstation & Camping Lantern
  const deskX = width - 68;
  const deskY = platformY - 24;

  // Rustic Log Table
  ctx.fillStyle = '#451a03';
  ctx.fillRect(deskX, deskY, 45, 24);
  ctx.fillStyle = '#78350f';
  ctx.fillRect(deskX, deskY, 45, 3);

  // Glowing Camping Lantern
  ctx.fillStyle = '#0f172a';
  ctx.fillRect(deskX + 28, deskY - 16, 10, 16);
  ctx.fillStyle = '#fef08a';
  ctx.fillRect(deskX + 30, deskY - 12, 6, 8); // Lantern light

  // Lantern Glow Aura
  ctx.fillStyle = 'rgba(254, 240, 138, 0.14)';
  ctx.beginPath();
  ctx.arc(deskX + 33, deskY - 8, 18, 0, Math.PI * 2);
  ctx.fill();

  // Field Laptop
  ctx.fillStyle = '#64748b';
  ctx.fillRect(deskX + 4, deskY - 12, 16, 12);
  ctx.fillStyle = status === 'running' && mode === 'work' ? '#38bdf8' : '#0284c7';
  ctx.fillRect(deskX + 6, deskY - 10, 12, 8);

  // Stool Log
  ctx.fillStyle = '#451a03';
  ctx.fillRect(deskX - 14, deskY + 6, 10, 18);

  // 6. Dynamic Rising Fire Embers
  embers.forEach((e) => {
    ctx.fillStyle = e.color;
    ctx.globalAlpha = e.opacity;
    ctx.fillRect(e.x, e.y, e.size, e.size);
    ctx.globalAlpha = 1;
  });

  return { platformY, deskX, deskY };
}
