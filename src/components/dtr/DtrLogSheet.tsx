import React, { useState } from 'react';
import { useLiveQuery } from 'dexie-react-hooks';
import { db, DtrSession } from '../../db/kronosDb';
import { DtrEntryModal } from './DtrEntryModal';
import { DtrDetailModal } from './DtrDetailModal';
import { DtrConfirmModal } from './DtrConfirmModal';

export const DtrLogSheet: React.FC = () => {
  const [filterDate, setFilterDate] = useState<string>(
    new Date().toISOString().split('T')[0]
  );
  const [isAddEditModalOpen, setIsAddEditModalOpen] = useState(false);
  const [editingSession, setEditingSession] = useState<DtrSession | null>(null);
  const [selectedDetailSession, setSelectedDetailSession] = useState<DtrSession | null>(null);
  const [isConfirmModalOpen, setIsConfirmModalOpen] = useState(false);
  const [sessionToDelete, setSessionToDelete] = useState<number | null>(null);

  const handleDeleteSession = (sessionId: number) => {
    setSessionToDelete(sessionId);
    setIsConfirmModalOpen(true);
  };

  const confirmDeleteSession = async () => {
    if (sessionToDelete) {
      await db.dtrSessions.delete(sessionToDelete);
      setSelectedDetailSession(null);
      setSessionToDelete(null);
    }
  };

  const handleEditSession = (session: DtrSession) => {
    setEditingSession(session);
    setIsAddEditModalOpen(true);
  };

  const sessions = useLiveQuery(async () => {
    if (filterDate === 'ALL') {
      return await db.dtrSessions.orderBy('id').reverse().toArray();
    }
    return await db.dtrSessions
      .where('dateKey')
      .equals(filterDate)
      .reverse()
      .toArray();
  }, [filterDate]);

  const totalMinutes = sessions
    ? sessions.reduce((acc, s) => acc + s.durationMinutes, 0)
    : 0;
  const totalCoins = sessions
    ? sessions.reduce((acc, s) => acc + s.coinsEarned, 0)
    : 0;
  const totalHours = (totalMinutes / 60).toFixed(1);

  const handleExportCsv = () => {
    if (!sessions || sessions.length === 0) return;

    const headers = [
      'ID',
      'Date',
      'Task Name',
      'Category',
      'Start Time',
      'End Time',
      'Duration (Min)',
      'Coins Earned',
      'Notes',
    ];
    const rows = sessions.map((s) => [
      s.id,
      s.dateKey,
      `"${s.taskName.replace(/"/g, '""')}"`,
      `"${s.category}"`,
      new Date(s.startTime).toLocaleTimeString(),
      new Date(s.endTime).toLocaleTimeString(),
      s.durationMinutes,
      s.coinsEarned,
      `"${(s.notes || '').replace(/"/g, '""')}"`,
    ]);

    const csvContent = [
      headers.join(','),
      ...rows.map((r) => r.join(',')),
    ].join('\n');
    const blob = new Blob([csvContent], {
      type: 'text/csv;charset=utf-8;',
    });
    const url = URL.createObjectURL(blob);
    const link = document.createElement('a');
    link.href = url;
    link.setAttribute('download', `kronos_dtr_log_${filterDate}.csv`);
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  };

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
      {/* Metric Summary Cards */}
      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '6px' }}>
        <div className="px-card" style={{ display: 'flex', flexDirection: 'column', gap: '4px', padding: '6px' }}>
          <span className="px-label">TIME</span>
          <span className="px-value">{totalHours}h</span>
        </div>

        <div className="px-card" style={{ display: 'flex', flexDirection: 'column', gap: '4px', padding: '6px' }}>
          <span className="px-label">COINS</span>
          <span className="px-value" style={{ color: 'var(--px-gold)' }}>+{totalCoins}</span>
        </div>
      </div>

      {/* Date & Filter Controls */}
      <div style={{ display: 'flex', flexDirection: 'column', gap: '6px' }}>
        <div style={{ display: 'flex', gap: '4px', alignItems: 'center' }}>
          <input
            type="date"
            value={filterDate === 'ALL' ? '' : filterDate}
            onChange={(e) => setFilterDate(e.target.value || 'ALL')}
            className="px-input"
            style={{ flex: 1 }}
          />

          <button
            onClick={() => setFilterDate(filterDate === 'ALL' ? new Date().toISOString().split('T')[0] : 'ALL')}
            className={filterDate === 'ALL' ? 'px-btn px-btn--cyan' : 'px-btn'}
            style={{ flexShrink: 0 }}
          >
            {filterDate === 'ALL' ? 'TODAY' : 'ALL'}
          </button>

          <button
            onClick={handleExportCsv}
            disabled={!sessions || sessions.length === 0}
            title="Export CSV"
            className="px-btn"
            style={{ flexShrink: 0, opacity: !sessions || sessions.length === 0 ? 0.4 : 1 }}
          >
            CSV
          </button>
        </div>

        {/* Add Entry Button */}
        <button
          onClick={() => {
            setEditingSession(null);
            setIsAddEditModalOpen(true);
          }}
          className="px-btn px-btn--primary"
          style={{ width: '100%' }}
        >
          + ADD DTR ENTRY
        </button>
      </div>

      {/* Session Cards List */}
      <div style={{ display: 'flex', flexDirection: 'column', gap: '6px' }}>
        {sessions && sessions.length > 0 ? (
          sessions.map((session: DtrSession) => (
            <div
              key={session.id}
              className="px-card"
              style={{
                display: 'flex',
                justifyContent: 'space-between',
                alignItems: 'center',
                padding: '6px 8px',
                cursor: 'pointer',
              }}
              onClick={() => setSelectedDetailSession(session)}
            >
              <div style={{ minWidth: 0, flex: 1, paddingRight: '6px' }}>
                <div className="px-label" style={{ color: 'var(--px-white)', whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>
                  {session.taskName}
                </div>
                <div className="px-label" style={{ marginTop: '2px', color: 'var(--px-cyan)' }}>
                  {session.durationMinutes}m &bull; {new Date(session.startTime).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
                </div>
              </div>

              <div style={{ display: 'flex', alignItems: 'center', gap: '6px', flexShrink: 0 }}>
                <button
                  onClick={(e) => {
                    e.stopPropagation();
                    handleEditSession(session);
                  }}
                  className="px-btn"
                  style={{ padding: '2px 4px' }}
                  title="Edit"
                >
                  ✎
                </button>
                <button
                  onClick={(e) => {
                    e.stopPropagation();
                    if (session.id) handleDeleteSession(session.id);
                  }}
                  className="px-btn px-btn--danger"
                  style={{ padding: '2px 4px' }}
                  title="Delete"
                >
                  ✕
                </button>
                <span className="px-badge" style={{ padding: '2px 4px' }}>
                  +{session.coinsEarned}
                </span>
              </div>
            </div>
          ))
        ) : (
          <div className="px-card" style={{ padding: '12px 8px', textAlign: 'center' }}>
            <span className="px-label">NO DTR LOGS</span>
          </div>
        )}
      </div>

      <DtrEntryModal
        isOpen={isAddEditModalOpen}
        onClose={() => setIsAddEditModalOpen(false)}
        initialSession={editingSession}
      />

      <DtrDetailModal
        session={selectedDetailSession}
        onClose={() => setSelectedDetailSession(null)}
        onEdit={handleEditSession}
        onDelete={handleDeleteSession}
      />

      <DtrConfirmModal
        isOpen={isConfirmModalOpen}
        onClose={() => setIsConfirmModalOpen(false)}
        onConfirm={confirmDeleteSession}
      />
    </div>
  );
};
