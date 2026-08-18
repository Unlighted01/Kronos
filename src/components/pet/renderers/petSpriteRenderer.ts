export interface PetRenderContext {
  ctx: CanvasRenderingContext2D;
  drawX: number;
  drawY: number;
  action: string;
  frame: number;
  direction: number;
  status: string;
  mode: string;
}

export function drawEnhancedPet(p: PetRenderContext): void {
  const { ctx, drawX, drawY, action, frame, direction } = p;

  ctx.save();

  // Flip horizontally if facing left
  if (direction < 0 && action === 'walking') {
    ctx.translate(drawX + 16, drawY);
    ctx.scale(-1, 1);
    ctx.translate(-drawX, -drawY);
  }

  // --- 1. PET SHADOW ---
  ctx.fillStyle = 'rgba(0, 0, 0, 0.25)';
  ctx.fillRect(drawX + 1, drawY + 16, 14, 2);
  ctx.fillRect(drawX + 3, drawY + 15, 10, 4);

  let bodyYOffset = 0;
  if (action === 'walking') {
    bodyYOffset = Math.abs(Math.sin(frame * 0.4) * 2);
  } else if (action === 'typing_laptop') {
    bodyYOffset = frame % 4 < 2 ? 0 : 1;
  } else if (action === 'petted') {
    bodyYOffset = Math.abs(Math.sin(frame * 0.3) * 1) + 1;
  } else if (action === 'idle') {
    bodyYOffset = Math.sin(frame * 0.1) * 1;
  } else if (action === 'napping' || action === 'sleeping') {
    bodyYOffset = 4 + Math.sin(frame * 0.05) * 1;
  }

  const bY = Math.floor(drawY - bodyYOffset);

  // --- 2. PET TAIL ---
  if (action !== 'napping' && action !== 'sleeping') {
    const tailWag = Math.sin(frame * (action === 'petted' ? 0.5 : 0.22)) * (action === 'petted' ? 6 : 3.5);
    ctx.save();
    ctx.translate(drawX - 2, bY + 9);
    ctx.rotate((tailWag * Math.PI) / 180);

    // Shadow outline
    ctx.fillStyle = '#92400e';
    ctx.fillRect(-3, -3, 6, 6);
    
    ctx.fillStyle = '#d97706';
    ctx.fillRect(-2, -2, 4, 4);
    ctx.fillStyle = '#f59e0b';
    ctx.fillRect(-1, -3, 3, 3);
    ctx.fillStyle = '#fef3c7'; // tip
    ctx.fillRect(-3, -4, 2, 2);
    ctx.restore();
  }

  // --- 3. PET BODY & FUR ---
  if (action === 'napping' || action === 'sleeping') {
    // C-shaped pixel body
    ctx.fillStyle = '#92400e'; // outline
    ctx.fillRect(drawX, bY + 4, 16, 12);
    
    ctx.fillStyle = '#d97706'; // shadow
    ctx.fillRect(drawX + 1, bY + 5, 14, 10);
    
    ctx.fillStyle = '#f59e0b'; // mid fur
    ctx.fillRect(drawX + 2, bY + 5, 12, 9);
    
    // hollow out center for C-shape
    ctx.clearRect(drawX + 6, bY + 7, 8, 4);
    ctx.fillStyle = '#fef3c7'; // belly inner
    ctx.fillRect(drawX + 5, bY + 8, 8, 3);

    // napping tail tucked
    ctx.fillStyle = '#f59e0b';
    ctx.fillRect(drawX + 12, bY + 11, 4, 3);
    ctx.fillStyle = '#fef3c7';
    ctx.fillRect(drawX + 14, bY + 12, 2, 2);

    // Head
    ctx.fillStyle = '#f59e0b';
    ctx.fillRect(drawX + 2, bY + 5, 8, 7);
    
    // Sleeping eye
    ctx.fillStyle = '#1a0a00';
    ctx.fillRect(drawX + 4, bY + 9, 2, 1);
    ctx.fillRect(drawX + 8, bY + 9, 2, 1);

    // z bubbles
    ctx.fillStyle = '#94a3b8';
    ctx.font = '8px monospace';
    const zOffset1 = (frame * 0.5) % 20;
    const zOffset2 = ((frame * 0.5) + 10) % 20;
    if (zOffset1 > 0) ctx.fillText('z', drawX + 12 + Math.sin(zOffset1 * 0.2)*2, bY - zOffset1);
    if (zOffset2 > 0) ctx.fillText('Z', drawX + 16 + Math.cos(zOffset2 * 0.2)*2, bY - 5 - zOffset2);

  } else {
    // Upright body
    // Outline first
    ctx.fillStyle = '#92400e';
    ctx.fillRect(drawX + 1, bY + 3, 16, 12);
    ctx.fillRect(drawX + 2, bY + 2, 14, 14);

    ctx.fillStyle = '#f59e0b'; // mid fur
    ctx.fillRect(drawX + 2, bY + 4, 14, 10);
    ctx.fillRect(drawX + 3, bY + 3, 12, 1); // top corner round
    ctx.fillRect(drawX + 3, bY + 13, 12, 1); // bottom corner round

    // Highlight (top-left face dither)
    ctx.fillStyle = '#fcd34d';
    for (let py = bY + 3; py < bY + 8; py++) {
      for (let px = drawX + 2; px < drawX + 8; px++) {
        if ((px + py) % 2 === 0) ctx.fillRect(px, py, 1, 1);
      }
    }

    // Shadow (bottom-right face dither)
    ctx.fillStyle = '#d97706';
    for (let py = bY + 8; py < bY + 14; py++) {
      for (let px = drawX + 8; px < drawX + 16; px++) {
        if ((px + py) % 2 === 0) ctx.fillRect(px, py, 1, 1);
      }
    }

    // Dithered chest patch
    ctx.fillStyle = '#fef3c7';
    for (let py = bY + 6; py < bY + 10; py++) {
      for (let px = drawX + 6; px < drawX + 12; px++) {
        const dist = Math.abs(px - (drawX+9)) + Math.abs(py - (bY+8));
        if (dist < 3 || (dist < 5 && (px+py)%2===0)) {
          ctx.fillRect(px, py, 1, 1);
        }
      }
    }

    // --- Head construction ---
    // Outline
    ctx.fillStyle = '#92400e';
    ctx.fillRect(drawX + 3, bY - 7, 12, 10);

    ctx.fillStyle = '#f59e0b';
    ctx.fillRect(drawX + 4, bY - 6, 10, 8);
    ctx.fillRect(drawX + 5, bY - 7, 8, 1);
    ctx.fillRect(drawX + 5, bY + 2, 8, 1);

    // Muzzle
    ctx.fillStyle = '#fef3c7';
    ctx.fillRect(drawX + 5, bY - 2, 6, 3);
    // nose
    ctx.fillStyle = '#1a0a00';
    ctx.fillRect(drawX + 7, bY - 2, 2, 1);

    // Ears
    if (action === 'typing_laptop') {
      // Headphones
      ctx.fillStyle = '#334155'; // Dark slate
      ctx.fillRect(drawX + 3, bY - 9, 2, 2);
      ctx.fillRect(drawX + 13, bY - 9, 2, 2);
      // Headband
      ctx.fillRect(drawX + 5, bY - 10, 8, 1);
      ctx.fillRect(drawX + 4, bY - 9, 1, 1);
      ctx.fillRect(drawX + 13, bY - 9, 1, 1);
    } else {
      // Left ear
      ctx.fillStyle = '#78350f'; // Outline
      ctx.fillRect(drawX + 3, bY - 11, 5, 6);
      
      ctx.fillStyle = '#d97706';
      ctx.fillRect(drawX + 4, bY - 10, 3, 4);
      ctx.fillRect(drawX + 5, bY - 11, 2, 1);
      
      ctx.fillStyle = '#fda4af';
      ctx.fillRect(drawX + 5, bY - 9, 1, 2);

      // Right ear
      ctx.fillStyle = '#78350f'; // Outline
      ctx.fillRect(drawX + 10, bY - 11, 5, 6);

      ctx.fillStyle = '#d97706';
      ctx.fillRect(drawX + 11, bY - 10, 3, 4);
      ctx.fillRect(drawX + 11, bY - 11, 2, 1);
      
      ctx.fillStyle = '#fda4af';
      ctx.fillRect(drawX + 12, bY - 9, 1, 2);
    }

    // Eyes
    if (action === 'petted') {
      // \( ˶ˆ꒳ˆ˵ )
      ctx.fillStyle = '#1a0a00';
      ctx.fillRect(drawX + 5, bY - 4, 3, 1);
      ctx.fillRect(drawX + 10, bY - 4, 3, 1);
    } else {
      // Left eye
      ctx.fillStyle = '#1a0a00'; // outline
      ctx.fillRect(drawX + 4, bY - 5, 4, 3);
      ctx.fillStyle = '#451a03'; // iris
      ctx.fillRect(drawX + 5, bY - 4, 2, 2);
      ctx.fillStyle = '#ffffff'; // specular
      ctx.fillRect(drawX + 6, bY - 5, 1, 1);

      // Right eye
      ctx.fillStyle = '#1a0a00'; // outline
      ctx.fillRect(drawX + 10, bY - 5, 4, 3);
      ctx.fillStyle = '#451a03'; // iris
      ctx.fillRect(drawX + 11, bY - 4, 2, 2);
      ctx.fillStyle = '#ffffff'; // specular
      ctx.fillRect(drawX + 12, bY - 5, 1, 1);
    }

    // Legs
    const drawLeg = (lx: number, ly: number, isFront: boolean) => {
      ctx.fillStyle = '#92400e';
      ctx.fillRect(lx - 1, ly, 4, 5); // outline
      ctx.fillStyle = isFront ? '#f59e0b' : '#d97706';
      ctx.fillRect(lx, ly, 2, 4);
      ctx.fillStyle = '#fef3c7'; // paw
      ctx.fillRect(lx, ly + 3, 2, 1);
    };

    let flY = bY + 12;
    let frY = bY + 12;
    let blY = bY + 12;
    let brY = bY + 12;

    if (action === 'walking') {
      flY += Math.sin(frame * 0.4) > 0 ? -1 : 1;
      frY += Math.sin(frame * 0.4 + Math.PI) > 0 ? -1 : 1;
      blY += Math.sin(frame * 0.4 + Math.PI) > 0 ? -1 : 1;
      brY += Math.sin(frame * 0.4) > 0 ? -1 : 1;
    } else if (action === 'typing_laptop') {
      const pawToggle = frame % 4 < 2;
      flY = bY + (pawToggle ? 10 : 9);
      frY = bY + (pawToggle ? 9 : 10);
    }

    drawLeg(drawX + 4, blY, false);
    drawLeg(drawX + 10, brY, false);
    drawLeg(drawX + 6, flY, true);
    drawLeg(drawX + 12, frY, true);

    // Overlays
    if (action === 'drinking_coffee') {
      // Blue ceramic mug 5x4px
      ctx.fillStyle = '#1a0a00'; // outline
      ctx.fillRect(drawX + 7, bY + 5, 7, 6);
      ctx.fillStyle = '#0ea5e9'; // mug
      ctx.fillRect(drawX + 8, bY + 6, 5, 4);
      
      // Steam (2 sinusoidal lines)
      ctx.fillStyle = 'rgba(255,255,255,0.6)';
      const sy1 = Math.floor(bY + 2 - (frame * 0.1) % 4);
      const sx1 = Math.floor(drawX + 9 + Math.sin(frame * 0.2));
      ctx.fillRect(sx1, sy1, 1, 1);
      ctx.fillRect(sx1 + 1, sy1 - 1, 1, 1);
      
      const sy2 = Math.floor(bY + 1 - (frame * 0.1) % 4);
      const sx2 = Math.floor(drawX + 11 + Math.cos(frame * 0.2));
      ctx.fillRect(sx2, sy2, 1, 1);
      ctx.fillRect(sx2 - 1, sy2 - 1, 1, 1);
    }

    if (action === 'petted') {
      // Pink heart particles
      ctx.fillStyle = '#ec4899';
      if (frame % 30 < 20) {
        // Heart 1
        const h1y = Math.floor(bY - 2 - (frame % 10) * 0.5);
        ctx.fillRect(drawX - 2, h1y, 1, 1);
        ctx.fillRect(drawX, h1y, 1, 1);
        ctx.fillRect(drawX - 2, h1y + 1, 3, 1);
        ctx.fillRect(drawX - 1, h1y + 2, 1, 1);
        
        // Heart 2
        const h2y = Math.floor(bY - 4 - (frame % 10) * 0.5);
        ctx.fillRect(drawX + 12, h2y, 1, 1);
        ctx.fillRect(drawX + 14, h2y, 1, 1);
        ctx.fillRect(drawX + 12, h2y + 1, 3, 1);
        ctx.fillRect(drawX + 13, h2y + 2, 1, 1);
      }
    }
  }

  ctx.restore();
}
