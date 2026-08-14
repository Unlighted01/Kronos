import React, { useEffect } from 'react';
import { Play, Pause, RotateCcw, SkipForward, LayoutDashboard, X, Pin, Lock } from 'lucide-react';
import { useAppStore } from '../../stores/useAppStore';
import { useTimerStore } from '../../stores/useTimerStore';
import { PlatformerPetCanvas } from '../pet/PlatformerPetCanvas';
import { audioSynth } from '../../utils/audioSynth';

export const WidgetView: React.FC = () => {
  const { alwaysOnTop, setAlwaysOnTop } = useAppStore();
  const {
    mode,
    status,
    timeLeft,
    completedSessions,
    startTimer,
    pauseTimer,
    resetTimer,
    skipPhase,
    tick,
  } = useTimerStore();

  // Sync initial Pin / Position Lock state from Main process on mount
  useEffect(() => {
    if (window.kronosElectron?.getPinState) {
      window.kronosElectron.getPinState().then((pinned) => {
        setAlwaysOnTop(pinned);
      }).catch(() => {});
    }
  }, [setAlwaysOnTop]);

  // Timer Tick Interval Effect
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
    if (window.kronosElectron) {
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

  const handleToggleAlwaysOnTop = async (e: React.MouseEvent) => {
    e.stopPropagation();
    audioSynth.playClick();
    const targetState = !alwaysOnTop;
    if (window.kronosElectron) {
      const nextState = await window.kronosElectron.toggleAlwaysOnTop(targetState);
      setAlwaysOnTop(nextState);
    } else {
      setAlwaysOnTop(targetState);
    }
  };

  const handleOpenDashboard = (e: React.MouseEvent) => {
    e.stopPropagation();
    audioSynth.playClick();
    if (window.kronosElectron) {
      window.kronosElectron.openDashboard();
    } else {
      window.location.hash = '#dashboard';
    }
  };

  const handleClose = (e: React.MouseEvent) => {
    e.stopPropagation();
    audioSynth.playClick();
    if (window.kronosElectron) {
      window.kronosElectron.closeWidget();
    } else {
      window.close();
    }
  };

  const getPhaseBadge = () => {
    if (mode === 'work') return { label: 'FOCUS', color: 'bg-indigo-500/20 text-indigo-300 border-indigo-500/30' };
    if (mode === 'shortBreak') return { label: 'SHORT BREAK', color: 'bg-emerald-500/20 text-emerald-300 border-emerald-500/30' };
    return { label: 'LONG BREAK', color: 'bg-purple-500/20 text-purple-300 border-purple-500/30' };
  };

  const badge = getPhaseBadge();

  return (
    <div className="widget-card">
      {/* Top Header: Dynamic Drag Region (Movable when unpinned, Locked when pinned) */}
      <div
        className={`flex items-center justify-between px-3 py-2 border-b border-white/10 select-none ${
          alwaysOnTop ? 'no-drag cursor-default' : 'drag-region cursor-move'
        }`}
        style={{ WebkitAppRegion: alwaysOnTop ? 'no-drag' : 'drag' } as React.CSSProperties}
      >
        <div className="flex items-center space-x-2">
          <span className="font-pixel text-[10px] text-indigo-400">KRONOS</span>
          {alwaysOnTop ? (
            <span className="text-[8px] text-amber-300 font-pixel flex items-center gap-1 bg-amber-500/20 px-1.5 py-0.5 rounded border border-amber-500/30">
              <Lock size={9} /> PINNED
            </span>
          ) : (
            <span className="bg-amber-500/20 text-amber-300 font-pixel text-[8px] px-1.5 py-0.5 rounded border border-amber-500/30">
              Lv.1
            </span>
          )}
          <span className="text-[9px] text-slate-400 font-mono">
            #{completedSessions}
          </span>
        </div>

        {/* Buttons container with explicit no-drag region */}
        <div
          className="no-drag flex items-center space-x-1"
          style={{ WebkitAppRegion: 'no-drag' } as React.CSSProperties}
        >
          <button
            onClick={handleToggleAlwaysOnTop}
            title={alwaysOnTop ? 'Pinned & Position Locked (Click to Unpin)' : 'Unpinned (Click to Pin & Lock)'}
            className={`no-drag p-1 rounded transition-colors ${
              alwaysOnTop
                ? 'text-indigo-400 bg-indigo-500/20 border border-indigo-500/30'
                : 'text-slate-400 hover:text-white'
            }`}
          >
            <Pin size={12} className={alwaysOnTop ? 'rotate-45 text-indigo-300' : ''} />
          </button>
          <button
            onClick={handleOpenDashboard}
            title="Open Full Dashboard"
            className="no-drag p-1 text-slate-400 hover:text-white rounded transition-colors"
          >
            <LayoutDashboard size={12} />
          </button>
          <button
            onClick={handleClose}
            title="Quit Application"
            className="no-drag p-1 text-slate-400 hover:text-rose-400 rounded transition-colors"
          >
            <X size={12} />
          </button>
        </div>
      </div>

      {/* 2D Pixel Platformer Pet Area */}
      <div className="p-2 flex justify-center">
        <PlatformerPetCanvas mode={mode} status={status} width={230} height={120} />
      </div>

      {/* Timer & Controls Area */}
      <div className="flex-1 flex flex-col items-center justify-center pb-3 text-center px-3">
        <div className="flex items-center space-x-2 mb-1">
          <span className={`font-pixel text-[8px] px-2 py-0.5 rounded border ${badge.color}`}>
            {badge.label}
          </span>
        </div>

        {/* Countdown Display */}
        <div className="font-mono text-3xl font-bold tracking-wider text-white mb-2">
          {formatTime(timeLeft)}
        </div>

        {/* Action Buttons */}
        <div
          className="no-drag flex items-center space-x-2"
          style={{ WebkitAppRegion: 'no-drag' } as React.CSSProperties}
        >
          <button
            onClick={handleTogglePlay}
            className="no-drag flex items-center space-x-1.5 px-4 py-1.5 bg-indigo-600 hover:bg-indigo-500 text-white rounded-xl font-semibold text-xs shadow-lg shadow-indigo-600/30 transition-all active:scale-95"
          >
            {status === 'running' ? <Pause size={14} /> : <Play size={14} />}
            <span>{status === 'running' ? 'Pause' : 'Start'}</span>
          </button>

          <button
            onClick={handleReset}
            className="no-drag p-2 bg-slate-800 hover:bg-slate-700 text-slate-300 rounded-xl transition-colors"
            title="Reset Timer"
          >
            <RotateCcw size={14} />
          </button>

          <button
            onClick={handleSkip}
            className="no-drag p-2 bg-slate-800 hover:bg-slate-700 text-slate-300 rounded-xl transition-colors"
            title="Skip Phase"
          >
            <SkipForward size={14} />
          </button>
        </div>
      </div>
    </div>
  );
};
