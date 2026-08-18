import React from 'react';

interface DtrConfirmModalProps {
  isOpen: boolean;
  onClose: () => void;
  onConfirm: () => void;
}

export const DtrConfirmModal: React.FC<DtrConfirmModalProps> = ({ isOpen, onClose, onConfirm }) => {
  if (!isOpen) return null;

  return (
    <div
      style={{
        position: 'fixed',
        inset: 0,
        zIndex: 60,
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        backgroundColor: 'rgba(7, 8, 15, 0.8)',
        padding: '8px',
      }}
    >
      <div
        className="px-card"
        style={{
          width: '90%',
          maxWidth: '260px',
          borderColor: 'var(--px-red)',
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
          gap: '8px',
          padding: '12px',
          textAlign: 'center',
        }}
      >
        <span style={{ fontSize: '24px' }}>🗑️</span>
        <span className="px-title" style={{ color: 'var(--px-red)' }}>DELETE ENTRY?</span>
        <p className="px-label" style={{ color: 'var(--px-muted)', lineHeight: 1.4 }}>
          Are you sure? This cannot be undone.
        </p>
        <div style={{ display: 'flex', gap: '8px', marginTop: '4px' }}>
          <button onClick={onClose} className="px-btn">
            CANCEL
          </button>
          <button
            onClick={() => {
              onConfirm();
              onClose();
            }}
            className="px-btn px-btn--danger"
          >
            DELETE
          </button>
        </div>
      </div>
    </div>
  );
};
