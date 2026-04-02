import { useState, useEffect } from 'react';
import api from '../utils/api';
import ConfirmDialog from '../components/ConfirmDialog';
import { 
    Trash2, Play, Disc, Search, X, Eye, 
    Film, Layers, Music, Zap, ChevronLeft, ChevronRight,
    Calendar, Star, Clock, ExternalLink
} from 'lucide-react';

const MediaList = () => {
    const [media, setMedia] = useState([]);
    const [filteredMedia, setFilteredMedia] = useState([]);
    const [search, setSearch] = useState('');
    const [activeTab, setActiveTab] = useState('all');
    const [previewItem, setPreviewItem] = useState(null);
    
    // Pagination State
    const [currentPage, setCurrentPage] = useState(1);
    const itemsPerPage = 8;
    
    const [confirmState, setConfirmState] = useState({ isOpen: false, title: '', message: '', type: 'danger', onConfirm: () => {} });

    const tabs = [
        { id: 'all', name: 'All Media', icon: Disc, color: 'text-indigo-400' },
        { id: 'movie', name: 'Movies', icon: Film, color: 'text-blue-400' },
        { id: 'show', name: 'Shows', icon: Layers, color: 'text-purple-400' },
        { id: 'short', name: 'Shorts', icon: Zap, color: 'text-rose-400' },
        { id: 'audio', name: 'Audio', icon: Music, color: 'text-amber-400' },
    ];

    const fetchMedia = async () => {
        try {
            const { data } = await api.get('/admin/media');
            setMedia(data);
            setFilteredMedia(data);
        } catch (err) {
            console.error('Failed to fetch media');
        }
    };

    useEffect(() => {
        fetchMedia();
    }, []);

    useEffect(() => {
        let result = media;
        if (activeTab !== 'all') {
            result = result.filter(m => {
                if (activeTab === 'movie') return m.type === 'movie' || m.type === 'video';
                if (activeTab === 'short') return m.type === 'short' || m.type === 'shorts';
                return m.type === activeTab;
            });
        }
        if (search) {
            result = result.filter(m => m.title.toLowerCase().includes(search.toLowerCase()));
        }
        setFilteredMedia(result);
        setCurrentPage(1); // Reset to page 1 on filter
    }, [search, media, activeTab]);

    const handleDelete = (id) => {
        setConfirmState({
            isOpen: true,
            title: 'Delete Asset',
            message: 'Are you sure you want to permanently delete this media asset? This action is irreversible and will break existing links.',
            type: 'danger',
            confirmText: 'Delete Permanently',
            onConfirm: async () => {
                try {
                    await api.delete(`/admin/media/${id}`);
                    fetchMedia();
                    setConfirmState(p => ({ ...p, isOpen: false }));
                } catch (err) {
                    alert('Deletion failed');
                    setConfirmState(p => ({ ...p, isOpen: false }));
                }
            }
        });
    };

    // Pagination Logic
    const lastIndex = currentPage * itemsPerPage;
    const firstIndex = lastIndex - itemsPerPage;
    const currentMedia = filteredMedia.slice(firstIndex, lastIndex);
    const totalPages = Math.ceil(filteredMedia.length / itemsPerPage);

    return (
        <div className="space-y-8 pb-24">
            {/* SEARCH & FILTERS */}
            <div className="flex flex-col md:flex-row justify-between items-center gap-6">
                <div className="relative w-full max-w-xl group">
                    <Search className="absolute left-5 top-1/2 -translate-y-1/2 text-white/20 group-focus-within:text-[#4f46e5] transition-all" size={18} />
                    <input 
                        type="text" 
                        placeholder="Scan media library database..." 
                        value={search}
                        onChange={(e) => setSearch(e.target.value)}
                        className="w-full bg-white/[0.03] border border-white/5 rounded-2xl pl-14 pr-6 py-4 focus:outline-none focus:ring-4 focus:ring-[#4f46e5]/10 focus:border-[#4f46e5]/50 text-sm font-bold text-white transition-all placeholder:text-white/10"
                    />
                </div>
                
                <div className="flex bg-white/[0.03] border border-white/5 p-1.5 rounded-2xl">
                    {tabs.map(tab => (
                        <button
                            key={tab.id}
                            onClick={() => setActiveTab(tab.id)}
                            className={`flex items-center gap-2 px-4 py-2.5 rounded-xl font-black text-[9px] uppercase tracking-widest transition-all ${
                                activeTab === tab.id 
                                ? 'bg-[#4f46e5] text-white shadow-lg' 
                                : 'text-white/30 hover:text-white'
                            }`}
                        >
                            <tab.icon size={14} className={activeTab === tab.id ? 'text-white' : tab.color} />
                            {tab.name}
                        </button>
                    ))}
                </div>
            </div>

            {/* VERTICAL LIST VIEW */}
            <div className="frosted-card overflow-hidden border border-white/5 p-0">
                <div className="overflow-x-auto">
                    <table className="w-full text-left">
                        <thead>
                            <tr className="bg-white/[0.02] border-b border-white/5">
                                <th className="px-8 py-5 text-[10px] font-black text-white/30 uppercase tracking-[0.2em]">Asset Identity</th>
                                <th className="px-6 py-5 text-[10px] font-black text-white/30 uppercase tracking-[0.2em]">Deployment</th>
                                <th className="px-6 py-5 text-[10px] font-black text-white/30 uppercase tracking-[0.2em]">Metadata</th>
                                <th className="px-6 py-5 text-[10px] font-black text-white/30 uppercase tracking-[0.2em]">Status</th>
                                <th className="px-8 py-5 text-[10px] font-black text-white/30 uppercase tracking-[0.2em] text-right">Operations</th>
                            </tr>
                        </thead>
                        <tbody className="divide-y divide-white/5">
                            {currentMedia.map((item) => (
                                <tr key={item._id} className="hover:bg-white/[0.02] group transition-all">
                                    <td className="px-8 py-6">
                                        <div className="flex items-center gap-5">
                                            <div className="w-16 h-20 rounded-xl overflow-hidden border border-white/10 flex-shrink-0 relative">
                                                <img src={item.imageUrl} className="w-full h-full object-cover grayscale-[0.3] group-hover:grayscale-0 transition-all duration-700" alt="" />
                                                <div className="absolute inset-0 bg-black/40 opacity-0 group-hover:opacity-100 flex items-center justify-center transition-all">
                                                     <Play size={16} className="text-white" />
                                                </div>
                                            </div>
                                            <div className="min-w-0">
                                                <h4 className="text-sm font-black text-white uppercase truncate group-hover:text-[#4f46e5] transition-colors">{item.title}</h4>
                                                <div className="flex items-center gap-3 mt-1.5 grayscale opacity-50 group-hover:grayscale-0 group-hover:opacity-100 transition-all">
                                                    <span className="text-[8px] font-black text-white/40 uppercase tracking-widest bg-white/5 px-1.5 py-0.5 rounded shadow-sm">{item.type}</span>
                                                    <span className="text-[10px] font-black text-white/30 flex items-center gap-1"><Calendar size={10} /> {item.year}</span>
                                                </div>
                                            </div>
                                        </div>
                                    </td>
                                    <td className="px-6 py-6">
                                        <div className="flex flex-col gap-1.5">
                                            <div className="flex items-center gap-2">
                                                <Star size={12} className="text-amber-500" />
                                                <span className="text-[10px] font-black text-white/60">{item.rating} RATING</span>
                                            </div>
                                            <div className="flex items-center gap-2">
                                                <Clock size={12} className="text-[#4f46e5]" />
                                                <span className="text-[10px] font-black text-white/40 uppercase tracking-tighter">{item.duration}</span>
                                            </div>
                                        </div>
                                    </td>
                                    <td className="px-6 py-6">
                                        {item.type === 'show' ? (
                                            <div className="bg-[#4f46e5]/10 px-3 py-1.5 rounded-lg border border-[#4f46e5]/20 inline-block">
                                                <span className="text-[8px] font-black text-[#4f46e5] uppercase tracking-widest">{item.episodes?.length || 0} SEASONS/EPISODES</span>
                                            </div>
                                        ) : (
                                            <div className="bg-emerald-500/10 px-3 py-1.5 rounded-lg border border-emerald-500/20 inline-block">
                                                <span className="text-[8px] font-black text-emerald-500 uppercase tracking-widest">SINGLE DEPLOYMENT</span>
                                            </div>
                                        )}
                                    </td>
                                    <td className="px-6 py-6">
                                        <div className="flex items-center gap-2">
                                            <span className="w-1.5 h-1.5 rounded-full bg-emerald-500 shadow-[0_0_8px_#10b981]"></span>
                                            <span className="text-[10px] font-black text-white/30 tracking-widest uppercase">PRODUCTION</span>
                                        </div>
                                    </td>
                                    <td className="px-8 py-6">
                                        <div className="flex items-center justify-end gap-3 opacity-0 group-hover:opacity-100 transition-all transform translate-x-2 group-hover:translate-x-0">
                                            <button 
                                                onClick={() => setPreviewItem(item)}
                                                className="w-9 h-9 bg-white/5 border border-white/10 text-white/40 hover:bg-[#4f46e5] hover:text-white rounded-xl flex items-center justify-center transition-all"
                                                title="Preview Content"
                                            >
                                                <Eye size={16} />
                                            </button>
                                            <button 
                                                onClick={() => handleDelete(item._id)}
                                                className="w-9 h-9 bg-rose-500/10 border border-rose-500/20 text-rose-500 hover:bg-rose-500 hover:text-white rounded-xl flex items-center justify-center transition-all"
                                                title="Eliminate Asset"
                                            >
                                                <Trash2 size={16} />
                                            </button>
                                        </div>
                                    </td>
                                </tr>
                            ))}
                        </tbody>
                    </table>
                </div>

                {/* PAGINATION PANEL */}
                {totalPages > 1 && (
                    <div className="px-8 py-6 border-t border-white/5 flex items-center justify-between bg-white/[0.01]">
                        <div className="text-[10px] font-black text-white/20 uppercase tracking-[0.2em]">
                            Displaying {firstIndex + 1}-{Math.min(lastIndex, filteredMedia.length)} of {filteredMedia.length} assets
                        </div>
                        <div className="flex items-center gap-1">
                            <button 
                                onClick={() => setCurrentPage(p => Math.max(1, p - 1))}
                                disabled={currentPage === 1}
                                className="w-10 h-10 flex items-center justify-center rounded-xl bg-white/5 border border-white/10 text-white disabled:opacity-20 hover:bg-white/10 transition-all font-black"
                            >
                                <ChevronLeft size={18} />
                            </button>
                            
                            {[...Array(totalPages)].map((_, i) => (
                                <button 
                                    key={i}
                                    onClick={() => setCurrentPage(i + 1)}
                                    className={`w-10 h-10 rounded-xl text-[10px] font-black uppercase transition-all ${
                                        currentPage === i + 1 
                                        ? 'bg-[#4f46e5] text-white shadow-xl shadow-[#4f46e5]/30' 
                                        : 'text-white/30 hover:bg-white/10 hover:text-white'
                                    }`}
                                >
                                    {i + 1}
                                </button>
                            ))}
                            
                            <button 
                                onClick={() => setCurrentPage(p => Math.min(totalPages, p + 1))}
                                disabled={currentPage === totalPages}
                                className="w-10 h-10 flex items-center justify-center rounded-xl bg-white/5 border border-white/10 text-white disabled:opacity-20 hover:bg-white/10 transition-all font-black"
                            >
                                <ChevronRight size={18} />
                            </button>
                        </div>
                    </div>
                )}
            </div>

            {filteredMedia.length === 0 && (
                <div className="py-32 flex flex-col items-center justify-center text-center frosted-card">
                    <Search size={48} className="text-white/10 mb-6" />
                    <h4 className="text-lg font-black text-white uppercase tracking-widest">No Results in Central Database</h4>
                    <p className="text-white/20 text-[10px] mt-2 font-black uppercase tracking-[0.2em]">Modify your scan parameters and try again</p>
                </div>
            )}

            {/* PREVIEW MODAL */}
            {previewItem && (
                <div className="fixed inset-0 z-[200] flex items-center justify-center p-6 sm:p-12">
                    <div className="absolute inset-0 bg-[#0f0e17]/95 backdrop-blur-3xl" onClick={() => setPreviewItem(null)}></div>
                    <div className="relative w-full max-w-6xl aspect-video bg-black rounded-[3rem] border border-white/10 overflow-hidden shadow-[0_0_100px_rgba(0,0,0,0.5)] animate-in zoom-in duration-500">
                        <button onClick={() => setPreviewItem(null)} className="absolute top-8 right-8 z-[210] w-12 h-12 bg-black/60 hover:bg-[#4f46e5] rounded-2xl flex items-center justify-center text-white transition-all shadow-xl backdrop-blur-md">
                            <X size={24} />
                        </button>
                        
                        {previewItem.type === 'audio' ? (
                            <div className="w-full h-full flex flex-col items-center justify-center p-20 text-center bg-gradient-to-t from-[#4f46e5]/10 to-transparent">
                                <div className="w-64 h-64 rounded-3xl overflow-hidden shadow-[0_30px_60px_rgba(0,0,0,0.5)] mb-12 border border-white/10 ring-8 ring-white/5">
                                    <img src={previewItem.imageUrl} className="w-full h-full object-cover" alt="" />
                                </div>
                                <h2 className="text-4xl font-black text-white mb-4 tracking-tight uppercase">{previewItem.title}</h2>
                                <p className="text-[#4f46e5] font-black text-[10px] uppercase tracking-[0.5em] mb-8">Sonic Transmission Active</p>
                                <audio controls className="w-full max-w-2xl h-14 rounded-full"><source src={previewItem.videoUrl} /></audio>
                            </div>
                        ) : (
                            <div className="w-full h-full group">
                                <video className="w-full h-full shadow-2xl" controls autoPlay poster={previewItem.imageUrl}>
                                    <source src={previewItem.videoUrl} />
                                </video>
                            </div>
                        )}
                    </div>
                </div>
            )}

            {/* Global Confirm Dialog */}
            <ConfirmDialog 
                isOpen={confirmState.isOpen}
                title={confirmState.title}
                message={confirmState.message}
                type={confirmState.type}
                confirmText={confirmState.confirmText}
                onConfirm={confirmState.onConfirm}
                onCancel={() => setConfirmState(p => ({ ...p, isOpen: false }))}
            />
        </div>
    );
};

export default MediaList;
