import { Outlet, Link, useNavigate, useLocation } from 'react-router-dom'
import { useAuthStore } from '../store/authStore'
import { Home, LayoutDashboard, Leaf, Shield, LogOut, Hexagon, Store } from 'lucide-react'
import { useState, useEffect } from 'react'

export default function Layout() {
  const user = useAuthStore((s) => s.user)
  const logout = useAuthStore((s) => s.logout)
  const navigate = useNavigate()
  const location = useLocation()
  const [scrolled, setScrolled] = useState(false)

  useEffect(() => {
    const handleScroll = () => setScrolled(window.scrollY > 20)
    window.addEventListener('scroll', handleScroll)
    return () => window.removeEventListener('scroll', handleScroll)
  }, [])

  const handleLogout = () => {
    logout()
    navigate('/login')
  }

  const navLinks = [
    { to: '/marketplace', label: 'Bozor', icon: Store, always: true },
    { to: '/dashboard', label: 'Portfolio', icon: LayoutDashboard, roles: ['INVESTOR'] },
    { to: '/beekeeper', label: 'Asalxonalarim', icon: Leaf, roles: ['BEEKEEPER'] },
    { to: '/admin', label: 'Boshqaruv', icon: Shield, roles: ['ADMIN'] },
  ]

  const visibleLinks = navLinks.filter(
    (l) => l.always || (user && l.roles?.includes(user.role))
  )

  return (
    <div className="min-h-screen flex flex-col relative overflow-hidden">
      
      {/* Background */}
      <div className="honeycomb-bg" />
      <div className="fixed inset-0 z-[-1] pointer-events-none">
        <div className="glow-orb glow-orb-1" />
        <div className="glow-orb glow-orb-2" />
        <div className="glow-orb glow-orb-3" />
        <div className="grid-lines" />
        <div className="particles">
          {Array.from({ length: 15 }).map((_, i) => <div key={i} className="particle" />)}
        </div>
      </div>

      {/* NAVBAR */}
      <nav className={`fixed top-0 w-full z-50 transition-all duration-500 ${scrolled ? 'py-3 bg-[#050507]/80 backdrop-blur-2xl border-b border-white/5 shadow-2xl' : 'py-5 bg-transparent'}`}>
        <div className="max-w-[1400px] mx-auto px-6 md:px-12 flex items-center justify-between">
          
          {/* Logo */}
          <Link to="/" className="flex items-center gap-3 group">
            <div className="relative flex items-center justify-center">
              <Hexagon className="w-9 h-9 text-honey-500 fill-honey-500/20 group-hover:fill-honey-500/40 transition-colors duration-500" />
              <div className="absolute w-2 h-2 rounded-full bg-honey-400 shadow-[0_0_15px_rgba(255,207,51,1)] animate-pulse" />
            </div>
            <span className="font-display font-black text-2xl tracking-[0.15em] bg-gradient-to-r from-white via-white to-honey-300 bg-clip-text text-transparent group-hover:to-white transition-all duration-500">
              MELARIUM
            </span>
          </Link>

          {/* Center Links */}
          <div className="hidden md:flex items-center gap-2 p-1.5 rounded-2xl bg-white/[0.02] border border-white/5 backdrop-blur-md">
            {visibleLinks.map((l) => {
              const Icon = l.icon
              const active = location.pathname === l.to || (l.to !== '/marketplace' && location.pathname.startsWith(l.to))
              return (
                <Link
                  key={l.to}
                  to={l.to}
                  className={`flex items-center gap-2 px-5 py-2.5 rounded-xl text-sm font-semibold transition-all duration-300 ${
                    active 
                      ? 'bg-white/10 text-honey-400 shadow-[inset_0_0_0_1px_rgba(255,255,255,0.1)]' 
                      : 'text-white/60 hover:text-white hover:bg-white/5'
                  }`}
                >
                  <Icon className="w-4 h-4" />
                  {l.label}
                </Link>
              )
            })}
          </div>

          {/* Right Actions */}
          <div className="flex items-center gap-4">
            {user ? (
              <div className="flex items-center gap-5">
                <div className="hidden sm:flex flex-col items-end">
                  <span className="text-sm font-bold text-white">{user.fullName || user.phone}</span>
                  <span className="text-[10px] font-black uppercase tracking-widest text-honey-gradient">{user.role}</span>
                </div>
                <div className="w-px h-8 bg-white/10 hidden sm:block" />
                <button 
                  onClick={handleLogout}
                  className="p-2.5 rounded-full text-white/50 hover:text-red-400 hover:bg-red-400/10 transition-all duration-300"
                >
                  <LogOut className="w-5 h-5" />
                </button>
              </div>
            ) : (
              <Link to="/login" className="btn-premium">
                Kirish
              </Link>
            )}
          </div>
        </div>
      </nav>

      {/* PAGE CONTENT */}
      <main className="flex-1 relative z-10 pt-20">
        <Outlet />
      </main>

      {/* FOOTER */}
      <footer className="relative mt-24 py-16 border-t border-white/5 bg-[#020203] overflow-hidden">
        <div className="absolute top-0 left-1/2 -translate-x-1/2 w-[800px] h-[1px] bg-gradient-to-r from-transparent via-honey-500/30 to-transparent" />
        <div className="max-w-[1400px] mx-auto px-6 md:px-12 flex flex-col items-center gap-6 relative z-10">
          <div className="flex items-center gap-3 opacity-40">
            <Hexagon className="w-6 h-6" />
            <span className="font-display font-bold tracking-[0.15em]">MELARIUM</span>
          </div>
          <p className="text-sm text-white/40">
            © 2024 Melarium — Barqaror agro-investitsiyalar kelajagi.
          </p>
        </div>
      </footer>
    </div>
  )
}
