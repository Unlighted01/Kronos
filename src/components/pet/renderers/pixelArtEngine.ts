// Pixel palette type — each material has 3 tones
export interface PixelPalette {
  highlight: string;
  mid: string;
  shadow: string;
  outline: string;
}

// Common palettes
export const PALETTES = {
  oakWood: { highlight: '#d97706', mid: '#92400e', shadow: '#451a03', outline: '#1c0a00' },
  darkWalnut: { highlight: '#92400e', mid: '#78350f', shadow: '#3c1a0a', outline: '#1c0800' },
  stone: { highlight: '#9ca3af', mid: '#6b7280', shadow: '#374151', outline: '#1f2937' },
  brick: { highlight: '#ef4444', mid: '#b91c1c', shadow: '#7f1d1d', outline: '#450a0a' },
  cream: { highlight: '#fef9c3', mid: '#fef08a', shadow: '#ca8a04', outline: '#78350f' },
  slate: { highlight: '#64748b', mid: '#475569', shadow: '#1e293b', outline: '#0f172a' },
  iron: { highlight: '#9ca3af', mid: '#4b5563', shadow: '#1f2937', outline: '#111827' },
  terracotta: { highlight: '#fb923c', mid: '#ea580c', shadow: '#9a3412', outline: '#431407' },
  glass: { highlight: '#bae6fd', mid: '#7dd3fc', shadow: '#0284c7', outline: '#075985' },
  plaster: { highlight: '#e2e8f0', mid: '#cbd5e1', shadow: '#94a3b8', outline: '#475569' },
};

export function drawPixelRect(
  ctx: CanvasRenderingContext2D,
  x: number, y: number, w: number, h: number,
  palette: PixelPalette
): void {
  ctx.fillStyle = palette.mid;
  ctx.fillRect(x, y, w, h);
  ctx.fillStyle = palette.outline;
  ctx.fillRect(x, y, w, 1);
  ctx.fillRect(x, y + h - 1, w, 1);
  ctx.fillRect(x, y, 1, h);
  ctx.fillRect(x + w - 1, y, 1, h);
  ctx.fillStyle = palette.highlight;
  ctx.fillRect(x + 1, y + 1, w - 2, 1);
  ctx.fillRect(x + 1, y + 1, 1, h - 2);
  ctx.fillStyle = palette.shadow;
  ctx.fillRect(x + 1, y + h - 2, w - 2, 1);
  ctx.fillRect(x + w - 2, y + 1, 1, h - 2);
}

export function dither(
  ctx: CanvasRenderingContext2D,
  x: number, y: number, w: number, h: number,
  color: string, density: number
): void {
  ctx.fillStyle = color;
  const step = density >= 0.5 ? 2 : 4;
  for (let py = y; py < y + h; py++) {
    for (let px = x; px < x + w; px++) {
      if ((px + py) % step === 0) {
        ctx.fillRect(px, py, 1, 1);
      }
    }
  }
}

export function drawWoodGrain(
  ctx: CanvasRenderingContext2D,
  x: number, y: number, w: number, h: number,
  palette: PixelPalette,
  plankHeight: number = 8
): void {
  ctx.fillStyle = palette.mid;
  ctx.fillRect(x, y, w, h);
  
  ctx.fillStyle = palette.outline;
  for (let py = y + plankHeight; py < y + h; py += plankHeight) {
    ctx.fillRect(x, py, w, 1);
  }
  
  ctx.fillStyle = palette.shadow;
  for (let py = y; py < y + h; py += plankHeight) {
    ctx.fillRect(x, py + 3, w, 1);
    if (plankHeight >= 8) ctx.fillRect(x, py + 6, w, 1);
  }
  
  ctx.fillStyle = palette.highlight;
  ctx.fillRect(x, y, w, 1);
  
  ctx.fillStyle = palette.outline;
  const stagger = Math.floor(w / 4);
  for (let py = y; py < y + h; py += plankHeight) {
    const offset = ((py / plankHeight) % 2 === 0) ? 0 : stagger;
    for (let px = x + offset; px < x + w; px += stagger * 2) {
      ctx.fillRect(px, py, 1, plankHeight);
    }
  }
  
  ctx.fillStyle = palette.shadow;
  for (let py = y + 3; py < y + h; py += plankHeight * 2 + 7) {
    const kx = x + ((py * 17) % Math.max(1, w - 6));
    ctx.fillRect(kx, py, 4, 3);
    ctx.fillRect(kx + 1, py - 1, 2, 1);
    ctx.fillRect(kx + 1, py + 3, 2, 1);
  }
}

export function drawBrickWall(
  ctx: CanvasRenderingContext2D,
  x: number, y: number, w: number, h: number,
  palette: PixelPalette,
  brickH: number = 6,
  brickW: number = 16
): void {
  ctx.fillStyle = palette.mid;
  ctx.fillRect(x, y, w, h);
  
  ctx.fillStyle = palette.outline;
  for (let py = y; py < y + h; py += brickH) {
    ctx.fillRect(x, py, w, 1);
  }
  
  for (let py = y; py < y + h; py += brickH) {
    const row = Math.floor((py - y) / brickH);
    const offsetX = (row % 2 === 0) ? 0 : brickW / 2;
    for (let px = x + offsetX; px < x + w; px += brickW) {
      ctx.fillRect(px, py, 1, brickH);
    }
  }
  
  ctx.fillStyle = palette.highlight;
  for (let py = y + 1; py < y + h; py += brickH) {
    ctx.fillRect(x, py, w, 1);
  }
  
  ctx.fillStyle = palette.shadow;
  for (let py = y + brickH - 2; py < y + h; py += brickH) {
    ctx.fillRect(x, py, w, 1);
  }
}

export function drawTileFloor(
  ctx: CanvasRenderingContext2D,
  x: number, y: number, w: number, h: number,
  colorA: string, colorB: string, grout: string,
  tileSize: number = 8
): void {
  for (let py = y; py < y + h; py += tileSize) {
    for (let px = x; px < x + w; px += tileSize) {
      const row = Math.floor((py - y) / tileSize);
      const col = Math.floor((px - x) / tileSize);
      ctx.fillStyle = (row + col) % 2 === 0 ? colorA : colorB;
      ctx.fillRect(px + 1, py + 1, Math.min(tileSize - 1, x + w - px - 1), Math.min(tileSize - 1, y + h - py - 1));
    }
  }
  ctx.fillStyle = grout;
  for (let py = y; py < y + h; py += tileSize) ctx.fillRect(x, py, w, 1);
  for (let px = x; px < x + w; px += tileSize) ctx.fillRect(px, y, 1, h);
}

export function drawPseudo3DBox(
  ctx: CanvasRenderingContext2D,
  x: number, y: number, w: number, h: number,
  topH: number,
  palette: PixelPalette
): void {
  ctx.fillStyle = palette.highlight;
  ctx.fillRect(x, y, w, topH);
  ctx.fillStyle = palette.mid;
  ctx.fillRect(x, y + topH, w, h - topH);
  ctx.fillStyle = palette.outline;
  ctx.fillRect(x, y, w, 1);
  ctx.fillRect(x, y + h - 1, w, 1);
  ctx.fillRect(x, y, 1, h);
  ctx.fillRect(x + w - 1, y, 1, h);
  ctx.fillRect(x, y + topH, w, 1);
  ctx.fillStyle = palette.shadow;
  ctx.fillRect(x + w - 2, y + topH + 1, 1, h - topH - 2);
}

export function drawPixelSphere(
  ctx: CanvasRenderingContext2D,
  cx: number, cy: number, r: number,
  palette: PixelPalette
): void {
  ctx.fillStyle = palette.mid;
  ctx.beginPath();
  ctx.arc(cx, cy, r, 0, Math.PI * 2);
  ctx.fill();
  ctx.strokeStyle = palette.outline;
  ctx.lineWidth = 1;
  ctx.beginPath();
  ctx.arc(cx, cy, r, 0, Math.PI * 2);
  ctx.stroke();
  ctx.fillStyle = palette.highlight;
  for (let py = cy - r; py < cy; py++) {
    for (let px = cx - r; px < cx; px++) {
      const dist = Math.sqrt((px - cx) ** 2 + (py - cy) ** 2);
      if (dist < r - 1 && (px + py) % 2 === 0) {
        ctx.fillRect(px, py, 1, 1);
      }
    }
  }
  ctx.fillStyle = palette.shadow;
  for (let py = cy; py < cy + r; py++) {
    for (let px = cx; px < cx + r; px++) {
      const dist = Math.sqrt((px - cx) ** 2 + (py - cy) ** 2);
      if (dist < r - 1 && (px + py) % 2 === 0) {
        ctx.fillRect(px, py, 1, 1);
      }
    }
  }
}

export function drawFabric(
  ctx: CanvasRenderingContext2D,
  x: number, y: number, w: number, h: number,
  palette: PixelPalette,
  tuftSpacing: number = 8
): void {
  ctx.fillStyle = palette.mid;
  ctx.fillRect(x, y, w, h);
  ctx.fillStyle = palette.highlight;
  ctx.fillRect(x, y, w, 2);
  ctx.fillStyle = palette.shadow;
  ctx.fillRect(x, y + h - 2, w, 2);
  ctx.fillStyle = palette.outline;
  ctx.fillRect(x, y, w, 1);
  ctx.fillRect(x, y + h - 1, w, 1);
  ctx.fillRect(x, y, 1, h);
  ctx.fillRect(x + w - 1, y, 1, h);
  ctx.fillStyle = palette.shadow;
  for (let px = x + tuftSpacing; px < x + w - 2; px += tuftSpacing) {
    for (let py = y + Math.floor(tuftSpacing / 2); py < y + h - 2; py += tuftSpacing) {
      ctx.fillRect(px, py, 2, 2);
    }
  }
}

export function drawLeaf(
  ctx: CanvasRenderingContext2D,
  x: number, y: number,
  color: string, shadowColor: string,
  size: number = 4
): void {
  ctx.fillStyle = color;
  ctx.fillRect(x, y, size, size);
  ctx.fillRect(x + 1, y - 1, size - 2, 1);
  ctx.fillRect(x + 1, y + size, size - 2, 1);
  ctx.fillStyle = shadowColor;
  ctx.fillRect(x + Math.floor(size / 2), y, 1, size);
}
