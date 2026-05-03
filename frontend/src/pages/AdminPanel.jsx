import { useState, useRef, useEffect } from 'react'
import { Routes, Route, Link, useLocation, Navigate } from 'react-router-dom'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { adminApi, reportApi } from '../api/axios'
import toast from 'react-hot-toast'
import {
  LayoutDashboard, Users, Layers, DollarSign, Activity, Settings,
  CheckCircle, Ban, Search, ChevronDown, TrendingUp, ArrowUpRight,
  AlertTriangle, MoreVertical, Eye, Edit, Trash2, Filter, Download, Check
} from 'lucide-react'

// Custom dark dropdown component
function CustomSelect({ value, onChange, options, small }) {
  const [open, setOpen] = useState(false)
  const ref = useRef(null)
  useEffect(() => {
    const h = (e) => { if (ref.current && !ref.current.contains(e.target)) setOpen(false) }
    document.addEventListener('mousedown', h)
    return () => document.removeEventListener('mousedown', h)
  }, [])
  const current = options.find(o => o.value === value)
  return (
    <div className="relative" ref={ref}>
      <button
        onClick={() => setOpen(!open)}
        className={`flex items-center justify-between gap-2 rounded-xl bg-white/[0.04] border border-white/[0.08] hover:border-white/15 text-white transition-all ${small ? 'px-3 py-1.5 text-xs min-w-[120px]' : 'px-4 py-3 text-sm min-w-[180px]'}`}
      >
        <span className="font-semibold">{current?.label}</span>
        <ChevronDown className={`w-3.5 h-3.5 text-white/40 transition-transform ${open ? 'rotate-180' : ''}`} />
      </button>
      {open && (
        <div className={`absolute top-[calc(100%+6px)] left-0 min-w-full bg-[#111116] border border-white/10 rounded-xl p-1.5 shadow-[0_15px_40px_rgba(0,0,0,0.7)] z-50 ${small ? 'text-xs' : 'text-sm'}`}>
          {options.map(o => (
            <button
              key={o.value}
              onClick={() => { onChange(o.value); setOpen(false) }}
              className={`w-full text-left px-3 py-2 rounded-lg flex items-center justify-between transition-all ${value === o.value ? 'bg-honey-500/10 text-honey-400 font-semibold' : 'text-white/70 hover:bg-white/5 hover:text-white'}`}
            >
              {o.label}
              {value === o.value && <Check className="w-3.5 h-3.5" />}
            </button>
          ))}
        </div>
      )}
    </div>
  )
}

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
    { to: '/admin/transactions', icon: DollarSign, label: 'Moliya & To\'lovlar' },
    { to: '/admin/topups', icon: CheckCircle, label: 'Balans So\'rovlari' },
    { to: '/admin/reports', icon: Activity, label: 'Hisobotlar' },
    { to: '/admin/settings', icon: Settings, label: 'Sozlamalar' },
  ]

  return (
    <div className="min-h-[calc(100vh-80px)]">
      {/* SIDEBAR — fixed, no scroll */}
      <aside className={`fixed top-[80px] left-0 bottom-0 ${sidebarCollapsed ? 'w-20' : 'w-64'} transition-all duration-300 border-r border-white/5 bg-[#080809]/95 backdrop-blur-xl flex flex-col z-40 overflow-hidden`}>
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

      {/* MAIN CONTENT — offset by sidebar width */}
      <main className={`${sidebarCollapsed ? 'ml-20' : 'ml-64'} transition-all duration-300 p-8`}>
        <Routes>
          <Route index element={<AdminDashboard />} />
          <Route path="users" element={<AdminUsers />} />
          <Route path="colonies" element={<AdminColonies />} />
          <Route path="transactions" element={<AdminTransactions />} />
          <Route path="topups" element={<AdminTopUps />} />
          <Route path="reports" element={<AdminReports />} />
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
  const [balModal, setBalModal] = useState(null)
  const [balAmt, setBalAmt] = useState('')

  const { data: usersData } = useQuery({
    queryKey: ['admin-users'],
    queryFn: async () => { const { data } = await adminApi.getUsers({ page: 0, size: 50 }); return data },
  })
  const toggleMut = useMutation({ mutationFn: (id) => adminApi.toggleActive(id), onSuccess: () => { toast.success('Yangilandi'); qc.invalidateQueries(['admin-users']) } })
  const roleMut = useMutation({ mutationFn: ({ id, role }) => adminApi.changeRole(id, role), onSuccess: () => { toast.success('Rol yangilandi'); qc.invalidateQueries(['admin-users']) } })
  const verifyMut = useMutation({ mutationFn: (id) => adminApi.verifyUser(id), onSuccess: () => { toast.success('Tasdiqlandi'); qc.invalidateQueries(['admin-users']) } })
  const unverifyMut = useMutation({ mutationFn: (id) => adminApi.unverifyUser(id), onSuccess: () => { toast.success('Bekor qilindi'); qc.invalidateQueries(['admin-users']) } })
  const balMut = useMutation({
    mutationFn: ({ id, amount }) => adminApi.addBalance(id, amount, "Admin to'ldirdi"),
    onSuccess: () => { toast.success("Balans to'ldirildi"); qc.invalidateQueries(['admin-users']); setBalModal(null); setBalAmt('') },
    onError: (e) => toast.error(e.response?.data?.message || 'Xatolik'),
  })

  const users = (usersData?.content || []).filter(u => {
    const ms = !search || u.phone?.includes(search) || u.fullName?.toLowerCase().includes(search.toLowerCase())
    return ms && (!roleFilter || u.role === roleFilter)
  })

  return (
    <div>
      <div className="flex items-center justify-between mb-8">
        <div><h1 className="font-display text-3xl font-black">Foydalanuvchilar</h1><p className="text-white/40 text-sm mt-1">Barcha foydalanuvchilarni boshqarish</p></div>
        <span className="text-sm text-white/30">{users.length} foydalanuvchi</span>
      </div>
      <div className="flex flex-wrap gap-3 mb-6">
        <div className="relative flex-1 min-w-[200px] max-w-md">
          <Search className="absolute left-4 top-1/2 -translate-y-1/2 w-4 h-4 text-white/30" />
          <input type="text" value={search} onChange={e => setSearch(e.target.value)} placeholder="Qidirish..." className="w-full pl-11 pr-4 py-3 rounded-xl bg-white/[0.03] border border-white/[0.06] text-sm focus:border-honey-500/30 focus:outline-none transition-colors" />
        </div>
        <CustomSelect value={roleFilter} onChange={setRoleFilter} options={[{ value: '', label: 'Barcha rollar' },{ value: 'INVESTOR', label: 'Investor' },{ value: 'BEEKEEPER', label: 'Asalarichi' },{ value: 'ADMIN', label: 'Admin' }]} />
      </div>
      <div className="glass-panel rounded-2xl">
        <table className="w-full">
          <thead><tr className="border-b border-white/5">
            <th className="text-left px-6 py-4 text-xs font-bold text-white/30 uppercase tracking-wider">Foydalanuvchi</th>
            <th className="text-left px-6 py-4 text-xs font-bold text-white/30 uppercase tracking-wider">Rol</th>
            <th className="text-left px-6 py-4 text-xs font-bold text-white/30 uppercase tracking-wider">Balans</th>
            <th className="text-left px-6 py-4 text-xs font-bold text-white/30 uppercase tracking-wider">Holat</th>
            <th className="text-right px-6 py-4 text-xs font-bold text-white/30 uppercase tracking-wider">Amallar</th>
          </tr></thead>
          <tbody>
            {users.map(u => (
              <tr key={u.id} className="border-b border-white/[0.03] hover:bg-white/[0.02] transition-colors">
                <td className="px-6 py-4"><div className="flex items-center gap-3">
                  <div className="w-9 h-9 rounded-full bg-gradient-to-br from-honey-500/20 to-honey-600/10 flex items-center justify-center text-xs font-bold text-honey-400">{(u.fullName||u.phone||'?')[0].toUpperCase()}</div>
                  <div><div className="text-sm font-semibold flex items-center gap-2">{u.fullName||'Noma\'lum'}{u.isVerified&&<CheckCircle className="w-3.5 h-3.5 text-emerald-400"/>}</div><div className="text-xs text-white/30">{u.phone}</div></div>
                </div></td>
                <td className="px-6 py-4"><CustomSelect value={u.role} onChange={(role)=>roleMut.mutate({id:u.id,role})} options={[{value:'INVESTOR',label:'Investor'},{value:'BEEKEEPER',label:'Asalarichi'},{value:'ADMIN',label:'Admin'}]} small/></td>
                <td className="px-6 py-4"><div className="text-sm font-bold text-honey-400">{Number(u.balance||0).toLocaleString()} UZS</div><button onClick={()=>setBalModal(u)} className="text-xs text-blue-400 hover:underline mt-0.5">+ To'ldirish</button></td>
                <td className="px-6 py-4"><span className={`inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-bold ${u.isActive?'bg-emerald-500/10 text-emerald-400':'bg-red-500/10 text-red-400'}`}><span className={`w-1.5 h-1.5 rounded-full ${u.isActive?'bg-emerald-400':'bg-red-400'}`}/>{u.isActive?'Faol':'Bloklangan'}</span></td>
                <td className="px-6 py-4 text-right"><div className="flex items-center justify-end gap-2">
                  <button onClick={()=>u.isVerified?unverifyMut.mutate(u.id):verifyMut.mutate(u.id)} className={`px-3 py-1.5 rounded-lg text-xs font-semibold ${u.isVerified?'bg-amber-500/10 text-amber-400 hover:bg-amber-500/20':'bg-emerald-500/10 text-emerald-400 hover:bg-emerald-500/20'}`}>{u.isVerified?'Bekor':'Tasdiqlash'}</button>
                  <button onClick={()=>toggleMut.mutate(u.id)} className={`px-3 py-1.5 rounded-lg text-xs font-semibold ${u.isActive?'bg-red-500/10 text-red-400 hover:bg-red-500/20':'bg-emerald-500/10 text-emerald-400 hover:bg-emerald-500/20'}`}>{u.isActive?'Bloklash':'Aktiv'}</button>
                </div></td>
              </tr>
            ))}
            {users.length===0&&(<tr><td colSpan={5} className="px-6 py-12 text-center text-white/20 text-sm">Ma'lumot topilmadi</td></tr>)}
          </tbody>
        </table>
      </div>
      {balModal&&(<div className="fixed inset-0 bg-black/60 backdrop-blur-sm flex items-center justify-center z-50" onClick={()=>setBalModal(null)}>
        <div className="bg-[#111116] border border-white/10 rounded-2xl p-6 w-full max-w-md shadow-2xl" onClick={e=>e.stopPropagation()}>
          <h3 className="font-display text-xl font-bold mb-1">Balansni to'ldirish</h3>
          <p className="text-sm text-white/40 mb-5">{balModal.fullName||balModal.phone}</p>
          <input type="number" value={balAmt} onChange={e=>setBalAmt(e.target.value)} placeholder="Summa (UZS)" className="w-full px-4 py-3 rounded-xl bg-white/[0.03] border border-white/[0.06] text-sm mb-5 focus:border-honey-500/30 focus:outline-none"/>
          <div className="flex gap-3">
            <button onClick={()=>setBalModal(null)} className="flex-1 px-4 py-3 rounded-xl bg-white/5 text-sm font-semibold hover:bg-white/10">Bekor</button>
            <button onClick={()=>{if(Number(balAmt)>0)balMut.mutate({id:balModal.id,amount:Number(balAmt)})}} disabled={balMut.isPending} className="flex-1 px-4 py-3 rounded-xl bg-honey-500/20 text-honey-400 text-sm font-bold hover:bg-honey-500/30 disabled:opacity-50">{balMut.isPending?'...':'To\'ldirish'}</button>
          </div>
        </div>
      </div>)}
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
          <h1 className="font-display text-3xl font-black">Moliya & To'lovlar</h1>
          <p className="text-white/40 text-sm mt-1">Platformadagi barcha moliyaviy operatsiyalar va balans o'zgarishlari</p>
        </div>
        <span className="text-sm text-white/30">{transactions.length} ta operatsiya</span>
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
//  REPORTS
// ═══════════════════════════════════════════
function AdminReports() {
  const qc = useQueryClient()

  const { data: reportsData } = useQuery({
    queryKey: ['admin-reports'],
    queryFn: async () => { const { data } = await adminApi.getReports({ page: 0, size: 50 }); return data },
  })

  const finalizeMut = useMutation({
    mutationFn: (id) => reportApi.finalize(id),
    onSuccess: () => { toast.success('Hisobot tasdiqlandi va foyda taqsimlandi!'); qc.invalidateQueries(['admin-reports']) },
    onError: (e) => toast.error(e.response?.data?.message || 'Xatolik yuz berdi'),
  })

  const reports = reportsData?.content || []

  return (
    <div>
      <div className="flex items-center justify-between mb-8">
        <div>
          <h1 className="font-display text-3xl font-black">Asal Hisobotlari</h1>
          <p className="text-white/40 text-sm mt-1">Asalarichilar tomonidan yuborilgan hisobotlarni tasdiqlash</p>
        </div>
        <span className="text-sm text-white/30">{reports.length} ta hisobot</span>
      </div>

      <div className="grid gap-4">
        {reports.map(r => (
          <div key={r.id} className="glass-panel rounded-2xl p-6 relative overflow-hidden">
            {r.isFinalized && <div className="absolute top-0 right-0 w-16 h-16 bg-emerald-500/10 rounded-bl-[100px] z-0" />}
            <div className="relative z-10 flex flex-col md:flex-row md:items-center justify-between gap-6">
              
              <div className="flex-1">
                <div className="flex items-center gap-3 mb-2">
                  <h3 className="font-display text-xl font-bold">Asal yig'imi #{r.id}</h3>
                  <span className={`px-2.5 py-1 rounded-lg text-xs font-bold ${r.isFinalized ? 'bg-emerald-500/10 text-emerald-400' : 'bg-amber-500/10 text-amber-400'}`}>
                    {r.isFinalized ? 'Tasdiqlangan' : 'Kutilmoqda'}
                  </span>
                </div>
                <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mt-4">
                  <div>
                    <div className="text-xs text-white/40 mb-1">Koloniya ID</div>
                    <div className="font-semibold">{r.colony?.name || r.colony?.id || '—'}</div>
                  </div>
                  <div>
                    <div className="text-xs text-white/40 mb-1">Davr</div>
                    <div className="font-semibold">{r.periodStart} - {r.periodEnd}</div>
                  </div>
                  <div>
                    <div className="text-xs text-white/40 mb-1">Hajm (KG)</div>
                    <div className="font-bold text-amber-400">{r.honeyVolumeKg} KG</div>
                  </div>
                  <div>
                    <div className="text-xs text-white/40 mb-1">Xarajatlar</div>
                    <div className="font-bold text-red-400">${r.expensesUsd}</div>
                  </div>
                </div>
                {r.notes && (
                  <div className="mt-4 p-3 rounded-xl bg-white/[0.02] text-sm text-white/60 italic border border-white/[0.05]">
                    "{r.notes}"
                  </div>
                )}
              </div>

              <div className="flex md:flex-col items-center justify-end gap-3 min-w-[140px]">
                {!r.isFinalized ? (
                  <button 
                    onClick={() => finalizeMut.mutate(r.id)}
                    disabled={finalizeMut.isPending}
                    className="w-full py-3 px-5 rounded-xl bg-emerald-500/10 text-emerald-400 font-bold hover:bg-emerald-500/20 transition-colors disabled:opacity-50 flex items-center justify-center gap-2"
                  >
                    <CheckCircle className="w-4 h-4" /> 
                    {finalizeMut.isPending ? 'Kuting...' : 'Tasdiqlash'}
                  </button>
                ) : (
                  <div className="text-emerald-400 text-sm font-bold flex items-center gap-2 px-4 py-2">
                    <CheckCircle className="w-5 h-5" /> Foyda taqsimlandi
                  </div>
                )}
              </div>

            </div>
          </div>
        ))}
        {reports.length === 0 && (
          <div className="glass-panel rounded-2xl p-12 text-center text-white/20 text-sm">
            Hozircha hisobotlar yo'q
          </div>
        )}
      </div>
    </div>
  )
}

// ═══════════════════════════════════════════
//  SETTINGS
// ═══════════════════════════════════════════
function AdminSettings() {
  const [settings, setSettings] = useState({ investmentCommissionPct: '8.0', honeyCommissionPct: '12.0', colonyListingFee: '50000', minimumInvestment: '100000' })
  const [saving, setSaving] = useState(false)

  useEffect(() => {
    adminApi.getSettings().then(({ data }) => setSettings({ investmentCommissionPct: String(data.investmentCommissionPct), honeyCommissionPct: String(data.honeyCommissionPct), colonyListingFee: String(data.colonyListingFee), minimumInvestment: String(data.minimumInvestment) })).catch(() => {})
  }, [])

  const handleSave = async () => {
    setSaving(true)
    try { await adminApi.updateSettings(settings); toast.success("Sozlamalar saqlandi") } catch { toast.error("Xatolik") }
    setSaving(false)
  }

  const inp = "w-full px-4 py-3 rounded-xl bg-white/[0.03] border border-white/[0.06] text-sm focus:border-honey-500/30 focus:outline-none"

  return (
    <div>
      <div className="flex items-center justify-between mb-8">
        <div><h1 className="font-display text-3xl font-black">Sozlamalar</h1><p className="text-white/40 text-sm mt-1">Platforma komissiya va to'lov sozlamalari</p></div>
        <button onClick={handleSave} disabled={saving} className="px-6 py-3 rounded-xl bg-honey-500/20 text-honey-400 text-sm font-bold hover:bg-honey-500/30 disabled:opacity-50">{saving ? 'Saqlanmoqda...' : 'Saqlash'}</button>
      </div>
      <div className="grid lg:grid-cols-2 gap-6">
        <div className="glass-panel rounded-2xl p-6">
          <h3 className="font-display text-lg font-bold mb-6">Komissiya foizlari</h3>
          <div className="space-y-5">
            <div><label className="block text-xs text-white/40 font-semibold mb-2">Investitsiya komissiyasi (%)</label><input type="number" value={settings.investmentCommissionPct} onChange={e => setSettings(p => ({...p, investmentCommissionPct: e.target.value}))} className={inp} /></div>
            <div><label className="block text-xs text-white/40 font-semibold mb-2">Asal sotish komissiyasi (%)</label><input type="number" value={settings.honeyCommissionPct} onChange={e => setSettings(p => ({...p, honeyCommissionPct: e.target.value}))} className={inp} /></div>
          </div>
        </div>
        <div className="glass-panel rounded-2xl p-6">
          <h3 className="font-display text-lg font-bold mb-6">To'lov sozlamalari</h3>
          <div className="space-y-5">
            <div><label className="block text-xs text-white/40 font-semibold mb-2">Koloniya joylashtirish to'lovi (UZS)</label><input type="number" value={settings.colonyListingFee} onChange={e => setSettings(p => ({...p, colonyListingFee: e.target.value}))} className={inp} /></div>
            <div><label className="block text-xs text-white/40 font-semibold mb-2">Minimal investitsiya (UZS)</label><input type="number" value={settings.minimumInvestment} onChange={e => setSettings(p => ({...p, minimumInvestment: e.target.value}))} className={inp} /></div>
          </div>
        </div>
      </div>
    </div>
  )
}

// ═══════════════════════════════════════════
//  TOP-UP REQUESTS MANAGEMENT
// ═══════════════════════════════════════════
function AdminTopUps() {
  const qc = useQueryClient()
  const { data: topups, isLoading } = useQuery({
    queryKey: ['admin-topups'],
    queryFn: async () => {
      const { data } = await topupApi.getPending()
      return data
    },
  })

  const processMutation = useMutation({
    mutationFn: ({ id, action, comment }) => topupApi.process(id, { action, comment }),
    onSuccess: () => {
      toast.success('Amal bajarildi')
      qc.invalidateQueries(['admin-topups'])
      qc.invalidateQueries(['admin-users'])
    },
    onError: () => toast.error('Xatolik yuz berdi'),
  })

  return (
    <div>
      <div className="mb-8">
        <h1 className="font-display text-3xl font-black">Balans So'rovlari</h1>
        <p className="text-white/40 text-sm mt-1">Foydalanuvchilar tomonidan yuborilgan balansni to'ldirish so'rovlari</p>
      </div>

      <div className="grid gap-4">
        {topups?.map(t => (
          <div key={t.id} className="glass-panel rounded-2xl p-6 hover:border-white/10 transition-all duration-300">
            <div className="flex flex-col md:flex-row md:items-center justify-between gap-6">
              <div className="flex items-center gap-4">
                <div className="w-12 h-12 rounded-xl bg-honey-500/10 flex items-center justify-center text-xl">
                  💰
                </div>
                <div>
                  <h3 className="font-bold text-lg">{t.user?.fullName || t.user?.phone}</h3>
                  <p className="text-xs text-white/40">To'lov usuli: <span className="text-honey-400 font-bold">{t.paymentMethod}</span></p>
                </div>
              </div>

              <div className="text-center md:text-left">
                <div className="text-xs text-white/40 mb-1">Summa</div>
                <div className="text-xl font-black text-honey-400">{Number(t.amount).toLocaleString()} UZS</div>
              </div>

              <div className="flex gap-2">
                <button
                  onClick={() => processMutation.mutate({ id: t.id, action: 'REJECT' })}
                  className="px-4 py-2 rounded-xl bg-red-500/10 text-red-400 text-sm font-bold hover:bg-red-500/20 transition-all"
                >
                  Rad etish
                </button>
                <button
                  onClick={() => processMutation.mutate({ id: t.id, action: 'APPROVE' })}
                  className="px-4 py-2 rounded-xl bg-emerald-500/10 text-emerald-400 text-sm font-bold hover:bg-emerald-500/20 transition-all"
                >
                  Tasdiqlash
                </button>
              </div>
            </div>
          </div>
        ))}

        {(!topups || topups.length === 0) && !isLoading && (
          <div className="glass-panel rounded-2xl p-12 text-center text-white/20 text-sm">
            Hozircha yangi so'rovlar yo'q
          </div>
        )}
        
        {isLoading && <div className="text-center py-12 text-white/40">Yuklanmoqda...</div>}
      </div>
    </div>
  )
}
