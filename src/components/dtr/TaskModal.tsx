import React, { useState } from 'react';
import { Tag, Check, X } from 'lucide-react';
import { useTimerStore } from '../../stores/useTimerStore';

interface TaskModalProps {
  isOpen: boolean;
  onClose: () => void;
  onConfirm: () => void;
}

const CATEGORY_PRESETS = [
  'Development',
  'Design',
  'Writing',
  'Research',
  'Meeting',
  'Study',
];

export const TaskModal: React.FC<TaskModalProps> = ({
  isOpen,
  onClose,
  onConfirm,
}) => {
  const { activeTaskName, activeCategory, setTaskInfo } = useTimerStore();
  const [taskName, setTaskName] = useState<string>(activeTaskName);
  const [category, setCategory] = useState<string>(activeCategory);

  if (!isOpen) return null;

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    setTaskInfo(taskName.trim() || 'General Work', category);
    onConfirm();
  };

  return (
    <div className="fixed inset-0 z-50 bg-slate-950/80 backdrop-blur-sm flex items-center justify-center p-4">
      <div className="bg-slate-900 border border-slate-800 rounded-2xl p-5 w-full max-w-sm shadow-2xl relative">
        <button
          onClick={onClose}
          className="absolute top-3 right-3 text-slate-400 hover:text-white p-1 rounded-lg"
        >
          <X size={16} />
        </button>

        <div className="flex items-center space-x-2 mb-4">
          <Tag className="text-indigo-400" size={18} />
          <h3 className="font-bold text-sm text-slate-100">Task & DTR Input</h3>
        </div>

        <form onSubmit={handleSubmit} className="space-y-4">
          <div>
            <label className="block text-[11px] font-medium text-slate-400 mb-1">
              Task / Project Name
            </label>
            <input
              type="text"
              value={taskName}
              onChange={(e) => setTaskName(e.target.value)}
              placeholder="e.g. Building API Endpoint"
              className="w-full bg-slate-950 border border-slate-800 rounded-xl px-3 py-2 text-xs text-white placeholder-slate-500 focus:outline-none focus:border-indigo-500"
              autoFocus
            />
          </div>

          <div>
            <label className="block text-[11px] font-medium text-slate-400 mb-1">
              Category Tag
            </label>
            <div className="flex flex-wrap gap-1.5 mb-2">
              {CATEGORY_PRESETS.map((preset) => (
                <button
                  type="button"
                  key={preset}
                  onClick={() => setCategory(preset)}
                  className={`text-[10px] px-2.5 py-1 rounded-lg border font-medium transition-colors ${
                    category === preset
                      ? 'bg-indigo-600/30 text-indigo-300 border-indigo-500/50'
                      : 'bg-slate-950 text-slate-400 border-slate-800 hover:text-slate-200'
                  }`}
                >
                  {preset}
                </button>
              ))}
            </div>
          </div>

          <div className="flex items-center justify-end space-x-2 pt-2">
            <button
              type="button"
              onClick={onClose}
              className="px-3 py-1.5 rounded-xl text-xs text-slate-400 hover:bg-slate-800"
            >
              Cancel
            </button>
            <button
              type="submit"
              className="flex items-center space-x-1.5 px-4 py-1.5 bg-indigo-600 hover:bg-indigo-500 text-white rounded-xl text-xs font-semibold shadow-lg shadow-indigo-600/20"
            >
              <Check size={14} />
              <span>Start Focus</span>
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};
