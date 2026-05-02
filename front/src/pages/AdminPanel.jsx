import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { adminApi } from '../api/axios'
import toast from 'react-hot-toast'
import { Users, Layers, DollarSign, Leaf, CheckCircle, Ban } from 'lucide-react'

export default function AdminPanel() {
  const qc = useQueryClient()

  const { data: stats } = useQuery({
    queryKey: ['admin-stats'],
    queryFn: async () => { const { data } = await adminApi.getStats(); return data },
    refetchInterval: 30_000,
  })

  const { data: usersData } = useQuery({
    queryKey: ['admin-users'],
    queryFn: async () => { const { data } = await adminApi.getUsers({ page: 0, size: 20 }); return data },
  })

  const { data: coloniesData } = useQuery({
    queryKey: ['admin-colonies'],
    queryFn: async () => { const { data } = await adminApi.getColonies({ page: 0, size: 20 }); return data },
  })

  const verifyMutation = useMutation({
    mutationFn: (id) => adminApi.verifyColony(id),
    onSuccess: () => { toast.success('Colony verified!'); qc.invalidateQueries(['admin-colonies']) },
  })

  const toggleMutation = useMutation({
    mutationFn: (id) => adminApi.toggleActive(id),
    onSuccess: () => { toast.success('User status updated'); qc.invalidateQueries(['admin-users']) },
  })

  const roleOptions = ['INVESTOR', 'BEEKEEPER', 'ADMIN']

  return (
    <div style={{ padding: '40px 0' }}>
      <div className="container">
        <h1 style={{ marginBottom: '6px' }}>Admin Panel</h1>
        <p style={{ color: 'var(--text-secondary)', marginBottom: '36px' }}>Platform overview and management</p>

        {/* STATS */}
        <div className="grid-4" style={{ marginBottom: '36px' }}>
          {[
            { label: 'Total Users',      value: stats?.totalUsers ?? '—',           icon: Users,      color: 'var(--honey-400)' },
            { label: 'Investors',        value: stats?.totalInvestors ?? '—',        icon: DollarSign, color: '#60a5fa' },
            { label: 'Active Colonies',  value: stats?.activeColonies ?? '—',        icon: Layers,     color: 'var(--success)' },
            { label: 'Platform Volume',  value: `$${stats?.totalInvestmentsUsd ?? 0}`, icon: DollarSign, color: 'var(--honey-500)' },
          ].map((s) => (
            <div className="stat-card" key={s.label}>
              <s.icon size={20} style={{ color: s.color, marginBottom: '8px' }} />
              <div className="stat-value" style={{ color: s.color }}>{s.value}</div>
              <div className="stat-label">{s.label}</div>
            </div>
          ))}
        </div>

        <div className="grid-2" style={{ gap: '28px', alignItems: 'start' }}>
          {/* USERS */}
          <div className="card" style={{ padding: 0, overflow: 'hidden' }}>
            <div style={{ padding: '18px 22px', borderBottom: '1px solid rgba(255,255,255,0.06)' }}>
              <h3 style={{ fontFamily: 'var(--font-body)', fontWeight: 600 }}>Users</h3>
            </div>
            <div className="table-wrap">
              <table>
                <thead>
                  <tr>
                    <th>Phone</th>
                    <th>Role</th>
                    <th>Status</th>
                    <th>Actions</th>
                  </tr>
                </thead>
                <tbody>
                  {(usersData?.content || []).map((u) => (
                    <tr key={u.id}>
                      <td style={{ fontSize: '0.85rem' }}>{u.phone}</td>
                      <td><span className="badge badge-honey">{u.role}</span></td>
                      <td>
                        <span className={`badge ${u.isActive ? 'badge-success' : 'badge-error'}`}>
                          {u.isActive ? 'Active' : 'Banned'}
                        </span>
                      </td>
                      <td>
                        <button
                          className={`btn btn-sm ${u.isActive ? 'btn-danger' : 'btn-ghost'}`}
                          onClick={() => toggleMutation.mutate(u.id)}
                          title={u.isActive ? 'Deactivate' : 'Activate'}
                        >
                          {u.isActive ? <Ban size={12} /> : <CheckCircle size={12} />}
                        </button>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>

          {/* COLONIES */}
          <div className="card" style={{ padding: 0, overflow: 'hidden' }}>
            <div style={{ padding: '18px 22px', borderBottom: '1px solid rgba(255,255,255,0.06)' }}>
              <h3 style={{ fontFamily: 'var(--font-body)', fontWeight: 600 }}>Colonies (Moderation)</h3>
            </div>
            <div className="table-wrap">
              <table>
                <thead>
                  <tr>
                    <th>Name</th>
                    <th>Location</th>
                    <th>Status</th>
                    <th>Verify</th>
                  </tr>
                </thead>
                <tbody>
                  {(coloniesData?.content || []).map((c) => (
                    <tr key={c.id}>
                      <td style={{ fontWeight: 600, fontSize: '0.85rem' }}>{c.name}</td>
                      <td style={{ fontSize: '0.8rem', color: 'var(--text-secondary)' }}>{c.location}</td>
                      <td>
                        <span className={`badge ${c.isVerified ? 'badge-success' : 'badge-neutral'}`}>
                          {c.isVerified ? '✓ Verified' : 'Pending'}
                        </span>
                      </td>
                      <td>
                        {!c.isVerified && (
                          <button
                            className="btn btn-primary btn-sm"
                            onClick={() => verifyMutation.mutate(c.id)}
                            disabled={verifyMutation.isPending}
                          >
                            <CheckCircle size={12} /> Approve
                          </button>
                        )}
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}
