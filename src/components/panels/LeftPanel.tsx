import React, { useState } from 'react';
import { useLiveQuery } from 'dexie-react-hooks';
import { db, initPetStats } from '../../db/kronosDb';
import { PetShop } from '../shop/PetShop';
import { useAppStore } from '../../stores/useAppStore';
import { PresetScale } from '../widget/WidgetSettingsPopover';
import { audioSynth } from '../../utils/audioSynth';

interface LeftPanelProps {
  onClose: () => void;
  scale?: PresetScale;
  onScaleChange?: (scale: PresetScale) => void;
  initialTab?: 'shop' | 'settings';
  width?: number;
}

export const LeftPanel: React.FC<LeftPanelProps> = ({
  onClose,
  scale = '1x',
  onScaleChange,
  initialTab = 'shop',
  width,
}) => {
  const [activeTab, setActiveTab] = useState<'shop' | 'settings'>(initialTab);
  const { alwaysOnTop, setAlwaysOnTop } = useAppStore();

  const petStats = useLiveQuery(async () => {
    return (await db.petStats.get('primary')) || (await initPetStats());
  });

  const coins = petStats?.coins ?? 0;

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
    <aside
      className="panel-left-container"
      style={{
        width: width ? `${width}px` : undefined,
        minWidth: width ? `${width}px` : undefined,
        maxWidth: width ? `${width}px` : undefined,
      }}
    >
      {/* Header */}
      <header className="px-header">
        <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
          <span className="px-title">◈ SHOP</span>
          <span className="px-badge">{coins} G</span>
        </div>
        <button
          onClick={onClose}
          className="px-btn px-btn--danger no-drag"
          style={{ padding: '2px 6px', WebkitAppRegion: 'no-drag' } as React.CSSProperties}
          title="Collapse Left Panel"
        >
          ✕
        </button>
      </header>

      {/* Tab Bar */}
      <div className="px-tab-bar">
        <button
          onClick={() => setActiveTab('shop')}
          className={activeTab === 'shop' ? 'px-tab px-tab--active' : 'px-tab'}
        >
          SHOP
        </button>
        <button
          onClick={() => setActiveTab('settings')}
          className={activeTab === 'settings' ? 'px-tab px-tab--active' : 'px-tab'}
        >
          CONFIG
        </button>
      </div>

      {/* Main Content */}
      <div className="px-scrollable">
        {activeTab === 'shop' && <PetShop />}

        {activeTab === 'settings' && (
          <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
            {/* WINDOW SCALE */}
            <div className="px-card" style={{ display: 'flex', flexDirection: 'column', gap: '6px' }}>
              <div className="px-label">WINDOW SCALE</div>
              <div style={{ display: 'flex', gap: '4px' }}>
                {(['1x', '1.25x', '1.5x'] as PresetScale[]).map((s) => (
                  <button
                    key={s}
                    onClick={() => handleSelectScale(s)}
                    className={scale === s ? 'px-btn px-btn--cyan' : 'px-btn'}
                    style={{ flex: 1 }}
                  >
                    {s.toUpperCase()}
                  </button>
                ))}
              </div>
            </div>

            {/* PIN WINDOW */}
            <div className="px-card" style={{ display: 'flex', flexDirection: 'column', gap: '6px' }}>
              <div className="px-label">PIN WINDOW</div>
              <button
                onClick={handleToggleAlwaysOnTop}
                className={alwaysOnTop ? 'px-btn px-btn--primary' : 'px-btn'}
                style={{ width: '100%' }}
              >
                {alwaysOnTop ? '📌 PINNED' : '📌 PIN TO TOP'}
              </button>
            </div>

            {/* TIMER PRESET */}
            <div className="px-card" style={{ display: 'flex', flexDirection: 'column', gap: '6px' }}>
              <div className="px-label">TIMER PRESET</div>
              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '6px' }}>
                <div style={{ display: 'flex', flexDirection: 'column', gap: '4px' }}>
                  <span className="px-label">FOCUS</span>
                  <input type="number" defaultValue={25} className="px-input" />
                </div>
                <div style={{ display: 'flex', flexDirection: 'column', gap: '4px' }}>
                  <span className="px-label">BREAK</span>
                  <input type="number" defaultValue={5} className="px-input" />
                </div>
              </div>
            </div>
          </div>
        )}
      </div>

      {/* Footer */}
      <div className="px-divider" />
      <footer style={{ padding: '6px 8px', textAlign: 'center', flexShrink: 0 }}>
        <span className="px-label">KRONOS v1.0</span>
      </footer>
    </aside>
  );
};

