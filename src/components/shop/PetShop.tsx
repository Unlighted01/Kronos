import React, { useState } from 'react';
import { useLiveQuery } from 'dexie-react-hooks';
import {
  db,
  initPetStats,
  SHOP_ITEMS,
  ShopCatalogItem,
} from '../../db/kronosDb';
import { audioSynth } from '../../utils/audioSynth';

export const PetShop: React.FC = () => {
  const [selectedCategory, setSelectedCategory] = useState<'all' | 'snack'>('all');

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
    <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
      {/* Category Tabs */}
      <div className="px-tab-bar" style={{ marginBottom: '2px' }}>
        <button
          onClick={() => {
            audioSynth.playClick();
            setSelectedCategory('all');
          }}
          className={selectedCategory === 'all' ? 'px-tab px-tab--active' : 'px-tab'}
        >
          ALL
        </button>
        <button
          onClick={() => {
            audioSynth.playClick();
            setSelectedCategory('snack');
          }}
          className={selectedCategory === 'snack' ? 'px-tab px-tab--active' : 'px-tab'}
        >
          SNACKS
        </button>
      </div>

      {/* Items Grid/List */}
      <div style={{ display: 'flex', flexDirection: 'column', gap: '6px' }}>
        {filteredItems.map((item) => {
          const isOwned = ownedItemIds.has(item.id) && item.category !== 'snack';
          const canAfford = coins >= item.price;

          return (
            <div
              key={item.id}
              className="px-card"
              style={{ display: 'flex', flexDirection: 'column', gap: '6px', padding: '6px' }}
            >
              <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', gap: '6px' }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: '8px', minWidth: 0, flex: 1 }}>
                  <span style={{ fontSize: '20px', lineHeight: 1 }}>{item.icon}</span>
                  <div style={{ minWidth: 0, flex: 1 }}>
                    <div className="px-label" style={{ color: 'var(--px-white)', whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>
                      {item.name}
                    </div>
                    <div style={{ display: 'flex', gap: '4px', marginTop: '3px' }}>
                      {item.statBoost?.energy && (
                        <span className="px-label" style={{ color: 'var(--px-gold)' }}>
                          ⚡+{item.statBoost.energy}
                        </span>
                      )}
                      {item.statBoost?.happiness && (
                        <span className="px-label" style={{ color: 'var(--px-magenta)' }}>
                          ♥+{item.statBoost.happiness}
                        </span>
                      )}
                    </div>
                  </div>
                </div>

                <span className="px-badge" style={{ flexShrink: 0 }}>
                  {item.price > 0 ? `${item.price} G` : 'FREE'}
                </span>
              </div>

              {isOwned ? (
                <button
                  disabled
                  className="px-btn"
                  style={{ opacity: 0.6, cursor: 'default', width: '100%' }}
                >
                  OWNED
                </button>
              ) : (
                <button
                  onClick={() => handleBuy(item)}
                  disabled={!canAfford}
                  className={canAfford ? 'px-btn px-btn--primary' : 'px-btn'}
                  style={{ width: '100%', opacity: canAfford ? 1 : 0.4 }}
                >
                  {canAfford ? 'BUY' : 'NEED COINS'}
                </button>
              )}
            </div>
          );
        })}
      </div>
    </div>
  );
};
