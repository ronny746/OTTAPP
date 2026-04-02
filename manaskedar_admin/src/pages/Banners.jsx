import { useState, useEffect } from 'react';
import api from '../utils/api';
import ConfirmDialog from '../components/ConfirmDialog';
import { 
    Plus, Trash2, Layout, Sparkles, TrendingUp, 
    ImageIcon, PlayCircle, ChevronLeft, ChevronRight, 
    Layers, ExternalLink, Calendar, Search
} from 'lucide-react';

const Banners = () => {
    const [banners, setBanners] = useState([]);
    const [media, setMedia] = useState([]);
    const [selectedMedia, setSelectedMedia] = useState('');
    const [loading, setLoading] = useState(false);
    
    // Pagination State
    const [currentPage, setCurrentPage] = useState(1);
    const itemsPerPage = 8;
    
    const [confirmState, setConfirmState] = useState({ isOpen: false, title: '', message: '', type: 'danger', onConfirm: () => {} });

    const fetchData = async () => {
        try {
            const { data: b } = await api.get('/user/banners');
            const { data: m } = await api.get('/user/media');
            setBanners(b);
            setMedia(m);
        } catch (err) {
            console.error('Data sync failure');
        }
    };

    useEffect(() => {
        fetchData();
    }, []);

    const handleAdd = async (e) => {
        e.preventDefault();
        const mediaItem = media.find(m => m._id === selectedMedia);
        if (!mediaItem) return;

        setLoading(true);
        try {
            await api.post('/admin/banners', { 
                imageUrl: mediaItem.imageUrl,
                mediaId: mediaItem._id 
            });
            fetchData();
            setSelectedMedia('');
        } catch (err) {
            alert('Promotion failed');
        }
        setLoading(false);
    };

    const handleDelete = (id) => {
        setConfirmState({
            isOpen: true,
            title: 'Terminate Promotion',
            message: 'Are you sure you want to remove this asset from the featured slider? This will not delete the media, only the slider banner.',
            type: 'danger',
            confirmText: 'Remove Promotion',
            onConfirm: async () => {
                try {
                    await api.delete(`/admin/banners/${id}`);
                    setBanners(banners.filter(b => b._id !== id));
                    setConfirmState(p => ({ ...p, isOpen: false }));
                } catch (err) {
                    alert('Elimination protocol failed');
                    setConfirmState(p => ({ ...p, isOpen: false }));
                }
            }
        });
    };

    // Pagination Logic
    const lastIndex = currentPage * itemsPerPage;
    const firstIndex = lastIndex - itemsPerPage;
    const currentBanners = banners.slice(firstIndex, lastIndex);
    const totalPages = Math.ceil(banners.length / itemsPerPage);

    return (
        <div className="space-y-12 pb-24">
            <div className="frosted-card p-10 border-white/10 ring-1 ring-[#4f46e5]/10">
                <div className="flex items-center gap-6 mb-12">
                    <div className="w-16 h-16 bg-gradient-to-br from-[#4f46e5] to-[#7c3aed] rounded-2xl flex items-center justify-center shadow-2xl shadow-[#4f46e5]/30 ring-1 ring-white/20">
                        <TrendingUp size={32} className="text-white" />
                    </div>
                    <div>
                        <h2 className="text-4xl font-black text-white tracking-tighter uppercase mb-1">Featured Gallery Pipeline</h2>
                        <p className="text-[rgba(255,255,255,0.4)] font-bold text-sm tracking-wide">Promote high-density assets to the homepage carousel</p>
                    </div>
                </div>

                <form onSubmit={handleAdd} className="flex flex-col md:flex-row gap-6 items-end max-w-4xl">
                    <div className="flex-1 w-full relative">
                        <label className="block text-[10px] font-black text-white/30 uppercase tracking-[0.3em] mb-4 ml-1">Asset Source Selection</label>
                        <div className="relative group">
                            <select
                                value={selectedMedia}
                                onChange={(e) => setSelectedMedia(e.target.value)}
                                className="w-full bg-white/[0.03] border border-white/10 rounded-2xl md:px-8 px-4 py-5 text-sm font-black text-white uppercase tracking-widest focus:outline-none focus:ring-4 focus:ring-[#4f46e5]/10 focus:border-[#4f46e5]/50 appearance-none transition-all cursor-pointer shadow-lg"
                                required
                            >
                                <option value="" className="bg-[#0f0e17]">-- [ SELECT ASSET TO PROMOTE ] --</option>
                                {media.filter(m => 
                                    m.type !== 'short' && 
                                    m.type !== 'shorts' && 
                                    !banners.some(b => b.mediaId?._id === m._id)
                                ).map(m => (
                                    <option key={m._id} value={m._id} className="bg-[#0f0e17] py-4">
                                        {m.title.toUpperCase()} • [{m.type.toUpperCase()}]
                                    </option>
                                ))}
                            </select>
                            <div className="absolute right-6 top-1/2 -translate-y-1/2 pointer-events-none text-white/20">
                                <Layout size={20} />
                            </div>
                        </div>
                    </div>
                    <button type="submit" disabled={loading} className="w-full md:w-auto h-[64px] px-12 bg-[#4f46e5] hover:bg-[#4338ca] text-white rounded-2xl flex items-center justify-center gap-3 font-black text-[11px] uppercase tracking-[0.2em] shadow-2xl shadow-[#4f46e5]/30 transition-all hover:scale-105 active:scale-95 group">
                        {loading ? (
                             <div className="animate-spin rounded-full h-5 w-5 border-2 border-white/20 border-t-white" />
                        ) : (
                            <><Sparkles size={20} className="group-hover:rotate-12 transition-transform" /> Commit Promotion</>
                        )}
                    </button>
                </form>
            </div>

            {/* VERTICAL BANNER LIST */}
            <div className="frosted-card overflow-hidden border border-white/5 p-0">
                <div className="overflow-x-auto text-white">
                    <table className="w-full text-left">
                        <thead className="bg-white/[0.02] border-b border-white/5">
                            <tr>
                                <th className="px-8 py-5 text-[10px] font-black text-white/30 uppercase tracking-[0.2em]">Promotion Detail</th>
                                <th className="px-6 py-5 text-[10px] font-black text-white/30 uppercase tracking-[0.2em]">Asset Class</th>
                                <th className="px-6 py-5 text-[10px] font-black text-white/30 uppercase tracking-[0.2em]">Source Metadata</th>
                                <th className="px-6 py-5 text-[10px] font-black text-white/30 uppercase tracking-[0.2em]">Status</th>
                                <th className="px-8 py-5 text-[10px] font-black text-white/30 uppercase tracking-[0.2em] text-right">Operations</th>
                            </tr>
                        </thead>
                        <tbody className="divide-y divide-white/5">
                            {currentBanners.map((banner) => (
                                <tr key={banner._id} className="hover:bg-white/[0.02] group transition-all">
                                    <td className="px-8 py-6">
                                        <div className="flex items-center gap-6">
                                            <div className="w-32 h-16 rounded-xl bg-white/5 overflow-hidden border border-white/10 relative group/img">
                                                <img src={banner.imageUrl} className="w-full h-full object-cover grayscale opacity-50 group-hover/img:grayscale-0 group-hover/img:opacity-100 transition-all duration-700" alt="" />
                                                <div className="absolute inset-0 bg-gradient-to-t from-black/60 to-transparent" />
                                            </div>
                                            <div className="min-w-0">
                                                <p className="text-xs font-black uppercase tracking-wide group-hover:text-[#4f46e5] transition-colors truncate">{banner.mediaId?.title || 'Unknown Asset'}</p>
                                                <p className="text-[9px] font-bold text-white/20 mt-1 uppercase tracking-widest">{banner._id}</p>
                                            </div>
                                        </div>
                                    </td>
                                    <td className="px-6 py-6">
                                        <span className="text-[10px] font-black uppercase text-white/30 tracking-widest border border-white/5 px-3 py-1 rounded bg-white/5 group-hover:border-[#4f46e5]/20 group-hover:text-[#4f46e5] transition-all">
                                            {banner.mediaId?.type || 'CORE'}
                                        </span>
                                    </td>
                                    <td className="px-6 py-6">
                                        <div className="flex flex-col gap-1.5 opacity-60 group-hover:opacity-100">
                                            <div className="flex items-center gap-2">
                                                <Calendar size={12} className="text-[#4f46e5]" />
                                                <span className="text-[10px] font-black uppercase">{banner.mediaId?.year || 'N/A'}</span>
                                            </div>
                                            <div className="flex items-center gap-2">
                                                <Layers size={12} className="text-emerald-500" />
                                                <span className="text-[10px] font-black uppercase">{banner.mediaId?.rating || '0.0'} RATING</span>
                                            </div>
                                        </div>
                                    </td>
                                    <td className="px-6 py-6">
                                        <div className="flex items-center gap-2.5">
                                            <div className="w-2 h-2 rounded-full bg-emerald-500 shadow-[0_0_10px_#10b981] animate-pulse"></div>
                                            <span className="text-[10px] font-black uppercase tracking-[0.2em] text-[#10b981]">Deployed</span>
                                        </div>
                                    </td>
                                    <td className="px-8 py-6">
                                        <div className="flex items-center justify-end gap-3 opacity-0 group-hover:opacity-100 transition-all translate-x-2 group-hover:translate-x-0">
                                            <button 
                                                onClick={() => handleDelete(banner._id)}
                                                className="w-10 h-10 bg-rose-500/10 border border-rose-500/20 text-rose-500 hover:bg-rose-500 hover:text-white rounded-xl flex items-center justify-center transition-all shadow-lg"
                                                title="Remove Promotion"
                                            >
                                                <Trash2 size={18} />
                                            </button>
                                        </div>
                                    </td>
                                </tr>
                            ))}
                        </tbody>
                    </table>
                </div>

                {/* Pagination Panel */}
                {totalPages > 1 && (
                    <div className="px-8 py-6 border-t border-white/5 flex items-center justify-between bg-white/[0.01]">
                        <div className="text-[10px] font-black text-white/20 uppercase tracking-[0.2em]">
                            Registry Page {currentPage} of {totalPages} • Entries {firstIndex + 1}-{Math.min(lastIndex, banners.length)}
                        </div>
                        <div className="flex items-center gap-2">
                            <button 
                                onClick={() => setCurrentPage(p => Math.max(1, p - 1))}
                                disabled={currentPage === 1}
                                className="w-10 h-10 flex items-center justify-center rounded-xl bg-white/5 border border-white/10 text-white disabled:opacity-10 hover:bg-[#4f46e5] transition-all"
                            >
                                <ChevronLeft size={18} />
                            </button>
                            
                            {[...Array(totalPages)].map((_, i) => (
                                <button 
                                    key={i}
                                    onClick={() => setCurrentPage(i + 1)}
                                    className={`w-10 h-10 rounded-xl text-[10px] font-black uppercase transition-all ${
                                        currentPage === i + 1 
                                        ? 'bg-[#4f46e5] text-white shadow-xl shadow-[#4f46e5]/40' 
                                        : 'text-white/20 hover:bg-white/5 hover:text-white'
                                    }`}
                                >
                                    {i + 1}
                                </button>
                            ))}
                            
                            <button 
                                onClick={() => setCurrentPage(p => Math.min(totalPages, p + 1))}
                                disabled={currentPage === totalPages}
                                className="w-10 h-10 flex items-center justify-center rounded-xl bg-white/5 border border-white/10 text-white disabled:opacity-10 hover:bg-[#4f46e5] transition-all"
                            >
                                <ChevronRight size={18} />
                            </button>
                        </div>
                    </div>
                )}
            </div>
            
            {banners.length === 0 && (
                <div className="py-32 flex flex-col items-center justify-center text-center frosted-card border-white/10">
                    <div className="w-24 h-24 bg-white/5 rounded-[2.5rem] flex items-center justify-center mb-8 shadow-2xl border border-white/10 text-white/10">
                        <ImageIcon size={48} />
                    </div>
                    <h3 className="text-xl font-black text-white uppercase tracking-[0.3em]">Promotion Registry Void</h3>
                    <p className="text-white/20 font-bold text-[10px] uppercase tracking-[0.2em] max-w-sm mt-3 leading-relaxed">No content currently indexed in featured gallery pulse</p>
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

export default Banners;
