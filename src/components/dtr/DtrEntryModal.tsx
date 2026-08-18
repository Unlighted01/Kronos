import React, { useState, useEffect } from 'react';
import { db, DtrSession } from '../../db/kronosDb';
import { audioSynth } from '../../utils/audioSynth';

interface DtrEntryModalProps {
  isOpen: boolean;
  onClose: () => void;
  initialSession?: DtrSession | null;
}

const CATEGORIES = ['Development', 'Design', 'Study', 'Meeting', 'General'];

export const DtrEntryModal: React.FC<DtrEntryModalProps> = ({
  isOpen,
  onClose,
  initialSession,
}) => {
  const [date, setDate] = useState<string>('');
  const [startTime, setStartTime] = useState<string>('');
  const [endTime, setEndTime] = useState<string>('');
  const [durationMinutes, setDurationMinutes] = useState<number>(25);
  const [taskName, setTaskName] = useState<string>('');
  const [category, setCategory] = useState<string>('Development');
  const [notes, setNotes] = useState<string>('');

  useEffect(() => {
    if (isOpen) {
      if (initialSession) {
        setDate(initialSession.dateKey);

        const start = new Date(initialSession.startTime);
        const end = new Date(initialSession.endTime);

        setStartTime(`${start.getHours().toString().padStart(2, '0')}:${start.getMinutes().toString().padStart(2, '0')}`);
        setEndTime(`${end.getHours().toString().padStart(2, '0')}:${end.getMinutes().toString().padStart(2, '0')}`);

        setDurationMinutes(initialSession.durationMinutes);
        setTaskName(initialSession.taskName);
        setCategory(initialSession.category);
        setNotes(initialSession.notes || '');
      } else {
        const now = new Date();
        const yyyy = now.getFullYear();
        const mm = String(now.getMonth() + 1).padStart(2, '0');
        const dd = String(now.getDate()).padStart(2, '0');
        setDate(`${yyyy}-${mm}-${dd}`);

        const currentStart = `${now.getHours().toString().padStart(2, '0')}:${now.getMinutes().toString().padStart(2, '0')}`;
        setStartTime(currentStart);

        const end = new Date(now.getTime() + 25 * 60000);
        const currentEnd = `${end.getHours().toString().padStart(2, '0')}:${end.getMinutes().toString().padStart(2, '0')}`;
        setEndTime(currentEnd);

        setDurationMinutes(25);
        setTaskName('');
        setCategory('Development');
        setNotes('');
      }
    }
  }, [isOpen, initialSession]);

  const handleTimeChange = (newStart: string, newEnd: string) => {
    setStartTime(newStart);
    setEndTime(newEnd);

    if (newStart && newEnd) {
      const [startH, startM] = newStart.split(':').map(Number);
      const [endH, endM] = newEnd.split(':').map(Number);
      let diff = (endH * 60 + endM) - (startH * 60 + startM);
      if (diff < 0) diff += 24 * 60;
      setDurationMinutes(diff);
    }
  };

  const handleSave = async () => {
    if (!taskName.trim()) return;

    try {
      const [startH, startM] = startTime.split(':').map(Number);
      const [endH, endM] = endTime.split(':').map(Number);

      const startIso = new Date(`${date}T${startH.toString().padStart(2, '0')}:${startM.toString().padStart(2, '0')}:00`).toISOString();
      const endIsoDate = new Date(`${date}T${endH.toString().padStart(2, '0')}:${endM.toString().padStart(2, '0')}:00`);

      if (endIsoDate.getTime() < new Date(startIso).getTime()) {
        endIsoDate.setDate(endIsoDate.getDate() + 1);
      }

      const endIso = endIsoDate.toISOString();

      if (initialSession?.id) {
        await db.dtrSessions.update(initialSession.id, {
          taskName,
          category,
          notes,
          startTime: startIso,
          endTime: endIso,
          durationMinutes,
          dateKey: date,
        });
      } else {
        const coinsEarned = Math.max(1, Math.floor(durationMinutes / 5));
        const expEarned = Math.max(1, Math.floor(durationMinutes / 2));

        await db.dtrSessions.add({
          taskName,
          category,
          notes,
          startTime: startIso,
          endTime: endIso,
          durationMinutes,
          status: 'completed',
          coinsEarned,
          expEarned,
          dateKey: date,
        });
      }

      audioSynth.playClick();
      onClose();
    } catch {
      // Error handled gracefully
    }
  };

  if (!isOpen) return null;

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
          maxWidth: '320px',
          display: 'flex',
          flexDirection: 'column',
          gap: '8px',
          padding: '10px',
          maxHeight: '85vh',
          overflowY: 'auto',
        }}
      >
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <span className="px-title">{initialSession ? 'EDIT ENTRY' : 'ADD DTR ENTRY'}</span>
          <button onClick={onClose} className="px-btn px-btn--danger" style={{ padding: '2px 6px' }}>
            ✕
          </button>
        </div>

        <div className="px-divider" />

        <div style={{ display: 'flex', flexDirection: 'column', gap: '6px' }}>
          <div>
            <span className="px-label">TASK NAME</span>
            <input
              type="text"
              placeholder="e.g. Code Review"
              value={taskName}
              onChange={(e) => setTaskName(e.target.value)}
              className="px-input"
              style={{ marginTop: '2px' }}
            />
          </div>

          <div>
            <span className="px-label">CATEGORY</span>
            <div style={{ display: 'flex', flexWrap: 'wrap', gap: '4px', marginTop: '2px' }}>
              {CATEGORIES.map((cat) => (
                <button
                  key={cat}
                  onClick={() => setCategory(cat)}
                  className={category === cat ? 'px-btn px-btn--cyan' : 'px-btn'}
                  style={{ fontSize: '6px', padding: '3px 6px' }}
                >
                  {cat.toUpperCase()}
                </button>
              ))}
            </div>
          </div>

          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '6px' }}>
            <div>
              <span className="px-label">DATE</span>
              <input
                type="date"
                value={date}
                onChange={(e) => setDate(e.target.value)}
                className="px-input"
                style={{ marginTop: '2px' }}
              />
            </div>
            <div>
              <span className="px-label">MINUTES</span>
              <input
                type="number"
                min={1}
                value={durationMinutes}
                onChange={(e) => setDurationMinutes(Number(e.target.value))}
                className="px-input"
                style={{ marginTop: '2px' }}
              />
            </div>
          </div>

          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '6px' }}>
            <div>
              <span className="px-label">START</span>
              <input
                type="time"
                value={startTime}
                onChange={(e) => handleTimeChange(e.target.value, endTime)}
                className="px-input"
                style={{ marginTop: '2px' }}
              />
            </div>
            <div>
              <span className="px-label">END</span>
              <input
                type="time"
                value={endTime}
                onChange={(e) => handleTimeChange(startTime, e.target.value)}
                className="px-input"
                style={{ marginTop: '2px' }}
              />
            </div>
          </div>

          <div>
            <span className="px-label">NOTES</span>
            <textarea
              placeholder="Optional notes..."
              value={notes}
              onChange={(e) => setNotes(e.target.value)}
              className="px-input"
              style={{ marginTop: '2px', height: '48px', resize: 'none' }}
            />
          </div>
        </div>

        <div className="px-divider" />

        <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '6px' }}>
          <button onClick={onClose} className="px-btn">
            CANCEL
          </button>
          <button
            onClick={handleSave}
            disabled={!taskName.trim() || !date || !startTime || !endTime}
            className="px-btn px-btn--primary"
            style={{ opacity: !taskName.trim() || !date || !startTime || !endTime ? 0.4 : 1 }}
          >
            SAVE
          </button>
        </div>
      </div>
    </div>
  );
};
