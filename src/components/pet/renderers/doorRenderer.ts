import { RoomDoor } from '../types/houseMapTypes';

export type { RoomDoor };

export function drawRoomDoors(
  ctx: CanvasRenderingContext2D,
  doors: RoomDoor[],
  frame: number,
  hoveredDoorId?: string | null
): void {
  for (const door of doors) {
    const isHovered = door.id === hoveredDoorId;
    const doorStyle: 'stairs-up' | 'stairs-down' | 'glass-garden' | 'wood' =
      door.icon === '🪜'
        ? door.direction === 'up'
          ? 'stairs-up'
          : 'stairs-down'
        : door.icon === '🌸' || door.icon === '🔥' || door.icon === '🍂'
        ? 'glass-garden'
        : 'wood';

    // Draw the door body based on style
    switch (doorStyle) {
      case 'wood':
        ctx.fillStyle = '#451a03'; // Dark frame
        ctx.fillRect(door.x, door.y, door.width, door.height);
        
        ctx.fillStyle = isHovered ? '#78350f' : '#92400e'; // Inner panel (bevel)
        ctx.fillRect(door.x + 2, door.y + 2, door.width - 4, door.height - 4);

        // Bottom threshold
        ctx.fillStyle = '#290f01';
        ctx.fillRect(door.x, door.y + door.height - 2, door.width, 2);

        // Panels
        ctx.fillStyle = '#b45309';
        ctx.fillRect(door.x + 4, door.y + 4, door.width - 8, door.height / 2 - 6);
        ctx.fillRect(door.x + 4, door.y + door.height / 2 + 2, door.width - 8, door.height / 2 - 8);

        // Brass doorknob
        ctx.fillStyle = '#fbbf24';
        ctx.fillRect(door.x + door.width - 5, door.y + door.height / 2, 2, 4);
        break;

      case 'stairs-up':
        // Vertical wooden ladder with vertical side rails and horizontal rungs
        ctx.fillStyle = '#451a03'; // side rails
        ctx.fillRect(door.x, door.y, 2, door.height);
        ctx.fillRect(door.x + door.width - 2, door.y, 2, door.height);
        
        ctx.fillStyle = isHovered ? '#fbbf24' : '#b45309'; // rungs
        const numRungs = Math.floor(door.height / 8);
        for (let i = 0; i < numRungs; i++) {
          ctx.fillRect(door.x + 2, door.y + 4 + (i * 8), door.width - 4, 2);
        }
        
        // Ceiling hatch at top
        ctx.fillStyle = '#290f01';
        ctx.fillRect(door.x - 2, door.y - 2, door.width + 4, 4);
        break;

      case 'stairs-down':
        // Floor cellar hatch with wooden planks, iron hinges, and stairs descending
        ctx.fillStyle = '#1a1a1a'; // hole
        ctx.fillRect(door.x, door.y, door.width, door.height);
        
        ctx.fillStyle = isHovered ? '#78350f' : '#451a03'; // hatch lid
        ctx.fillRect(door.x, door.y, door.width, 4);
        
        ctx.fillStyle = '#78350f'; // stairs descending
        for (let i = 0; i < 3; i++) {
           ctx.fillRect(door.x + 4, door.y + 4 + i * 3, door.width - 8, 2);
        }
        
        // Frame
        ctx.fillStyle = '#290f01';
        ctx.fillRect(door.x - 1, door.y - 1, door.width + 2, 2);
        ctx.fillRect(door.x - 1, door.y + door.height - 1, door.width + 2, 2);
        ctx.fillRect(door.x - 1, door.y - 1, 2, door.height + 2);
        ctx.fillRect(door.x + door.width - 1, door.y - 1, 2, door.height + 2);

        // Iron hinges on lid
        ctx.fillStyle = '#94a3b8';
        ctx.fillRect(door.x + 2, door.y, 2, 3);
        ctx.fillRect(door.x + door.width - 4, door.y, 2, 3);
        break;

      case 'glass-garden':
        // Arched greenhouse door with emerald lattice and glass panes
        ctx.fillStyle = '#065f46';
        ctx.beginPath();
        if (ctx.roundRect) {
          ctx.roundRect(door.x, door.y, door.width, door.height, [door.width/2, door.width/2, 0, 0]);
        } else {
          ctx.rect(door.x, door.y, door.width, door.height);
        }
        ctx.fill();

        ctx.fillStyle = isHovered ? 'rgba(167, 243, 208, 0.4)' : 'rgba(110, 231, 183, 0.2)';
        
        const paneW = (door.width - 6) / 2;
        const paneH = (door.height - 10) / 3;
        
        for (let row = 0; row < 3; row++) {
           for (let col = 0; col < 2; col++) {
               const px = door.x + 2 + col * (paneW + 2);
               const py = door.y + 6 + row * (paneH + 2);
               ctx.fillRect(px, py, paneW, paneH);
           }
        }
        break;
    }

    // Door Hover Outline / Pulse and Ambient Glow
    if (isHovered) {
      ctx.strokeStyle = '#fde047';
      ctx.lineWidth = 1;
      ctx.strokeRect(door.x - 1, door.y - 1, door.width + 2, door.height + 2);

      // Directional floating badge label (Pulsing gently)
      const bounceOffset = Math.sin(frame * 0.4) * 2;
      const badgeY = door.y - 12 + bounceOffset;
      const badgeX = Math.max(0, Math.min(240 - 60, door.x + door.width / 2 - 30));

      // Label pill background
      ctx.fillStyle = 'rgba(15, 23, 42, 0.95)';
      ctx.fillRect(badgeX, badgeY - 6, 60, 12);
      ctx.strokeStyle = '#fbbf24';
      ctx.lineWidth = 1;
      ctx.strokeRect(badgeX, badgeY - 6, 60, 12);

      // Label text
      ctx.fillStyle = '#fde047';
      ctx.font = '8px sans-serif';
      ctx.textAlign = 'center';
      ctx.fillText(`${door.icon} ${door.label}`, badgeX + 30, badgeY + 3);
      ctx.textAlign = 'start';
    } else {
      // Subtle ambient highlight for interactive doors
      ctx.strokeStyle = 'rgba(255, 255, 255, 0.15)';
      ctx.lineWidth = 1;
      ctx.strokeRect(door.x - 1, door.y - 1, door.width + 2, door.height + 2);
    }
  }
}
