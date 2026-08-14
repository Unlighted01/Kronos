import React, { useState, useEffect } from 'react';
import { X } from 'lucide-react';
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
      if (diff < 0) diff += 24 * 60; // handle passing midnight
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
          dateKey: date
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
          dateKey: date
        });
      }

      audioSynth.playClick();
      onClose();
    } catch (err) {
      // Handle error gracefully
    }
  };

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 backdrop-blur-sm p-4">
      <div className="w-[90%] max-w-[340px] bg-slate-900/95 border border-white/15 rounded-2xl shadow-2xl backdrop-blur-xl p-4 flex flex-col max-h-[85vh]">
        <div className="flex items-center justify-between pb-3 border-b border-white/10">
          <h2 className="text-sm font-bold text-slate-100 flex items-center gap-2">{initialSession ? 'Edit Entry' : 'Add DTR Entry'}</h2>
          <button onClick={onClose} className="p-1 text-slate-400 hover:text-white rounded-lg hover:bg-slate-800 transition-colors">
            <X size={16} />
          </button>
        </div>

        <div className="overflow-y-auto pr-1 space-y-4 mt-4 custom-scrollbar">
          <div>
            <label className="block text-[10px] font-bold text-slate-400 uppercase tracking-wider mb-1.5">Task Name</label>
            <input
              type="text"
              placeholder="Task name"
              value={taskName}
              onChange={(e) => setTaskName(e.target.value)}
              className="w-full h-8 px-3 text-xs bg-slate-950 border border-white/10 rounded-xl text-slate-100 placeholder-slate-500 focus:outline-none focus:border-indigo-500 font-medium"
            />
          </div>

          <div>
            <label className="block text-[10px] font-bold text-slate-400 uppercase tracking-wider mb-1.5">Category</label>
            <div className="flex flex-wrap gap-1.5">
              {CATEGORIES.map((cat) => (
                <button
                  key={cat}
                  onClick={() => setCategory(cat)}
                  className={`px-2.5 py-1 text-xs font-semibold rounded-lg border transition-all select-none whitespace-nowrap ${
                    category === cat
                      ? 'bg-indigo-600 border-indigo-400 text-white shadow-md font-bold scale-[1.02]'
                      : 'bg-slate-950/60 border-white/10 text-slate-300 hover:bg-slate-800 hover:text-white hover:border-white/20'
                  }`}
                >
                  {cat}
                </button>
              ))}
            </div>
          </div>

          <div className="grid grid-cols-2 gap-2.5">
            <div>
              <label className="block text-[10px] font-bold text-slate-400 uppercase tracking-wider mb-1.5">Date</label>
              <input
                type="date"
                value={date}
                onChange={(e) => setDate(e.target.value)}
                className="w-full h-8 px-2.5 text-xs bg-slate-950 border border-white/10 rounded-xl text-slate-100 font-mono focus:outline-none focus:border-indigo-500"
              />
            </div>
            <div>
              <label className="block text-[10px] font-bold text-slate-400 uppercase tracking-wider mb-1.5">Duration (min)</label>
              <input
                type="number"
                min={1}
                value={durationMinutes}
                onChange={(e) => setDurationMinutes(Number(e.target.value))}
                className="w-full h-8 px-2.5 text-xs bg-slate-950 border border-white/10 rounded-xl text-slate-100 font-mono focus:outline-none focus:border-indigo-500"
              />
            </div>
          </div>

          <div className="grid grid-cols-2 gap-2.5">
            <div>
              <label className="block text-[10px] font-bold text-slate-400 uppercase tracking-wider mb-1.5">Start Time</label>
              <input
                type="time"
                value={startTime}
                onChange={(e) => handleTimeChange(e.target.value, endTime)}
                className="w-full h-8 px-2.5 text-xs bg-slate-950 border border-white/10 rounded-xl text-slate-100 font-mono focus:outline-none focus:border-indigo-500"
              />
            </div>
            <div>
              <label className="block text-[10px] font-bold text-slate-400 uppercase tracking-wider mb-1.5">End Time</label>
              <input
                type="time"
                value={endTime}
                onChange={(e) => handleTimeChange(startTime, e.target.value)}
                className="w-full h-8 px-2.5 text-xs bg-slate-950 border border-white/10 rounded-xl text-slate-100 font-mono focus:outline-none focus:border-indigo-500"
              />
            </div>
          </div>

          <div>
            <label className="block text-[10px] font-bold text-slate-400 uppercase tracking-wider mb-1.5">Notes (Optional)</label>
            <textarea
              placeholder="Notes..."
              value={notes}
              onChange={(e) => setNotes(e.target.value)}
              className="w-full h-14 p-2.5 text-xs bg-slate-950 border border-white/10 rounded-xl text-slate-100 placeholder-slate-500 resize-none font-mono focus:outline-none focus:border-indigo-500 custom-scrollbar"
            />
          </div>
        </div>

        <div className="pt-3 mt-2 border-t border-white/10 flex justify-end items-center gap-2">
          <button
            onClick={onClose}
            className="px-3.5 py-1.5 text-xs font-semibold text-slate-300 bg-slate-800/80 hover:bg-slate-800 border border-white/10 rounded-xl transition-all"
          >
            Cancel
          </button>
          <button
            onClick={handleSave}
            disabled={!taskName.trim() || !date || !startTime || !endTime}
            className="px-4 py-1.5 text-xs font-bold text-white bg-indigo-600 hover:bg-indigo-500 disabled:opacity-40 rounded-xl transition-all shadow-md active:scale-95"
          >
            Save
          </button>
        </div>
      </div>
    </div>
  );
};
