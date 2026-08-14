import { TimeOfDay } from '../types/biomeTypes';

export function getTimeOfDay(): TimeOfDay {
  const hour = new Date().getHours();
  if (hour >= 5 && hour < 8) return 'dawn';
  if (hour >= 8 && hour < 17) return 'day';
  if (hour >= 17 && hour < 20) return 'sunset';
  return 'night';
}

export function drawWindowSky(
  ctx: CanvasRenderingContext2D,
  winX: number,
  winY: number,
  winW: number,
  winH: number,
  timeOfDay: TimeOfDay,
  frame: number
): void {
  // Window Background based on time of day
  ctx.save();
  ctx.beginPath();
  ctx.rect(winX, winY, winW, winH);
  ctx.clip();

  if (timeOfDay === 'dawn') {
    const grad = ctx.createLinearGradient(winX, winY, winX, winY + winH);
    grad.addColorStop(0, '#f472b6');
    grad.addColorStop(1, '#fdba74');
    ctx.fillStyle = grad;
    ctx.fillRect(winX, winY, winW, winH);

    // Rising Sun
    ctx.fillStyle = '#fef08a';
    ctx.fillRect(winX + winW / 2 - 4, winY + winH - 12, 8, 8);
  } else if (timeOfDay === 'day') {
    const grad = ctx.createLinearGradient(winX, winY, winX, winY + winH);
    grad.addColorStop(0, '#38bdf8');
    grad.addColorStop(1, '#93c5fd');
    ctx.fillStyle = grad;
    ctx.fillRect(winX, winY, winW, winH);

    // Bright Sun
    ctx.fillStyle = '#fef08a';
    ctx.fillRect(winX + winW - 12, winY + 4, 6, 6);

    // Drifting pixel clouds
    ctx.fillStyle = 'rgba(255, 255, 255, 0.8)';
    const cloudX = winX + ((frame * 0.2) % (winW + 20)) - 10;
    ctx.fillRect(cloudX, winY + 8, 12, 4);
    ctx.fillRect(cloudX + 3, winY + 6, 6, 2);
  } else if (timeOfDay === 'sunset') {
    const grad = ctx.createLinearGradient(winX, winY, winX, winY + winH);
    grad.addColorStop(0, '#7c3aed');
    grad.addColorStop(0.5, '#f97316');
    grad.addColorStop(1, '#fbbf24');
    ctx.fillStyle = grad;
    ctx.fillRect(winX, winY, winW, winH);

    // Setting Sun
    ctx.fillStyle = '#f43f5e';
    ctx.fillRect(winX + 6, winY + winH - 10, 8, 8);
  } else {
    // Night
    const grad = ctx.createLinearGradient(winX, winY, winX, winY + winH);
    grad.addColorStop(0, '#020617');
    grad.addColorStop(1, '#0f172a');
    ctx.fillStyle = grad;
    ctx.fillRect(winX, winY, winW, winH);

    // Moon
    ctx.fillStyle = '#fef08a';
    ctx.fillRect(winX + winW - 10, winY + 4, 5, 5);
    ctx.fillStyle = '#020617';
    ctx.fillRect(winX + winW - 8, winY + 4, 3, 5);

    // Twinkling stars
    ctx.fillStyle = frame % 20 < 10 ? '#ffffff' : '#94a3b8';
    ctx.fillRect(winX + 4, winY + 6, 1.5, 1.5);
    ctx.fillRect(winX + 12, winY + 14, 1.5, 1.5);
  }

  ctx.restore();

  // 4-Pane Window Frame
  ctx.strokeStyle = '#334155';
  ctx.lineWidth = 2;
  ctx.strokeRect(winX, winY, winW, winH);

  ctx.fillStyle = '#334155';
  ctx.fillRect(winX + winW / 2 - 1, winY, 2, winH);
  ctx.fillRect(winX, winY + winH / 2 - 1, winW, 2);
}
