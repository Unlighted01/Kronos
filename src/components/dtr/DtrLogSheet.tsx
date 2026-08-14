import React, { useState } from 'react';
import { useLiveQuery } from 'dexie-react-hooks';
import { db, DtrSession } from '../../db/kronosDb';
import { Calendar, Download, Clock, Award } from 'lucide-react';

export const DtrLogSheet: React.FC = () => {
  const [filterDate, setFilterDate] = useState<string>(
    new Date().toISOString().split('T')[0]
  );

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
    <div className="space-y-2 select-none">
      {/* Metric Summary Cards */}
      <div className="grid grid-cols-2 gap-1">
        <div className="bg-slate-950/80 p-2 rounded-xl border border-white/10 flex items-center space-x-2 shadow-inner">
          <Clock size={14} className="text-indigo-400 shrink-0" />
          <div className="truncate">
            <span className="text-[7.5px] text-slate-400 font-semibold block">TOTAL TIME</span>
            <span className="text-xs font-bold text-slate-100 font-mono">{totalHours}h</span>
          </div>
        </div>

        <div className="bg-slate-950/80 p-2 rounded-xl border border-white/10 flex items-center space-x-2 shadow-inner">
          <Award size={14} className="text-amber-400 shrink-0" />
          <div className="truncate">
            <span className="text-[7.5px] text-slate-400 font-semibold block">COINS</span>
            <span className="text-xs font-bold text-amber-400 font-mono">+{totalCoins}</span>
          </div>
        </div>
      </div>

      {/* Date & Filter Controls */}
      <div className="flex items-center space-x-1">
        <div className="flex-1 flex items-center space-x-1 bg-slate-900/60 border border-white/10 rounded-lg px-2 py-1">
          <Calendar size={11} className="text-slate-400 shrink-0" />
          <input
            type="date"
            value={filterDate === 'ALL' ? '' : filterDate}
            onChange={(e) => setFilterDate(e.target.value || 'ALL')}
            className="bg-transparent text-[9px] text-slate-200 focus:outline-none w-full font-mono"
          />
        </div>

        <button
          onClick={() => setFilterDate(filterDate === 'ALL' ? new Date().toISOString().split('T')[0] : 'ALL')}
          className={`text-[8.5px] px-2 py-1 rounded-lg border font-semibold transition-colors shrink-0 ${
            filterDate === 'ALL'
              ? 'bg-indigo-600/30 text-indigo-300 border-indigo-500/40'
              : 'bg-slate-900 text-slate-400 border-white/5 hover:text-slate-200'
          }`}
        >
          {filterDate === 'ALL' ? 'Today' : 'All'}
        </button>

        <button
          onClick={handleExportCsv}
          disabled={!sessions || sessions.length === 0}
          title="Export CSV"
          className="p-1 bg-emerald-600/30 hover:bg-emerald-600/40 border border-emerald-500/30 text-emerald-300 disabled:opacity-30 rounded-lg shrink-0"
        >
          <Download size={11} />
        </button>
      </div>

      {/* Session Cards List */}
      <div className="space-y-1">
        {sessions && sessions.length > 0 ? (
          sessions.map((session: DtrSession) => (
            <div
              key={session.id}
              className="bg-slate-900/60 border border-white/5 rounded-xl p-2 flex items-center justify-between hover:border-white/20 hover:bg-slate-800/50 transition-all"
            >
              <div className="truncate pr-1">
                <div className="font-semibold text-[10px] text-slate-200 truncate">
                  {session.taskName}
                </div>
                <div className="text-[7.5px] text-indigo-400 font-mono">
                  {session.durationMinutes} min &bull; {new Date(session.startTime).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
                </div>
              </div>

              <span className="text-[8.5px] font-bold text-amber-400 font-mono shrink-0">
                +{session.coinsEarned}c
              </span>
            </div>
          ))
        ) : (
          <div className="py-6 text-center text-slate-500 text-[9.5px] bg-slate-900/40 rounded-xl border border-white/5 p-3">
            No DTR records found. Complete a focus session to log work hours!
          </div>
        )}
      </div>
    </div>
  );
};
