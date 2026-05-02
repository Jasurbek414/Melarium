import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { authApi } from '../api/axios'
import { useAuthStore } from '../store/authStore'
import toast from 'react-hot-toast'
import { Phone, Mail, ShieldCheck, ArrowRight } from 'lucide-react'

const STEPS = { INPUT: 'INPUT', OTP: 'OTP' }
const MODES = { PHONE: 'phone', EMAIL: 'email' }

export default function Login() {
  const [step, setStep]   = useState(STEPS.INPUT)
  const [mode, setMode]   = useState(MODES.EMAIL)
  const [input, setInput] = useState('')
  const [otp, setOtp]     = useState('')
  const [loading, setLoading] = useState(false)
  const [devOtp, setDevOtp]   = useState(null)

  const setAuth   = useAuthStore((s) => s.setAuth)
  const navigate  = useNavigate()

  const handleSend = async (e) => {
    e.preventDefault()
    if (mode === MODES.PHONE && !input.match(/^\+998[0-9]{9}$/)) {
      toast.error('Format: +998901234567')
      return
    }
    if (mode === MODES.EMAIL && !input.includes('@')) {
      toast.error('Valid email required')
      return
    }

    setLoading(true)
    try {
      let data
      if (mode === MODES.EMAIL) {
        const res = await authApi.sendOtpEmail(input)
        data = res.data
      } else {
        const res = await authApi.sendOtp(input)
        data = res.data
      }
      setDevOtp(data.otpCode)
      setStep(STEPS.OTP)
      toast.success(mode === MODES.EMAIL
        ? `OTP sent to ${input}!`
        : 'OTP sent!')
    } catch (err) {
      toast.error(err.response?.data?.message || 'Failed to send OTP')
    } finally {
      setLoading(false)
    }
  }

  const handleVerify = async (e) => {
    e.preventDefault()
    setLoading(true)
    try {
      let data
      if (mode === MODES.EMAIL) {
        const res = await authApi.verifyOtpEmail(input, otp)
        data = res.data
      } else {
        const res = await authApi.verifyOtp(input, otp)
        data = res.data
      }
      setAuth(data)
      toast.success(`Welcome! Role: ${data.role}`)
      navigate('/')
    } catch (err) {
      toast.error(err.response?.data?.message || 'Invalid OTP')
    } finally {
      setLoading(false)
    }
  }

  return (
    <div style={{
      minHeight: '100vh',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      padding: '24px',
      background: 'radial-gradient(ellipse 80% 50% at 50% -20%, rgba(245,158,11,0.12) 0%, transparent 60%)',
    }}>
      <div style={{ width: '100%', maxWidth: '420px' }}>
        {/* Logo */}
        <div style={{ textAlign: 'center', marginBottom: '40px' }}>
          <div style={{ fontSize: '3rem', marginBottom: '8px' }}>🍯</div>
          <h1 style={{ fontSize: '2rem', marginBottom: '8px' }}>MELARIUM</h1>
          <p style={{ color: 'var(--text-secondary)', fontSize: '0.95rem' }}>
            Invest in beekeeping colonies. Earn honey-backed returns.
          </p>
        </div>

        <div className="card" style={{ padding: '32px' }}>
          {step === STEPS.INPUT ? (
            <form onSubmit={handleSend}>
              <h2 style={{ fontSize: '1.25rem', marginBottom: '6px', fontFamily: 'var(--font-body)', fontWeight: 600 }}>Sign In</h2>
              <p style={{ color: 'var(--text-secondary)', fontSize: '0.875rem', marginBottom: '20px' }}>
                OTP sent to your {mode === MODES.EMAIL ? 'email' : 'phone'}
              </p>

              {/* Mode Toggle */}
              <div style={{
                display: 'flex', borderRadius: 'var(--radius-md)',
                background: 'rgba(255,255,255,0.05)',
                border: '1px solid rgba(255,255,255,0.1)',
                padding: '4px', marginBottom: '20px', gap: '4px',
              }}>
                {[
                  { label: 'Email', value: MODES.EMAIL, icon: Mail },
                  { label: 'Phone', value: MODES.PHONE, icon: Phone },
                ].map((m) => {
                  const Icon = m.icon
                  const active = mode === m.value
                  return (
                    <button
                      key={m.value}
                      type="button"
                      onClick={() => { setMode(m.value); setInput('') }}
                      style={{
                        flex: 1, padding: '8px', border: 'none', borderRadius: '8px',
                        cursor: 'pointer', fontWeight: 600, fontSize: '0.875rem',
                        background: active ? 'var(--grad-honey)' : 'transparent',
                        color: active ? 'var(--forest-900)' : 'var(--text-secondary)',
                        transition: 'all 0.2s',
                        display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '6px',
                      }}
                    >
                      <Icon size={14} />{m.label}
                    </button>
                  )
                })}
              </div>

              <div className="form-group" style={{ marginBottom: '24px' }}>
                <label className="form-label">
                  {mode === MODES.EMAIL ? 'Email Address' : 'Phone Number'}
                </label>
                <div className="relative">
                  <input
                    className="form-input"
                    type={mode === MODES.EMAIL ? 'email' : 'tel'}
                    placeholder={mode === MODES.EMAIL ? 'your@email.com' : '+998901234567'}
                    value={input}
                    onChange={(e) => setInput(e.target.value)}
                    style={{ paddingLeft: '44px' }}
                    required
                  />
                  {mode === MODES.EMAIL
                    ? <Mail size={16} style={{ position: 'absolute', left: '14px', top: '50%', transform: 'translateY(-50%)', color: 'var(--text-muted)' }} />
                    : <Phone size={16} style={{ position: 'absolute', left: '14px', top: '50%', transform: 'translateY(-50%)', color: 'var(--text-muted)' }} />
                  }
                </div>
              </div>

              <button type="submit" className="btn btn-primary btn-lg w-full" disabled={loading}>
                {loading ? 'Sending...' : <><ArrowRight size={16} /> Send OTP</>}
              </button>
            </form>
          ) : (
            <form onSubmit={handleVerify}>
              <h2 style={{ fontSize: '1.25rem', marginBottom: '6px', fontFamily: 'var(--font-body)', fontWeight: 600 }}>
                Enter OTP
              </h2>
              <p style={{ color: 'var(--text-secondary)', fontSize: '0.875rem', marginBottom: '20px' }}>
                Code sent to <span style={{ color: 'var(--honey-400)' }}>{input}</span>
              </p>

              {/* DEV: show OTP */}
              {devOtp && (
                <div style={{
                  background: 'rgba(245,158,11,0.1)', border: '1px solid rgba(245,158,11,0.3)',
                  borderRadius: 'var(--radius-md)', padding: '12px 16px', marginBottom: '20px',
                  display: 'flex', alignItems: 'center', gap: '10px',
                }}>
                  <ShieldCheck size={16} style={{ color: 'var(--honey-400)', flexShrink: 0 }} />
                  <div>
                    <div style={{ fontSize: '0.7rem', color: 'var(--text-secondary)' }}>[DEV] Your OTP:</div>
                    <div style={{ fontWeight: 700, fontSize: '1.5rem', letterSpacing: '0.2em', color: 'var(--honey-400)' }}>
                      {devOtp}
                    </div>
                  </div>
                </div>
              )}

              <div className="form-group" style={{ marginBottom: '24px' }}>
                <label className="form-label">6-Digit Code</label>
                <input
                  className="form-input"
                  type="text"
                  placeholder="123456"
                  value={otp}
                  onChange={(e) => setOtp(e.target.value.replace(/\D/g, '').slice(0, 6))}
                  maxLength={6}
                  style={{ fontSize: '1.5rem', letterSpacing: '0.3em', textAlign: 'center' }}
                  required
                />
              </div>

              <button type="submit" className="btn btn-primary btn-lg w-full" disabled={loading || otp.length !== 6}>
                {loading ? 'Verifying...' : 'Verify & Login'}
              </button>

              <button
                type="button"
                className="btn btn-ghost w-full"
                style={{ marginTop: '10px' }}
                onClick={() => { setStep(STEPS.INPUT); setDevOtp(null); setOtp('') }}
              >
                ← Change {mode === MODES.EMAIL ? 'email' : 'number'}
              </button>
            </form>
          )}
        </div>

        {/* Features */}
        <div className="grid-3" style={{ marginTop: '32px', gap: '12px' }}>
          {[
            { emoji: '🐝', text: 'Live Colony Tracking' },
            { emoji: '📈', text: 'ROI up to 25%' },
            { emoji: '🍯', text: 'Honey or Cash' },
          ].map((f) => (
            <div key={f.text} style={{
              textAlign: 'center', padding: '16px 8px',
              background: 'rgba(255,255,255,0.03)',
              borderRadius: 'var(--radius-md)',
              border: '1px solid rgba(255,255,255,0.06)',
            }}>
              <div style={{ fontSize: '1.5rem', marginBottom: '4px' }}>{f.emoji}</div>
              <div style={{ fontSize: '0.75rem', color: 'var(--text-secondary)' }}>{f.text}</div>
            </div>
          ))}
        </div>
      </div>
    </div>
  )
}
