import React, { useEffect } from 'react';
import { useAppStore } from '../../stores/useAppStore';
import { useTimerStore } from '../../stores/useTimerStore';
import { PlatformerPetCanvas } from '../pet/PlatformerPetCanvas';
import { PresetScale } from './WidgetSettingsPopover';
import { audioSynth } from '../../utils/audioSynth';

interface WidgetViewProps {
  leftOpen?: boolean;
  rightOpen?: boolean;
  onToggleLeft?: () => void;
  onToggleRight?: () => void;
  scale?: PresetScale;
}

export const WidgetView: React.FC<WidgetViewProps> = ({
  leftOpen = false,
  rightOpen = false,
  onToggleLeft,
  onToggleRight,
  scale = '1x',
}) => {
  const { alwaysOnTop, setAlwaysOnTop } = useAppStore();
  const {
    mode,
    status,
    timeLeft,
    startTimer,
    pauseTimer,
    resetTimer,
    skipPhase,
    tick,
  } = useTimerStore();

  // Sync initial Pin state on mount
  useEffect(() => {
    if (window.kronosElectron?.getPinState) {
      window.kronosElectron
        .getPinState()
        .then((pinned) => {
          setAlwaysOnTop(pinned);
        })
        .catch(() => {});
    }
  }, [setAlwaysOnTop]);

  // Timer Tick Interval Effect with Cleanup
  useEffect(() => {
    let interval: NodeJS.Timeout | null = null;
    if (status === 'running') {
      interval = setInterval(() => {
        tick();
      }, 1000);
    }
    return () => {
      if (interval) clearInterval(interval);
    };
  }, [status, tick]);

  // IPC Tray Listener Effect
  useEffect(() => {
    if (window.kronosElectron?.onTimerAction) {
      window.kronosElectron.onTimerAction((action) => {
        if (action === 'toggle') {
          if (status === 'running') {
            pauseTimer();
          } else {
            startTimer();
          }
        } else if (action === 'reset') {
          resetTimer();
        }
      });
    }
  }, [status, startTimer, pauseTimer, resetTimer]);

  const formatTime = (seconds: number): string => {
    const mins = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
  };

  const handleTogglePlay = () => {
    audioSynth.playClick();
    if (status === 'running') {
      pauseTimer();
    } else {
      startTimer();
    }
  };

  const handleReset = () => {
    audioSynth.playClick();
    resetTimer();
  };

  const handleSkip = () => {
    audioSynth.playChime();
    skipPhase(true);
  };

  const handleClose = (e: React.MouseEvent) => {
    e.stopPropagation();
    audioSynth.playClick();
    if (window.kronosElectron?.closeWidget) {
      window.kronosElectron.closeWidget();
    } else {
      window.close();
    }
  };

  // Responsive dynamic platformer dimensions based on active scale preset
  const canvasWidth = scale === '1.5x' ? 360 : scale === '1.25x' ? 300 : 240;
  const canvasHeight = scale === '1.5x' ? 210 : scale === '1.25x' ? 175 : 140;

  return (
    <div style={{ display: 'flex', flexDirection: 'column', height: '100%', width: '100%', userSelect: 'none', backgroundColor: 'var(--px-bg-base)' }}>
      {/* Clean Single-Line Titlebar (36px) */}
      <header
        className="px-header"
        style={{ WebkitAppRegion: alwaysOnTop ? 'no-drag' : 'drag' } as React.CSSProperties}
      >
        {/* Left Section */}
        <div className="no-drag" style={{ WebkitAppRegion: 'no-drag' } as React.CSSProperties}>
          {onToggleLeft && (
            <button
              onClick={onToggleLeft}
              title={leftOpen ? 'Collapse Shop & Settings' : 'Expand Shop & Settings'}
              className={`px-btn ${leftOpen ? 'px-btn--cyan' : ''}`}
            >
              {leftOpen ? '▶' : '◀'}
            </button>
          )}
        </div>

        {/* Center Section: Continuous Drag Region */}
        <div style={{ flex: 1, display: 'flex', justifyContent: 'center', alignItems: 'center' }}>
          <span className="px-title">KRONOS</span>
        </div>

        {/* Right Section */}
        <div
          className="no-drag"
          style={{ WebkitAppRegion: 'no-drag', display: 'flex', gap: '4px' } as React.CSSProperties}
        >
          {onToggleRight && (
            <button
              onClick={onToggleRight}
              title={rightOpen ? 'Collapse Vitals & DTR' : 'Expand Vitals & DTR'}
              className={`px-btn ${rightOpen ? 'px-btn--cyan' : ''}`}
            >
              {rightOpen ? '◀' : '▶'}
            </button>
          )}

          <button
            onClick={handleClose}
            title="Quit Kronos"
            className="px-btn px-btn--danger"
          >
            ✕
          </button>
        </div>
      </header>

      {/* Main Dynamic Content Workspace */}
      <main style={{ flex: 1, display: 'flex', flexDirection: 'column', overflow: 'hidden', minHeight: 0, justifyContent: 'space-between' }}>
        {/* 2D Pixel Platformer Pet Canvas Section */}
        <div style={{ flex: 1, display: 'flex', flexDirection: 'column', justifyContent: 'center', alignItems: 'center', minHeight: 0, overflow: 'hidden', padding: '6px 0 2px' }}>
          <PlatformerPetCanvas
            mode={mode}
            status={status}
            width={canvasWidth}
            height={canvasHeight}
          />
        </div>

        {/* Timer Readout & Controls — docked to bottom, no extra margin */}
        <div
          className="no-drag"
          style={{
            display: 'flex',
            flexDirection: 'column',
            alignItems: 'center',
            padding: '6px 8px 8px',
            borderTop: '2px solid var(--px-border)',
            background: 'var(--px-bg-base)',
            WebkitAppRegion: 'no-drag',
            flexShrink: 0,
          } as React.CSSProperties}
        >
          {/* Phase label */}
          <div className={`px-phase-label--${mode === 'work' ? 'work' : mode === 'shortBreak' ? 'break' : 'longbreak'}`}>
            {mode === 'work' ? 'FOCUS' : mode === 'shortBreak' ? 'SHORT BREAK' : 'LONG BREAK'}
          </div>

          {/* Timer */}
          <div className="px-timer" style={{ margin: '4px 0 6px' }}>
            {formatTime(timeLeft)}
          </div>

          {/* Controls */}
          <div style={{ display: 'flex', gap: '4px', justifyContent: 'center', alignItems: 'center', width: '100%', flexShrink: 0 }}>
            <button
              onClick={handleTogglePlay}
              className="px-btn px-btn--cyan"
              style={{ minWidth: '76px', justifyContent: 'center' }}
            >
              {status === 'running' ? '❙❙ PAUSE' : '▶ START'}
            </button>
            <button onClick={handleReset} className="px-btn" title="Reset Timer">↺</button>
            <button onClick={handleSkip} className="px-btn" title="Skip Phase">⏭</button>
          </div>
        </div>
      </main>
    </div>
  );
};
