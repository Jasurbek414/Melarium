import { Outlet, Link, useNavigate, useLocation } from 'react-router-dom'
import { useAuthStore } from '../store/authStore'
import { Home, LayoutDashboard, Leaf, Shield, LogOut, Menu, X } from 'lucide-react'
import { useState } from 'react'

export default function Layout() {
  const user = useAuthStore((s) => s.user)
  const logout = useAuthStore((s) => s.logout)
  const navigate = useNavigate()
  const location = useLocation()
  const [menuOpen, setMenuOpen] = useState(false)

  const handleLogout = () => {
    logout()
    navigate('/login')
  }

  const navLinks = [
    { to: '/', label: 'Marketplace', icon: Home, always: true },
    { to: '/dashboard', label: 'My Portfolio', icon: LayoutDashboard, roles: ['INVESTOR'] },
    { to: '/beekeeper', label: 'My Colonies', icon: Leaf, roles: ['BEEKEEPER'] },
    { to: '/admin', label: 'Admin Panel', icon: Shield, roles: ['ADMIN'] },
  ]

  const visibleLinks = navLinks.filter(
    (l) => l.always || (user && l.roles?.includes(user.role))
  )

  return (
    <div style={{ minHeight: '100vh', display: 'flex', flexDirection: 'column' }}>
      {/* NAVBAR */}
      <nav className="navbar">
        <div className="container navbar-inner">
          <Link to="/" className="logo">🍯 MELARIUM</Link>

          {/* Desktop Nav */}
          <div className="flex gap-2" style={{ display: 'flex', gap: '4px' }}>
            {visibleLinks.map((l) => {
              const Icon = l.icon
              const active = location.pathname === l.to
              return (
                <Link
                  key={l.to}
                  to={l.to}
                  className={`btn btn-ghost btn-sm ${active ? 'text-honey' : ''}`}
                  style={active ? { borderColor: 'rgba(245,158,11,0.4)', background: 'rgba(245,158,11,0.08)' } : {}}
                >
                  <Icon size={15} />
                  {l.label}
                </Link>
              )
            })}
          </div>

          {/* Right Side */}
          <div className="flex items-center gap-3">
            {user ? (
              <>
                <div style={{ textAlign: 'right', display: 'none' }}>
                  <div style={{ fontSize: '0.8rem', color: 'var(--text-secondary)' }}>{user.phone}</div>
                  <div style={{ fontSize: '0.75rem', color: 'var(--honey-500)' }}>{user.role}</div>
                </div>
                <span className={`badge badge-honey`}>{user.role}</span>
                <button className="btn btn-outline btn-sm" onClick={handleLogout}>
                  <LogOut size={14} />
                  Logout
                </button>
              </>
            ) : (
              <Link to="/login" className="btn btn-primary btn-sm">Sign In</Link>
            )}
          </div>
        </div>
      </nav>

      {/* PAGE CONTENT */}
      <main style={{ flex: 1 }}>
        <Outlet />
      </main>

      {/* FOOTER */}
      <footer style={{
        padding: '24px 0',
        borderTop: '1px solid rgba(255,255,255,0.06)',
        textAlign: 'center',
        color: 'var(--text-muted)',
        fontSize: '0.8rem',
      }}>
        © 2024 MELARIUM — Agro Investment Platform. All rights reserved.
      </footer>
    </div>
  )
}
