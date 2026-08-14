import React, { useState } from 'react';
import { useLiveQuery } from 'dexie-react-hooks';
import {
  db,
  initPetStats,
  SHOP_ITEMS,
  ShopCatalogItem,
} from '../../db/kronosDb';
import { Award, Check, Zap, Heart } from 'lucide-react';
import { audioSynth } from '../../utils/audioSynth';

export const PetShop: React.FC = () => {
  const [selectedCategory, setSelectedCategory] = useState<
    'all' | 'snack'
  >('all');

  const petStats = useLiveQuery(async () => {
    return (await db.petStats.get('primary')) || (await initPetStats());
  });

  const inventory = useLiveQuery(async () => {
    return await db.inventory.toArray();
  });

  const coins = petStats?.coins || 0;

  const filteredItems = SHOP_ITEMS.filter((item) =>
    selectedCategory === 'all' ? true : item.category === selectedCategory
  );

  const ownedItemIds = new Set(inventory?.map((inv) => inv.itemId));

  const handleBuy = async (item: ShopCatalogItem) => {
    if (!petStats || coins < item.price) return;

    audioSynth.playVictory();

    // Deduct coins
    await db.petStats.put({
      ...petStats,
      coins: coins - item.price,
      lastUpdated: new Date().toISOString(),
    });

    // Add to Inventory
    await db.inventory.add({
      itemId: item.id,
      name: item.name,
      category: item.category,
      icon: item.icon,
      environmentId: item.environmentId,
      statBoost: item.statBoost,
      purchasedAt: new Date().toISOString(),
    });

  };

  return (
    <div className="space-y-2 select-none">
      {/* Wallet Bar */}
      <div className="flex items-center justify-between px-2.5 py-2 bg-gradient-to-r from-slate-900/90 to-slate-800/90 border border-white/10 rounded-xl shadow-inner">
        <span className="font-pixel text-[7.5px] text-slate-400">WALLET</span>
        <div className="flex items-center space-x-1 text-amber-400 font-bold text-xs drop-shadow-sm">
          <Award size={13} />
          <span className="font-mono">{coins} Coins</span>
        </div>
      </div>

      {/* Category Segmented Control (Sleek & Well-Divided) */}
      <div className="grid grid-cols-2 gap-1.5">
        {(['all', 'snack'] as const).map((cat) => (
          <button
            key={cat}
            onClick={() => {
              audioSynth.playClick();
              setSelectedCategory(cat);
            }}
            className={`py-1.5 px-2 text-[8.5px] font-bold uppercase tracking-wider rounded-lg transition-all text-center flex items-center justify-center border ${
              selectedCategory === cat
                ? 'bg-indigo-600 text-white border-indigo-500 shadow-md'
                : 'bg-slate-900 text-slate-400 border-white/10 hover:border-white/20 hover:text-slate-200 hover:bg-slate-800'
            }`}
          >
            {cat === 'all' ? 'All' : 'Snacks'}
          </button>
        ))}
      </div>

      {/* Items List */}
      <div className="space-y-1.5">
        {filteredItems.map((item) => {
          const isOwned = ownedItemIds.has(item.id) && item.category !== 'snack';
          const canAfford = coins >= item.price;

          return (
            <div
              key={item.id}
              className="bg-slate-900/60 border border-white/5 rounded-xl p-2 flex flex-col justify-between hover:border-white/20 hover:bg-slate-800/50 transition-all group"
            >
              <div className="flex items-start justify-between mb-1.5">
                <div className="flex items-center space-x-2 truncate">
                  <span className="text-xl p-1 bg-slate-950 rounded-lg border border-white/5 group-hover:scale-105 transition-transform">
                    {item.icon}
                  </span>
                  <div className="truncate">
                    <h3 className="font-bold text-[10.5px] text-slate-100 truncate group-hover:text-white transition-colors">
                      {item.name}
                    </h3>
                    <p className="text-[7.5px] text-slate-400 truncate">
                      {item.description}
                    </p>
                    <div className="flex items-center space-x-1 mt-0.5">
                      {item.statBoost?.energy && (
                        <span className="flex items-center text-[7.5px] text-amber-400 bg-amber-500/10 px-1 py-0.5 rounded">
                          <Zap size={8} className="mr-0.5" />
                          +{item.statBoost.energy}
                        </span>
                      )}
                      {item.statBoost?.happiness && (
                        <span className="flex items-center text-[7.5px] text-pink-400 bg-pink-500/10 px-1 py-0.5 rounded">
                          <Heart size={8} className="mr-0.5" />
                          +{item.statBoost.happiness}
                        </span>
                      )}
                    </div>
                  </div>
                </div>

                <span className="text-[9.5px] font-bold text-amber-400 shrink-0 font-mono">
                  {item.price > 0 ? `${item.price}c` : 'Free'}
                </span>
              </div>

              {isOwned ? (
                <button
                  disabled
                  className="w-full flex items-center justify-center space-x-1 py-1 rounded-lg text-[9px] font-semibold transition-all bg-emerald-600/20 text-emerald-300 border border-emerald-500/30 cursor-default"
                >
                  <Check size={11} />
                  <span>Owned</span>
                </button>
              ) : (
                <button
                  onClick={() => handleBuy(item)}
                  disabled={!canAfford}
                  className={`w-full flex items-center justify-center space-x-1 py-1 rounded-lg text-[9px] font-semibold transition-all ${
                    canAfford
                      ? 'bg-indigo-600 hover:bg-indigo-500 text-white shadow-sm'
                      : 'bg-slate-900 text-slate-500 border border-white/5 cursor-not-allowed'
                  }`}
                >
                  <span>{canAfford ? 'Buy Snack' : 'Need Coins'}</span>
                </button>
              )}
            </div>
          );
        })}
      </div>
    </div>
  );
};
