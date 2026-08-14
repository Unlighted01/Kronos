import React from 'react';

interface DtrConfirmModalProps {
  isOpen: boolean;
  onClose: () => void;
  onConfirm: () => void;
}

export const DtrConfirmModal: React.FC<DtrConfirmModalProps> = ({ isOpen, onClose, onConfirm }) => {
  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 z-[60] flex items-center justify-center bg-black/60 backdrop-blur-sm p-4">
      <div className="w-[90%] max-w-[300px] bg-slate-950/95 border border-rose-500/30 rounded-2xl p-5 shadow-2xl backdrop-blur-xl text-center">
        <div className="text-4xl mb-3 animate-bounce">🗑️</div>
        <h2 className="text-sm font-bold text-slate-100 mb-1">Delete DTR Entry?</h2>
        <p className="text-xs text-slate-400 mb-5">Are you sure you want to delete this log? This action cannot be undone.</p>
        <div className="flex justify-center items-center gap-3">
          <button
            onClick={onClose}
            className="px-4 py-1.5 text-xs font-semibold text-slate-300 bg-slate-800/80 hover:bg-slate-800 border border-white/10 rounded-xl transition-all"
          >
            Cancel
          </button>
          <button
            onClick={() => {
              onConfirm();
              onClose();
            }}
            className="px-4 py-1.5 text-xs font-bold text-white bg-rose-600 hover:bg-rose-500 rounded-xl transition-all shadow-md active:scale-95"
          >
            Delete
          </button>
        </div>
      </div>
    </div>
  );
};
