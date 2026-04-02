import { useState, useEffect } from 'react';
import api from '../utils/api';
import { useNavigate } from 'react-router-dom';
import { Play, CheckCircle2, AlertCircle, Film, Clock, AlignLeft, PlusCircle, Image as ImageIcon, Trash2, ArrowRightCircle, Database, Layers } from 'lucide-react';
import MediaPicker from '../components/MediaPicker';

const AddMedia = () => {
    const navigate = useNavigate();
    const [formData, setFormData] = useState({
        title: '',
        type: 'movie',
        description: '',
        imageUrl: '',
        videoUrl: '',
        year: '2024',
        rating: '4.5',
        duration: '2h 15m',
        episodes: []
    });
    
    const [isPickerOpen, setIsPickerOpen] = useState({ image: false, video: false, episode: -1 });

    const addEpisode = () => {
        setFormData({
            ...formData,
            episodes: [...formData.episodes, { title: '', videoUrl: '', duration: '45m', order: formData.episodes.length + 1 }]
        });
    };

    const removeEpisode = (index) => {
        const newEps = formData.episodes.filter((_, i) => i !== index);
        setFormData({ ...formData, episodes: newEps });
    };

    const updateEpisode = (index, field, value) => {
        const newEps = [...formData.episodes];
        newEps[index][field] = value;
        setFormData({ ...formData, episodes: newEps });
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        try {
            await api.post('/admin/media', formData);
            navigate('/media');
        } catch (err) {
            alert('Operation failed');
        }
    };

    return (
        <div className="max-w-5xl mx-auto pb-48">
            <div className="flex items-center gap-5 mb-10">
                <div className="w-14 h-14 bg-[#4f46e5] rounded-2xl flex items-center justify-center shadow-xl shadow-[#4f46e5]/20">
                    <PlusCircle size={28} className="text-white" />
                </div>
                <div>
                    <h2 className="text-3xl font-black text-white tracking-tight uppercase">Add New Media</h2>
                    <p className="text-white/30 font-bold text-sm">Fill in the details to publish new content</p>
                </div>
            </div>

            <form onSubmit={handleSubmit} className="space-y-8">
                {/* 1. BASIC INFO */}
                <div className="frosted-card p-10">
                    <h3 className="text-xs font-black text-[#4f46e5] uppercase tracking-widest mb-10 flex items-center gap-3">
                        <span className="w-6 h-[2px] bg-[#4f46e5]/50"></span> Basic Information
                    </h3>
                    
                    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
                        <div className="space-y-2">
                            <label className="text-[10px] font-black text-white/30 uppercase tracking-widest ml-1">Title</label>
                            <input
                                type="text"
                                placeholder="Enter movie/show title..."
                                className="input-field py-3.5 font-bold"
                                value={formData.title}
                                onChange={(e) => setFormData({ ...formData, title: e.target.value })}
                                required
                            />
                        </div>
                        
                        <div className="space-y-2">
                            <label className="text-[10px] font-black text-white/30 uppercase tracking-widest ml-1">Media Type</label>
                            <select
                                className="input-field py-3.5 font-bold appearance-none uppercase"
                                value={formData.type}
                                onChange={(e) => setFormData({ ...formData, type: e.target.value })}
                            >
                                <option value="movie">Movie</option>
                                <option value="show">Web Series / Show</option>
                                <option value="short">Short Video</option>
                                <option value="audio">Audio / Music</option>
                            </select>
                        </div>

                        <div className="space-y-2">
                            <label className="text-[10px] font-black text-white/30 uppercase tracking-widest ml-1">Release Year</label>
                            <input
                                type="text"
                                placeholder="e.g. 2024"
                                className="input-field py-3.5 font-bold"
                                value={formData.year}
                                onChange={(e) => setFormData({ ...formData, year: e.target.value })}
                            />
                        </div>
                    </div>

                    <div className="mt-8 space-y-2">
                        <label className="text-[10px] font-black text-white/30 uppercase tracking-widest ml-1">Description</label>
                        <textarea
                            rows="4"
                            placeholder="Write a short summary..."
                            className="input-field resize-none py-4 font-bold text-white/70"
                            value={formData.description}
                            onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                        ></textarea>
                    </div>
                </div>

                {/* 2. MEDIA SELECTION - COMPACT & PREMIUM */}
                <div className="grid grid-cols-1 md:grid-cols-2 gap-8 mt-5">
                    {/* Thumbnail Image Selection */}
                    <div 
                        onClick={() => setIsPickerOpen({ ...isPickerOpen, image: true })}
                        className={`relative group cursor-pointer transition-all duration-300 rounded-[2rem] border overflow-hidden p-6 ${formData.imageUrl ? 'bg-indigo-500/10 border-indigo-500/30 ring-1 ring-indigo-500/20' : 'bg-white/[0.02] border-white/10 hover:border-indigo-500/40 hover:bg-white/[0.04]'}`}
                    >
                        <div className="flex items-center justify-between mb-4">
                            <div className="flex items-center gap-3">
                                <div className={`w-10 h-10 rounded-xl flex items-center justify-center transition-all ${formData.imageUrl ? 'bg-indigo-500 text-white shadow-lg shadow-indigo-500/30' : 'bg-white/5 text-white/40 group-hover:text-white'}`}>
                                    <ImageIcon size={18} />
                                </div>
                                <div>
                                    <h4 className="text-[10px] font-black text-white uppercase tracking-widest">Select Thumbnail</h4>
                                    <p className="text-[8px] text-indigo-500 font-bold uppercase tracking-widest mt-0.5">High Res Preferred</p>
                                </div>
                            </div>
                            {formData.imageUrl && <CheckCircle2 size={16} className="text-indigo-500" />}
                        </div>
                        
                        <div className={`h-24 rounded-2xl border border-white/5 bg-black/40 overflow-hidden flex flex-col items-center justify-center transition-all ${!formData.imageUrl && 'group-hover:border-indigo-500/20 group-hover:bg-indigo-500/5'}`}>
                            {formData.imageUrl ? (
                                <img src={formData.imageUrl} className="w-full h-full object-cover group-hover:scale-110 transition-transform duration-500" alt="" />
                            ) : (
                                <div className="flex flex-col items-center gap-2">
                                    <Database size={20} className="text-white/10 group-hover:text-indigo-500/40 transition-colors" />
                                    <span className="text-white/20 text-[7px] uppercase font-black tracking-widest group-hover:text-white/40">Enter Library</span>
                                </div>
                            )}
                        </div>
                    </div>

                    {/* Video Selection Card */}
                    <div 
                        onClick={() => formData.type !== 'show' && setIsPickerOpen({ ...isPickerOpen, video: true })}
                        className={`relative group cursor-pointer transition-all duration-300 rounded-[2rem] border overflow-hidden p-6 ${formData.type === 'show' ? 'opacity-40 cursor-not-allowed bg-black/20 border-white/5' : (formData.videoUrl ? 'bg-emerald-500/10 border-emerald-500/30 ring-1 ring-emerald-500/20' : 'bg-white/[0.02] border-white/10 hover:border-emerald-500/40 hover:bg-white/[0.04]')}`}
                    >
                        <div className="flex items-center justify-between mb-4">
                            <div className="flex items-center gap-3">
                                <div className={`w-10 h-10 rounded-xl flex items-center justify-center transition-all ${formData.type === 'show' ? 'bg-white/5 text-white/20' : (formData.videoUrl ? 'bg-emerald-500 text-white shadow-lg shadow-emerald-500/30' : 'bg-white/5 text-white/40 group-hover:text-white')}`}>
                                    <Film size={18} />
                                </div>
                                <div>
                                    <h4 className="text-[10px] font-black text-white uppercase tracking-widest">{formData.type === 'show' ? 'Series Mode' : 'Select Main Video'}</h4>
                                    <p className="text-[8px] text-emerald-500 font-bold uppercase tracking-widest mt-0.5">{formData.type === 'show' ? 'Add Episodes Below' : '4K Optimized Output'}</p>
                                </div>
                            </div>
                            {formData.videoUrl && <CheckCircle2 size={16} className="text-emerald-500" />}
                        </div>
                        
                        <div className={`h-24 rounded-2xl border border-white/5 bg-black/40 overflow-hidden flex flex-col items-center justify-center transition-all ${!formData.videoUrl && 'group-hover:border-emerald-500/20 group-hover:bg-emerald-500/5'}`}>
                            {formData.type === 'show' ? (
                                <Layers size={24} className="text-white/10" />
                            ) : formData.videoUrl ? (
                                <div className="flex flex-col items-center gap-2 text-emerald-500/60">
                                    <Play size={20} className="animate-pulse" />
                                    <span className="text-white/40 text-[7px] uppercase font-black tracking-widest">{formData.videoUrl.split('/').pop()}</span>
                                </div>
                            ) : (
                                <div className="flex flex-col items-center gap-2">
                                    <ArrowRightCircle size={20} className="text-white/10 group-hover:text-emerald-500/40 transition-colors" />
                                    <span className="text-white/20 text-[7px] uppercase font-black tracking-widest group-hover:text-white/40 text-center">Reference File</span>
                                </div>
                            )}
                        </div>
                    </div>
                </div>

                {/* 3. EPISODES */}
                {formData.type === 'show' && (
                    <div className="frosted-card p-10">
                        <div className="flex items-center justify-between mb-10">
                            <h3 className="text-xs font-black text-[#4f46e5] uppercase tracking-widest flex items-center gap-3">
                                <span className="w-6 h-[2px] bg-[#4f46e5]/50"></span> Episodes List
                            </h3>
                            <button 
                                type="button" 
                                onClick={addEpisode}
                                className="px-5 py-2.5 bg-[#4f46e5] text-white rounded-xl font-black text-[10px] uppercase tracking-widest shadow-lg shadow-[#4f46e5]/20 hover:scale-105 transition-all"
                            >
                                + Add Episode
                            </button>
                        </div>

                        <div className="space-y-4">
                            {formData.episodes.map((ep, idx) => (
                                <div key={idx} className="bg-white/5 border border-white/5 rounded-2xl p-6 flex flex-col md:flex-row gap-6 items-center">
                                    <div className="w-12 h-12 bg-white/5 rounded-xl flex items-center justify-center font-black text-[#4f46e5] text-xl">
                                        {idx + 1}
                                    </div>
                                    
                                    <div className="flex-1 grid grid-cols-1 md:grid-cols-3 gap-4 w-full">
                                        <input
                                            type="text"
                                            placeholder="Episode Title"
                                            className="input-field py-2.5 text-xs bg-black/20"
                                            value={ep.title}
                                            onChange={(e) => updateEpisode(idx, 'title', e.target.value)}
                                        />
                                        <input
                                            type="text"
                                            placeholder="Duration (e.g. 45m)"
                                            className="input-field py-2.5 text-xs bg-black/20"
                                            value={ep.duration}
                                            onChange={(e) => updateEpisode(idx, 'duration', e.target.value)}
                                        />
                                        <button 
                                            type="button"
                                            onClick={() => setIsPickerOpen({ ...isPickerOpen, episode: idx })}
                                            className={`py-2.5 rounded-xl border border-dashed text-[9px] font-black uppercase transition-all ${ep.videoUrl ? 'border-emerald-500/40 bg-emerald-500/5 text-emerald-500' : 'border-white/10 text-white/30 hover:border-white/20'}`}
                                        >
                                            {ep.videoUrl ? 'Video Linked' : 'Select Video'}
                                        </button>
                                    </div>

                                    <button type="button" onClick={() => removeEpisode(idx)} className="p-3 text-rose-500/50 hover:text-rose-500 transition-all">
                                        <Trash2 size={20} />
                                    </button>
                                </div>
                            ))}
                        </div>
                    </div>
                )}

                {/* 4. SUBMIT */}
                <div className="flex flex-col md:flex-row items-center justify-between py-10 border-t border-white/5 gap-8">
                    <div className="flex items-center gap-4 text-white/20 max-w-lg">
                        <AlertCircle size={20} className="flex-shrink-0" />
                        <p className="text-[10px] font-bold uppercase tracking-widest leading-relaxed">
                            Please verify all details before publishing. Make sure you have selected the correct files from the library.
                        </p>
                    </div>
                    
                    <button 
                        type="submit" 
                        className="px-12 py-5 bg-[#4f46e5] text-white rounded-2xl font-black uppercase tracking-widest text-xs hover:scale-105 transition-all shadow-xl shadow-[#4f46e5]/30"
                    >
                        Publish Content
                    </button>
                </div>
            </form>

            <MediaPicker 
                isOpen={isPickerOpen.image}
                type="image"
                title="Select Thumbnail"
                onClose={() => setIsPickerOpen({ ...isPickerOpen, image: false })}
                onSelect={(asset) => setFormData({ ...formData, imageUrl: asset.url })}
            />
            
            <MediaPicker 
                isOpen={isPickerOpen.video}
                type="video"
                title="Select Main Video"
                onClose={() => setIsPickerOpen({ ...isPickerOpen, video: false })}
                onSelect={(asset) => setFormData({ ...formData, videoUrl: asset.url })}
            />

            <MediaPicker 
                isOpen={isPickerOpen.episode !== -1}
                type="video"
                title={`Select Episode ${isPickerOpen.episode + 1} Video`}
                onClose={() => setIsPickerOpen({ ...isPickerOpen, episode: -1 })}
                onSelect={(asset) => updateEpisode(isPickerOpen.episode, 'videoUrl', asset.url)}
            />
        </div>
    );
};

export default AddMedia;
