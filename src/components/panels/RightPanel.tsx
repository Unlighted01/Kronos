import React, { useState } from 'react';
import { useLiveQuery } from 'dexie-react-hooks';
import { db, initPetStats, InventoryItem } from '../../db/kronosDb';
import { DtrLogSheet } from '../dtr/DtrLogSheet';
import {
  Heart,
  Zap,
  Award,
  ShoppingBag,
  Calendar,
  ChevronRight,
  Sparkles,
} from 'lucide-react';
import { audioSynth } from '../../utils/audioSynth';

interface RightPanelProps {
  onClose: () => void;
  initialTab?: 'vitals' | 'inventory' | 'dtr';
}

export const RightPanel: React.FC<RightPanelProps> = ({
  onClose,
  initialTab = 'vitals',
}) => {
  const [activeTab, setActiveTab] = useState<'vitals' | 'inventory' | 'dtr'>(initialTab);

  const petStats = useLiveQuery(async () => {
    return (await db.petStats.get('primary')) || (await initPetStats());
  });

  const inventoryItems = useLiveQuery(async () => {
    return await db.inventory.toArray();
  }) || [];

  const level = petStats?.level || 1;
  const coins = petStats?.coins || 150;
  const exp = petStats?.exp || 0;
  const energy = petStats?.energy || 80;
  const happiness = petStats?.happiness || 80;
  const maxExp = level * 100;
  const expPercent = Math.min(100, Math.round((exp / maxExp) * 100));

  const handleUseItem = async (item: InventoryItem) => {
    if (!item.id) return;
    audioSynth.playChime();

    // Snack / Consumable
    await db.inventory.delete(item.id);

    const stats = await db.petStats.get('primary');
    if (stats) {
      const boostEnergy = item.statBoost?.energy || 20;
      const boostHappiness = item.statBoost?.happiness || 20;
      const newEnergy = Math.min(100, stats.energy + boostEnergy);
      const newHappiness = Math.min(100, stats.happiness + boostHappiness);
      await db.petStats.update('primary', { energy: newEnergy, happiness: newHappiness });
    }
  };

  return (
    <aside className="panel-right-container">
      {/* Aligned Titlebar (36px) */}
      <header className="unified-header">
        <div className="flex items-center space-x-1.5 truncate">
          <Sparkles size={12} className="text-indigo-400 shrink-0" />
          <span className="font-bold text-[10px] text-indigo-300 tracking-wider truncate">
            VITALS & DTR
          </span>
        </div>
        <button
          onClick={onClose}
          title="Collapse Right Panel"
          className="p-1 text-slate-400 hover:text-white rounded bg-slate-900/80 hover:bg-slate-800 border border-white/5 transition-colors no-drag shrink-0"
          style={{ WebkitAppRegion: 'no-drag' } as React.CSSProperties}
        >
          <ChevronRight size={11} />
        </button>
      </header>

      {/* Navigation Tabs (Sleek Segmented Control) */}
      <div className="grid grid-cols-3 gap-0.5 mx-2 mt-2 mb-1.5 bg-slate-950/80 p-0.5 rounded-lg border border-white/5 shadow-inner shrink-0">
        <button
          onClick={() => setActiveTab('vitals')}
          className={`flex items-center justify-center space-x-0.5 py-1 rounded-md font-semibold text-[9px] transition-all ${
            activeTab === 'vitals'
              ? 'bg-indigo-500/20 text-indigo-300 border border-indigo-500/30 shadow-sm'
              : 'text-slate-400 hover:text-slate-200'
          }`}
        >
          <Heart size={9} />
          <span>Vitals</span>
        </button>

        <button
          onClick={() => setActiveTab('inventory')}
          className={`flex items-center justify-center space-x-0.5 py-1 rounded-md font-semibold text-[9px] transition-all ${
            activeTab === 'inventory'
              ? 'bg-indigo-500/20 text-indigo-300 border border-indigo-500/30 shadow-sm'
              : 'text-slate-400 hover:text-slate-200'
          }`}
        >
          <ShoppingBag size={9} />
          <span>Bag</span>
        </button>

        <button
          onClick={() => setActiveTab('dtr')}
          className={`flex items-center justify-center space-x-0.5 py-1 rounded-md font-semibold text-[9px] transition-all ${
            activeTab === 'dtr'
              ? 'bg-indigo-500/20 text-indigo-300 border border-indigo-500/30 shadow-sm'
              : 'text-slate-400 hover:text-slate-200'
          }`}
        >
          <Calendar size={9} />
          <span>DTR</span>
        </button>
      </div>

      {/* Main Scrollable Content Area */}
      <div className="flex-1 min-h-0 overflow-y-auto px-2 pb-1.5 space-y-2">
        {/* Tab 1: Pet Vitals & Stats */}
        {activeTab === 'vitals' && (
          <div className="space-y-2">
            <div className="bg-slate-900/60 border border-white/10 rounded-lg p-2 space-y-1.5">
              <div className="flex items-center justify-between">
                <span className="font-pixel text-[7.5px] text-indigo-400">LVL {level}</span>
                <div className="flex items-center space-x-0.5 text-amber-400 font-bold text-[10px]">
                  <Award size={11} />
                  <span className="font-mono">{coins}</span>
                </div>
              </div>

              <div>
                <div className="flex items-center justify-between text-[7.5px] text-slate-400 mb-0.5 font-mono">
                  <span>EXP</span>
                  <span>{exp}/{maxExp}</span>
                </div>
                <div className="w-full bg-slate-950 h-1.5 rounded-full overflow-hidden shadow-inner border border-white/5">
                  <div
                    className="bg-indigo-500 h-full transition-all duration-500 shadow-[0_0_8px_rgba(99,102,241,0.6)]"
                    style={{ width: `${expPercent}%` }}
                  />
                </div>
              </div>
            </div>

            <div className="space-y-1.5">
              <div className="bg-slate-900/60 p-2 rounded-lg border border-white/10">
                <div className="flex items-center justify-between text-[8px] text-amber-300 mb-1 font-semibold">
                  <span className="flex items-center space-x-1">
                    <Zap size={10} />
                    <span>ENERGY</span>
                  </span>
                  <span className="font-mono">{energy}%</span>
                </div>
                <div className="w-full bg-slate-950 h-1.5 rounded-full overflow-hidden shadow-inner">
                  <div className="bg-amber-400 h-full transition-all shadow-[0_0_8px_rgba(251,191,36,0.6)]" style={{ width: `${energy}%` }} />
                </div>
              </div>

              <div className="bg-slate-900/60 p-2 rounded-lg border border-white/10">
                <div className="flex items-center justify-between text-[8px] text-pink-300 mb-1 font-semibold">
                  <span className="flex items-center space-x-1">
                    <Heart size={10} />
                    <span>JOY</span>
                  </span>
                  <span className="font-mono">{happiness}%</span>
                </div>
                <div className="w-full bg-slate-950 h-1.5 rounded-full overflow-hidden shadow-inner">
                  <div className="bg-pink-400 h-full transition-all shadow-[0_0_8px_rgba(244,114,182,0.6)]" style={{ width: `${happiness}%` }} />
                </div>
              </div>
            </div>
          </div>
        )}

        {/* Tab 2: Inventory Bag */}
        {activeTab === 'inventory' && (
          <div className="space-y-1.5">
            {inventoryItems.length === 0 ? (
              <div className="text-center py-4 text-[9px] text-slate-400 bg-slate-900/40 rounded-lg border border-white/5 p-2">
                Bag empty! Buy snacks from the Pet Shop.
              </div>
            ) : (
              <div className="space-y-1">
                {inventoryItems.map((item) => (
                  <div
                    key={item.id}
                    className="flex items-center justify-between p-1.5 bg-slate-900/60 border border-white/10 rounded-lg hover:bg-slate-800/40 transition-colors"
                  >
                    <div className="flex items-center space-x-1.5 truncate">
                      <span className="text-sm">{item.icon || '📦'}</span>
                      <div className="truncate">
                        <div className="font-semibold text-[9.5px] text-slate-200 truncate">{item.name}</div>
                        <div className="text-[7px] text-indigo-400 capitalize">{item.category}</div>
                      </div>
                    </div>
                    <button
                      onClick={() => handleUseItem(item)}
                      className="px-1.5 py-0.5 rounded text-[8px] font-semibold shrink-0 transition-colors bg-indigo-600 hover:bg-indigo-500 text-white shadow-sm"
                    >
                      Feed
                    </button>
                  </div>
                ))}
              </div>
            )}
          </div>
        )}

        {/* Tab 3: DTR Logs Sheet */}
        {activeTab === 'dtr' && <DtrLogSheet />}
      </div>

      {/* Footer */}
      <footer className="h-5 min-h-[20px] flex items-center justify-center border-t border-white/5 text-[7.5px] text-slate-500 font-mono shrink-0">
        Vitals, Bag & DTR &bull; 220px
      </footer>
    </aside>
  );
};
