import React, { useState, useEffect } from 'react';
import { LeftPanel } from '../panels/LeftPanel';
import { RightPanel } from '../panels/RightPanel';
import { WidgetView } from '../widget/WidgetView';
import { syncAndUnlockAllItems } from '../../db/kronosDb';

export type PresetScale = '1x' | '1.25x' | '1.5x';

export const ThreePanelWorkspace: React.FC = () => {
  const [leftOpen, setLeftOpen] = useState<boolean>(false);
  const [rightOpen, setRightOpen] = useState<boolean>(false);
  const [scale, setScale] = useState<PresetScale>('1x');

  useEffect(() => {
    syncAndUnlockAllItems().catch(() => {});
  }, []);

  // Trigger IPC window bounds update when panel toggle or preset scale changes
  useEffect(() => {
    if (window.kronosElectron?.updatePanelLayout) {
      window.kronosElectron.updatePanelLayout({
        leftOpen,
        rightOpen,
        scale,
      });
    }
  }, [leftOpen, rightOpen, scale]);

  const toggleLeft = () => setLeftOpen((prev) => !prev);
  const toggleRight = () => setRightOpen((prev) => !prev);

  return (
    <div className="workspace-root">
      {/* Left Collapsible Panel: Shop & Settings (240px) */}
      {leftOpen && (
        <LeftPanel
          onClose={() => setLeftOpen(false)}
          scale={scale}
          onScaleChange={(newScale) => setScale(newScale)}
        />
      )}

      {/* Middle Fixed Pet & Pomodoro Panel */}
      <div className="panel-middle-container">
        <WidgetView
          leftOpen={leftOpen}
          rightOpen={rightOpen}
          onToggleLeft={toggleLeft}
          onToggleRight={toggleRight}
          scale={scale}
        />
      </div>

      {/* Right Collapsible Panel: Vitals, Inventory & DTR Logs (220px) */}
      {rightOpen && <RightPanel onClose={() => setRightOpen(false)} />}
    </div>
  );
};
