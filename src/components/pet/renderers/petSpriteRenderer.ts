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

/**
 * Enhanced Multi-Action High-Detail Pixel Pet Sprite Renderer
 * Features: Cute cat-like ears, expressive eyes with specular highlights, blush cheeks,
 * shaded fur gradients, and action-specific accessories.
 */
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
  ctx.beginPath();
  ctx.ellipse(drawX + 8, drawY + 17, 9, 3, 0, 0, Math.PI * 2);
  ctx.fill();

  // --- 2. PET TAIL ---
  const tailSway = Math.sin(frame * 0.3) * 3;
  ctx.fillStyle = '#7c3aed';
  ctx.fillRect(drawX - 3, drawY + 8 + tailSway, 3, 4);
  ctx.fillStyle = '#a78bfa';
  ctx.fillRect(drawX - 5, drawY + 6 + tailSway, 3, 3);

  // --- 3. PET BODY & FUR ---
  let bodyYOffset = 0;
  if (action === 'walking') {
    bodyYOffset = Math.abs(Math.sin(frame * 0.4) * 2);
  } else if (action === 'typing_laptop') {
    bodyYOffset = frame % 2 === 0 ? 0 : 1;
  } else if (action === 'micro_dance') {
    bodyYOffset = Math.abs(Math.sin(frame * 0.6) * 4);
  } else if (action === 'petted') {
    bodyYOffset = Math.abs(Math.sin(frame * 0.8) * 3);
  }

  const bY = drawY - bodyYOffset;

  // Base Body (Cute Rounded Pixel Body)
  ctx.fillStyle = '#8b5cf6'; // Primary Purple
  ctx.fillRect(drawX + 1, bY + 4, 14, 12);
  ctx.fillRect(drawX + 2, bY + 2, 12, 15);

  // Body Shading / Shadow
  ctx.fillStyle = '#6d28d9';
  ctx.fillRect(drawX + 1, bY + 12, 14, 4);
  ctx.fillRect(drawX + 2, bY + 14, 12, 3);

  // Body Highlight (Top & Left)
  ctx.fillStyle = '#c4b5fd';
  ctx.fillRect(drawX + 3, bY + 2, 10, 2);
  ctx.fillRect(drawX + 2, bY + 4, 2, 8);

  // --- 4. CUTE EARS ---
  // Left Ear
  ctx.fillStyle = '#7c3aed';
  ctx.fillRect(drawX + 2, bY - 3, 4, 5);
  ctx.fillRect(drawX + 3, bY - 5, 2, 3);
  ctx.fillStyle = '#f472b6'; // Pink Inner Ear
  ctx.fillRect(drawX + 3, bY - 2, 2, 3);

  // Right Ear
  ctx.fillStyle = '#7c3aed';
  ctx.fillRect(drawX + 10, bY - 3, 4, 5);
  ctx.fillRect(drawX + 11, bY - 5, 2, 3);
  ctx.fillStyle = '#f472b6'; // Pink Inner Ear
  ctx.fillRect(drawX + 11, bY - 2, 2, 3);

  // --- 5. FEET / LEGS ---
  if (action === 'walking') {
    const legPhase = frame % 4;
    ctx.fillStyle = '#6d28d9';
    if (legPhase === 0 || legPhase === 2) {
      ctx.fillRect(drawX + 2, bY + 15, 3, 3);
      ctx.fillRect(drawX + 11, bY + 15, 3, 3);
    } else {
      ctx.fillRect(drawX + 4, bY + 14, 3, 3);
      ctx.fillRect(drawX + 9, bY + 14, 3, 3);
    }
  } else {
    // Sitting / Idle feet
    ctx.fillStyle = '#6d28d9';
    ctx.fillRect(drawX + 3, bY + 15, 3, 2);
    ctx.fillRect(drawX + 10, bY + 15, 3, 2);
  }

  // --- 6. FACIAL FEATURES & EYES ---
  if (action === 'napping') {
    // Sleeping Eyes (^ ^ or - -)
    ctx.fillStyle = '#312e81';
    ctx.fillRect(drawX + 4, bY + 7, 3, 1);
    ctx.fillRect(drawX + 10, bY + 7, 3, 1);

    // Sleep 'Z' Particles
    ctx.fillStyle = '#94a3b8';
    ctx.font = '8px monospace';
    const zFloat = (frame % 12);
    ctx.fillText('z', drawX + 16, bY - zFloat);
  } else if (action === 'petted') {
    // Happy Heart/Wink Eyes
    ctx.fillStyle = '#ec4899';
    ctx.font = '8px monospace';
    ctx.fillText('♥', drawX + 3, bY + 9);
    ctx.fillText('♥', drawX + 9, bY + 9);

    // Cute Blush
    ctx.fillStyle = 'rgba(244, 114, 182, 0.7)';
    ctx.fillRect(drawX + 2, bY + 9, 2, 2);
    ctx.fillRect(drawX + 12, bY + 9, 2, 2);
  } else if (action === 'drinking_coffee') {
    // Savoring Eyes (^ ^)
    ctx.fillStyle = '#1e1b4b';
    ctx.fillRect(drawX + 4, bY + 6, 3, 1);
    ctx.fillRect(drawX + 3, bY + 7, 1, 1);
    ctx.fillRect(drawX + 6, bY + 7, 1, 1);

    ctx.fillRect(drawX + 10, bY + 6, 3, 1);
    ctx.fillRect(drawX + 9, bY + 7, 1, 1);
    ctx.fillRect(drawX + 12, bY + 7, 1, 1);

    // Coffee Mug in Paws
    ctx.fillStyle = '#f59e0b';
    ctx.fillRect(drawX + 6, bY + 8, 5, 6);
    ctx.fillStyle = '#ffffff';
    ctx.fillRect(drawX + 7, bY + 7, 3, 2); // Cream foam

    // Rising Steam Mote
    ctx.fillStyle = 'rgba(255, 255, 255, 0.6)';
    ctx.fillRect(drawX + 7 + Math.sin(frame * 0.3) * 2, bY + 3 - (frame % 6), 2, 2);
  } else if (action === 'typing_laptop') {
    // Focused Laptop Eyes (Looking Right/Down with Specular Highlight)
    ctx.fillStyle = '#0f172a';
    ctx.fillRect(drawX + 5, bY + 6, 3, 3);
    ctx.fillRect(drawX + 10, bY + 6, 3, 3);

    // Specular Eye Highlight
    ctx.fillStyle = '#ffffff';
    ctx.fillRect(drawX + 5, bY + 6, 1, 1);
    ctx.fillRect(drawX + 10, bY + 6, 1, 1);

    // Cute Paws Typing
    ctx.fillStyle = '#c4b5fd';
    const pawToggle = frame % 2 === 0;
    ctx.fillRect(drawX + 12, bY + (pawToggle ? 10 : 9), 3, 2);
    ctx.fillRect(drawX + 14, bY + (pawToggle ? 9 : 10), 3, 2);
  } else {
    // Normal / Looking at User Expressive Eyes
    const isBlinking = frame % 40 > 37;
    if (isBlinking) {
      ctx.fillStyle = '#1e1b4b';
      ctx.fillRect(drawX + 4, bY + 7, 3, 1);
      ctx.fillRect(drawX + 10, bY + 7, 3, 1);
    } else {
      // Big Cute Anime/Pixel Eyes with Shading
      ctx.fillStyle = '#0f172a';
      ctx.fillRect(drawX + 4, bY + 5, 3, 4);
      ctx.fillRect(drawX + 10, bY + 5, 3, 4);

      // White Glint
      ctx.fillStyle = '#ffffff';
      ctx.fillRect(drawX + 4, bY + 5, 2, 2);
      ctx.fillRect(drawX + 10, bY + 5, 2, 2);

      // Pupil Blue Tint
      ctx.fillStyle = '#38bdf8';
      ctx.fillRect(drawX + 5, bY + 7, 2, 2);
      ctx.fillRect(drawX + 11, bY + 7, 2, 2);
    }

    // Cute Rosy Cheeks
    ctx.fillStyle = 'rgba(251, 113, 133, 0.5)';
    ctx.fillRect(drawX + 2, bY + 8, 2, 2);
    ctx.fillRect(drawX + 12, bY + 8, 2, 2);
  }

  ctx.restore();
}
