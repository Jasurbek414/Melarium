import { useState } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { colonyApi, reportApi } from '../api/axios'
import { useAuthStore } from '../store/authStore'
import toast from 'react-hot-toast'
import { Plus, CheckCircle } from 'lucide-react'

export default function BeekeeperDashboard() {
  const user = useAuthStore((s) => s.user)
  const qc = useQueryClient()
  const [showForm, setShowForm] = useState(false)
  const [showReportForm, setShowReportForm] = useState(null)

  const { data: colonies, isLoading } = useQuery({
    queryKey: ['my-colonies'],
    queryFn: async () => {
      const { data } = await colonyApi.getMarketplace({ page: 0, size: 50 })
      return data
    },
  })

  const [form, setForm] = useState({
    name: '', location: '', description: '',
    pricePerShare: '', totalShares: '100', expectedRoiPct: '',
    temperatureCelsius: '', humidityPct: '', weightKg: '',
  })

  const createMutation = useMutation({
    mutationFn: (data) => colonyApi.create(data),
    onSuccess: () => {
      toast.success('Colony created! Awaiting admin verification.')
      setShowForm(false)
      qc.invalidateQueries(['my-colonies'])
    },
    onError: (err) => toast.error(err.response?.data?.message || 'Failed to create colony'),
  })

  const handleCreate = (e) => {
    e.preventDefault()
    createMutation.mutate({
      ...form,
      pricePerShare: parseFloat(form.pricePerShare),
      totalShares: parseInt(form.totalShares),
      expectedRoiPct: parseFloat(form.expectedRoiPct),
      temperatureCelsius: form.temperatureCelsius ? parseFloat(form.temperatureCelsius) : null,
      humidityPct: form.humidityPct ? parseFloat(form.humidityPct) : null,
      weightKg: form.weightKg ? parseFloat(form.weightKg) : null,
    })
  }

  return (
    <div style={{ padding: '40px 0' }}>
      <div className="container">
        <div className="flex items-center justify-between" style={{ marginBottom: '36px' }}>
          <div>
            <h1>My Colonies</h1>
            <p style={{ color: 'var(--text-secondary)' }}>Manage your beekeeping colonies</p>
          </div>
          <button className="btn btn-primary" onClick={() => setShowForm(!showForm)}>
            <Plus size={16} /> Add Colony
          </button>
        </div>

        {/* CREATE FORM */}
        {showForm && (
          <div className="card" style={{ marginBottom: '32px', padding: '28px' }}>
            <h3 style={{ fontFamily: 'var(--font-body)', marginBottom: '20px' }}>New Colony</h3>
            <form onSubmit={handleCreate}>
              <div className="grid-2" style={{ gap: '16px', marginBottom: '16px' }}>
                {[
                  { key: 'name', label: 'Colony Name', placeholder: 'Honey Valley #1' },
                  { key: 'location', label: 'Location', placeholder: 'Tashkent, Uzbekistan' },
                  { key: 'pricePerShare', label: 'Price per Share ($)', placeholder: '25', type: 'number' },
                  { key: 'totalShares', label: 'Total Shares', placeholder: '100', type: 'number' },
                  { key: 'expectedRoiPct', label: 'Expected ROI (%)', placeholder: '18.5', type: 'number' },
                ].map((f) => (
                  <div className="form-group" key={f.key}>
                    <label className="form-label">{f.label}</label>
                    <input
                      className="form-input"
                      type={f.type || 'text'}
                      placeholder={f.placeholder}
                      value={form[f.key]}
                      onChange={(e) => setForm({ ...form, [f.key]: e.target.value })}
                      required
                    />
                  </div>
                ))}
              </div>

              <div className="form-group" style={{ marginBottom: '16px' }}>
                <label className="form-label">Description</label>
                <textarea
                  className="form-input"
                  rows={3}
                  placeholder="Describe your colony, location benefits, beekeeping experience..."
                  value={form.description}
                  onChange={(e) => setForm({ ...form, description: e.target.value })}
                  style={{ resize: 'vertical' }}
                />
              </div>

              <div style={{ marginBottom: '8px', color: 'var(--text-muted)', fontSize: '0.8rem' }}>IoT Data (optional)</div>
              <div className="grid-3" style={{ gap: '12px', marginBottom: '20px' }}>
                {[
                  { key: 'temperatureCelsius', label: 'Temperature (°C)' },
                  { key: 'humidityPct', label: 'Humidity (%)' },
                  { key: 'weightKg', label: 'Hive Weight (kg)' },
                ].map((f) => (
                  <div className="form-group" key={f.key}>
                    <label className="form-label">{f.label}</label>
                    <input
                      className="form-input"
                      type="number"
                      step="0.1"
                      value={form[f.key]}
                      onChange={(e) => setForm({ ...form, [f.key]: e.target.value })}
                    />
                  </div>
                ))}
              </div>

              <div className="flex gap-3">
                <button type="submit" className="btn btn-primary" disabled={createMutation.isPending}>
                  {createMutation.isPending ? 'Creating...' : 'Create Colony'}
                </button>
                <button type="button" className="btn btn-ghost" onClick={() => setShowForm(false)}>Cancel</button>
              </div>
            </form>
          </div>
        )}

        {/* COLONIES LIST */}
        {isLoading ? (
          <div style={{ display: 'flex', justifyContent: 'center', padding: '60px' }}>
            <div className="spinner" />
          </div>
        ) : (
          <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
            {(colonies?.content || []).map((colony) => (
              <div className="card" key={colony.id} style={{ display: 'flex', alignItems: 'center', gap: '20px' }}>
                <div style={{ fontSize: '2rem' }}>🐝</div>
                <div style={{ flex: 1 }}>
                  <div className="flex items-center gap-2" style={{ marginBottom: '4px' }}>
                    <span style={{ fontWeight: 600 }}>{colony.name}</span>
                    {!colony.isVerified && <span className="badge badge-neutral">Pending</span>}
                    {colony.isVerified && <span className="badge badge-success">✓ Verified</span>}
                  </div>
                  <div style={{ fontSize: '0.8rem', color: 'var(--text-secondary)' }}>
                    {colony.location} · {colony.availableShares}/{colony.totalShares} shares · ROI: {colony.expectedRoiPct}%
                  </div>
                </div>
                <button
                  className="btn btn-outline btn-sm"
                  onClick={() => setShowReportForm(colony.id === showReportForm ? null : colony.id)}
                >
                  <CheckCircle size={14} /> Honey Report
                </button>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  )
}
