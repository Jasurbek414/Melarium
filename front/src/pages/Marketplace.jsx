import { useState } from 'react'
import { useQuery } from '@tanstack/react-query'
import { Link } from 'react-router-dom'
import { colonyApi } from '../api/axios'
import { MapPin, TrendingUp, ChevronRight, Search } from 'lucide-react'

const STATUS_COLORS = {
  AVAILABLE:  'badge-success',
  ACTIVE:     'badge-honey',
  HARVESTING: 'badge-info',
  COMPLETED:  'badge-neutral',
  SUSPENDED:  'badge-error',
}

export default function Marketplace() {
  const [search, setSearch] = useState('')
  const [status, setStatus] = useState('')
  const [page, setPage] = useState(0)

  const { data, isLoading } = useQuery({
    queryKey: ['marketplace', page, search, status],
    queryFn: async () => {
      const params = { page, size: 12 }
      if (search) params.location = search
      if (status) params.status = status
      const { data } = await colonyApi.getMarketplace(params)
      return data
    },
    keepPreviousData: true,
  })

  return (
    <div style={{ padding: '40px 0', minHeight: '80vh' }}>
      <div className="container">
        <div style={{ textAlign: 'center', marginBottom: '48px' }}>
          <h1 style={{ marginBottom: '12px' }}>🐝 Colony Marketplace</h1>
          <p style={{ color: 'var(--text-secondary)', fontSize: '1.1rem', maxWidth: '560px', margin: '0 auto' }}>
            Browse verified beekeeping colonies. Invest in shares, earn honey-backed returns.
          </p>
        </div>

        {/* FILTERS */}
        <div style={{ display: 'flex', gap: '12px', marginBottom: '32px', flexWrap: 'wrap', alignItems: 'center' }}>
          <div className="relative" style={{ flex: 1, minWidth: '240px' }}>
            <input
              className="form-input"
              placeholder="Search by location..."
              value={search}
              onChange={(e) => { setSearch(e.target.value); setPage(0) }}
              style={{ paddingLeft: '40px' }}
            />
            <Search size={15} style={{ position: 'absolute', left: '12px', top: '50%', transform: 'translateY(-50%)', color: 'var(--text-muted)' }} />
          </div>
          <select
            className="form-input"
            style={{ width: 'auto', minWidth: '160px' }}
            value={status}
            onChange={(e) => { setStatus(e.target.value); setPage(0) }}
          >
            <option value="">All Status</option>
            <option value="AVAILABLE">Available</option>
            <option value="ACTIVE">Active</option>
            <option value="HARVESTING">Harvesting</option>
            <option value="COMPLETED">Completed</option>
          </select>
        </div>

        {/* GRID */}
        {isLoading ? (
          <div style={{ display: 'flex', justifyContent: 'center', padding: '80px 0' }}>
            <div className="spinner" />
          </div>
        ) : data?.content?.length === 0 ? (
          <div style={{ textAlign: 'center', padding: '80px 0', color: 'var(--text-muted)' }}>
            <div style={{ fontSize: '3rem', marginBottom: '16px' }}>🐝</div>
            <p>No colonies found. Try adjusting your filters.</p>
          </div>
        ) : (
          <div className="grid-3" style={{ gap: '24px' }}>
            {data?.content?.map((colony) => <ColonyCard key={colony.id} colony={colony} />)}
          </div>
        )}

        {/* PAGINATION */}
        {data && data.totalPages > 1 && (
          <div style={{ display: 'flex', justifyContent: 'center', gap: '8px', marginTop: '40px' }}>
            <button className="btn btn-outline btn-sm" disabled={page === 0} onClick={() => setPage((p) => p - 1)}>← Prev</button>
            <span style={{ padding: '7px 14px', color: 'var(--text-secondary)', fontSize: '0.875rem' }}>{page + 1} / {data.totalPages}</span>
            <button className="btn btn-outline btn-sm" disabled={page >= data.totalPages - 1} onClick={() => setPage((p) => p + 1)}>Next →</button>
          </div>
        )}
      </div>
    </div>
  )
}

function ColonyCard({ colony }) {
  const soldPct = Math.round(((colony.totalShares - colony.availableShares) / colony.totalShares) * 100)
  return (
    <Link to={`/colony/${colony.id}`} style={{ textDecoration: 'none' }}>
      <div className="card animate-fade-in" style={{ cursor: 'pointer', padding: '0', overflow: 'hidden' }}>
        <div style={{
          height: '180px', background: 'linear-gradient(135deg, #1a3520 0%, #132918 100%)',
          display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: '4rem', position: 'relative',
        }}>
          🐝
          <div style={{ position: 'absolute', top: '12px', right: '12px' }}>
            <span className={`badge ${STATUS_COLORS[colony.status] || 'badge-neutral'}`}>{colony.status}</span>
          </div>
          {colony.isVerified && (
            <div style={{ position: 'absolute', top: '12px', left: '12px' }}>
              <span className="badge badge-success">✓ Verified</span>
            </div>
          )}
        </div>
        <div style={{ padding: '20px' }}>
          <h3 style={{ fontFamily: 'var(--font-body)', marginBottom: '6px' }}>{colony.name}</h3>
          <div className="flex items-center gap-2" style={{ marginBottom: '16px' }}>
            <MapPin size={13} style={{ color: 'var(--text-muted)', flexShrink: 0 }} />
            <span style={{ fontSize: '0.8rem', color: 'var(--text-secondary)' }}>{colony.location}</span>
          </div>
          <div style={{ display: 'flex', gap: '12px', marginBottom: '16px' }}>
            <div style={{ flex: 1 }}>
              <div style={{ fontSize: '0.7rem', color: 'var(--text-muted)', textTransform: 'uppercase', letterSpacing: '0.07em' }}>Price/share</div>
              <div style={{ fontWeight: 700, color: 'var(--honey-400)' }}>${colony.pricePerShare}</div>
            </div>
            <div style={{ flex: 1 }}>
              <div style={{ fontSize: '0.7rem', color: 'var(--text-muted)', textTransform: 'uppercase', letterSpacing: '0.07em' }}>Expected ROI</div>
              <div className="flex items-center gap-1" style={{ fontWeight: 700, color: 'var(--success)' }}>
                <TrendingUp size={13} />{colony.expectedRoiPct}%
              </div>
            </div>
            <div style={{ flex: 1 }}>
              <div style={{ fontSize: '0.7rem', color: 'var(--text-muted)', textTransform: 'uppercase', letterSpacing: '0.07em' }}>Available</div>
              <div style={{ fontWeight: 700 }}>{colony.availableShares} <span style={{ fontWeight: 400, fontSize: '0.8rem', color: 'var(--text-secondary)' }}>shares</span></div>
            </div>
          </div>
          <div style={{ marginBottom: '16px' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '4px' }}>
              <span style={{ fontSize: '0.75rem', color: 'var(--text-secondary)' }}>Sold</span>
              <span style={{ fontSize: '0.75rem', color: 'var(--text-secondary)' }}>{soldPct}%</span>
            </div>
            <div style={{ height: '4px', background: 'rgba(255,255,255,0.1)', borderRadius: '2px' }}>
              <div style={{ height: '100%', width: `${soldPct}%`, background: 'var(--grad-honey)', borderRadius: '2px' }} />
            </div>
          </div>
          <div className="flex items-center justify-between">
            <span style={{ fontSize: '0.75rem', color: 'var(--text-muted)' }}>by {colony.beekeeperName || 'Anonymous'}</span>
            <ChevronRight size={16} style={{ color: 'var(--honey-500)' }} />
          </div>
        </div>
      </div>
    </Link>
  )
}
