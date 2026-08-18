import React, { useState, useEffect } from 'react';
import { LeftPanel } from '../panels/LeftPanel';
import { RightPanel } from '../panels/RightPanel';
import { WidgetView } from '../widget/WidgetView';
import { syncAndUnlockAllItems } from '../../db/kronosDb';

export type PresetScale = '1x' | '1.25x' | '1.5x';

/** Panel widths per scale preset — must match PRESET_DIMS in electron/main.ts */
const PANEL_WIDTHS: Record<PresetScale, { left: number; right: number }> = {
  '1x':    { left: 220, right: 200 },
  '1.25x': { left: 255, right: 230 },
  '1.5x':  { left: 290, right: 260 },
};

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
      window.kronosElectron.updatePanelLayout({ leftOpen, rightOpen, scale });
    }
  }, [leftOpen, rightOpen, scale]);

  const toggleLeft = () => setLeftOpen((prev) => !prev);
  const toggleRight = () => setRightOpen((prev) => !prev);

  const panelW = PANEL_WIDTHS[scale];

  return (
    <div className="workspace-root">
      {/* Left Panel: fixed width per scale */}
      {leftOpen && (
        <LeftPanel
          onClose={() => setLeftOpen(false)}
          scale={scale}
          onScaleChange={(newScale) => setScale(newScale)}
          width={panelW.left}
        />
      )}

      {/* Middle Widget Panel: fills remaining space (window width is exact) */}
      <div className="panel-middle-container">
        <WidgetView
          leftOpen={leftOpen}
          rightOpen={rightOpen}
          onToggleLeft={toggleLeft}
          onToggleRight={toggleRight}
          scale={scale}
        />
      </div>

      {/* Right Panel: fixed width per scale */}
      {rightOpen && (
        <RightPanel
          onClose={() => setRightOpen(false)}
          width={panelW.right}
        />
      )}
    </div>
  );
};
