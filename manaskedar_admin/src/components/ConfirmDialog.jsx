import { X, AlertTriangle, ShieldCheck } from 'lucide-react';

const ConfirmDialog = ({ isOpen, title, message, onConfirm, onCancel, type = 'danger', confirmText = 'Confirm' }) => {
    if (!isOpen) return null;

    const colors = {
        danger: 'text-rose-500 border-rose-500/20 bg-rose-500/5 hover:bg-rose-500',
        warning: 'text-amber-500 border-amber-500/20 bg-amber-500/5 hover:bg-amber-500',
        success: 'text-emerald-500 border-emerald-500/20 bg-emerald-500/5 hover:bg-emerald-500',
        primary: 'text-[#4f46e5] border-[#4f46e5]/20 bg-[#4f46e5]/5 hover:bg-[#4f46e5]'
    };

    return (
        <div className="fixed inset-0 z-[100] flex items-center justify-center p-4">
            <div className="absolute inset-0 bg-black/90 backdrop-blur-md animate-in fade-in duration-300" onClick={onCancel}></div>
            
            <div className="frosted-card w-full max-w-sm p-8 relative z-10 border border-white/20 animate-in zoom-in slide-in-from-bottom-4 duration-300 shadow-[0_0_50px_rgba(0,0,0,0.5)]">
                <div className="flex flex-col items-center text-center">
                    <div className={`w-16 h-16 rounded-2xl flex items-center justify-center mb-6 border border-white/10 bg-white/5 
                                   ${type === 'danger' ? 'text-rose-500' : type === 'warning' ? 'text-amber-500' : 'text-[#4f46e5]'}`}>
                        {type === 'danger' ? <AlertTriangle size={32} /> : <ShieldCheck size={32} />}
                    </div>

                    <h3 className="text-xl font-black text-white uppercase tracking-widest mb-3">{title}</h3>
                    <p className="text-xs font-bold text-white/30 tracking-wide mb-8 leading-relaxed">
                        {message}
                    </p>

                    <div className="flex gap-4 w-full">
                        <button 
                            onClick={onCancel}
                            className="flex-1 py-4 bg-white/5 rounded-xl text-[10px] font-black uppercase text-white/40 hover:bg-white/10 transition-all border border-white/5"
                        >
                            Abort
                        </button>
                        <button 
                            onClick={onConfirm}
                            className={`flex-1 py-4 rounded-xl text-[10px] font-black uppercase text-white transition-all shadow-lg shadow-black/20 ${colors[type] || colors.primary}`}
                        >
                            {confirmText}
                        </button>
                    </div>
                </div>

                <button 
                    onClick={onCancel} 
                    className="absolute top-4 right-4 p-2 text-white/20 hover:text-white transition-colors"
                >
                    <X size={18} />
                </button>
            </div>
        </div>
    );
};

export default ConfirmDialog;
