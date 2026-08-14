import React, { useEffect } from 'react';
import {
  Play,
  Pause,
  RotateCcw,
  SkipForward,
  X,
  PanelLeft,
  PanelRight,
} from 'lucide-react';
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

  const getPhaseConfig = () => {
    if (mode === 'work') {
      return {
        label: 'FOCUS',
        color: 'bg-indigo-600/20 text-indigo-300 border-indigo-500/30',
        dotColor: 'bg-indigo-400',
      };
    }
    if (mode === 'shortBreak') {
      return {
        label: 'SHORT BREAK',
        color: 'bg-emerald-500/20 text-emerald-300 border-emerald-500/30',
        dotColor: 'bg-emerald-400',
      };
    }
    return {
      label: 'LONG BREAK',
      color: 'bg-purple-500/20 text-purple-300 border-purple-500/30',
      dotColor: 'bg-purple-400',
    };
  };

  const phase = getPhaseConfig();

  // Responsive dynamic platformer dimensions based on active scale preset
  const canvasWidth = scale === '1.5x' ? 360 : scale === '1.25x' ? 300 : 240;
  const canvasHeight = scale === '1.5x' ? 230 : scale === '1.25x' ? 180 : 140;

  return (
    <div className="w-full h-full relative flex flex-col justify-between overflow-hidden select-none">
      {/* Clean Single-Line Titlebar (36px) */}
      <header
        className={`unified-header ${
          alwaysOnTop ? 'no-drag cursor-default' : 'drag-region cursor-move'
        }`}
        style={{ WebkitAppRegion: alwaysOnTop ? 'no-drag' : 'drag' } as React.CSSProperties}
      >
        {/* Left Section: PanelLeft Toggle (Shop & Settings) */}
        <div className="flex items-center space-x-1.5 no-drag" style={{ WebkitAppRegion: 'no-drag' } as React.CSSProperties}>
          {onToggleLeft && (
            <button
              onClick={onToggleLeft}
              title={leftOpen ? 'Collapse Shop & Settings' : 'Expand Shop & Settings'}
              className={`p-1 rounded-md transition-all ${
                leftOpen
                  ? 'text-indigo-300 bg-indigo-500/25 border border-indigo-500/40'
                  : 'text-slate-400 hover:text-slate-200 hover:bg-white/10'
              }`}
            >
              <PanelLeft size={11} />
            </button>
          )}

          <div className="flex items-center space-x-1 pl-0.5">
            <span className="w-1.5 h-1.5 rounded-full bg-indigo-400 animate-pulse" />
            <span className="font-pixel text-[8px] text-indigo-300 tracking-wider">KRONOS</span>
          </div>
        </div>

        {/* Center Section: Continuous Drag Region */}
        <div className="flex-1 h-full" />

        {/* Right Section: Single PanelRight Toggle (Vitals, Bag & DTR) + Close */}
        <div
          className="no-drag flex items-center space-x-1"
          style={{ WebkitAppRegion: 'no-drag' } as React.CSSProperties}
        >
          {/* PanelRight Toggle Pill */}
          {onToggleRight && (
            <button
              onClick={onToggleRight}
              title={rightOpen ? 'Collapse Vitals & DTR' : 'Expand Vitals & DTR'}
              className={`p-1 rounded-md transition-all ${
                rightOpen
                  ? 'text-indigo-300 bg-indigo-500/25 border border-indigo-500/40'
                  : 'text-slate-400 hover:text-slate-200 hover:bg-white/10'
              }`}
            >
              <PanelRight size={11} />
            </button>
          )}

          <div className="w-px h-3 bg-white/10 mx-0.5" />

          {/* Quit Button */}
          <button
            onClick={handleClose}
            title="Quit Kronos"
            className="p-1 text-slate-400 hover:text-rose-300 hover:bg-rose-500/20 rounded-md transition-all"
          >
            <X size={11} />
          </button>
        </div>
      </header>

      {/* Main Dynamic Content Workspace */}
      <main className="flex-1 flex flex-col justify-between p-2 overflow-hidden min-h-0">
        {/* 2D Pixel Platformer Pet Canvas Section */}
        <section className="flex-1 flex justify-center items-center overflow-hidden min-h-0">
          <PlatformerPetCanvas
            mode={mode}
            status={status}
            width={canvasWidth}
            height={canvasHeight}
          />
        </section>

        {/* Compact Timer Readout & Action Deck */}
        <section className="flex flex-col items-center justify-center text-center pt-1 pb-0.5 shrink-0">
          {/* Phase Badge */}
          <div className="flex items-center space-x-1 mb-0.5">
            <span
              className={`font-pixel text-[7px] px-2 py-0.5 rounded-full border flex items-center gap-1 ${phase.color}`}
            >
              <span className={`w-1 h-1 rounded-full ${phase.dotColor} shadow-[0_0_6px_currentColor] ${status === 'running' ? 'animate-pulse' : ''}`} />
              {phase.label}
            </span>
          </div>

          {/* Clean Monospace Digital Clock with Subtle Glow */}
          <div className="font-mono font-semibold tracking-widest text-white text-xl select-none leading-none my-0.5 text-shadow-glow">
            {formatTime(timeLeft)}
          </div>

          {/* Floating Glassmorphism Timer Control Dock */}
          <div
            className="no-drag flex items-center space-x-1 bg-slate-900/50 backdrop-blur-md p-1 rounded-xl border border-white/10 mt-0.5 shadow-lg"
            style={{ WebkitAppRegion: 'no-drag' } as React.CSSProperties}
          >
            <button
              onClick={handleTogglePlay}
              className={`no-drag flex items-center space-x-1 px-2.5 py-1 rounded-lg font-semibold text-[11px] text-white transition-all active:scale-95 border ${
                status === 'running'
                  ? 'bg-amber-600 hover:bg-amber-500 border-amber-400/30'
                  : 'bg-indigo-600 hover:bg-indigo-500 border-indigo-400/30'
              }`}
            >
              {status === 'running' ? <Pause size={11} /> : <Play size={11} />}
              <span>{status === 'running' ? 'Pause' : 'Start'}</span>
            </button>

            <button
              onClick={handleReset}
              className="no-drag p-1 bg-slate-800 hover:bg-slate-700 text-slate-300 hover:text-white rounded-lg border border-white/5 transition-all active:scale-95"
              title="Reset Timer"
            >
              <RotateCcw size={11} />
            </button>

            <button
              onClick={handleSkip}
              className="no-drag p-1 bg-slate-800 hover:bg-slate-700 text-slate-300 hover:text-white rounded-lg border border-white/5 transition-all active:scale-95"
              title="Skip Phase"
            >
              <SkipForward size={11} />
            </button>
          </div>
        </section>
      </main>
    </div>
  );
};
