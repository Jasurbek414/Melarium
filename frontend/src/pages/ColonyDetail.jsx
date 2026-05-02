import { useState } from 'react'
import { useParams, useNavigate } from 'react-router-dom'
import { useQuery } from '@tanstack/react-query'
import { colonyApi, investmentApi } from '../api/axios'
import { useAuthStore } from '../store/authStore'
import toast from 'react-hot-toast'
import { MapPin, TrendingUp, Thermometer, Droplets, Weight } from 'lucide-react'

export default function ColonyDetail() {
  const { id } = useParams()
  const navigate = useNavigate()
  const user = useAuthStore((s) => s.user)
  const accessToken = useAuthStore((s) => s.accessToken)
  const [shares, setShares] = useState(1)
  const [buying, setBuying] = useState(false)

  const { data: colony, isLoading } = useQuery({
    queryKey: ['colony', id],
    queryFn: async () => { const { data } = await colonyApi.getById(id); return data },
  })

  if (isLoading) return (
    <div style={{ display: 'flex', justifyContent: 'center', padding: '80px' }}>
      <div className="spinner" />
    </div>
  )

  if (!colony) return <div style={{ textAlign: 'center', padding: '80px', color: 'var(--text-muted)' }}>Colony not found</div>

  const totalCost = (parseFloat(colony.pricePerShare) * shares).toFixed(2)
  const expectedReturn = (parseFloat(totalCost) * parseFloat(colony.expectedRoiPct) / 100).toFixed(2)

  const handleBuy = async () => {
    if (!accessToken) { navigate('/login'); return }
    setBuying(true)
    try {
      await investmentApi.buy({ colonyId: colony.id, sharesCount: shares })
      toast.success(`Successfully bought ${shares} shares!`)
      navigate('/dashboard')
    } catch (err) {
      toast.error(err.response?.data?.message || 'Purchase failed')
    } finally {
      setBuying(false)
    }
  }

  return (
    <div style={{ padding: '40px 0' }}>
      <div className="container">
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 380px', gap: '32px', alignItems: 'start' }}>
          {/* LEFT */}
          <div>
            <div style={{
              height: '260px',
              background: 'linear-gradient(135deg, #1a3520, #0d1f13)',
              borderRadius: 'var(--radius-xl)',
              display: 'flex', alignItems: 'center', justifyContent: 'center',
              fontSize: '6rem', marginBottom: '24px',
              border: '1px solid rgba(255,255,255,0.06)',
            }}>🐝</div>

            <div className="flex items-center gap-3" style={{ marginBottom: '8px' }}>
              <h1 style={{ fontSize: '2rem' }}>{colony.name}</h1>
              {colony.isVerified && <span className="badge badge-success">✓ Verified</span>}
            </div>

            <div className="flex items-center gap-2" style={{ marginBottom: '20px' }}>
              <MapPin size={15} style={{ color: 'var(--text-muted)' }} />
              <span style={{ color: 'var(--text-secondary)' }}>{colony.location}</span>
            </div>

            <p style={{ color: 'var(--text-secondary)', lineHeight: 1.7, marginBottom: '32px' }}>
              {colony.description || 'A premium beekeeping colony managed by an experienced beekeeper. Invest in shares and earn honey-backed returns.'}
            </p>

            {/* IoT Panel */}
            <div className="card" style={{ marginBottom: '24px' }}>
              <h3 style={{ marginBottom: '16px', fontFamily: 'var(--font-body)' }}>🌡️ Live IoT Data</h3>
              <div className="grid-3">
                <div style={{ textAlign: 'center' }}>
                  <Thermometer size={20} style={{ color: 'var(--honey-400)', margin: '0 auto 6px' }} />
                  <div style={{ fontWeight: 700, fontSize: '1.2rem' }}>
                    {colony.temperatureCelsius ?? '—'}°C
                  </div>
                  <div style={{ fontSize: '0.75rem', color: 'var(--text-muted)' }}>Temperature</div>
                </div>
                <div style={{ textAlign: 'center' }}>
                  <Droplets size={20} style={{ color: '#60a5fa', margin: '0 auto 6px' }} />
                  <div style={{ fontWeight: 700, fontSize: '1.2rem' }}>
                    {colony.humidityPct ?? '—'}%
                  </div>
                  <div style={{ fontSize: '0.75rem', color: 'var(--text-muted)' }}>Humidity</div>
                </div>
                <div style={{ textAlign: 'center' }}>
                  <Weight size={20} style={{ color: '#34d399', margin: '0 auto 6px' }} />
                  <div style={{ fontWeight: 700, fontSize: '1.2rem' }}>
                    {colony.weightKg ?? '—'} kg
                  </div>
                  <div style={{ fontSize: '0.75rem', color: 'var(--text-muted)' }}>Hive Weight</div>
                </div>
              </div>
            </div>
          </div>

          {/* RIGHT: Buy Panel */}
          <div className="card" style={{ position: 'sticky', top: '90px' }}>
            <div style={{ marginBottom: '20px' }}>
              <div style={{ fontSize: '0.75rem', color: 'var(--text-muted)', textTransform: 'uppercase', letterSpacing: '0.07em' }}>Price per share</div>
              <div style={{ fontSize: '2rem', fontWeight: 700, color: 'var(--honey-400)' }}>${colony.pricePerShare}</div>
            </div>

            <div style={{ display: 'flex', gap: '12px', marginBottom: '20px' }}>
              <div style={{ flex: 1, background: 'rgba(16,185,129,0.08)', border: '1px solid rgba(16,185,129,0.2)', borderRadius: 'var(--radius-md)', padding: '12px', textAlign: 'center' }}>
                <TrendingUp size={16} style={{ color: 'var(--success)', margin: '0 auto 4px' }} />
                <div style={{ fontWeight: 700, color: 'var(--success)' }}>{colony.expectedRoiPct}%</div>
                <div style={{ fontSize: '0.7rem', color: 'var(--text-muted)' }}>Expected ROI</div>
              </div>
              <div style={{ flex: 1, background: 'rgba(245,158,11,0.08)', border: '1px solid rgba(245,158,11,0.2)', borderRadius: 'var(--radius-md)', padding: '12px', textAlign: 'center' }}>
                <div style={{ fontWeight: 700, color: 'var(--honey-400)' }}>{colony.availableShares}</div>
                <div style={{ fontSize: '0.7rem', color: 'var(--text-muted)' }}>Shares Left</div>
              </div>
            </div>

            <div className="form-group" style={{ marginBottom: '16px' }}>
              <label className="form-label">Number of Shares</label>
              <input
                className="form-input"
                type="number"
                min={1}
                max={colony.availableShares}
                value={shares}
                onChange={(e) => setShares(Math.max(1, parseInt(e.target.value) || 1))}
              />
            </div>

            <div style={{ background: 'rgba(255,255,255,0.03)', borderRadius: 'var(--radius-md)', padding: '14px', marginBottom: '20px' }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '6px' }}>
                <span style={{ color: 'var(--text-secondary)', fontSize: '0.875rem' }}>Total Investment</span>
                <span style={{ fontWeight: 700 }}>${totalCost}</span>
              </div>
              <div style={{ display: 'flex', justifyContent: 'space-between' }}>
                <span style={{ color: 'var(--text-secondary)', fontSize: '0.875rem' }}>Expected Return</span>
                <span style={{ fontWeight: 700, color: 'var(--success)' }}>+${expectedReturn}</span>
              </div>
            </div>

            <button
              className="btn btn-primary btn-lg w-full"
              onClick={handleBuy}
              disabled={buying || colony.availableShares === 0}
            >
              {buying ? 'Processing...' : colony.availableShares === 0 ? 'Fully Funded' : `Invest $${totalCost}`}
            </button>

            {!accessToken && (
              <p style={{ textAlign: 'center', marginTop: '12px', fontSize: '0.8rem', color: 'var(--text-muted)' }}>
                You need to <a href="/login" style={{ color: 'var(--honey-400)' }}>sign in</a> to invest
              </p>
            )}
          </div>
        </div>
      </div>
    </div>
  )
}
