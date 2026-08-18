import React from 'react';
import { DtrSession } from '../../db/kronosDb';

interface DtrDetailModalProps {
  session: DtrSession | null;
  onClose: () => void;
  onEdit: (session: DtrSession) => void;
  onDelete: (sessionId: number) => void;
}

export const DtrDetailModal: React.FC<DtrDetailModalProps> = ({
  session,
  onClose,
  onEdit,
  onDelete,
}) => {
  if (!session) return null;

  const dateObj = new Date(session.startTime);
  const formattedDate = dateObj.toLocaleDateString(undefined, {
    weekday: 'short',
    year: 'numeric',
    month: 'short',
    day: 'numeric',
  });

  const startStr = dateObj.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
  const endStr = new Date(session.endTime).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });

  const handleDelete = () => {
    if (session.id) onDelete(session.id);
  };

  return (
    <div
      style={{
        position: 'fixed',
        inset: 0,
        zIndex: 50,
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
          maxWidth: '300px',
          display: 'flex',
          flexDirection: 'column',
          gap: '8px',
          padding: '10px',
          maxHeight: '85vh',
          overflowY: 'auto',
        }}
      >
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <span className="px-title" style={{ whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>
            {session.taskName}
          </span>
          <button onClick={onClose} className="px-btn px-btn--danger" style={{ padding: '2px 6px' }}>
            ✕
          </button>
        </div>

        <div className="px-divider" />

        <div style={{ display: 'flex', flexDirection: 'column', gap: '4px' }}>
          <div className="px-label">📅 {formattedDate}</div>
          <div className="px-label">⏰ {startStr} - {endStr}</div>
        </div>

        <div style={{ display: 'flex', gap: '4px', flexWrap: 'wrap' }}>
          <span className="px-badge--cyan">{session.durationMinutes} MIN</span>
          <span className="px-badge">{session.category.toUpperCase()}</span>
          <span className="px-badge" style={{ background: 'var(--px-gold)' }}>+{session.coinsEarned} G</span>
        </div>

        <div>
          <div className="px-label" style={{ marginBottom: '4px' }}>NOTES</div>
          <div
            className="px-card"
            style={{
              padding: '6px',
              fontFamily: 'JetBrains Mono, monospace',
              fontSize: '10px',
              color: session.notes ? 'var(--px-white)' : 'var(--px-muted)',
              whiteSpace: 'pre-wrap',
            }}
          >
            {session.notes || 'No notes added.'}
          </div>
        </div>

        <div className="px-divider" />

        <div style={{ display: 'flex', justifyContent: 'space-between', gap: '8px' }}>
          <button onClick={handleDelete} className="px-btn px-btn--danger">
            DELETE
          </button>
          <button
            onClick={() => {
              onEdit(session);
              onClose();
            }}
            className="px-btn px-btn--cyan"
          >
            EDIT
          </button>
        </div>
      </div>
    </div>
  );
};
