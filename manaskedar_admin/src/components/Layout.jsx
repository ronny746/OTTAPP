import { useState } from 'react';
import Sidebar from './Sidebar';
import { Outlet } from 'react-router-dom';
import { Bell, Search, Menu, X } from 'lucide-react';

const Layout = () => {
    const [isSidebarOpen, setSidebarOpen] = useState(false);

    return (
        <div className="flex bg-[#0f0e17] min-h-screen overflow-hidden">
            {/* Mobile Overlay */}
            {isSidebarOpen && (
                <div 
                    className="fixed inset-0 bg-black/60 z-30 lg:hidden backdrop-blur-sm"
                    onClick={() => setSidebarOpen(false)}
                />
            )}
            
            <Sidebar isOpen={isSidebarOpen} closeSidebar={() => setSidebarOpen(false)} />
            
            <main className="flex-1 overflow-y-auto px-4 md:px-8 pb-12 relative h-screen">
                <header className="flex justify-between items-center py-6 glass-header sticky top-0 z-20 px-8 -mx-8">
                    <div className="flex items-center gap-4">
                        <button 
                            onClick={() => setSidebarOpen(true)}
                            className="lg:hidden p-2 text-white/50 hover:text-white bg-white/5 rounded-xl transition-all"
                        >
                            <Menu size={20} />
                        </button>
                        <div>
                            <h1 className="text-lg md:text-xl font-bold text-white tracking-tight">System Terminal</h1>
                            <p className="hidden md:block text-[10px] text-[rgba(255,255,255,0.3)] font-black uppercase tracking-widest mt-0.5">Control Center • Active Session</p>
                        </div>
                    </div>
                    
                    <div className="flex items-center gap-6">
                        <div className="hidden lg:block relative group">
                            <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-[rgba(255,255,255,0.3)]" size={16} />
                            <input 
                                type="text" 
                                placeholder="Universal search..." 
                                className="bg-[rgba(255,255,255,0.05)] border border-[rgba(255,255,255,0.08)] rounded-full pl-10 pr-4 py-2 text-xs font-bold focus:outline-none focus:border-[#4f46e5]/50 transition-all w-64"
                            />
                        </div>
                        
                        <button className="relative w-10 h-10 rounded-xl bg-[rgba(255,255,255,0.05)] flex items-center justify-center text-[rgba(255,255,255,0.5)] hover:text-white transition-all">
                            <Bell size={18} />
                            <span className="absolute top-2 right-2 w-2 h-2 bg-[#4f46e5] rounded-full border-2 border-[#0f0e17]"></span>
                        </button>

                        <div className="flex items-center gap-4 pl-4 border-l border-[rgba(255,255,255,0.1)]">
                            <div className="hidden sm:block text-right">
                                <p className="text-sm font-bold text-white">Rohit Admin</p>
                                <p className="text-[10px] font-black text-[#4f46e5] uppercase tracking-widest">Super Admin</p>
                            </div>
                            <div className="w-10 h-10 rounded-xl bg-[#4f46e5]/20 border border-[#4f46e5]/30 flex items-center justify-center text-[#4f46e5] font-black text-sm">
                                RA
                            </div>
                        </div>
                    </div>
                </header>
                
                <div className="max-w-7xl mx-auto pt-8">
                    <Outlet />
                </div>
            </main>
        </div>
    );
};

export default Layout;
