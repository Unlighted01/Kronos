import React, { useState } from "react";
import { useLiveQuery } from "dexie-react-hooks";
import {
    db,
    initPetStats,
    SHOP_ITEMS,
    ShopCatalogItem,
    InventoryItem,
} from "../../db/kronosDb";
import { Award, ShoppingBag, Check, Zap, Heart } from "lucide-react";
import { audioSynth } from "../../utils/audioSynth";

export const PetShop: React.FC = () => {
    const [selectedCategory, setSelectedCategory] = useState<
        "all" | "snack" | "furniture" | "wallpaper"
    >("all");

    const petStats = useLiveQuery(async () => {
        return (await db.petStats.get("primary")) || (await initPetStats());
    });

    const inventory = useLiveQuery(async () => {
        return await db.inventory.toArray();
    });

    const coins = petStats?.coins || 0;
    const energy = petStats?.energy || 80;
    const happiness = petStats?.happiness || 80;

    const filteredItems = SHOP_ITEMS.filter((item) =>
        selectedCategory === "all" ? true : item.category === selectedCategory,
    );

    const ownedItemIds = new Set(inventory?.map((inv) => inv.itemId));

    const handleBuy = async (item: ShopCatalogItem) => {
        if (!petStats || coins < item.price) return;

        audioSynth.playVictory();

        // Deduct coins
        await db.petStats.put({
            ...petStats,
            coins: coins - item.price,
            lastUpdated: new Date().toISOString(),
        });

        // Add to Inventory
        await db.inventory.add({
            itemId: item.id,
            name: item.name,
            category: item.category,
            icon: item.icon,
            statBoost: item.statBoost,
            purchasedAt: new Date().toISOString(),
        });
    };

    const handleUseItem = async (item: InventoryItem) => {
        if (!petStats || !item.statBoost) return;

        audioSynth.playChime();

        const newEnergy = Math.min(100, energy + (item.statBoost.energy || 0));
        const newHappiness = Math.min(
            100,
            happiness + (item.statBoost.happiness || 0),
        );

        await db.petStats.put({
            ...petStats,
            energy: newEnergy,
            happiness: newHappiness,
            lastUpdated: new Date().toISOString(),
        });

        // If snack, consume item
        if (item.category === "snack" && item.id) {
            await db.inventory.delete(item.id);
        }
    };

    return (
        <div className="space-y-6">
            {/* Top Banner & Wallet Status */}
            <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 bg-slate-950/60 border border-slate-800 rounded-2xl p-5">
                <div>
                    <h2 className="text-xl font-bold text-slate-100 flex items-center space-x-2">
                        <ShoppingBag className="text-indigo-400" size={22} />
                        <span>Pet Shop & Theme Unlocks</span>
                    </h2>
                    <p className="text-xs text-slate-400 mt-0.5">
                        Spend Kronos Coins earned from focus sessions to buy
                        snacks & 2D platformer themes!
                    </p>
                </div>

                <div className="flex items-center space-x-4">
                    <div className="bg-amber-500/10 border border-amber-500/20 px-4 py-2 rounded-xl flex items-center space-x-2">
                        <Award className="text-amber-400" size={18} />
                        <div>
                            <span className="text-[10px] text-amber-300 font-pixel block">
                                WALLET
                            </span>
                            <span className="text-lg font-bold text-amber-400">
                                {coins} Coins
                            </span>
                        </div>
                    </div>
                </div>
            </div>

            {/* Category Tabs */}
            <div className="flex items-center space-x-2 border-b border-slate-800 pb-3">
                {(["all", "snack", "furniture", "wallpaper"] as const).map(
                    (cat) => (
                        <button
                            key={cat}
                            onClick={() => {
                                audioSynth.playClick();
                                setSelectedCategory(cat);
                            }}
                            className={`text-xs px-3.5 py-1.5 rounded-xl border font-medium uppercase tracking-wider transition-colors ${
                                selectedCategory === cat
                                    ? "bg-indigo-600/30 text-indigo-300 border-indigo-500/50"
                                    : "bg-slate-950 text-slate-400 border-slate-800 hover:text-slate-200"
                            }`}
                        >
                            {cat === "all"
                                ? "All Items"
                                : cat === "snack"
                                  ? "Snacks & Treats"
                                  : cat === "furniture"
                                    ? "2D Furniture"
                                    : "Wallpapers"}
                        </button>
                    ),
                )}
            </div>

            {/* Catalog Grid */}
            <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
                {filteredItems.map((item) => {
                    const isOwned =
                        ownedItemIds.has(item.id) && item.category !== "snack";
                    const canAfford = coins >= item.price;

                    return (
                        <div
                            key={item.id}
                            className="bg-slate-950/60 border border-slate-800 rounded-2xl p-4 flex flex-col justify-between hover:border-slate-700 transition-all"
                        >
                            <div>
                                <div className="flex items-start justify-between mb-3">
                                    <span className="text-4xl p-2 bg-slate-900 rounded-2xl border border-slate-800">
                                        {item.icon}
                                    </span>
                                    <span className="bg-amber-500/10 text-amber-400 border border-amber-500/20 font-bold text-xs px-2.5 py-1 rounded-lg">
                                        {item.price} Coins
                                    </span>
                                </div>

                                <h3 className="font-bold text-sm text-slate-100 mb-1">
                                    {item.name}
                                </h3>
                                <p className="text-xs text-slate-400 mb-3">
                                    {item.description}
                                </p>

                                {item.statBoost && (
                                    <div className="flex items-center space-x-2 mb-3">
                                        {item.statBoost.energy && (
                                            <span className="flex items-center space-x-1 text-[10px] text-amber-400 bg-amber-500/10 px-2 py-0.5 rounded border border-amber-500/20">
                                                <Zap size={10} />
                                                <span>
                                                    +{item.statBoost.energy}{" "}
                                                    Energy
                                                </span>
                                            </span>
                                        )}
                                        {item.statBoost.happiness && (
                                            <span className="flex items-center space-x-1 text-[10px] text-pink-400 bg-pink-500/10 px-2 py-0.5 rounded border border-pink-500/20">
                                                <Heart size={10} />
                                                <span>
                                                    +{item.statBoost.happiness}{" "}
                                                    Joy
                                                </span>
                                            </span>
                                        )}
                                    </div>
                                )}
                            </div>

                            <button
                                onClick={() => handleBuy(item)}
                                disabled={isOwned || !canAfford}
                                className={`w-full flex items-center justify-center space-x-1.5 py-2 rounded-xl text-xs font-semibold transition-all ${
                                    isOwned
                                        ? "bg-slate-800 text-slate-500 cursor-not-allowed"
                                        : canAfford
                                          ? "bg-indigo-600 hover:bg-indigo-500 text-white shadow-lg shadow-indigo-600/20"
                                          : "bg-slate-900 text-slate-500 border border-slate-800 cursor-not-allowed"
                                }`}
                            >
                                {isOwned ? (
                                    <>
                                        <Check size={14} />
                                        <span>Owned</span>
                                    </>
                                ) : (
                                    <span>
                                        {canAfford
                                            ? "Purchase"
                                            : "Not Enough Coins"}
                                    </span>
                                )}
                            </button>
                        </div>
                    );
                })}
            </div>

            {/* User Inventory Section */}
            {inventory && inventory.length > 0 && (
                <div className="pt-4">
                    <h3 className="text-sm font-bold text-slate-200 mb-3">
                        Your Inventory & Treats
                    </h3>
                    <div className="grid grid-cols-1 sm:grid-cols-4 gap-3">
                        {inventory.map((invItem) => (
                            <div
                                key={invItem.id}
                                className="bg-slate-950 border border-slate-800 rounded-xl p-3 flex items-center justify-between"
                            >
                                <div className="flex items-center space-x-2">
                                    <span className="text-2xl">
                                        {invItem.icon}
                                    </span>
                                    <div>
                                        <h4 className="text-xs font-bold text-slate-200">
                                            {invItem.name}
                                        </h4>
                                        <span className="text-[9px] text-slate-500 uppercase">
                                            {invItem.category}
                                        </span>
                                    </div>
                                </div>

                                {invItem.statBoost && (
                                    <button
                                        onClick={() => handleUseItem(invItem)}
                                        className="px-2.5 py-1 bg-indigo-600 hover:bg-indigo-500 text-white text-[10px] font-semibold rounded-lg shadow"
                                    >
                                        Feed
                                    </button>
                                )}
                            </div>
                        ))}
                    </div>
                </div>
            )}
        </div>
    );
};
