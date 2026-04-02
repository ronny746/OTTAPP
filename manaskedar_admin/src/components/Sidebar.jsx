import { NavLink } from 'react-router-dom';
import { LayoutDashboard, Film, ListPlus, Image as ImageIcon, LogOut, PlusCircle, Users, Bell, Search, X } from 'lucide-react';
import { useAuth } from '../context/AuthContext';

const Sidebar = ({ isOpen, closeSidebar }) => {
    const { logout } = useAuth();
    const navItems = [
        { name: 'Dashboard', path: '/', icon: LayoutDashboard },
        { name: 'Media List', path: '/media', icon: Film },
        { name: 'Upload Assets', path: '/assets', icon: ImageIcon },
        { name: 'Add Media', path: '/add-media', icon: PlusCircle },
        { name: 'Banners', path: '/banners', icon: ImageIcon },
        { name: 'Users', path: '/users', icon: Users },
    ];

    return (
        <aside className={`fixed lg:static inset-y-0 left-0 w-72 h-screen bg-[#0f0e17] lg:bg-[rgba(255,255,255,0.025)] border-r border-[rgba(255,255,255,0.08)] flex flex-col p-6 z-40 transition-transform duration-300 transform ${isOpen ? 'translate-x-0' : '-translate-x-full lg:translate-x-0'}`}>
            <div className="flex items-center justify-between mb-12 px-2">
                <div className="flex items-center gap-3">
                    <img src="/logo.png" alt="Logo" className="h-9 w-auto object-contain" />
                    <div className="text-xl font-black text-white tracking-tighter">
                        MANAS<span className="text-[#4f46e5]">KEDAR</span>
                    </div>
                </div>
                <button onClick={closeSidebar} className="lg:hidden p-2 text-white/30 hover:text-white font-bold">
                    (X)
                </button>
            </div>
            
            <nav className="flex-1 space-y-2">
                {navItems.map((item) => (
                    <NavLink
                        key={item.path}
                        to={item.path}
                        onClick={closeSidebar}
                        className={({ isActive }) => 
                            `flex items-center gap-4 px-4 py-3.5 rounded-xl transition-all duration-300 font-bold group ${
                                isActive 
                                ? 'bg-[rgba(79,70,229,0.15)] text-[#4f46e5] border border-[rgba(79,70,229,0.2)]' 
                                : 'text-[rgba(255,255,255,0.35)] hover:bg-[rgba(255,255,255,0.05)] hover:text-white'
                            }`
                        }
                    >
                        <item.icon size={20} />
                        <span>{item.name}</span>
                    </NavLink>
                ))}
            </nav>

            <button 
                onClick={logout}
                className="mt-auto flex items-center gap-4 px-4 py-3.5 text-[rgba(255,255,255,0.3)] hover:text-rose-500 hover:bg-rose-500/10 rounded-xl transition-all font-bold"
            >
                <LogOut size={20} />
                <span>Log out</span>
            </button>
        </aside>
    );
};

export default Sidebar;
