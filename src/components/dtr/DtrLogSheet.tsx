import React, { useState } from 'react';
import { useLiveQuery } from 'dexie-react-hooks';
import { db, DtrSession } from '../../db/kronosDb';
import { Calendar, Download, Clock, Award, Tag } from 'lucide-react';

export const DtrLogSheet: React.FC = () => {
  const [filterDate, setFilterDate] = useState<string>(
    new Date().toISOString().split('T')[0]
  );

  // Live Query from Dexie IndexedDB
  const sessions = useLiveQuery(
    async () => {
      if (filterDate === 'ALL') {
        return await db.dtrSessions.orderBy('id').reverse().toArray();
      }
      return await db.dtrSessions
        .where('dateKey')
        .equals(filterDate)
        .reverse()
        .toArray();
    },
    [filterDate]
  );

  const totalMinutes = sessions
    ? sessions.reduce((acc, s) => acc + s.durationMinutes, 0)
    : 0;
  const totalCoins = sessions
    ? sessions.reduce((acc, s) => acc + s.coinsEarned, 0)
    : 0;
  const totalHours = (totalMinutes / 60).toFixed(1);

  const handleExportCsv = () => {
    if (!sessions || sessions.length === 0) return;

    const headers = ['ID', 'Date', 'Task Name', 'Category', 'Start Time', 'End Time', 'Duration (Min)', 'Coins Earned'];
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

    const csvContent = [headers.join(','), ...rows.map((r) => r.join(','))].join('\n');
    const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
    const url = URL.createObjectURL(blob);
    const link = document.createElement('a');
    link.href = url;
    link.setAttribute('download', `kronos_dtr_log_${filterDate}.csv`);
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  };

  return (
    <div className="space-y-6">
      {/* Top Header & Filter Controls */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h2 className="text-xl font-bold text-slate-100">Daily Time Record (DTR)</h2>
          <p className="text-xs text-slate-400">Track and export your daily focused work records</p>
        </div>

        <div className="flex items-center space-x-3">
          <div className="flex items-center space-x-2 bg-slate-950 border border-slate-800 rounded-xl px-3 py-1.5">
            <Calendar size={14} className="text-slate-400" />
            <input
              type="date"
              value={filterDate === 'ALL' ? '' : filterDate}
              onChange={(e) => setFilterDate(e.target.value || 'ALL')}
              className="bg-transparent text-xs text-slate-200 focus:outline-none"
            />
          </div>

          <button
            onClick={() => setFilterDate('ALL')}
            className={`text-xs px-3 py-1.5 rounded-xl border font-medium transition-colors ${
              filterDate === 'ALL'
                ? 'bg-indigo-600/30 text-indigo-300 border-indigo-500/40'
                : 'bg-slate-950 text-slate-400 border-slate-800 hover:text-slate-200'
            }`}
          >
            All Logs
          </button>

          <button
            onClick={handleExportCsv}
            disabled={!sessions || sessions.length === 0}
            className="flex items-center space-x-1.5 px-3 py-1.5 bg-emerald-600 hover:bg-emerald-500 disabled:opacity-50 text-white rounded-xl text-xs font-semibold shadow-lg shadow-emerald-600/20 transition-all"
          >
            <Download size={14} />
            <span>Export CSV</span>
          </button>
        </div>
      </div>

      {/* Summary Metric Cards */}
      <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
        <div className="bg-slate-950/60 border border-slate-800 rounded-2xl p-4 flex items-center space-x-4">
          <div className="p-3 bg-indigo-500/20 text-indigo-400 rounded-xl">
            <Clock size={20} />
          </div>
          <div>
            <span className="text-[10px] text-slate-400 uppercase tracking-wider font-semibold">Total Hours Worked</span>
            <div className="text-xl font-bold text-slate-100">{totalHours} hrs</div>
          </div>
        </div>

        <div className="bg-slate-950/60 border border-slate-800 rounded-2xl p-4 flex items-center space-x-4">
          <div className="p-3 bg-emerald-500/20 text-emerald-400 rounded-xl">
            <Tag size={20} />
          </div>
          <div>
            <span className="text-[10px] text-slate-400 uppercase tracking-wider font-semibold">Sessions Completed</span>
            <div className="text-xl font-bold text-slate-100">{sessions ? sessions.length : 0}</div>
          </div>
        </div>

        <div className="bg-slate-950/60 border border-slate-800 rounded-2xl p-4 flex items-center space-x-4">
          <div className="p-3 bg-amber-500/20 text-amber-400 rounded-xl">
            <Award size={20} />
          </div>
          <div>
            <span className="text-[10px] text-slate-400 uppercase tracking-wider font-semibold">Coins Earned</span>
            <div className="text-xl font-bold text-slate-100">{totalCoins}</div>
          </div>
        </div>
      </div>

      {/* DTR Log Sheet Table */}
      <div className="bg-slate-950/50 border border-slate-800 rounded-2xl overflow-hidden shadow-xl">
        <div className="overflow-x-auto">
          <table className="w-full text-left text-xs text-slate-300">
            <thead className="bg-slate-950 border-b border-slate-800 text-[10px] uppercase tracking-wider text-slate-400 font-pixel">
              <tr>
                <th className="py-3.5 px-4">Date</th>
                <th className="py-3.5 px-4">Task Name</th>
                <th className="py-3.5 px-4">Category</th>
                <th className="py-3.5 px-4">Time Range</th>
                <th className="py-3.5 px-4">Duration</th>
                <th className="py-3.5 px-4">Coins</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-800/60">
              {sessions && sessions.length > 0 ? (
                sessions.map((session: DtrSession) => (
                  <tr key={session.id} className="hover:bg-slate-900/50 transition-colors">
                    <td className="py-3 px-4 font-mono text-slate-400">{session.dateKey}</td>
                    <td className="py-3 px-4 font-semibold text-slate-100">{session.taskName}</td>
                    <td className="py-3 px-4">
                      <span className="bg-indigo-500/10 text-indigo-400 border border-indigo-500/20 px-2 py-0.5 rounded text-[10px] font-medium">
                        {session.category}
                      </span>
                    </td>
                    <td className="py-3 px-4 font-mono text-slate-400">
                      {new Date(session.startTime).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })} - {' '}
                      {new Date(session.endTime).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
                    </td>
                    <td className="py-3 px-4 font-mono text-indigo-300 font-semibold">{session.durationMinutes} min</td>
                    <td className="py-3 px-4 font-mono text-amber-400 font-semibold">+{session.coinsEarned}</td>
                  </tr>
                ))
              ) : (
                <tr>
                  <td colSpan={6} className="py-8 text-center text-slate-500 text-xs">
                    No Daily Time Records logged for this date. Start a focus session to record DTR logs!
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
};
