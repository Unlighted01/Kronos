import React, { useState } from 'react';
import { PetShop } from '../shop/PetShop';
import { useAppStore } from '../../stores/useAppStore';
import { PresetScale } from '../widget/WidgetSettingsPopover';
import {
  ShoppingBag,
  Sliders,
  ChevronLeft,
  Coins,
  Maximize2,
  Pin,
  Lock,
  Unlock,
} from 'lucide-react';
import { audioSynth } from '../../utils/audioSynth';

interface LeftPanelProps {
  onClose: () => void;
  scale?: PresetScale;
  onScaleChange?: (scale: PresetScale) => void;
  initialTab?: 'shop' | 'settings';
}

export const LeftPanel: React.FC<LeftPanelProps> = ({
  onClose,
  scale = '1x',
  onScaleChange,
  initialTab = 'shop',
}) => {
  const [activeTab, setActiveTab] = useState<'shop' | 'settings'>(initialTab);
  const { alwaysOnTop, setAlwaysOnTop } = useAppStore();

  const handleToggleAlwaysOnTop = async () => {
    audioSynth.playClick();
    if (window.kronosElectron?.toggleAlwaysOnTop) {
      try {
        const nextState = await window.kronosElectron.toggleAlwaysOnTop();
        setAlwaysOnTop(nextState);
      } catch {
        setAlwaysOnTop(!alwaysOnTop);
      }
    } else {
      setAlwaysOnTop(!alwaysOnTop);
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
    <aside className="panel-left-container">
      {/* Aligned Titlebar (36px) */}
      <header className="unified-header">
        <div className="flex items-center space-x-1.5 truncate">
          <Coins size={12} className="text-indigo-400 shrink-0" />
          <span className="font-bold text-[10px] text-indigo-300 tracking-wider truncate">
            SHOP & SETTINGS
          </span>
        </div>
        <button
          onClick={onClose}
          title="Collapse Left Panel"
          className="p-1 text-slate-400 hover:text-white rounded bg-slate-900/80 hover:bg-slate-800 border border-white/5 transition-colors no-drag shrink-0"
          style={{ WebkitAppRegion: 'no-drag' } as React.CSSProperties}
        >
          <ChevronLeft size={11} />
        </button>
      </header>

      {/* Navigation Tabs (Sleek Segmented Control) */}
      <div className="grid grid-cols-2 gap-0.5 mx-2 mt-2 mb-1.5 bg-slate-950/80 p-0.5 rounded-lg border border-white/5 shadow-inner shrink-0">
        <button
          onClick={() => setActiveTab('shop')}
          className={`flex items-center justify-center space-x-1 py-1 rounded-md font-semibold text-[9.5px] transition-all ${
            activeTab === 'shop'
              ? 'bg-indigo-500/20 text-indigo-300 border border-indigo-500/30 shadow-sm'
              : 'text-slate-400 hover:text-slate-200'
          }`}
        >
          <ShoppingBag size={10} />
          <span>Pet Shop</span>
        </button>

        <button
          onClick={() => setActiveTab('settings')}
          className={`flex items-center justify-center space-x-1 py-1 rounded-md font-semibold text-[9.5px] transition-all ${
            activeTab === 'settings'
              ? 'bg-indigo-500/20 text-indigo-300 border border-indigo-500/30 shadow-sm'
              : 'text-slate-400 hover:text-slate-200'
          }`}
        >
          <Sliders size={10} />
          <span>Settings</span>
        </button>
      </div>

      {/* Main Workspace Content */}
      <div className="flex-1 min-h-0 overflow-y-auto px-2 pb-1.5 space-y-1.5">
        {/* Tab 1: Pet Shop */}
        {activeTab === 'shop' && <PetShop />}

        {/* Tab 2: Widget Settings */}
        {activeTab === 'settings' && (
          <div className="space-y-2">
            {/* Window Scale Preset Section */}
            <div className="bg-slate-900/60 border border-white/10 rounded-lg p-2 space-y-1.5">
              <div className="flex items-center space-x-1 text-[8px] font-bold text-slate-300">
                <Maximize2 size={10} className="text-indigo-400" />
                <span>WINDOW SCALE</span>
              </div>
              <div className="grid grid-cols-3 gap-1">
                {(['1x', '1.25x', '1.5x'] as PresetScale[]).map((s) => (
                  <button
                    key={s}
                    onClick={() => handleSelectScale(s)}
                    className={`py-1 text-[9px] font-semibold rounded border transition-all ${
                      scale === s
                        ? 'bg-indigo-600/40 text-indigo-200 border-indigo-500/60'
                        : 'bg-slate-950/60 text-slate-400 border-white/5 hover:text-slate-200'
                    }`}
                  >
                    {s}
                  </button>
                ))}
              </div>
            </div>

            {/* Always-on-Top & Position Lock */}
            <div className="bg-slate-900/60 border border-white/10 rounded-lg p-2 space-y-1.5">
              <div className="flex items-center justify-between">
                <div className="flex items-center space-x-1 text-[8px] font-bold text-slate-300">
                  <Pin size={10} className="text-indigo-400" />
                  <span>PIN & LOCK</span>
                </div>
                <span className="text-[7.5px] font-mono text-slate-400">
                  {alwaysOnTop ? 'PINNED' : 'FREE'}
                </span>
              </div>

              <button
                onClick={handleToggleAlwaysOnTop}
                className={`w-full flex items-center justify-center space-x-1.5 py-1 rounded text-[9px] font-semibold border transition-all ${
                  alwaysOnTop
                    ? 'bg-amber-600/30 text-amber-300 border-amber-500/40'
                    : 'bg-slate-950/60 text-slate-300 border-white/10 hover:bg-slate-950'
                }`}
              >
                {alwaysOnTop ? <Lock size={10} /> : <Unlock size={10} />}
                <span>{alwaysOnTop ? 'Pinned & Position Locked' : 'Pin to Top (Lock Move)'}</span>
              </button>
            </div>

            {/* Pomodoro Duration Timings */}
            <div className="bg-slate-900/60 border border-white/10 rounded-lg p-2 space-y-1.5">
              <div className="flex items-center space-x-1 text-[8px] font-bold text-slate-300">
                <Sliders size={10} className="text-indigo-400" />
                <span>POMODORO TIMING</span>
              </div>
              <div className="grid grid-cols-2 gap-1.5">
                <div>
                  <label className="block text-[7.5px] text-slate-400 mb-0.5">Focus Min</label>
                  <input
                    type="number"
                    defaultValue={25}
                    className="w-full bg-slate-950 border border-white/10 rounded px-1.5 py-0.5 text-[9.5px] text-slate-200 text-center"
                  />
                </div>
                <div>
                  <label className="block text-[7.5px] text-slate-400 mb-0.5">Break Min</label>
                  <input
                    type="number"
                    defaultValue={5}
                    className="w-full bg-slate-950 border border-white/10 rounded px-1.5 py-0.5 text-[9.5px] text-slate-200 text-center"
                  />
                </div>
              </div>
            </div>
          </div>
        )}
      </div>

      {/* Footer */}
      <footer className="h-5 min-h-[20px] flex items-center justify-center border-t border-white/5 text-[7.5px] text-slate-500 font-mono shrink-0">
        Shop & Settings &bull; 240px
      </footer>
    </aside>
  );
};
