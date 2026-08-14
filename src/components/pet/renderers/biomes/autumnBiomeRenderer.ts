import { LeafParticle } from '../../types/biomeTypes';

export function renderAutumnGrove(
  ctx: CanvasRenderingContext2D,
  width: number,
  height: number,
  frame: number,
  leaves: LeafParticle[],
  _mode?: string,
  _status?: string
): { platformY: number; deskX: number; deskY: number } {
  const platformY = height - 28;

  // 1. Warm Golden Amber Afternoon Sky
  const skyGrad = ctx.createLinearGradient(0, 0, 0, platformY);
  skyGrad.addColorStop(0, '#fed7aa');
  skyGrad.addColorStop(0.5, '#fdba74');
  skyGrad.addColorStop(1, '#ea580c');
  ctx.fillStyle = skyGrad;
  ctx.fillRect(0, 0, width, platformY);

  // 2. Distant Misty Autumn Forest Ridges
  ctx.fillStyle = '#9a3412';
  ctx.beginPath();
  ctx.moveTo(0, platformY - 25);
  ctx.lineTo(width * 0.35, platformY - 48);
  ctx.lineTo(width * 0.7, platformY - 32);
  ctx.lineTo(width, platformY - 52);
  ctx.lineTo(width, platformY);
  ctx.lineTo(0, platformY);
  ctx.closePath();
  ctx.fill();

  // 3. Golden-Orange Autumn Maple Tree (Left)
  const treeX = 22;
  const treeY = platformY - 20;

  // Trunk with Bark Texture
  ctx.fillStyle = '#451a03';
  ctx.fillRect(treeX + 12, treeY - 25, 8, 25);
  ctx.fillStyle = '#78350f';
  ctx.fillRect(treeX + 12, treeY - 25, 2, 25); // Bark highlight
  ctx.fillStyle = '#451a03';
  ctx.fillRect(treeX + 6, treeY - 36, 12, 11);

  // Maple Canopy (Rich Multi-Layered Autumn Foliage)
  ctx.fillStyle = '#ea580c';
  ctx.beginPath();
  ctx.arc(treeX + 6, treeY - 45, 18, 0, Math.PI * 2);
  ctx.arc(treeX + 26, treeY - 48, 16, 0, Math.PI * 2);
  ctx.arc(treeX + 16, treeY - 58, 15, 0, Math.PI * 2);
  ctx.fill();

  ctx.fillStyle = '#f59e0b';
  ctx.beginPath();
  ctx.arc(treeX + 8, treeY - 48, 12, 0, Math.PI * 2);
  ctx.arc(treeX + 22, treeY - 50, 11, 0, Math.PI * 2);
  ctx.fill();

  ctx.fillStyle = '#dc2626';
  ctx.beginPath();
  ctx.arc(treeX + 16, treeY - 42, 9, 0, Math.PI * 2);
  ctx.fill();

  ctx.fillStyle = '#fef08a';
  ctx.fillRect(treeX + 12, treeY - 52, 4, 3); // Golden leaf highlight
  ctx.fillRect(treeX + 22, treeY - 46, 3, 3);

  // 4. Woodland Earthy Ground with Fallen Leaves
  ctx.fillStyle = '#78350f';
  ctx.fillRect(0, platformY, width, 28);
  ctx.fillStyle = '#92400e';
  ctx.fillRect(0, platformY, width, 2.5);

  // Fallen Leaf Patches
  ctx.fillStyle = '#ea580c';
  for (let x = 60; x < width - 40; x += 25) {
    ctx.fillRect(x, platformY + 6, 8, 3);
    ctx.fillRect(x + 4, platformY + 8, 6, 2);
  }
  ctx.fillStyle = '#f59e0b';
  for (let x = 70; x < width - 50; x += 30) {
    ctx.fillRect(x, platformY + 12, 6, 3);
  }

  // 5. Rustic Log Bench Workstation & Hot Cider Mug
  const deskX = width - 68;
  const deskY = platformY - 24;

  ctx.fillStyle = '#451a03';
  ctx.fillRect(deskX, deskY, 45, 24);
  ctx.fillStyle = '#78350f';
  ctx.fillRect(deskX, deskY, 45, 3);

  // Hot Spiced Cider Mug with Steam & Cinnamon Stick
  ctx.fillStyle = '#f8fafc';
  ctx.fillRect(deskX + 14, deskY - 8, 8, 8);
  ctx.fillStyle = '#b45309';
  ctx.fillRect(deskX + 16, deskY - 7, 4, 3); // Amber cider
  ctx.fillStyle = '#78350f';
  ctx.fillRect(deskX + 19, deskY - 12, 2, 6); // Cinnamon stick

  // Steam
  ctx.fillStyle = 'rgba(255, 255, 255, 0.6)';
  ctx.fillRect(deskX + 15, deskY - 10 - (frame % 8), 2, 2);

  // Stool
  ctx.fillStyle = '#451a03';
  ctx.fillRect(deskX - 14, deskY + 6, 10, 18);

  // 6. Dynamic Falling Maple Leaves
  leaves.forEach((l) => {
    ctx.save();
    ctx.translate(l.x, l.y);
    ctx.rotate(l.rotation);
    ctx.fillStyle = l.color;
    ctx.fillRect(-l.size / 2, -l.size / 2, l.size, l.size);
    ctx.restore();
  });

  return { platformY, deskX, deskY };
}
