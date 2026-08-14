import { RoomDoor, drawRoomDoors } from '../doorRenderer';

export function renderLivingRoom(
  ctx: CanvasRenderingContext2D,
  width: number,
  height: number,
  frame: number,
  _mode?: string,
  _status?: string,
  doors: RoomDoor[] = [],
  hoveredDoorId?: string | null
): { platformY: number; deskX: number; deskY: number } {
  const platformY = 112;

  // 1. Warm sage/taupe patterned wallpaper with wooden wainscoting
  ctx.fillStyle = '#78716c'; // Taupe base
  ctx.fillRect(0, 0, width, platformY);
  
  // Sage pattern
  ctx.fillStyle = '#65a30d';
  for (let x = 0; x < width; x += 16) {
    for (let y = 0; y < platformY - 40; y += 16) {
      ctx.fillRect(x + 4, y + 4, 4, 4);
    }
  }

  // Wooden wainscoting
  ctx.fillStyle = '#78350f';
  ctx.fillRect(0, platformY - 40, width, 40);
  ctx.fillStyle = '#451a03';
  ctx.fillRect(0, platformY - 40, width, 2);
  for (let x = 0; x < width; x += 32) {
    ctx.fillRect(x, platformY - 38, 2, 38);
    ctx.fillRect(x + 4, platformY - 34, 24, 30);
  }

  // 2. Cozy brick fireplace with crackling animated fire and mantlepiece with framed photos
  const fireX = width / 2 - 24;
  const fireY = platformY - 50;
  
  // Brick fireplace
  ctx.fillStyle = '#991b1b'; // Red brick
  ctx.fillRect(fireX, fireY, 48, 50);
  // Brick lines
  ctx.fillStyle = '#450a0a';
  for (let y = fireY; y < platformY; y += 8) {
    ctx.fillRect(fireX, y, 48, 1);
    const offsetX = (y % 16 === 0) ? 0 : 8;
    for (let x = fireX + offsetX; x < fireX + 48; x += 16) {
      ctx.fillRect(x, y, 1, 8);
    }
  }
  
  // Mantlepiece
  ctx.fillStyle = '#451a03';
  ctx.fillRect(fireX - 4, fireY - 4, 56, 4);
  // Framed photos
  ctx.fillStyle = '#b45309'; // Gold frame
  ctx.fillRect(fireX + 8, fireY - 14, 12, 10);
  ctx.fillStyle = '#f0f9ff';
  ctx.fillRect(fireX + 9, fireY - 13, 10, 8);
  ctx.fillStyle = '#cbd5e1'; // Silver frame
  ctx.fillRect(fireX + 28, fireY - 18, 14, 14);
  ctx.fillStyle = '#0f172a';
  ctx.fillRect(fireX + 29, fireY - 17, 12, 12);

  // Firebox
  ctx.fillStyle = '#000000';
  ctx.fillRect(fireX + 8, fireY + 16, 32, 34);
  
  // Animated Fire
  ctx.fillStyle = '#ea580c';
  ctx.beginPath();
  const f1 = (frame % 10) > 4 ? 4 : 0;
  const f2 = (frame % 14) > 7 ? 6 : 0;
  ctx.moveTo(fireX + 12, platformY);
  ctx.lineTo(fireX + 18, fireY + 28 - f1);
  ctx.lineTo(fireX + 24, platformY - 10);
  ctx.lineTo(fireX + 30, fireY + 20 - f2);
  ctx.lineTo(fireX + 36, platformY);
  ctx.fill();
  
  ctx.fillStyle = '#fde047'; // Inner flame
  ctx.beginPath();
  ctx.moveTo(fireX + 16, platformY);
  ctx.lineTo(fireX + 24, fireY + 32);
  ctx.lineTo(fireX + 32, platformY);
  ctx.fill();

  // 3. Corduroy tufted lounge sofa with throw pillows
  const sofaX = 16;
  const sofaY = platformY - 24;
  ctx.fillStyle = '#451a03'; // Sofa legs
  ctx.fillRect(sofaX + 4, sofaY + 20, 4, 4);
  ctx.fillRect(sofaX + 40, sofaY + 20, 4, 4);
  
  ctx.fillStyle = '#475569'; // Slate base
  ctx.fillRect(sofaX, sofaY, 48, 20);
  // Tufting lines
  ctx.fillStyle = '#334155';
  for (let x = sofaX + 4; x < sofaX + 48; x += 8) {
    ctx.fillRect(x, sofaY, 1, 20);
  }
  
  // Throw pillows
  ctx.fillStyle = '#ca8a04'; // Gold pillow
  ctx.fillRect(sofaX + 4, sofaY + 4, 12, 10);
  ctx.fillStyle = '#f87171'; // Red accent pillow
  ctx.fillRect(sofaX + 34, sofaY + 6, 10, 8);

  // 4. Polished dark walnut hardwood floorboards with a circular woven rug
  // Floor
  ctx.fillStyle = '#271404';
  ctx.fillRect(0, platformY, width, height - platformY);
  ctx.fillStyle = '#451a03'; // Planks
  for (let y = platformY + 4; y < height; y += 6) {
    ctx.fillRect(0, y, width, 1);
  }
  
  // Circular woven rug
  const rugX = width / 2;
  const rugY = platformY + 12;
  ctx.fillStyle = '#d4d4d8';
  ctx.beginPath();
  ctx.ellipse(rugX, rugY, 40, 10, 0, 0, Math.PI * 2);
  ctx.fill();
  ctx.fillStyle = '#a1a1aa';
  ctx.beginPath();
  ctx.ellipse(rugX, rugY, 32, 8, 0, 0, Math.PI * 2);
  ctx.fill();

  // 5. Warm brass arc floor lamp with soft glowing light pool
  const lampX = 6;
  const lampY = platformY - 60;
  ctx.strokeStyle = '#fbbf24'; // Brass
  ctx.lineWidth = 2;
  ctx.beginPath();
  ctx.moveTo(lampX, platformY);
  ctx.lineTo(lampX, lampY);
  ctx.quadraticCurveTo(lampX + 16, lampY - 10, lampX + 32, lampY + 10);
  ctx.stroke();
  
  // Lamp head
  ctx.fillStyle = '#f59e0b';
  ctx.beginPath();
  ctx.arc(lampX + 32, lampY + 10, 6, Math.PI, 0);
  ctx.fill();

  // Light pool
  ctx.fillStyle = 'rgba(253, 230, 138, 0.15)';
  ctx.beginPath();
  ctx.moveTo(lampX + 32, lampY + 10);
  ctx.lineTo(lampX + 60, platformY);
  ctx.lineTo(lampX + 4, platformY);
  ctx.fill();

  // 6. Turntable vinyl record player on wooden credenza
  const credenzaX = width - 64;
  const credenzaY = platformY - 24;
  ctx.fillStyle = '#78350f'; // Credenza
  ctx.fillRect(credenzaX, credenzaY, 48, 24);
  // Drawers
  ctx.fillStyle = '#92400e';
  ctx.fillRect(credenzaX + 4, credenzaY + 4, 18, 16);
  ctx.fillRect(credenzaX + 26, credenzaY + 4, 18, 16);
  
  // Turntable
  ctx.fillStyle = '#1e293b';
  ctx.fillRect(credenzaX + 8, credenzaY - 6, 20, 6);
  
  // Vinyl disc
  ctx.fillStyle = '#000000';
  ctx.beginPath();
  ctx.ellipse(credenzaX + 16, credenzaY - 6, 8, 2, 0, 0, Math.PI * 2);
  ctx.fill();
  // Center label (spinning)
  const spinColor = (frame % 20 < 10) ? '#ef4444' : '#3b82f6';
  ctx.fillStyle = spinColor;
  ctx.beginPath();
  ctx.ellipse(credenzaX + 16, credenzaY - 6, 3, 1, 0, 0, Math.PI * 2);
  ctx.fill();
  
  // Floating music notes
  if (frame % 60 < 30) {
    ctx.fillStyle = '#475569';
    ctx.font = '10px sans-serif';
    ctx.fillText('♪', credenzaX + 10, credenzaY - 12 - (frame % 10));
  } else {
    ctx.fillStyle = '#64748b';
    ctx.font = '12px sans-serif';
    ctx.fillText('♫', credenzaX + 22, credenzaY - 16 - (frame % 8));
  }

  drawRoomDoors(ctx, doors, frame, hoveredDoorId);

  return { platformY, deskX: 170, deskY: 88 };
}
