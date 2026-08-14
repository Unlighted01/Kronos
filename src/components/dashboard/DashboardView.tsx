import React from 'react';
import { Home, Calendar, ShoppingBag, Settings, Award, Zap, Heart } from 'lucide-react';
import { DtrLogSheet } from '../dtr/DtrLogSheet';
import { PetShop } from '../shop/PetShop';
import { useLiveQuery } from 'dexie-react-hooks';
import { db, initPetStats } from '../../db/kronosDb';

export const DashboardView: React.FC = () => {
  const [activeTab, setActiveTab] = React.useState<'home' | 'dtr' | 'shop' | 'settings'>('home');

  const petStats = useLiveQuery(async () => {
    return (await db.petStats.get('primary')) || (await initPetStats());
  });

  const level = petStats?.level || 1;
  const coins = petStats?.coins || 150;
  const exp = petStats?.exp || 0;
  const energy = petStats?.energy || 80;
  const happiness = petStats?.happiness || 80;
  const maxExp = level * 100;
  const expPercent = Math.min(100, Math.round((exp / maxExp) * 100));

  return (
    <div className="w-screen h-screen bg-slate-900 text-slate-100 flex overflow-hidden">
      {/* Sidebar Navigation */}
      <aside className="w-60 bg-slate-950 border-r border-slate-800 p-4 flex flex-col justify-between">
        <div>
          <div className="flex items-center space-x-3 px-2 py-3 mb-6">
            <span className="text-2xl">⏳</span>
            <div>
              <h1 className="font-pixel text-xs text-indigo-400">KRONOS</h1>
              <p className="text-[10px] text-slate-400">2D Platformer DTR</p>
            </div>
          </div>

          <nav className="space-y-1">
            <button
              onClick={() => setActiveTab('home')}
              className={`w-full flex items-center space-x-3 px-3 py-2.5 rounded-xl font-medium text-xs transition-colors ${
                activeTab === 'home'
                  ? 'bg-indigo-600/20 text-indigo-400 border border-indigo-500/30'
                  : 'text-slate-400 hover:text-slate-200 hover:bg-slate-900'
              }`}
            >
              <Home size={16} />
              <span>Pet Room</span>
            </button>

            <button
              onClick={() => setActiveTab('dtr')}
              className={`w-full flex items-center space-x-3 px-3 py-2.5 rounded-xl font-medium text-xs transition-colors ${
                activeTab === 'dtr'
                  ? 'bg-indigo-600/20 text-indigo-400 border border-indigo-500/30'
                  : 'text-slate-400 hover:text-slate-200 hover:bg-slate-900'
              }`}
            >
              <Calendar size={16} />
              <span>Daily Time Record</span>
            </button>

            <button
              onClick={() => setActiveTab('shop')}
              className={`w-full flex items-center space-x-3 px-3 py-2.5 rounded-xl font-medium text-xs transition-colors ${
                activeTab === 'shop'
                  ? 'bg-indigo-600/20 text-indigo-400 border border-indigo-500/30'
                  : 'text-slate-400 hover:text-slate-200 hover:bg-slate-900'
              }`}
            >
              <ShoppingBag size={16} />
              <span>Pet Shop</span>
            </button>

            <button
              onClick={() => setActiveTab('settings')}
              className={`w-full flex items-center space-x-3 px-3 py-2.5 rounded-xl font-medium text-xs transition-colors ${
                activeTab === 'settings'
                  ? 'bg-indigo-600/20 text-indigo-400 border border-indigo-500/30'
                  : 'text-slate-400 hover:text-slate-200 hover:bg-slate-900'
              }`}
            >
              <Settings size={16} />
              <span>Settings</span>
            </button>
          </nav>
        </div>

        {/* Live Coins / EXP & Pet Care Widget */}
        <div className="bg-slate-900/60 border border-slate-800 rounded-xl p-3 space-y-2">
          <div className="flex items-center justify-between">
            <span className="text-[10px] text-slate-400 font-pixel">COINS</span>
            <div className="flex items-center space-x-1 text-amber-400 font-bold text-xs">
              <Award size={14} />
              <span>{coins}</span>
            </div>
          </div>

          <div>
            <div className="flex items-center justify-between text-[9px] text-slate-400 mb-1">
              <span>EXP (Lv.{level})</span>
              <span>{exp} / {maxExp}</span>
            </div>
            <div className="w-full bg-slate-800 h-1.5 rounded-full overflow-hidden">
              <div
                className="bg-indigo-500 h-full transition-all duration-500"
                style={{ width: `${expPercent}%` }}
              />
            </div>
          </div>

          <div className="grid grid-cols-2 gap-2 pt-1">
            <div className="bg-slate-950 px-2 py-1 rounded-lg border border-slate-800">
              <div className="flex items-center justify-between text-[9px] text-amber-300">
                <span className="flex items-center space-x-0.5">
                  <Zap size={10} />
                  <span>ENERGY</span>
                </span>
                <span>{energy}%</span>
              </div>
            </div>
            <div className="bg-slate-950 px-2 py-1 rounded-lg border border-slate-800">
              <div className="flex items-center justify-between text-[9px] text-pink-300">
                <span className="flex items-center space-x-0.5">
                  <Heart size={10} />
                  <span>JOY</span>
                </span>
                <span>{happiness}%</span>
              </div>
            </div>
          </div>
        </div>
      </aside>

      {/* Main Content Area */}
      <main className="flex-1 bg-slate-900 p-6 overflow-y-auto">
        {activeTab === 'home' && (
          <div>
            <h2 className="text-xl font-bold mb-4">2D Pixel Platformer Pet Room</h2>
            <div className="bg-slate-950/50 border border-slate-800 rounded-2xl p-8 text-center flex flex-col items-center justify-center min-h-[360px]">
              <span className="text-6xl mb-4 animate-bounce">👾</span>
              <h3 className="font-pixel text-sm text-indigo-400 mb-2">Level {level} Kronos Pet</h3>
              <p className="text-xs text-slate-400 max-w-sm mb-4">
                Your virtual pet lives in your 2D platformer widget workspace! Complete focus timers to earn coins, unlock pet skins, and feed your pet snacks.
              </p>
            </div>
          </div>
        )}

        {activeTab === 'dtr' && <DtrLogSheet />}

        {activeTab === 'shop' && <PetShop />}

        {activeTab === 'settings' && (
          <div>
            <h2 className="text-xl font-bold mb-4">Settings & Timer Preferences</h2>
            <div className="bg-slate-950/50 border border-slate-800 rounded-2xl p-6 space-y-4 max-w-lg">
              <div>
                <label className="block text-xs font-semibold text-slate-300 mb-1">
                  Default Work Duration (Minutes)
                </label>
                <input
                  type="number"
                  defaultValue={25}
                  className="w-full bg-slate-950 border border-slate-800 rounded-xl px-3 py-2 text-xs text-slate-100"
                />
              </div>

              <div>
                <label className="block text-xs font-semibold text-slate-300 mb-1">
                  Short Break Duration (Minutes)
                </label>
                <input
                  type="number"
                  defaultValue={5}
                  className="w-full bg-slate-950 border border-slate-800 rounded-xl px-3 py-2 text-xs text-slate-100"
                />
              </div>
            </div>
          </div>
        )}
      </main>
    </div>
  );
};
