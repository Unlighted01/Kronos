import React, { useEffect, useRef } from "react";
import { TimerMode, TimerStatus } from "../../stores/useTimerStore";

interface PlatformerPetCanvasProps {
    mode: TimerMode;
    status: TimerStatus;
    width?: number;
    height?: number;
}

export const PlatformerPetCanvas: React.FC<PlatformerPetCanvasProps> = ({
    mode,
    status,
    width = 240,
    height = 140,
}) => {
    const canvasRef = useRef<HTMLCanvasElement | null>(null);
    const frameRef = useRef<number>(0);
    const petXRef = useRef<number>(60);
    const petDirectionRef = useRef<number>(1); // 1 = right, -1 = left

    useEffect(() => {
        const canvas = canvasRef.current;
        if (!canvas) return;
        const ctx = canvas.getContext("2d");
        if (!ctx) return;

        ctx.imageSmoothingEnabled = false;

        let lastTime = performance.now();
        const frameInterval = 1000 / 12; // Throttled to 12 FPS for retro pixel look & <0.1% CPU

        let animationId: number;

        const render = (now: number) => {
            animationId = requestAnimationFrame(render);

            const elapsed = now - lastTime;
            if (elapsed < frameInterval) return;
            lastTime = now - (elapsed % frameInterval);

            frameRef.current = (frameRef.current + 1) % 60;
            const frame = frameRef.current;

            // Clear Canvas
            ctx.clearRect(0, 0, width, height);

            // 1. Draw 2D Pixel Platform Background (Room Wallpaper)
            ctx.fillStyle = "#0f172a"; // Deep night sky
            ctx.fillRect(0, 0, width, height);

            // Stars / Wall Grid
            ctx.fillStyle = "#1e293b";
            for (let i = 10; i < width; i += 30) {
                for (let j = 10; j < height - 30; j += 30) {
                    ctx.fillRect(i, j, 2, 2);
                }
            }

            // 2. Draw 2D Pixel Platform Floor (Grass/Brick Top)
            const platformY = height - 28;

            // Platform Base
            ctx.fillStyle = "#1e1b4b";
            ctx.fillRect(0, platformY, width, 28);

            // Platform Top Grass Layer
            ctx.fillStyle = "#4f46e5";
            ctx.fillRect(0, platformY, width, 4);

            // Platform Edge Highlights
            ctx.fillStyle = "#818cf8";
            for (let x = 0; x < width; x += 8) {
                ctx.fillRect(x, platformY, 4, 2);
            }

            // 3. Draw Workstation Furniture (Desk, Monitor, Chair)
            const deskX = width - 75;
            const deskY = platformY - 24;

            // Desk Wood
            ctx.fillStyle = "#312e81";
            ctx.fillRect(deskX, deskY, 45, 24);
            ctx.fillStyle = "#4338ca";
            ctx.fillRect(deskX, deskY, 45, 4); // Desk surface highlight

            // Laptop / Monitor
            ctx.fillStyle = "#64748b";
            ctx.fillRect(deskX + 12, deskY - 18, 22, 18);
            ctx.fillStyle =
                status === "running" && mode === "work" ? "#38bdf8" : "#0284c7";
            ctx.fillRect(deskX + 14, deskY - 16, 18, 14);

            // Code Lines on Screen
            if (status === "running" && mode === "work") {
                ctx.fillStyle = "#ffffff";
                const lineOffset = (frame % 3) * 3;
                ctx.fillRect(deskX + 16, deskY - 14 + lineOffset, 8, 2);
                ctx.fillRect(deskX + 16, deskY - 10 + lineOffset, 12, 2);
            }

            // Chair
            ctx.fillStyle = "#475569";
            ctx.fillRect(deskX - 14, deskY + 6, 12, 18);
            ctx.fillRect(deskX - 16, deskY - 6, 4, 20); // Chair Backrest

            // 4. Draw Animated 2D Pixel Pet (Tamagotchi)
            if (mode === "work" && status === "running") {
                // --- WORK STATE: Pet sitting at desk typing ---
                const petX = deskX - 10;
                const petY = deskY + 2 + (frame % 2 === 0 ? 0 : -1); // Subtle typing wobble

                // Body (Purple Blob / Slime Pet)
                ctx.fillStyle = "#a855f7";
                ctx.fillRect(petX, petY, 16, 14);
                ctx.fillStyle = "#c084fc";
                ctx.fillRect(petX + 2, petY + 2, 12, 4); // Body highlight

                // Eyes
                ctx.fillStyle = "#ffffff";
                ctx.fillRect(petX + 10, petY + 4, 3, 3);
                ctx.fillStyle = "#0f172a";
                ctx.fillRect(petX + 11, petY + 5, 2, 2);

                // Cute Glasses
                ctx.fillStyle = "#fbbf24";
                ctx.fillRect(petX + 8, petY + 3, 6, 5);
                ctx.fillStyle = "#38bdf8";
                ctx.fillRect(petX + 9, petY + 4, 4, 3);

                // Typing Hands
                if (frame % 2 === 0) {
                    ctx.fillStyle = "#c084fc";
                    ctx.fillRect(petX + 14, petY + 10, 4, 3);
                } else {
                    ctx.fillStyle = "#c084fc";
                    ctx.fillRect(petX + 15, petY + 9, 4, 3);
                }

                // Floating Code Sparkles
                ctx.fillStyle = "#f472b6";
                const sparkleY = petY - 8 - (frame % 6);
                ctx.fillRect(petX + (frame % 10), sparkleY, 2, 2);
            } else if (mode !== "work" && status === "running") {
                // --- BREAK STATE: Pet walking along 2D platform ---
                petXRef.current += petDirectionRef.current * 0.8;
                if (petXRef.current > deskX - 30) petDirectionRef.current = -1;
                if (petXRef.current < 20) petDirectionRef.current = 1;

                const petX = petXRef.current;
                const bounceY =
                    platformY - 16 - Math.abs(Math.sin(frame * 0.3) * 4);

                // Body
                ctx.fillStyle = "#ec4899";
                ctx.fillRect(petX, bounceY, 16, 14);
                ctx.fillStyle = "#f472b6";
                ctx.fillRect(petX + 2, bounceY + 2, 12, 4);

                // Eyes (Happy Cheerful eyes)
                ctx.fillStyle = "#ffffff";
                ctx.fillRect(petX + 4, bounceY + 4, 3, 3);
                ctx.fillRect(petX + 10, bounceY + 4, 3, 3);
                ctx.fillStyle = "#0f172a";
                ctx.fillRect(petX + 5, bounceY + 5, 1, 2);
                ctx.fillRect(petX + 11, bounceY + 5, 1, 2);

                // Floating Coffee Cup or Heart
                ctx.fillStyle = "#f59e0b";
                ctx.fillRect(petX + 6, bounceY - 10, 4, 6);
            } else {
                // --- IDLE / PAUSED STATE: Pet standing on platform breathing ---
                const petX = 60;
                const idleBreathY =
                    platformY - 16 + (Math.floor(frame / 6) % 2 === 0 ? 0 : 1);

                // Body
                ctx.fillStyle = "#8b5cf6";
                ctx.fillRect(petX, idleBreathY, 16, 14);
                ctx.fillStyle = "#a78bfa";
                ctx.fillRect(petX + 2, idleBreathY + 2, 12, 4);

                // Eyes (Blinking animation)
                const isBlinking = frame % 20 === 0 || frame % 20 === 1;
                ctx.fillStyle = "#ffffff";
                if (!isBlinking) {
                    ctx.fillRect(petX + 3, idleBreathY + 4, 3, 3);
                    ctx.fillRect(petX + 10, idleBreathY + 4, 3, 3);
                    ctx.fillStyle = "#0f172a";
                    ctx.fillRect(petX + 4, idleBreathY + 5, 2, 2);
                    ctx.fillRect(petX + 11, idleBreathY + 5, 2, 2);
                } else {
                    ctx.fillStyle = "#0f172a";
                    ctx.fillRect(petX + 3, idleBreathY + 6, 3, 1);
                    ctx.fillRect(petX + 10, idleBreathY + 6, 3, 1);
                }

                // Zzz Floating Sleep particles when paused
                if (status === "paused") {
                    ctx.fillStyle = "#94a3b8";
                    const zY = idleBreathY - 8 - ((frame * 2) % 12);
                    const zX = petX + 14 + (frame % 6);
                    ctx.font = "8px monospace";
                    ctx.fillText("z", zX, zY);
                }
            }
        };

        animationId = requestAnimationFrame(render);

        return () => {
            cancelAnimationFrame(animationId);
        };
    }, [mode, status, width, height]);

    return (
        <div className="relative rounded-xl overflow-hidden border border-indigo-500/20 shadow-inner">
            <canvas
                ref={canvasRef}
                width={width}
                height={height}
                style={{
                    imageRendering: "pixelated",
                    width: `${width}px`,
                    height: `${height}px`,
                }}
            />
        </div>
    );
};
