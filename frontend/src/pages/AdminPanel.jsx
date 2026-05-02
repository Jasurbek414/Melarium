import { useState } from 'react'
import { Routes, Route, Link, useLocation, Navigate } from 'react-router-dom'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { adminApi } from '../api/axios'
import toast from 'react-hot-toast'
import {
  LayoutDashboard, Users, Layers, DollarSign, Activity, Settings,
  CheckCircle, Ban, Search, ChevronDown, TrendingUp, ArrowUpRight,
  AlertTriangle, MoreVertical, Eye, Edit, Trash2, Filter, Download
} from 'lucide-react'

// ═══════════════════════════════════════════
//  ADMIN LAYOUT WITH SIDEBAR
// ═══════════════════════════════════════════
export default function AdminPanel() {
  const [sidebarCollapsed, setSidebarCollapsed] = useState(false)
  const location = useLocation()

  const navItems = [
    { to: '/admin', icon: LayoutDashboard, label: 'Dashboard', exact: true },
    { to: '/admin/users', icon: Users, label: 'Foydalanuvchilar' },
    { to: '/admin/colonies', icon: Layers, label: 'Koloniyalar' },
    { to: '/admin/transactions', icon: DollarSign, label: 'Tranzaksiyalar' },
    { to: '/admin/settings', icon: Settings, label: 'Sozlamalar' },
  ]

  return (
    <div className="flex min-h-[calc(100vh-80px)]">
      {/* SIDEBAR */}
      <aside className={`${sidebarCollapsed ? 'w-20' : 'w-64'} transition-all duration-300 border-r border-white/5 bg-[#080809] flex flex-col`}>
        <div className="p-4 border-b border-white/5 flex items-center justify-between">
          {!sidebarCollapsed && <span className="text-sm font-bold text-honey-500 tracking-wider">ADMIN</span>}
          <button onClick={() => setSidebarCollapsed(!sidebarCollapsed)} className="p-2 rounded-lg hover:bg-white/5 text-white/40 hover:text-white transition-colors">
            <ChevronDown className={`w-4 h-4 transition-transform ${sidebarCollapsed ? '-rotate-90' : 'rotate-90'}`} />
          </button>
        </div>

        <nav className="flex-1 p-3 space-y-1">
          {navItems.map(item => {
            const isActive = item.exact ? location.pathname === item.to : location.pathname.startsWith(item.to) && item.to !== '/admin'
            const Icon = item.icon
            return (
              <Link
                key={item.to}
                to={item.to}
                className={`flex items-center gap-3 px-4 py-3 rounded-xl text-sm font-semibold transition-all duration-200 ${
                  isActive
                    ? 'bg-honey-500/10 text-honey-400 border border-honey-500/20'
                    : 'text-white/40 hover:text-white hover:bg-white/5 border border-transparent'
                }`}
              >
                <Icon className="w-5 h-5 flex-shrink-0" />
                {!sidebarCollapsed && <span>{item.label}</span>}
              </Link>
            )
          })}
        </nav>
      </aside>

      {/* MAIN CONTENT */}
      <main className="flex-1 p-8 overflow-y-auto">
        <Routes>
          <Route index element={<AdminDashboard />} />
          <Route path="users" element={<AdminUsers />} />
          <Route path="colonies" element={<AdminColonies />} />
          <Route path="transactions" element={<AdminTransactions />} />
          <Route path="settings" element={<AdminSettings />} />
        </Routes>
      </main>
    </div>
  )
}

// ═══════════════════════════════════════════
//  DASHBOARD
// ═══════════════════════════════════════════
function AdminDashboard() {
  const { data: stats } = useQuery({
    queryKey: ['admin-stats'],
    queryFn: async () => { const { data } = await adminApi.getStats(); return data },
    refetchInterval: 30_000,
  })

  const statCards = [
    { label: 'Jami foydalanuvchilar', value: stats?.totalUsers ?? '—', icon: Users, change: '+12%', color: 'text-blue-400', bg: 'bg-blue-500/10' },
    { label: 'Investorlar', value: stats?.totalInvestors ?? '—', icon: TrendingUp, change: '+8%', color: 'text-emerald-400', bg: 'bg-emerald-500/10' },
    { label: 'Faol koloniyalar', value: stats?.activeColonies ?? '—', icon: Layers, change: '+5%', color: 'text-honey-400', bg: 'bg-honey-500/10' },
    { label: 'Platforma hajmi', value: `$${stats?.totalInvestmentsUsd ?? 0}`, icon: DollarSign, change: '+18%', color: 'text-purple-400', bg: 'bg-purple-500/10' },
  ]

  return (
    <div>
      <div className="mb-8">
        <h1 className="font-display text-3xl font-black">Dashboard</h1>
        <p className="text-white/40 text-sm mt-1">Platforma umumiy ko'rinishi</p>
      </div>

      {/* Stats Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-5 mb-8">
        {statCards.map((s, i) => (
          <div key={i} className="glass-panel rounded-2xl p-6 hover:border-white/10 transition-all duration-300">
            <div className="flex items-center justify-between mb-4">
              <div className={`w-10 h-10 rounded-xl ${s.bg} flex items-center justify-center`}>
                <s.icon className={`w-5 h-5 ${s.color}`} />
              </div>
              <span className="text-xs font-bold text-emerald-400 flex items-center gap-1">
                <ArrowUpRight className="w-3 h-3" /> {s.change}
              </span>
            </div>
            <div className="font-display text-2xl font-bold mb-1">{s.value}</div>
            <p className="text-xs text-white/30 font-semibold">{s.label}</p>
          </div>
        ))}
      </div>

      {/* Activity & Quick Actions */}
      <div className="grid lg:grid-cols-3 gap-6">
        <div className="lg:col-span-2 glass-panel rounded-2xl p-6">
          <h3 className="font-display text-lg font-bold mb-4">So'nggi faoliyat</h3>
          <div className="space-y-3">
            {[
              { text: 'Yangi investor ro\'yxatdan o\'tdi', time: '2 daqiqa oldin', type: 'user' },
              { text: 'Bo\'stonliq koloniyasi tasdiqlandi', time: '15 daqiqa oldin', type: 'colony' },
              { text: '3,500,000 UZS investitsiya kiritildi', time: '1 soat oldin', type: 'money' },
              { text: 'Samarqand koloniyasi asal hisoboti', time: '3 soat oldin', type: 'report' },
              { text: 'Yangi asalarichi qo\'shildi', time: '5 soat oldin', type: 'user' },
            ].map((a, i) => (
              <div key={i} className="flex items-center gap-4 p-3 rounded-xl hover:bg-white/[0.02] transition-colors">
                <div className={`w-2 h-2 rounded-full flex-shrink-0 ${a.type === 'user' ? 'bg-blue-400' : a.type === 'colony' ? 'bg-emerald-400' : a.type === 'money' ? 'bg-honey-400' : 'bg-purple-400'}`} />
                <span className="text-sm flex-1">{a.text}</span>
                <span className="text-xs text-white/30">{a.time}</span>
              </div>
            ))}
          </div>
        </div>

        <div className="glass-panel rounded-2xl p-6">
          <h3 className="font-display text-lg font-bold mb-4">Tezkor harakatlar</h3>
          <div className="space-y-3">
            {[
              { label: 'Koloniyani tasdiqlash', icon: CheckCircle, color: 'text-emerald-400' },
              { label: 'Foydalanuvchini bloklash', icon: Ban, color: 'text-red-400' },
              { label: 'Hisobot yaratish', icon: Download, color: 'text-blue-400' },
              { label: 'Tizim sozlamalari', icon: Settings, color: 'text-white/40' },
            ].map((q, i) => (
              <button key={i} className="w-full flex items-center gap-3 p-3 rounded-xl hover:bg-white/5 transition-colors text-left">
                <q.icon className={`w-5 h-5 ${q.color}`} />
                <span className="text-sm font-medium">{q.label}</span>
              </button>
            ))}
          </div>
        </div>
      </div>
    </div>
  )
}

// ═══════════════════════════════════════════
//  USERS MANAGEMENT
// ═══════════════════════════════════════════
function AdminUsers() {
  const qc = useQueryClient()
  const [search, setSearch] = useState('')
  const [roleFilter, setRoleFilter] = useState('')

  const { data: usersData, isLoading } = useQuery({
    queryKey: ['admin-users'],
    queryFn: async () => { const { data } = await adminApi.getUsers({ page: 0, size: 50 }); return data },
  })

  const toggleMutation = useMutation({
    mutationFn: (id) => adminApi.toggleActive(id),
    onSuccess: () => { toast.success('Holat yangilandi'); qc.invalidateQueries(['admin-users']) },
  })

  const roleMutation = useMutation({
    mutationFn: ({ id, role }) => adminApi.changeRole(id, role),
    onSuccess: () => { toast.success('Rol yangilandi'); qc.invalidateQueries(['admin-users']) },
  })

  const users = (usersData?.content || []).filter(u => {
    const matchSearch = !search || u.phone?.includes(search) || u.fullName?.toLowerCase().includes(search.toLowerCase())
    const matchRole = !roleFilter || u.role === roleFilter
    return matchSearch && matchRole
  })

  return (
    <div>
      <div className="flex items-center justify-between mb-8">
        <div>
          <h1 className="font-display text-3xl font-black">Foydalanuvchilar</h1>
          <p className="text-white/40 text-sm mt-1">Barcha foydalanuvchilarni boshqarish</p>
        </div>
        <span className="text-sm text-white/30">{users.length} foydalanuvchi</span>
      </div>

      {/* Filters */}
      <div className="flex flex-wrap gap-3 mb-6">
        <div className="relative flex-1 min-w-[200px] max-w-md">
          <Search className="absolute left-4 top-1/2 -translate-y-1/2 w-4 h-4 text-white/30" />
          <input
            type="text"
            value={search}
            onChange={e => setSearch(e.target.value)}
            placeholder="Qidirish..."
            className="w-full pl-11 pr-4 py-3 rounded-xl bg-white/[0.03] border border-white/[0.06] text-sm focus:border-honey-500/30 focus:outline-none transition-colors"
          />
        </div>
        <select
          value={roleFilter}
          onChange={e => setRoleFilter(e.target.value)}
          className="px-4 py-3 rounded-xl bg-white/[0.03] border border-white/[0.06] text-sm focus:border-honey-500/30 focus:outline-none transition-colors appearance-none cursor-pointer"
        >
          <option value="">Barcha rollar</option>
          <option value="INVESTOR">Investor</option>
          <option value="BEEKEEPER">Asalarichi</option>
          <option value="ADMIN">Admin</option>
        </select>
      </div>

      {/* Table */}
      <div className="glass-panel rounded-2xl overflow-hidden">
        <table className="w-full">
          <thead>
            <tr className="border-b border-white/5">
              <th className="text-left px-6 py-4 text-xs font-bold text-white/30 uppercase tracking-wider">Foydalanuvchi</th>
              <th className="text-left px-6 py-4 text-xs font-bold text-white/30 uppercase tracking-wider">Rol</th>
              <th className="text-left px-6 py-4 text-xs font-bold text-white/30 uppercase tracking-wider">Holat</th>
              <th className="text-right px-6 py-4 text-xs font-bold text-white/30 uppercase tracking-wider">Amallar</th>
            </tr>
          </thead>
          <tbody>
            {users.map(u => (
              <tr key={u.id} className="border-b border-white/[0.03] hover:bg-white/[0.02] transition-colors">
                <td className="px-6 py-4">
                  <div className="flex items-center gap-3">
                    <div className="w-9 h-9 rounded-full bg-gradient-to-br from-honey-500/20 to-honey-600/10 flex items-center justify-center text-xs font-bold text-honey-400">
                      {(u.fullName || u.phone || '?')[0].toUpperCase()}
                    </div>
                    <div>
                      <div className="text-sm font-semibold">{u.fullName || 'Noma\'lum'}</div>
                      <div className="text-xs text-white/30">{u.phone}</div>
                    </div>
                  </div>
                </td>
                <td className="px-6 py-4">
                  <select
                    value={u.role}
                    onChange={e => roleMutation.mutate({ id: u.id, role: e.target.value })}
                    className="px-3 py-1.5 rounded-lg bg-white/[0.03] border border-white/[0.06] text-xs font-semibold focus:outline-none cursor-pointer"
                  >
                    <option value="INVESTOR">Investor</option>
                    <option value="BEEKEEPER">Asalarichi</option>
                    <option value="ADMIN">Admin</option>
                  </select>
                </td>
                <td className="px-6 py-4">
                  <span className={`inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-bold ${u.isActive ? 'bg-emerald-500/10 text-emerald-400' : 'bg-red-500/10 text-red-400'}`}>
                    <span className={`w-1.5 h-1.5 rounded-full ${u.isActive ? 'bg-emerald-400' : 'bg-red-400'}`} />
                    {u.isActive ? 'Faol' : 'Bloklangan'}
                  </span>
                </td>
                <td className="px-6 py-4 text-right">
                  <button
                    onClick={() => toggleMutation.mutate(u.id)}
                    className={`px-4 py-2 rounded-lg text-xs font-semibold transition-all ${
                      u.isActive
                        ? 'bg-red-500/10 text-red-400 hover:bg-red-500/20'
                        : 'bg-emerald-500/10 text-emerald-400 hover:bg-emerald-500/20'
                    }`}
                  >
                    {u.isActive ? 'Bloklash' : 'Aktivlashtirish'}
                  </button>
                </td>
              </tr>
            ))}
            {users.length === 0 && (
              <tr><td colSpan={4} className="px-6 py-12 text-center text-white/20 text-sm">Ma'lumot topilmadi</td></tr>
            )}
          </tbody>
        </table>
      </div>
    </div>
  )
}

// ═══════════════════════════════════════════
//  COLONIES MANAGEMENT
// ═══════════════════════════════════════════
function AdminColonies() {
  const qc = useQueryClient()

  const { data: coloniesData } = useQuery({
    queryKey: ['admin-colonies'],
    queryFn: async () => { const { data } = await adminApi.getColonies({ page: 0, size: 50 }); return data },
  })

  const verifyMutation = useMutation({
    mutationFn: (id) => adminApi.verifyColony(id),
    onSuccess: () => { toast.success('Koloniya tasdiqlandi!'); qc.invalidateQueries(['admin-colonies']) },
  })

  const colonies = coloniesData?.content || []

  return (
    <div>
      <div className="flex items-center justify-between mb-8">
        <div>
          <h1 className="font-display text-3xl font-black">Koloniyalar</h1>
          <p className="text-white/40 text-sm mt-1">Koloniyalarni tekshirish va tasdiqlash</p>
        </div>
        <span className="text-sm text-white/30">{colonies.length} koloniya</span>
      </div>

      <div className="grid gap-4">
        {colonies.map(c => (
          <div key={c.id} className="glass-panel rounded-2xl p-6 hover:border-white/10 transition-all duration-300">
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-4">
                <div className="w-12 h-12 rounded-xl bg-gradient-to-br from-honey-500/20 to-honey-600/10 flex items-center justify-center text-lg">
                  🐝
                </div>
                <div>
                  <h3 className="font-semibold text-base">{c.name}</h3>
                  <p className="text-xs text-white/30">{c.location}</p>
                </div>
              </div>

              <div className="flex items-center gap-4">
                <span className={`inline-flex items-center gap-1.5 px-3 py-1.5 rounded-full text-xs font-bold ${c.isVerified ? 'bg-emerald-500/10 text-emerald-400' : 'bg-amber-500/10 text-amber-400'}`}>
                  {c.isVerified ? '✓ Tasdiqlangan' : '⏳ Kutilmoqda'}
                </span>

                {!c.isVerified && (
                  <button
                    onClick={() => verifyMutation.mutate(c.id)}
                    disabled={verifyMutation.isPending}
                    className="px-5 py-2 rounded-xl bg-emerald-500/10 text-emerald-400 text-xs font-bold hover:bg-emerald-500/20 transition-colors"
                  >
                    <CheckCircle className="w-4 h-4 inline mr-1" /> Tasdiqlash
                  </button>
                )}
              </div>
            </div>
          </div>
        ))}

        {colonies.length === 0 && (
          <div className="glass-panel rounded-2xl p-12 text-center text-white/20 text-sm">
            Hozircha koloniya yo'q
          </div>
        )}
      </div>
    </div>
  )
}

// ═══════════════════════════════════════════
//  TRANSACTIONS
// ═══════════════════════════════════════════
function AdminTransactions() {
  const { data: txData } = useQuery({
    queryKey: ['admin-transactions'],
    queryFn: async () => { const { data } = await adminApi.getTransactions({ page: 0, size: 50 }); return data },
  })

  const transactions = txData?.content || []

  return (
    <div>
      <div className="flex items-center justify-between mb-8">
        <div>
          <h1 className="font-display text-3xl font-black">Tranzaksiyalar</h1>
          <p className="text-white/40 text-sm mt-1">Barcha moliyaviy operatsiyalar</p>
        </div>
      </div>

      <div className="glass-panel rounded-2xl overflow-hidden">
        <table className="w-full">
          <thead>
            <tr className="border-b border-white/5">
              <th className="text-left px-6 py-4 text-xs font-bold text-white/30 uppercase tracking-wider">ID</th>
              <th className="text-left px-6 py-4 text-xs font-bold text-white/30 uppercase tracking-wider">Investor</th>
              <th className="text-left px-6 py-4 text-xs font-bold text-white/30 uppercase tracking-wider">Koloniya</th>
              <th className="text-left px-6 py-4 text-xs font-bold text-white/30 uppercase tracking-wider">Summa</th>
              <th className="text-left px-6 py-4 text-xs font-bold text-white/30 uppercase tracking-wider">Sana</th>
            </tr>
          </thead>
          <tbody>
            {transactions.map((t, i) => (
              <tr key={t.id || i} className="border-b border-white/[0.03] hover:bg-white/[0.02] transition-colors">
                <td className="px-6 py-4 text-xs text-white/30 font-mono">#{t.id}</td>
                <td className="px-6 py-4 text-sm">{t.investorName || t.investorPhone || '—'}</td>
                <td className="px-6 py-4 text-sm text-white/60">{t.colonyName || '—'}</td>
                <td className="px-6 py-4 text-sm font-bold text-honey-400">{t.amount ? `${t.amount.toLocaleString()} UZS` : '—'}</td>
                <td className="px-6 py-4 text-xs text-white/30">{t.createdAt ? new Date(t.createdAt).toLocaleDateString('uz') : '—'}</td>
              </tr>
            ))}
            {transactions.length === 0 && (
              <tr><td colSpan={5} className="px-6 py-12 text-center text-white/20 text-sm">Hozircha tranzaksiya yo'q</td></tr>
            )}
          </tbody>
        </table>
      </div>
    </div>
  )
}

// ═══════════════════════════════════════════
//  SETTINGS
// ═══════════════════════════════════════════
function AdminSettings() {
  return (
    <div>
      <div className="mb-8">
        <h1 className="font-display text-3xl font-black">Sozlamalar</h1>
        <p className="text-white/40 text-sm mt-1">Tizim konfiguratsiyasi</p>
      </div>

      <div className="grid lg:grid-cols-2 gap-6">
        <div className="glass-panel rounded-2xl p-6">
          <h3 className="font-display text-lg font-bold mb-6">Umumiy</h3>
          <div className="space-y-5">
            <div>
              <label className="block text-xs text-white/40 font-semibold mb-2">Platforma nomi</label>
              <input type="text" defaultValue="Melarium" className="w-full px-4 py-3 rounded-xl bg-white/[0.03] border border-white/[0.06] text-sm focus:border-honey-500/30 focus:outline-none" />
            </div>
            <div>
              <label className="block text-xs text-white/40 font-semibold mb-2">Aloqa email</label>
              <input type="email" defaultValue="admin@melarium.uz" className="w-full px-4 py-3 rounded-xl bg-white/[0.03] border border-white/[0.06] text-sm focus:border-honey-500/30 focus:outline-none" />
            </div>
            <div>
              <label className="block text-xs text-white/40 font-semibold mb-2">Minimal investitsiya (UZS)</label>
              <input type="number" defaultValue="100000" className="w-full px-4 py-3 rounded-xl bg-white/[0.03] border border-white/[0.06] text-sm focus:border-honey-500/30 focus:outline-none" />
            </div>
          </div>
        </div>

        <div className="glass-panel rounded-2xl p-6">
          <h3 className="font-display text-lg font-bold mb-6">Xavfsizlik</h3>
          <div className="space-y-4">
            {[
              { label: 'Ikki bosqichli autentifikatsiya', desc: 'Admin login uchun 2FA', enabled: true },
              { label: 'IP cheklash', desc: 'Faqat ruxsat berilgan IP lar', enabled: false },
              { label: 'Audit log', desc: 'Barcha o\'zgarishlarni qayd qilish', enabled: true },
            ].map((s, i) => (
              <div key={i} className="flex items-center justify-between p-4 rounded-xl bg-white/[0.02]">
                <div>
                  <div className="text-sm font-semibold">{s.label}</div>
                  <div className="text-xs text-white/30">{s.desc}</div>
                </div>
                <div className={`w-11 h-6 rounded-full relative cursor-pointer transition-colors ${s.enabled ? 'bg-honey-500' : 'bg-white/10'}`}>
                  <div className={`absolute top-0.5 w-5 h-5 rounded-full bg-white shadow transition-all ${s.enabled ? 'left-[22px]' : 'left-0.5'}`} />
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  )
}
