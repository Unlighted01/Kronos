import { PetalParticle } from '../../types/biomeTypes';

export function renderSakuraGarden(
  ctx: CanvasRenderingContext2D,
  width: number,
  height: number,
  _frame: number,
  petals: PetalParticle[],
  _mode?: string,
  _status?: string
): { platformY: number; deskX: number; deskY: number } {
  const platformY = height - 28;

  // 1. Pastel Spring Morning Sky
  const skyGrad = ctx.createLinearGradient(0, 0, 0, platformY);
  skyGrad.addColorStop(0, '#e0e7ff');
  skyGrad.addColorStop(0.6, '#fce7f3');
  skyGrad.addColorStop(1, '#fbcfe8');
  ctx.fillStyle = skyGrad;
  ctx.fillRect(0, 0, width, platformY);

  // 2. Distant Misty Lavender Mountains
  ctx.fillStyle = '#cbd5e1';
  ctx.beginPath();
  ctx.moveTo(0, platformY - 20);
  ctx.lineTo(width * 0.3, platformY - 48);
  ctx.lineTo(width * 0.65, platformY - 28);
  ctx.lineTo(width, platformY - 42);
  ctx.lineTo(width, platformY);
  ctx.lineTo(0, platformY);
  ctx.closePath();
  ctx.fill();

  // 3. Sprawling Cherry Blossom Tree (Left Side)
  const treeX = 25;
  const treeY = platformY - 20;

  // Tree Trunk & Branches with Bark Highlights
  ctx.fillStyle = '#451a03';
  ctx.fillRect(treeX + 10, treeY - 25, 8, 25);
  ctx.fillStyle = '#78350f';
  ctx.fillRect(treeX + 10, treeY - 25, 2, 25); // Bark highlight
  ctx.fillStyle = '#451a03';
  ctx.fillRect(treeX + 4, treeY - 35, 12, 10);
  ctx.fillRect(treeX - 4, treeY - 42, 12, 8);
  ctx.fillRect(treeX + 14, treeY - 42, 14, 8);

  // Sakura Blossom Canopy (Multi-Shade Pink Clusters)
  ctx.fillStyle = '#f472b6';
  ctx.beginPath();
  ctx.arc(treeX + 4, treeY - 45, 18, 0, Math.PI * 2);
  ctx.arc(treeX + 22, treeY - 48, 16, 0, Math.PI * 2);
  ctx.arc(treeX + 12, treeY - 58, 15, 0, Math.PI * 2);
  ctx.fill();

  ctx.fillStyle = '#fbcfe8';
  ctx.beginPath();
  ctx.arc(treeX + 6, treeY - 46, 12, 0, Math.PI * 2);
  ctx.arc(treeX + 20, treeY - 50, 10, 0, Math.PI * 2);
  ctx.fill();

  ctx.fillStyle = '#ffffff';
  ctx.fillRect(treeX + 8, treeY - 50, 3, 3); // White blossom highlight
  ctx.fillRect(treeX + 18, treeY - 46, 3, 3);

  // 4. Lush Grassy Lawn & Cobblestone Path
  ctx.fillStyle = '#15803d';
  ctx.fillRect(0, platformY, width, 28);
  ctx.fillStyle = '#22c55e';
  ctx.fillRect(0, platformY, width, 3);

  // Fallen Petals Carpet on Grass
  ctx.fillStyle = '#f472b6';
  for (let x = 12; x < width - 15; x += 16) {
    ctx.fillRect(x, platformY + 6, 3, 2);
    ctx.fillRect(x + 5, platformY + 12, 2, 2);
  }

  // Cobblestone stepping stones with moss
  ctx.fillStyle = '#cbd5e1';
  for (let x = 70; x < width - 60; x += 30) {
    ctx.fillRect(x, platformY + 6, 14, 6);
    ctx.fillStyle = '#16a34a';
    ctx.fillRect(x + 1, platformY + 6, 2, 2); // Moss
    ctx.fillStyle = '#cbd5e1';
  }

  // 5. Park Bench & Outdoor Tea Table
  const deskX = width - 68;
  const deskY = platformY - 24;

  // Rustic Wooden Park Bench
  ctx.fillStyle = '#78350f';
  ctx.fillRect(deskX, deskY, 45, 24);
  ctx.fillStyle = '#92400e';
  ctx.fillRect(deskX, deskY, 45, 3);

  // Steaming Matcha Cup & Bamboo Whisk
  ctx.fillStyle = '#f8fafc';
  ctx.fillRect(deskX + 14, deskY - 8, 8, 8);
  ctx.fillStyle = '#84cc16';
  ctx.fillRect(deskX + 16, deskY - 7, 4, 3); // Green matcha

  // Steam
  ctx.fillStyle = 'rgba(255, 255, 255, 0.7)';
  ctx.fillRect(deskX + 17, deskY - 11, 2, 2);

  // Bench Backrest
  ctx.fillStyle = '#451a03';
  ctx.fillRect(deskX + 38, deskY - 14, 4, 20);

  // 6. Dynamic Drifting Sakura Petals
  petals.forEach((p) => {
    ctx.save();
    ctx.translate(p.x, p.y);
    ctx.rotate(p.rotation);
    ctx.fillStyle = `rgba(244, 114, 182, ${p.opacity})`;
    ctx.fillRect(-p.size / 2, -p.size / 2, p.size, p.size * 1.5);
    ctx.restore();
  });

  return { platformY, deskX, deskY };
}
