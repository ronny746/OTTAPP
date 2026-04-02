import { useState, useEffect } from 'react';
import api from '../utils/api';
import { Search, X, Film, Image as ImageIcon, Music, Check } from 'lucide-react';

const MediaPicker = ({ isOpen, onClose, onSelect, type = 'all', title = 'Select Asset' }) => {
    const [assets, setAssets] = useState([]);
    const [searchTerm, setSearchTerm] = useState('');

    useEffect(() => {
        if (isOpen) {
            api.get(`/admin/assets?type=${type === 'all' ? '' : type}`).then(res => setAssets(res.data));
        }
    }, [isOpen, type]);

    if (!isOpen) return null;

    const filtered = assets.filter(a => a.name.toLowerCase().includes(searchTerm.toLowerCase()));

    return (
        <div className="fixed inset-0 z-[100] flex items-center justify-center p-4 md:p-10">
            <div className="absolute inset-0 bg-[#0f0e17]/95 backdrop-blur-xl" onClick={onClose}></div>
            
            <div className="relative w-full max-w-5xl h-[80vh] bg-[#1a1926] border border-white/10 rounded-[2.5rem] shadow-[0_0_50px_rgba(0,0,0,0.5)] flex flex-col overflow-hidden">
                <div className="p-8 border-b border-white/5 flex items-center justify-between">
                    <div>
                        <h3 className="text-2xl font-black text-white tracking-tight uppercase">{title}</h3>
                        <p className="text-[10px] font-bold text-[#4f46e5] tracking-[0.3em] uppercase mt-1">Authorized Data Selection</p>
                    </div>
                    <button onClick={onClose} className="p-3 hover:bg-white/5 rounded-2xl text-white/40 hover:text-white transition-all">
                        <X size={24} />
                    </button>
                </div>

                <div className="p-8 flex-1 overflow-hidden flex flex-col gap-6">
                    <div className="flex bg-white/5 p-4 rounded-2xl border border-white/5 items-center gap-4">
                        <Search className="text-white/20" />
                        <input 
                            type="text" 
                            placeholder="Filter by hash or name..."
                            className="bg-transparent border-none text-white font-bold w-full focus:ring-0"
                            value={searchTerm}
                            onChange={(e) => setSearchTerm(e.target.value)}
                        />
                    </div>

                    <div className="flex-1 overflow-y-auto grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-4 pr-2 custom-scrollbar">
                        {filtered.map(asset => (
                            <div 
                                key={asset._id}
                                onClick={() => {
                                    onSelect(asset);
                                    onClose();
                                }}
                                className="group p-4 bg-white/[0.02] border border-white/5 rounded-2xl cursor-pointer hover:border-[#4f46e5]/50 hover:bg-[#4f46e5]/5 transition-all flex items-center gap-4"
                            >
                                <div className="w-16 h-12 bg-white/5 rounded-xl flex items-center justify-center overflow-hidden">
                                    {asset.type === 'image' ? (
                                        <img src={asset.url} className="w-full h-full object-cover" alt="" />
                                    ) : (
                                        asset.type === 'video' ? <Film size={20} className="text-white/20" /> : <Music size={20} className="text-white/20" />
                                    )}
                                </div>
                                <div className="flex-1 min-w-0">
                                    <h4 className="text-white font-bold text-xs truncate uppercase tracking-wider">{asset.name.split('_').pop()}</h4>
                                    <span className="text-[9px] text-white/20 font-black uppercase tracking-widest">{asset.type} • {(asset.fileSize / (1024*1024)).toFixed(1)}MB</span>
                                </div>
                                <div className="w-8 h-8 rounded-lg bg-white/5 flex items-center justify-center opacity-0 group-hover:opacity-100 transition-all">
                                    <Check size={16} className="text-[#4f46e5]" />
                                </div>
                            </div>
                        ))}
                    </div>
                </div>
            </div>
        </div>
    );
};

export default MediaPicker;
