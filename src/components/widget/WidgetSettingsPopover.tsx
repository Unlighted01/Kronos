import React from 'react';
import { Monitor, Pin, Utensils, X } from 'lucide-react';
import { useAppStore } from '../../stores/useAppStore';
import { audioSynth } from '../../utils/audioSynth';
import { QuickFeedPopover } from '../pet/QuickFeedPopover';

export type PresetScale = '1x' | '1.25x' | '1.5x';

interface WidgetSettingsPopoverProps {
  scale: PresetScale;
  onScaleChange?: (scale: PresetScale) => void;
  onClose: () => void;
}

export const WidgetSettingsPopover: React.FC<WidgetSettingsPopoverProps> = ({
  scale,
  onScaleChange,
  onClose,
}) => {
  const { alwaysOnTop, setAlwaysOnTop } = useAppStore();
  const [showFeeder, setShowFeeder] = React.useState<boolean>(false);

  const handleTogglePin = async () => {
    audioSynth.playClick();
    const nextState = !alwaysOnTop;
    if (window.kronosElectron?.toggleAlwaysOnTop) {
      const state = await window.kronosElectron.toggleAlwaysOnTop(nextState);
      setAlwaysOnTop(state);
    } else {
      setAlwaysOnTop(nextState);
    }
  };

  const handleSelectScale = (nextScale: PresetScale) => {
    audioSynth.playClick();
    if (onScaleChange) onScaleChange(nextScale);
    if (window.kronosElectron?.setPresetSize) {
      window.kronosElectron.setPresetSize(nextScale);
    }
  };

  return (
    <div className="absolute top-10 right-8 z-50 w-48 bg-slate-950/95 backdrop-blur-xl border border-white/10 rounded-xl shadow-2xl p-2.5 text-slate-100 animate-in fade-in zoom-in-95 duration-100 select-none no-drag">
      <div className="flex items-center justify-between pb-1.5 border-b border-white/10 mb-2">
        <span className="font-pixel text-[8px] text-indigo-400 font-semibold tracking-wider">
          WIDGET SETTINGS
        </span>
        <button
          onClick={onClose}
          className="text-slate-400 hover:text-white p-0.5 rounded hover:bg-white/10"
        >
          <X size={11} />
        </button>
      </div>

      <div className="space-y-2">
        {/* Scale Preset Switcher */}
        <div>
          <label className="block text-[8px] font-semibold text-slate-400 mb-1 flex items-center space-x-1">
            <Monitor size={10} />
            <span>WINDOW SCALE PRESET</span>
          </label>
          <div className="grid grid-cols-3 gap-1 bg-slate-900/80 p-0.5 rounded-lg border border-white/5">
            {(['1x', '1.25x', '1.5x'] as PresetScale[]).map((s) => (
              <button
                key={s}
                onClick={() => handleSelectScale(s)}
                className={`py-1 text-[9px] font-pixel rounded transition-colors ${
                  scale === s
                    ? 'bg-indigo-600 text-white font-bold'
                    : 'text-slate-400 hover:text-slate-200'
                }`}
              >
                {s}
              </button>
            ))}
          </div>
        </div>

        {/* Pin & Lock Toggle */}
        <button
          onClick={handleTogglePin}
          className={`w-full flex items-center justify-between p-1.5 rounded-lg border text-[10px] font-medium transition-colors ${
            alwaysOnTop
              ? 'bg-amber-500/20 text-amber-300 border-amber-500/30'
              : 'bg-slate-900/60 text-slate-300 border-white/5 hover:bg-white/5'
          }`}
        >
          <span className="flex items-center space-x-1.5">
            <Pin size={11} className={alwaysOnTop ? 'rotate-45 text-amber-300' : ''} />
            <span>Always-on-Top Pin</span>
          </span>
          <span className="font-pixel text-[8px]">
            {alwaysOnTop ? 'PINNED' : 'OFF'}
          </span>
        </button>

        {/* Quick Snack Feeder Toggle */}
        <button
          onClick={() => setShowFeeder(!showFeeder)}
          className="w-full flex items-center justify-between p-1.5 rounded-lg border border-white/5 bg-slate-900/60 text-slate-300 hover:bg-white/5 text-[10px] font-medium transition-colors"
        >
          <span className="flex items-center space-x-1.5">
            <Utensils size={11} className="text-amber-400" />
            <span>Quick Snack Feeder</span>
          </span>
          <span className="text-[9px] text-indigo-400 font-bold">&rarr;</span>
        </button>
      </div>

      {showFeeder && <QuickFeedPopover onClose={() => setShowFeeder(false)} />}
    </div>
  );
};
