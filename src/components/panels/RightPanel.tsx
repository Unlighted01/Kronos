import React, { useState } from 'react';
import { useLiveQuery } from 'dexie-react-hooks';
import { db, initPetStats, InventoryItem } from '../../db/kronosDb';
import { DtrLogSheet } from '../dtr/DtrLogSheet';
import { audioSynth } from '../../utils/audioSynth';

interface RightPanelProps {
  onClose: () => void;
  initialTab?: 'vitals' | 'inventory' | 'dtr';
  width?: number;
}

export const RightPanel: React.FC<RightPanelProps> = ({
  onClose,
  initialTab = 'vitals',
  width,
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
    <aside
      className="panel-right-container"
      style={{
        width: width ? `${width}px` : undefined,
        minWidth: width ? `${width}px` : undefined,
        maxWidth: width ? `${width}px` : undefined,
      }}
    >
      {/* Aligned Titlebar (36px) */}
      <header className="px-header">
        <span className="px-title">◈ VITALS</span>
        <button
          onClick={onClose}
          title="Collapse Right Panel"
          className="px-btn px-btn--danger no-drag"
          style={{ WebkitAppRegion: 'no-drag' } as React.CSSProperties}
        >
          ✕
        </button>
      </header>

      {/* Navigation Tabs */}
      <div className="px-tab-bar">
        <button
          onClick={() => setActiveTab('vitals')}
          className={activeTab === 'vitals' ? 'px-tab px-tab--active' : 'px-tab'}
        >
          VITALS
        </button>
        <button
          onClick={() => setActiveTab('inventory')}
          className={activeTab === 'inventory' ? 'px-tab px-tab--active' : 'px-tab'}
        >
          BAG
        </button>
        <button
          onClick={() => setActiveTab('dtr')}
          className={activeTab === 'dtr' ? 'px-tab px-tab--active' : 'px-tab'}
        >
          DTR
        </button>
      </div>

      {/* Main Scrollable Content Area */}
      <div className="px-scrollable" style={{ flex: 1, overflowY: 'auto', padding: '0 8px' }}>
        {/* Tab 1: Pet Vitals & Stats */}
        {activeTab === 'vitals' && (
          <div className="px-card" style={{ display: 'flex', flexDirection: 'column', gap: '8px', padding: '8px' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between' }}>
              <span className="px-badge">LVL {level}</span>
              <span className="px-badge--cyan">{coins} G</span>
            </div>
            
            <div>
              <div className="px-label" style={{ marginBottom: '4px' }}>EXP</div>
              <div className="px-stat-bar">
                <div className="px-stat-bar__fill--exp" style={{ width: `${expPercent}%` }} />
              </div>
            </div>
            
            <div className="px-divider" />
            
            <div>
              <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '4px' }}>
                <span className="px-label">ENERGY</span>
                <span className="px-value">{energy}%</span>
              </div>
              <div className="px-stat-bar">
                <div className="px-stat-bar__fill--energy" style={{ width: `${energy}%` }} />
              </div>
            </div>
              
            <div>
              <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '4px' }}>
                <span className="px-label">JOY</span>
                <span className="px-value">{happiness}%</span>
              </div>
              <div className="px-stat-bar">
                <div className="px-stat-bar__fill--joy" style={{ width: `${happiness}%` }} />
              </div>
            </div>
          </div>
        )}

        {/* Tab 2: Inventory Bag */}
        {activeTab === 'inventory' && (
          <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
            {inventoryItems.length === 0 ? (
              <div className="px-card" style={{ padding: '8px', textAlign: 'center' }}>
                <span className="px-label">BAG EMPTY</span>
              </div>
            ) : (
              inventoryItems.map((item) => (
                <div key={item.id} className="px-item-slot" style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '8px' }}>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '8px', overflow: 'hidden' }}>
                    <span style={{ fontSize: '24px' }}>{item.icon || '📦'}</span>
                    <div style={{ overflow: 'hidden' }}>
                      <div className="px-label" style={{ whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>{item.name}</div>
                      <div className="px-label" style={{ color: 'var(--px-magenta)' }}>{item.category}</div>
                    </div>
                  </div>
                  <button
                    onClick={() => handleUseItem(item)}
                    className="px-btn px-btn--primary"
                  >
                    USE
                  </button>
                </div>
              ))
            )}
          </div>
        )}

        {/* Tab 3: DTR Logs Sheet */}
        {activeTab === 'dtr' && <DtrLogSheet />}
      </div>

      {/* Footer */}
      <div style={{ padding: '8px', textAlign: 'center' }}>
        <div className="px-divider" style={{ marginBottom: '8px' }} />
        <span className="px-label">VITALS & DTR</span>
      </div>
    </aside>
  );
};
