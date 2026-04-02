import { useState, useEffect } from 'react';
import api from '../utils/api';
import { Film, Users, Play, ListMusic, ArrowUpRight, TrendingUp } from 'lucide-react';

const Dashboard = () => {
    const [stats, setStats] = useState({
        totalMedia: 0,
        totalUsers: 0,
        totalVideos: 0,
        totalShorts: 0,
        totalAudio: 0,
        totalShows: 0,
        recentUsers: []
    });

    useEffect(() => {
        const fetchStats = async () => {
            try {
                const { data } = await api.get('/admin/stats');
                setStats({
                  totalMedia: data.media,
                  totalUsers: data.users,
                  totalVideos: data.movies,
                  totalShorts: data.shorts,
                  totalAudio: data.audio,
                  totalShows: data.shows,
                  recentUsers: data.recentUsers || []
                });
            } catch (err) {
                console.error('Cant fetch stats');
            }
        };
        fetchStats();
    }, []);

    const cards = [
        { title: 'Global Library', value: stats.totalMedia, icon: Film, color: 'text-[#4f46e5]', bg: 'bg-[#4f46e5]/10' },
        { title: 'Subscribers', value: stats.totalUsers, icon: Users, color: 'text-emerald-500', bg: 'bg-emerald-500/10' },
        { title: 'Movies', value: stats.totalVideos, icon: Play, color: 'text-rose-500', bg: 'bg-rose-500/10' },
        { title: 'Shorts', value: stats.totalShorts, icon: TrendingUp, color: 'text-amber-500', bg: 'bg-amber-500/10' },
        { title: 'Audio Library', value: stats.totalAudio, icon: ListMusic, color: 'text-cyan-500', bg: 'bg-cyan-500/10' },
    ];

    // Chart logic: Normalize the counts relative to totalMedia
    const chartItems = [
        { name: 'Movies', val: stats.totalVideos },
        { name: 'Shows', val: stats.totalShows },
        { name: 'Shorts', val: stats.totalShorts },
        { name: 'Audio', val: stats.totalAudio }
    ];
    const maxVal = Math.max(...chartItems.map(i => i.val), 1);

    return (
        <div className="space-y-8 pb-12">
            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-5 gap-4">
                {cards.map((card, idx) => (
                    <div key={idx} className="frosted-card p-5 flex flex-col justify-between h-40 group">
                        <div className="flex justify-between items-start">
                            <div className={`${card.bg} p-3 rounded-xl border border-[rgba(255,255,255,0.05)] group-hover:scale-110 transition-transform`}>
                                <card.icon className={card.color} size={20} />
                            </div>
                            <div className={`text-[8px] font-black uppercase tracking-widest ${card.color} bg-white/5 px-2 py-1 rounded-md border border-[rgba(255,255,255,0.05)]`}>
                                ACTIVE
                            </div>
                        </div>
                        <div>
                            <p className="text-[rgba(255,255,255,0.3)] text-[9px] font-black uppercase tracking-widest mb-1">{card.title}</p>
                            <div className="flex items-end justify-between">
                                <h3 className="text-2xl font-black text-white tracking-tight">{card.value.toLocaleString()}</h3>
                                <ArrowUpRight className="text-white/5 group-hover:text-[#4f46e5] transition-colors" size={20} />
                            </div>
                        </div>
                    </div>
                ))}
            </div>

            <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
                <div className="lg:col-span-2 frosted-card p-8">
                    <div className="flex justify-between items-center mb-12">
                        <div>
                            <h3 className="text-lg font-black text-white tracking-tight uppercase">Content Distribution</h3>
                            <p className="text-xs text-[rgba(255,255,255,0.3)] font-bold">Relative balance across production types</p>
                        </div>
                        <div className="text-[10px] font-black text-white/20 uppercase tracking-widest border border-white/5 px-4 py-2 rounded-lg">
                           Live Dataset
                        </div>
                    </div>
                    
                    <div className="flex items-end justify-around gap-4 h-[250px] px-8">
                        {chartItems.map((item, i) => (
                            <div key={i} className="flex-1 flex flex-col items-center group h-full">
                                <div className="flex-1 w-full flex items-end justify-center relative">
                                    <div 
                                        className="w-12 bg-gradient-to-t from-[#4f46e5] to-[#7c3aed] rounded-t-xl transition-all duration-1000 ease-out group-hover:brightness-125 group-hover:shadow-[0_0_30px_#4f46e550] relative" 
                                        style={{ height: `${(item.val / maxVal) * 100}%`, minHeight: '4px' }}
                                    >
                                        <div className="absolute -top-8 left-1/2 -translate-x-1/2 bg-white text-black px-2 py-1 rounded font-black text-[9px] opacity-0 group-hover:opacity-100 transition-opacity">
                                            {item.val}
                                        </div>
                                    </div>
                                </div>
                                <span className="mt-6 text-[10px] font-black text-white/30 uppercase tracking-[0.2em]">{item.name}</span>
                            </div>
                        ))}
                    </div>
                </div>

                <div className="frosted-card p-8 flex flex-col">
                    <div className="mb-8">
                        <h3 className="text-lg font-black text-white tracking-tight uppercase">Real-time Activity</h3>
                        <p className="text-xs text-[rgba(255,255,255,0.3)] font-bold">Recent sub-network interactions</p>
                    </div>
                    
                    <div className="flex-1 space-y-6">
                        {stats.recentUsers.length > 0 ? stats.recentUsers.map((user, i) => (
                            <div key={user._id} className="flex items-center gap-4 group cursor-pointer">
                                <div className="w-10 h-10 bg-white/5 rounded-xl flex items-center justify-center border border-white/10 text-[rgba(255,255,255,0.2)] group-hover:border-[#4f46e5]/50 group-hover:text-[#4f46e5] transition-all uppercase font-black text-xs">
                                    {user.name?.substring(0, 2) || 'US'}
                                </div>
                                <div className="flex-1 min-w-0">
                                    <p className="text-xs font-black text-[rgba(255,255,255,0.8)] truncate">New entity registered</p>
                                    <p className="text-[10px] font-bold text-[rgba(255,255,255,0.3)] mt-0.5 truncate">
                                        {user.name} • {new Date(user.createdAt).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
                                    </p>
                                </div>
                                <div className="w-1.5 h-1.5 rounded-full bg-emerald-500 shadow-[0_0_8px_#10b981]"></div>
                            </div>
                        )) : (
                            <div className="flex-1 flex items-center justify-center text-[10px] font-black text-white/10 uppercase tracking-widest">
                                No recent activity
                            </div>
                        )}
                    </div>
                    <button className="w-full py-3 mt-8 bg-white/5 rounded-xl text-[10px] font-black uppercase tracking-widest text-[rgba(255,255,255,0.4)] hover:text-white hover:bg-white/10 transition-all border border-white/5">
                        Deep Network Audit
                    </button>
                </div>
            </div>
        </div>
    );
};

export default Dashboard;
