import { useQuery } from '@tanstack/react-query'
import { investmentApi } from '../api/axios'
import { useAuthStore } from '../store/authStore'
import { TrendingUp, DollarSign, Layers, Clock } from 'lucide-react'

const STATUS_BADGE = {
  PENDING:   'badge-neutral',
  ACTIVE:    'badge-honey',
  COMPLETED: 'badge-success',
  CANCELLED: 'badge-error',
}

export default function InvestorDashboard() {
  const user = useAuthStore((s) => s.user)

  const { data, isLoading } = useQuery({
    queryKey: ['my-investments'],
    queryFn: async () => {
      const { data } = await investmentApi.getMyPortfolio({ page: 0, size: 50 })
      return data
    },
  })

  const investments = data?.content || []
  const totalInvested = investments.reduce((s, i) => s + parseFloat(i.totalInvested || 0), 0)
  const totalExpectedRoi = investments.reduce((s, i) => s + parseFloat(i.expectedRoi || 0), 0)
  const totalActualReturn = investments.reduce((s, i) => s + parseFloat(i.actualReturn || 0), 0)
  const activeCount = investments.filter((i) => i.status === 'ACTIVE').length

  return (
    <div style={{ padding: '40px 0' }}>
      <div className="container">
        <h1 style={{ marginBottom: '6px' }}>My Portfolio</h1>
        <p style={{ color: 'var(--text-secondary)', marginBottom: '36px' }}>
          Welcome back, {user?.phone}
        </p>

        {/* STATS */}
        <div className="grid-4" style={{ marginBottom: '36px' }}>
          {[
            { label: 'Total Invested', value: `$${totalInvested.toFixed(2)}`, icon: DollarSign, color: 'var(--honey-400)' },
            { label: 'Expected ROI', value: `$${totalExpectedRoi.toFixed(2)}`, icon: TrendingUp, color: 'var(--success)' },
            { label: 'Actual Returns', value: `$${totalActualReturn.toFixed(2)}`, icon: TrendingUp, color: '#60a5fa' },
            { label: 'Active Investments', value: activeCount, icon: Layers, color: 'var(--honey-500)' },
          ].map((s) => (
            <div className="stat-card" key={s.label}>
              <s.icon size={20} style={{ color: s.color, marginBottom: '8px' }} />
              <div className="stat-value" style={{ color: s.color }}>{s.value}</div>
              <div className="stat-label">{s.label}</div>
            </div>
          ))}
        </div>

        {/* TABLE */}
        <div className="card" style={{ padding: '0', overflow: 'hidden' }}>
          <div style={{ padding: '20px 24px', borderBottom: '1px solid rgba(255,255,255,0.06)' }}>
            <h3 style={{ fontFamily: 'var(--font-body)', fontWeight: 600 }}>Investment History</h3>
          </div>
          {isLoading ? (
            <div style={{ display: 'flex', justifyContent: 'center', padding: '48px' }}>
              <div className="spinner" />
            </div>
          ) : investments.length === 0 ? (
            <div style={{ textAlign: 'center', padding: '64px', color: 'var(--text-muted)' }}>
              <div style={{ fontSize: '2.5rem', marginBottom: '12px' }}>🐝</div>
              <p>No investments yet. Browse the <a href="/" style={{ color: 'var(--honey-400)' }}>marketplace</a> to get started!</p>
            </div>
          ) : (
            <div className="table-wrap">
              <table>
                <thead>
                  <tr>
                    <th>Colony</th>
                    <th>Shares</th>
                    <th>Invested</th>
                    <th>Expected ROI</th>
                    <th>Actual Return</th>
                    <th>Status</th>
                    <th>Date</th>
                  </tr>
                </thead>
                <tbody>
                  {investments.map((inv) => (
                    <tr key={inv.id}>
                      <td>
                        <div style={{ fontWeight: 600 }}>{inv.colonyName}</div>
                        <div style={{ fontSize: '0.75rem', color: 'var(--text-muted)' }}>{inv.colonyLocation}</div>
                      </td>
                      <td>{inv.sharesCount} shares</td>
                      <td style={{ fontWeight: 600 }}>${parseFloat(inv.totalInvested).toFixed(2)}</td>
                      <td style={{ color: 'var(--success)' }}>+${parseFloat(inv.expectedRoi || 0).toFixed(2)}</td>
                      <td style={{ color: parseFloat(inv.actualReturn) > 0 ? 'var(--success)' : 'var(--text-muted)' }}>
                        ${parseFloat(inv.actualReturn || 0).toFixed(2)}
                      </td>
                      <td><span className={`badge ${STATUS_BADGE[inv.status]}`}>{inv.status}</span></td>
                      <td style={{ color: 'var(--text-muted)', fontSize: '0.8rem' }}>
                        {new Date(inv.createdAt).toLocaleDateString()}
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </div>
      </div>
    </div>
  )
}
