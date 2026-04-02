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
                <div className="p-8 border-b border-white/5 flex items-center justify-between bg-white/[0.01]">
                    <div className="flex items-center gap-5">
                        <div className="w-12 h-12 rounded-2xl bg-[#4f46e5]/10 flex items-center justify-center border border-[#4f46e5]/20">
                            {type === 'image' ? <ImageIcon className="text-[#4f46e5]" size={24} /> : <Film className="text-[#4f46e5]" size={24} />}
                        </div>
                        <div>
                            <h3 className="text-xl font-black text-white tracking-tight uppercase leading-none">{title}</h3>
                            <div className="flex items-center gap-2 mt-2">
                                <span className="flex h-1.5 w-1.5 rounded-full bg-emerald-500 animate-pulse"></span>
                                <span className="text-[8px] font-black text-white/30 tracking-[0.2em] uppercase">Security Protocol: Authorized Media Retrieval</span>
                            </div>
                        </div>
                    </div>
                    <button onClick={onClose} className="p-3 bg-white/5 hover:bg-white/10 rounded-2xl text-white/20 hover:text-white transition-all border border-white/5 group">
                        <X size={20} className="group-hover:rotate-90 transition-transform duration-300" />
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
                                className="group relative p-3 bg-white/[0.02] border border-white/5 rounded-[1.5rem] cursor-pointer hover:border-[#4f46e5]/40 hover:bg-[#4f46e5]/5 transition-all flex items-center gap-4 active:scale-95"
                            >
                                <div className="w-20 h-14 bg-black/40 rounded-2xl flex items-center justify-center border border-white/[0.03] overflow-hidden group-hover:border-[#4f46e5]/30">
                                    {asset.type === 'image' ? (
                                        <img src={asset.url} className="w-full h-full object-cover group-hover:scale-110 transition-transform duration-500" alt="" />
                                    ) : (
                                        <div className="relative">
                                            {asset.type === 'video' ? <Film size={18} className="text-[#4f46e5]" /> : <Music size={18} className="text-[#4f46e5]" />}
                                            <div className="absolute -inset-2 bg-[#4f46e5]/20 blur-lg opacity-0 group-hover:opacity-100 transition-opacity"></div>
                                        </div>
                                    )}
                                </div>
                                <div className="flex-1 min-w-0">
                                    <h4 className="text-white/80 font-black text-[10px] uppercase truncate tracking-widest leading-none mb-1.5 group-hover:text-white transition-colors">
                                        {asset.name.split('_').pop().replace('.mp4', '').replace('.jpg', '').replace('.png', '')}
                                    </h4>
                                    <div className="flex items-center gap-2">
                                        <span className="px-1.5 py-0.5 rounded bg-white/5 text-[7px] text-white/40 font-black uppercase tracking-widest border border-white/5">
                                            {asset.type}
                                        </span>
                                        <span className="text-[7px] text-white/20 font-black uppercase tracking-widest">• {(asset.fileSize / (1024*1024)).toFixed(1)} MB</span>
                                    </div>
                                </div>
                                <div className="w-8 h-8 rounded-full bg-indigo-500 text-white flex items-center justify-center opacity-0 group-hover:opacity-100 scale-50 group-hover:scale-100 transition-all shadow-lg shadow-indigo-500/30">
                                    <Check size={14} className="stroke-[3]" />
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
