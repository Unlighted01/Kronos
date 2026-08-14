import { RoomDoor, drawRoomDoors } from '../doorRenderer';

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

  // 1. Dark Cozy Attic Wall Background
  ctx.fillStyle = '#1c1917';
  ctx.fillRect(0, 0, width, platformY);

  // 2. Slanted Wooden Ceiling Rafters with Wood Grain
  ctx.fillStyle = '#451a03';
  ctx.beginPath();
  ctx.moveTo(0, 0);
  ctx.lineTo(width / 2, 20);
  ctx.lineTo(width, 0);
  ctx.lineTo(width, 7);
  ctx.lineTo(width / 2, 26);
  ctx.lineTo(0, 7);
  ctx.closePath();
  ctx.fill();

  ctx.fillStyle = '#78350f';
  ctx.fillRect(width / 2 - 2, 22, 4, 18); // Center beam

  // 3. Tall Bookshelves packed with colorful books
  const shelfX = 12;
  const shelfY = 20;
  const shelfW = 68;
  const shelfH = platformY - 22;

  ctx.fillStyle = '#292524';
  ctx.fillRect(shelfX, shelfY, shelfW, shelfH);
  ctx.fillStyle = '#451a03';
  ctx.strokeRect(shelfX, shelfY, shelfW, shelfH);

  // Bookshelf shelves & colorful books with gold ribbons
  const bookColors = ['#ef4444', '#3b82f6', '#10b981', '#f59e0b', '#8b5cf6', '#ec4899', '#06b6d4'];
  for (let sY = shelfY + 16; sY < platformY - 8; sY += 20) {
    ctx.fillStyle = '#78350f';
    ctx.fillRect(shelfX + 2, sY, shelfW - 4, 3);
    ctx.fillStyle = '#92400e';
    ctx.fillRect(shelfX + 2, sY, shelfW - 4, 1);

    // Book spines
    let bx = shelfX + 4;
    let cIdx = 0;
    while (bx < shelfX + shelfW - 8) {
      const bW = cIdx % 2 === 0 ? 4 : 5;
      const bH = 12 + (cIdx % 3) * 2;
      ctx.fillStyle = bookColors[cIdx % bookColors.length];
      ctx.fillRect(bx, sY - bH, bW, bH);

      // Gold Foil Trim on Book
      if (cIdx % 2 === 0) {
        ctx.fillStyle = '#fef08a';
        ctx.fillRect(bx + 1, sY - bH + 2, bW - 2, 1);
      }

      bx += bW + 1;
      cIdx++;
    }
  }

  // 4. Arched Stained-Glass Window (Center)
  const arcX = width - 110;
  const arcY = 16;
  const arcW = 30;
  const arcH = 36;

  ctx.save();
  ctx.beginPath();
  ctx.arc(arcX + arcW / 2, arcY + arcW / 2, arcW / 2, Math.PI, 0);
  ctx.lineTo(arcX + arcW, arcY + arcH);
  ctx.lineTo(arcX, arcY + arcH);
  ctx.closePath();
  ctx.clip();

  // Stained glass luminous panes
  ctx.fillStyle = '#6366f1';
  ctx.fillRect(arcX, arcY, arcW / 2, arcH / 2);
  ctx.fillStyle = '#ec4899';
  ctx.fillRect(arcX + arcW / 2, arcY, arcW / 2, arcH / 2);
  ctx.fillStyle = '#f59e0b';
  ctx.fillRect(arcX, arcY + arcH / 2, arcW / 2, arcH / 2);
  ctx.fillStyle = '#10b981';
  ctx.fillRect(arcX + arcW / 2, arcY + arcH / 2, arcW / 2, arcH / 2);
  ctx.restore();

  ctx.strokeStyle = '#78350f';
  ctx.lineWidth = 2;
  ctx.strokeRect(arcX, arcY + arcW / 2, arcW, arcH - arcW / 2);
  
  // Stained Glass Light Shafts
  ctx.fillStyle = 'rgba(99, 102, 241, 0.15)'; // sapphire beam
  ctx.beginPath();
  ctx.moveTo(arcX + 4, arcY + arcH);
  ctx.lineTo(arcX - 40, platformY);
  ctx.lineTo(arcX - 10, platformY);
  ctx.lineTo(arcX + 12, arcY + arcH);
  ctx.fill();
  
  ctx.fillStyle = 'rgba(236, 72, 153, 0.15)'; // ruby beam
  ctx.beginPath();
  ctx.moveTo(arcX + 16, arcY + arcH);
  ctx.lineTo(arcX - 5, platformY);
  ctx.lineTo(arcX + 25, platformY);
  ctx.lineTo(arcX + 24, arcY + arcH);
  ctx.fill();
  
  // Floating Dust Motes across beams
  ctx.fillStyle = 'rgba(253, 230, 138, 0.6)';
  for(let i=0; i<3; i++) {
    const dx = arcX - 20 + Math.sin(frame * 0.02 + i) * 15;
    const dy = platformY - 20 - ((frame * 0.2 + i * 15) % 40);
    ctx.fillRect(dx, dy, 1.5, 1.5);
  }

  // 5. Dark Oak Timber Flooring
  ctx.fillStyle = '#451a03';
  ctx.fillRect(0, platformY, width, 28);
  ctx.fillStyle = '#78350f';
  ctx.fillRect(0, platformY, width, 2.5);

  for (let x = 0; x < width; x += 35) {
    ctx.fillStyle = '#291305';
    ctx.fillRect(x, platformY + 10, width, 1);
    ctx.fillRect(x + 15, platformY, 1, 10);
    ctx.fillRect(x, platformY + 10, 1, 18);
  }

  // 6. Reading Armchair & Reading Desk (Right)
  const deskX = width - 65;
  const deskY = platformY - 24;

  // Velvet Reading Chair with Cushion Crease
  ctx.fillStyle = '#831843';
  ctx.fillRect(deskX - 18, deskY + 2, 16, 22);
  ctx.fillStyle = '#9d174d';
  ctx.fillRect(deskX - 22, deskY - 6, 6, 28);
  ctx.fillStyle = '#be185d';
  ctx.fillRect(deskX - 16, deskY + 6, 12, 3); // Tufting line

  // Small Reading Side Desk
  ctx.fillStyle = '#78350f';
  ctx.fillRect(deskX, deskY, 40, 24);
  ctx.fillStyle = '#92400e';
  ctx.fillRect(deskX, deskY, 40, 3);

  // Open Tome on Stand with turning page effect
  ctx.fillStyle = '#fef08a';
  ctx.fillRect(deskX + 8, deskY - 9, 16, 9);
  ctx.fillStyle = '#ffffff';
  ctx.fillRect(deskX + 10, deskY - 8, 12, 7);
  ctx.fillStyle = '#3b82f6';
  ctx.fillRect(deskX + 15, deskY - 9, 2, 9); // Ribbon bookmark

  // Antique Globe (Left of desk)
  const globeX = deskX - 35;
  const globeY = platformY - 14;
  ctx.fillStyle = '#78350f'; // Base
  ctx.fillRect(globeX + 4, globeY + 10, 8, 4);
  ctx.fillRect(globeX + 7, globeY + 6, 2, 4);
  ctx.strokeStyle = '#b45309'; // Stand arch
  ctx.beginPath();
  ctx.arc(globeX + 8, globeY, 8, -Math.PI/4, Math.PI);
  ctx.stroke();
  
  ctx.fillStyle = '#0ea5e9'; // Ocean
  ctx.beginPath();
  ctx.arc(globeX + 8, globeY, 6, 0, Math.PI*2);
  ctx.fill();
  
  const gBoost = objectStates.globeSpinBoost || 0;
  const globeFrame = frame * (0.05 + gBoost * 0.05);
  ctx.fillStyle = '#84cc16'; // Land
  ctx.beginPath();
  ctx.ellipse(globeX + 8 + Math.sin(globeFrame)*3, globeY, 2, 4, 0, 0, Math.PI*2);
  ctx.fill();

  // Candlestick
  ctx.fillStyle = '#e5e7eb'; // Wax
  ctx.fillRect(deskX + 32, deskY - 16, 4, 16);
  ctx.fillStyle = '#d1d5db';
  ctx.fillRect(deskX + 30, deskY, 8, 2); // Base

  if (objectStates.isCandleLit ?? true) {
    const flicker = Math.sin(frame * 0.5) * 1;
    ctx.fillStyle = '#f97316';
    ctx.beginPath();
    ctx.moveTo(deskX + 34, deskY - 16);
    ctx.lineTo(deskX + 32 + flicker, deskY - 22);
    ctx.lineTo(deskX + 36, deskY - 16);
    ctx.fill();
    ctx.fillStyle = '#fef08a';
    ctx.fillRect(deskX + 33, deskY - 18, 2, 3);
    
    // Light Cone
    ctx.fillStyle = 'rgba(251, 191, 36, 0.16)';
    ctx.beginPath();
    ctx.moveTo(deskX + 34, deskY - 18);
    ctx.lineTo(deskX + 5, platformY);
    ctx.lineTo(deskX + 45, platformY);
    ctx.closePath();
    ctx.fill();
  } else {
    // Thin smoke
    ctx.fillStyle = 'rgba(255,255,255,0.4)';
    const sx = Math.sin(frame * 0.1) * 2;
    ctx.fillRect(deskX + 33 + sx, deskY - 20 - (frame%10)*0.5, 1, 1);
  }

  // Floating Magic Reading Dust Sparkle
  const dustY = deskY - 14 - (frame % 16);
  ctx.fillStyle = 'rgba(254, 240, 138, 0.8)';
  ctx.fillRect(deskX + 12 + Math.sin(frame * 0.2) * 4, dustY, 2, 2);

  drawRoomDoors(ctx, doors, frame, hoveredDoorId);

  return { platformY, deskX, deskY };
}
