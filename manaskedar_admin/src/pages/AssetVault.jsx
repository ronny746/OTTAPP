import { useState, useEffect } from 'react';
import api from '../utils/api';
import ConfirmDialog from '../components/ConfirmDialog';
import { 
    Upload, Trash2, CheckCircle2, Film, Image as ImageIcon, 
    Music, Search, Plus, X, Globe, Shield, 
    ChevronLeft, ChevronRight, HardDrive, 
    Download, ExternalLink, Calendar, Database
} from 'lucide-react';

const AssetVault = () => {
    const [assets, setAssets] = useState([]);
    const [uploading, setUploading] = useState(false);
    const [searchTerm, setSearchTerm] = useState('');
    const [filterType, setFilterType] = useState('all');
    
    // Pagination State
    const [currentPage, setCurrentPage] = useState(1);
    const itemsPerPage = 10;
    
    const [confirmState, setConfirmState] = useState({ isOpen: false, title: '', message: '', type: 'danger', onConfirm: () => {} });

    useEffect(() => {
        fetchAssets();
    }, []);

    const fetchAssets = async () => {
        try {
            const res = await api.get('/admin/assets');
            setAssets(res.data);
        } catch (err) {
            console.error('Failed to fetch assets');
        }
    };

    const handleFileChange = async (e) => {
        const file = e.target.files[0];
        if (!file) return;

        setUploading(true);
        const formData = new FormData();
        formData.append('file', file);

        try {
            const uploadRes = await api.post('/admin/upload', formData, {
                headers: { 'Content-Type': 'multipart/form-data' }
            });
            
            const resData = uploadRes.data;
            const isImage = file.type.startsWith('image/');
            let type = 'audio';
            if (isImage) {
                type = 'image';
            } else if (file.type.startsWith('video/')) {
                type = 'video';
            }

            await api.post('/admin/assets', {
                name: file.name,
                url: resData.url,
                type: type,
                fileSize: file.size
            });

            setUploading(false);
            fetchAssets();
        } catch (err) {
            console.error('Upload failed:', err);
            alert('Upload failed');
            setUploading(false);
        }
    };

    const deleteAsset = (id) => {
        setConfirmState({
            isOpen: true,
            title: 'Delete Global Asset',
            message: 'Are you sure you want to delete this raw binary from the vault? This will erase the record from the library.',
            type: 'danger',
            confirmText: 'Acknowledge & Delete',
            onConfirm: async () => {
                try {
                    await api.delete(`/admin/assets/${id}`);
                    fetchAssets();
                    setConfirmState(p => ({ ...p, isOpen: false }));
                } catch (err) {
                    alert('Delete failed');
                    setConfirmState(p => ({ ...p, isOpen: false }));
                }
            }
        });
    };

    const filteredAssets = assets.filter(a => 
        a.name.toLowerCase().includes(searchTerm.toLowerCase()) && 
        (filterType === 'all' || a.type === filterType)
    );

    // Pagination Logic
    const lastIndex = currentPage * itemsPerPage;
    const firstIndex = lastIndex - itemsPerPage;
    const currentAssets = filteredAssets.slice(firstIndex, lastIndex);
    const totalPages = Math.ceil(filteredAssets.length / itemsPerPage);

    return (
        <div className="max-w-7xl mx-auto pb-24 space-y-12">
            {/* Header Section */}
            <div className="flex flex-col md:flex-row md:items-end justify-between gap-8">
                <div className="flex items-center gap-6">
                    <div className="w-16 h-16 bg-gradient-to-br from-[#4f46e5] to-[#7c3aed] rounded-2xl flex items-center justify-center shadow-2xl shadow-[#4f46e5]/30 ring-1 ring-white/20">
                        <Database className="text-white" size={32} />
                    </div>
                    <div>
                        <h2 className="text-4xl font-black text-white tracking-tighter uppercase mb-2">Central Asset Vault</h2>
                        <div className="flex items-center gap-4">
                            <span className="text-[10px] font-black text-white/40 uppercase tracking-[0.2em] flex items-center gap-1.5 bg-white/5 px-2 py-1 rounded">
                                <Globe size={12} className="text-[#4f46e5]" /> Global Binary Repository
                            </span>
                            <span className="text-[10px] font-black text-emerald-500 uppercase tracking-[0.2em] flex items-center gap-1.5 bg-emerald-500/5 px-2 py-1 rounded">
                                <HardDrive size={12} /> {assets.length} Persistent Elements
                            </span>
                        </div>
                    </div>
                </div>

                <div className="flex bg-white/5 p-1.5 rounded-2xl border border-white/10 backdrop-blur-md">
                    {['all', 'video', 'image', 'audio'].map(type => (
                        <button
                            key={type}
                            onClick={() => { setFilterType(type); setCurrentPage(1); }}
                            className={`px-6 py-2.5 rounded-xl font-black text-[9px] uppercase tracking-[0.2em] transition-all ${
                                filterType === type ? 'bg-[#4f46e5] text-white shadow-xl shadow-[#4f46e5]/30' : 'text-white/40 hover:text-white'
                            }`}
                        >
                            {type}
                        </button>
                    ))}
                </div>
            </div>

            {/* Search & Upload Area */}
            <div className="grid grid-cols-1 lg:grid-cols-4 gap-8">
                <div className="lg:col-span-3 frosted-card p-4 flex items-center gap-4 border-white/10">
                    <Search className="text-white/20 ml-4" />
                    <input 
                        type="text" 
                        placeholder="Scan by unique asset identifier..."
                        className="bg-transparent border-none text-white font-bold w-full focus:ring-0 placeholder:text-white/10"
                        value={searchTerm}
                        onChange={(e) => { setSearchTerm(e.target.value); setCurrentPage(1); }}
                    />
                </div>
                
                <div className="relative">
                    <input 
                        type="file"
                        onChange={handleFileChange}
                        className="hidden"
                        id="vault-upload"
                    />
                    <label 
                        htmlFor="vault-upload" 
                        className={`flex items-center justify-center gap-3 w-full h-full min-h-[64px] bg-[#4f46e5] hover:bg-[#4338ca] text-white rounded-2xl font-black uppercase tracking-widest text-[11px] cursor-pointer transition-all shadow-2xl shadow-[#4f46e5]/30 ${uploading ? 'opacity-50 pointer-events-none' : ''}`}
                    >
                        {uploading ? (
                            <div className="animate-spin rounded-full h-5 w-5 border-2 border-white/20 border-t-white" />
                        ) : (
                            <><Plus size={20} /> Transfuse New Binary</>
                        )}
                    </label>
                </div>
            </div>

                {/* Vertical Asset Table */}
                <div className="frosted-card overflow-hidden border border-white/5 p-0">
                    <div className="overflow-x-auto text-white">
                        <table className="w-full text-left">
                            <thead className="bg-white/[0.02] border-b border-white/5">
                                <tr>
                                    <th className="px-8 py-5 text-[10px] font-black text-white/30 uppercase tracking-[0.2em]">Source Identity</th>
                                    <th className="px-6 py-5 text-[10px] font-black text-white/30 uppercase tracking-[0.2em]">Class</th>
                                    <th className="px-6 py-5 text-[10px] font-black text-white/30 uppercase tracking-[0.2em]">Density (Size)</th>
                                    <th className="px-6 py-5 text-[10px] font-black text-white/30 uppercase tracking-[0.2em]">Integration</th>
                                    <th className="px-8 py-5 text-[10px] font-black text-white/30 uppercase tracking-[0.2em] text-right">Actions</th>
                                </tr>
                            </thead>
                            <tbody className="divide-y divide-white/5">
                                {currentAssets.map((asset) => (
                                    <tr key={asset._id} className="hover:bg-white/[0.02] group transition-all">
                                        <td className="px-8 py-5">
                                            <div className="flex items-center gap-5">
                                                <div className="w-12 h-12 rounded-xl bg-white/5 overflow-hidden flex items-center justify-center border border-white/10 group-hover:border-[#4f46e5]/30">
                                                    {asset.type === 'image' ? (
                                                        <img src={asset.url} className="w-full h-full object-cover grayscale opacity-50 group-hover:grayscale-0 group-hover:opacity-100 transition-all" alt="" />
                                                    ) : (
                                                        asset.type === 'video' ? <Film size={20} className="text-[#4f46e5]" /> : <Music size={20} className="text-amber-500" />
                                                    )}
                                                </div>
                                                <div className="min-w-0">
                                                    <p className="text-xs font-black uppercase truncate group-hover:text-[#4f46e5] transition-colors">{asset.name.split('_').pop()}</p>
                                                    <p className="text-[9px] font-bold text-white/20 mt-0.5 truncate max-w-[200px]">{asset.url}</p>
                                                </div>
                                            </div>
                                        </td>
                                        <td className="px-6 py-5">
                                            <span className="text-[10px] font-black uppercase text-white/40 tracking-widest bg-white/5 px-2 py-0.5 rounded border border-white/5 shadow-sm group-hover:text-[#4f46e5] group-hover:border-[#4f46e5]/20 group-hover:bg-[#4f46e5]/5">
                                                {asset.type}
                                            </span>
                                        </td>
                                        <td className="px-6 py-5">
                                            <div className="flex items-center gap-2">
                                                <HardDrive size={12} className="text-white/20" />
                                                <span className="text-[10px] font-black text-white/60">{(asset.fileSize / (1024 * 1024)).toFixed(2)} MB</span>
                                            </div>
                                        </td>
                                        <td className="px-6 py-5">
                                            <div className="flex flex-col gap-1">
                                                <div className="flex items-center gap-2">
                                                    <CheckCircle2 size={12} className="text-emerald-500" />
                                                    <span className="text-[9px] font-black text-white/30 uppercase tracking-widest">Validated</span>
                                                </div>
                                                <div className="flex items-center gap-2 opacity-50">
                                                    <Calendar size={12} className="text-white/40" />
                                                    <span className="text-[9px] font-bold text-white/20">{new Date(asset.createdAt).toLocaleDateString()}</span>
                                                </div>
                                            </div>
                                        </td>
                                        <td className="px-8 py-5">
                                            <div className="flex items-center justify-end gap-3 opacity-0 group-hover:opacity-100 transition-all translate-x-2 group-hover:translate-x-0">
                                                <a 
                                                    href={asset.url} 
                                                    target="_blank" 
                                                    rel="noreferrer"
                                                    className="w-9 h-9 bg-white/5 border border-white/10 text-white/40 hover:bg-[#4f46e5] hover:text-white rounded-xl flex items-center justify-center transition-all"
                                                >
                                                    <Download size={16} />
                                                </a>
                                                <button 
                                                    onClick={() => deleteAsset(asset._id)}
                                                    className="w-9 h-9 bg-rose-500/10 border border-rose-500/20 text-rose-500 hover:bg-rose-500 hover:text-white rounded-xl flex items-center justify-center transition-all"
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

                    {/* Pagination Panel */}
                    {totalPages > 1 && (
                        <div className="px-8 py-6 border-t border-white/5 flex items-center justify-between bg-white/[0.01]">
                            <div className="text-[10px] font-black text-white/20 uppercase tracking-[0.2em]">
                                Page {currentPage} of {totalPages} • Scanning offsets {firstIndex + 1}-{Math.min(lastIndex, filteredAssets.length)}
                            </div>
                            <div className="flex items-center gap-1.5">
                                <button 
                                    onClick={() => setCurrentPage(p => Math.max(1, p - 1))}
                                    disabled={currentPage === 1}
                                    className="w-10 h-10 flex items-center justify-center rounded-xl bg-white/5 border border-white/10 text-white disabled:opacity-20 hover:bg-white/10 transition-all"
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

                {filteredAssets.length === 0 && (
                    <div className="py-24 flex flex-col items-center justify-center text-center frosted-card border-white/5">
                        <HardDrive size={48} className="text-white/10 mb-6" />
                        <h4 className="text-lg font-black text-white uppercase tracking-widest">Vault Empty</h4>
                        <p className="text-white/20 text-[10px] mt-2 font-black uppercase tracking-[0.2em]">No raw binaries matched your current sync parameters</p>
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

export default AssetVault;
