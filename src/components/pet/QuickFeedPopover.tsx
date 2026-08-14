import React from 'react';
import { useLiveQuery } from 'dexie-react-hooks';
import { db, InventoryItem } from '../../db/kronosDb';
import { audioSynth } from '../../utils/audioSynth';
import { Utensils, X } from 'lucide-react';

interface QuickFeedPopoverProps {
  onClose: () => void;
}

export const QuickFeedPopover: React.FC<QuickFeedPopoverProps> = ({ onClose }) => {
  const inventoryItems = useLiveQuery(async () => {
    return await db.inventory.where('category').equals('snack').toArray();
  }) || [];

  const handleFeedItem = async (item: InventoryItem) => {
    if (!item.id) return;
    audioSynth.playChime();

    // Remove snack from Dexie inventory when eaten
    await db.inventory.delete(item.id);

    // Boost Pet Vitals in Dexie DB
    const stats = await db.petStats.get('primary');
    if (stats) {
      const boostEnergy = item.statBoost?.energy || 20;
      const boostHappiness = item.statBoost?.happiness || 20;
      const newEnergy = Math.min(100, stats.energy + boostEnergy);
      const newHappiness = Math.min(100, stats.happiness + boostHappiness);
      await db.petStats.update('primary', { energy: newEnergy, happiness: newHappiness });
    }

    onClose();
  };

  return (
    <div className="absolute top-10 right-2 z-50 w-52 bg-slate-950/95 border border-indigo-500/30 backdrop-blur-md rounded-xl p-3 shadow-2xl text-white select-none">
      <div className="flex items-center justify-between pb-2 border-b border-white/10 mb-2">
        <div className="flex items-center space-x-1.5 text-xs font-semibold text-indigo-300">
          <Utensils size={12} />
          <span>Quick Feed Snacks</span>
        </div>
        <button
          onClick={onClose}
          className="text-slate-400 hover:text-white p-0.5 rounded"
        >
          <X size={12} />
        </button>
      </div>

      {inventoryItems.length === 0 ? (
        <div className="text-center py-3 text-[10px] text-slate-400">
          No snacks in inventory! Visit Pet Shop in Dashboard to buy snacks.
        </div>
      ) : (
        <div className="space-y-1.5 max-h-40 overflow-y-auto pr-1">
          {inventoryItems.map((item: InventoryItem) => (
            <button
              key={item.id}
              onClick={() => handleFeedItem(item)}
              className="w-full flex items-center justify-between px-2.5 py-1.5 bg-slate-900 hover:bg-indigo-600/30 border border-slate-800 hover:border-indigo-500/40 rounded-lg text-left transition-all text-xs"
            >
              <div className="flex items-center space-x-2">
                <span className="text-base">{item.icon || '🍕'}</span>
                <div>
                  <div className="font-semibold text-[11px] text-slate-200">{item.name}</div>
                  <div className="text-[9px] text-indigo-400">Snack</div>
                </div>
              </div>
              <span className="text-[9px] bg-indigo-500/20 text-indigo-300 px-1.5 py-0.5 rounded font-mono">
                FEED
              </span>
            </button>
          ))}
        </div>
      )}
    </div>
  );
};
