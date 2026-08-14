import { RoomDoor, drawRoomDoors } from '../doorRenderer';

export function renderGreenhouse(
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

  // 1. Sky through Glass Atrium Ceiling
  const skyGrad = ctx.createLinearGradient(0, 0, 0, platformY);
  skyGrad.addColorStop(0, '#7dd3fc');
  skyGrad.addColorStop(1, '#bae6fd');
  ctx.fillStyle = skyGrad;
  ctx.fillRect(0, 0, width, platformY);

  // Distant Garden Trees through glass
  ctx.fillStyle = '#86efac';
  ctx.beginPath();
  ctx.arc(40, platformY - 20, 30, 0, Math.PI * 2);
  ctx.arc(90, platformY - 25, 25, 0, Math.PI * 2);
  ctx.fill();

  // 2. Greenhouse Glass Metal Panes & Iron Ribs
  ctx.strokeStyle = '#047857';
  ctx.lineWidth = 2;

  // Roof glass diagonals
  ctx.beginPath();
  ctx.moveTo(0, 0);
  ctx.lineTo(width / 2, 22);
  ctx.lineTo(width, 0);
  ctx.stroke();

  // Glass specular glint line
  ctx.fillStyle = 'rgba(255, 255, 255, 0.4)';
  ctx.fillRect(width * 0.3, 4, 30, 2);
  ctx.fillRect(width * 0.65, 8, 25, 2);

  for (let x = 30; x < width; x += 40) {
    ctx.beginPath();
    ctx.moveTo(x, 0);
    ctx.lineTo(x, platformY);
    ctx.stroke();
  }

  // 3. Hanging Ivy Vines & Flowering Baskets
  for (let x = 20; x < width - 40; x += 50) {
    // Hanging pot
    ctx.fillStyle = '#b45309';
    ctx.fillRect(x + 6, 18, 12, 8);
    // Ivy leaves
    ctx.fillStyle = '#16a34a';
    ctx.fillRect(x + 2, 24, 6, 8 + Math.sin(x + frame * 0.05) * 3);
    ctx.fillRect(x + 12, 24, 7, 12 + Math.cos(x + frame * 0.05) * 4);
    // Pink Orchid flower
    ctx.fillStyle = '#f472b6';
    ctx.fillRect(x + 5, 22, 3, 3);
    ctx.fillRect(x + 11, 28, 3, 3);
  }

  // 4. Large Potted Monstera (Left Corner)
  const plantX = 12;
  const plantY = platformY - 34;

  // Ceramic Planter Pot with Shading
  ctx.fillStyle = '#f8fafc';
  ctx.fillRect(plantX + 4, plantY + 16, 18, 18);
  ctx.fillStyle = '#cbd5e1';
  ctx.fillRect(plantX + 16, plantY + 16, 6, 18); // Shadow side
  ctx.fillStyle = '#e2e8f0';
  ctx.fillRect(plantX + 2, plantY + 14, 22, 3);

  // Big Monstera Leaves with Vein Highlights
  ctx.fillStyle = '#15803d';
  ctx.beginPath();
  ctx.arc(plantX + 6, plantY + 6, 9, 0, Math.PI * 2);
  ctx.arc(plantX + 19, plantY + 4, 11, 0, Math.PI * 2);
  ctx.arc(plantX + 13, plantY - 3, 10, 0, Math.PI * 2);
  ctx.fill();

  ctx.fillStyle = '#22c55e';
  ctx.fillRect(plantX + 12, plantY - 2, 2, 8); // Leaf vein
  ctx.fillRect(plantX + 6, plantY + 6, 2, 6);

  // Flowering Begonia
  ctx.fillStyle = '#f472b6';
  ctx.fillRect(plantX + 8, plantY + 4, 3, 3);
  ctx.fillRect(plantX + 17, plantY + 2, 3, 3);

  // 5. Rustic Stone Paver Flooring
  ctx.fillStyle = '#334155';
  ctx.fillRect(0, platformY, width, 28);
  ctx.fillStyle = '#64748b';
  ctx.fillRect(0, platformY, width, 2.5);

  // Stone cobblestones pattern
  for (let x = 0; x < width; x += 18) {
    ctx.fillStyle = '#1e293b';
    ctx.fillRect(x, platformY + 8, 16, 1);
    ctx.fillRect(x + 9, platformY + 18, 16, 1);
  }

  // 6. Wooden Garden Potting Bench / Workstation
  const deskX = width - 68;
  const deskY = platformY - 24;

  ctx.fillStyle = '#78350f';
  ctx.fillRect(deskX, deskY, 45, 24);
  ctx.fillStyle = '#92400e';
  ctx.fillRect(deskX, deskY, 45, 3);

  // Watering Can & Seedling Pots
  ctx.fillStyle = '#10b981';
  ctx.fillRect(deskX + 6, deskY - 10, 10, 10);
  ctx.fillStyle = '#059669';
  ctx.fillRect(deskX + 14, deskY - 14, 4, 6); // Spout

  ctx.fillStyle = '#b45309';
  ctx.fillRect(deskX + 22, deskY - 8, 6, 8);
  ctx.fillRect(deskX + 32, deskY - 8, 6, 8);
  ctx.fillStyle = '#22c55e';
  ctx.fillRect(deskX + 24, deskY - 12, 3, 4); // Green sprout
  ctx.fillRect(deskX + 34, deskY - 12, 3, 4);

  // Stool
  ctx.fillStyle = '#78350f';
  ctx.fillRect(deskX - 14, deskY + 6, 10, 18);

  // Warm Sunbeams Streaming
  ctx.fillStyle = 'rgba(254, 240, 138, 0.12)';
  ctx.beginPath();
  ctx.moveTo(width / 3, 0);
  ctx.lineTo(width / 3 + 35, 0);
  ctx.lineTo(width, platformY);
  ctx.lineTo(width - 45, platformY);
  ctx.closePath();
  ctx.fill();

  drawRoomDoors(ctx, doors, frame, hoveredDoorId);

  return { platformY, deskX, deskY };
}
