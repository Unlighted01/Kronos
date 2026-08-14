import React from 'react';
import { X, Edit2, Trash2, Clock, Calendar, Tag, Award, AlignLeft } from 'lucide-react';
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
    weekday: 'long',
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
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 backdrop-blur-sm p-4">
      <div className="w-[90%] max-w-[340px] bg-slate-900/95 border border-white/15 rounded-2xl shadow-2xl backdrop-blur-xl p-4 flex flex-col">
        <div className="flex items-center justify-between pb-3 border-b border-white/10">
          <h2 className="text-sm font-bold text-slate-100 truncate pr-2">
            {session.taskName}
          </h2>
          <button onClick={onClose} className="p-1 text-slate-400 hover:text-white rounded-lg hover:bg-slate-800 transition-colors">
            <X size={16} />
          </button>
        </div>

        <div className="py-4 space-y-4 overflow-y-auto custom-scrollbar">
          <div className="flex flex-col space-y-2">
            <div className="flex items-center text-xs text-slate-300">
              <Calendar size={14} className="text-slate-500 mr-2" />
              <span>{formattedDate}</span>
            </div>
            <div className="flex items-center text-xs text-slate-300">
              <Clock size={14} className="text-slate-500 mr-2" />
              <span>{startStr} - {endStr}</span>
            </div>
          </div>

          <div className="flex flex-wrap gap-2">
            <div className="flex items-center px-2 py-1 bg-slate-950/60 rounded-lg border border-slate-700/50">
              <Clock size={12} className="text-indigo-400 mr-1.5" />
              <span className="text-xs font-semibold text-slate-200">{session.durationMinutes} min</span>
            </div>
            <div className="flex items-center px-2 py-1 bg-slate-950/60 rounded-lg border border-slate-700/50">
              <Tag size={12} className="text-emerald-400 mr-1.5" />
              <span className="text-xs font-semibold text-slate-200">{session.category}</span>
            </div>
            <div className="flex items-center px-2 py-1 bg-slate-950/60 rounded-lg border border-slate-700/50">
              <Award size={12} className="text-amber-400 mr-1.5" />
              <span className="text-xs font-semibold text-amber-300">+{session.coinsEarned}c</span>
            </div>
          </div>

          <div>
            <div className="flex items-center text-[10px] font-bold text-slate-400 mb-2 uppercase tracking-wider">
              <AlignLeft size={12} className="mr-1.5" /> Notes
            </div>
            {session.notes ? (
              <p className="text-xs text-slate-300 bg-slate-950 p-3 rounded-xl border border-white/5 whitespace-pre-wrap font-mono">
                {session.notes}
              </p>
            ) : (
              <p className="text-xs text-slate-500 italic bg-slate-950/50 p-3 rounded-xl border border-white/5">
                No notes added.
              </p>
            )}
          </div>
        </div>

        <div className="pt-3 mt-2 border-t border-white/10 flex justify-between items-center gap-2">
          <button
            onClick={handleDelete}
            className="flex items-center justify-center px-3 py-1.5 text-xs font-semibold text-rose-400 bg-rose-400/10 hover:bg-rose-400/20 border border-rose-400/20 rounded-xl transition-all"
          >
            <Trash2 size={12} className="mr-1.5" /> Delete
          </button>
          <button
            onClick={() => {
              onEdit(session);
              onClose();
            }}
            className="flex items-center justify-center px-4 py-1.5 bg-indigo-600 hover:bg-indigo-500 text-white text-xs font-bold rounded-xl transition-all shadow-md active:scale-95"
          >
            <Edit2 size={12} className="mr-1.5" /> Edit
          </button>
        </div>
      </div>
    </div>
  );
};
