import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { useMutation } from '@tanstack/react-query'
import { authApi } from '../api/axios'
import { useAuthStore } from '../store/authStore'
import { Hexagon, Phone, Mail, ArrowRight, ShieldCheck, TrendingUp, DollarSign } from 'lucide-react'
import toast from 'react-hot-toast'

export default function Login() {
  const [step, setStep] = useState(1)
  const [phone, setPhone] = useState('')
  const [otp, setOtp] = useState('')
  const setAuth = useAuthStore((s) => s.setAuth)
  const navigate = useNavigate()

  const sendOtp = useMutation({
    mutationFn: () => authApi.sendOtp(phone),
    onSuccess: () => {
      toast.success('Security code sent!')
      setStep(2)
    },
    onError: () => toast.error('Verification failed. Please try again.'),
  })

  const verifyOtp = useMutation({
    mutationFn: () => authApi.verifyOtp(phone, otp),
    onSuccess: ({ data }) => {
      toast.success('Welcome back!')
      setAuth(data.user, data.accessToken, data.refreshToken)
      navigate('/')
    },
    onError: () => toast.error('Invalid security code.'),
  })

  const handleSubmit = (e) => {
    e.preventDefault()
    if (step === 1) sendOtp.mutate()
    else verifyOtp.mutate()
  }

  return (
    <div className="min-h-screen bg-[#050507] flex flex-col justify-center relative overflow-hidden selection:bg-honey-500/30">
      
      {/* Background Ornaments */}
      <div className="absolute inset-0 z-0 pointer-events-none">
        <div className="absolute top-[20%] left-[20%] w-[500px] h-[500px] bg-honey-500/10 rounded-full blur-[150px] animate-blob"></div>
        <div className="absolute bottom-[10%] right-[20%] w-[600px] h-[600px] bg-amber-600/10 rounded-full blur-[150px] animate-blob" style={{ animationDelay: '2s' }}></div>
        <div className="absolute inset-0 bg-[url('https://www.transparenttextures.com/patterns/cubes.png')] opacity-[0.02]"></div>
      </div>

      <div className="container relative z-10 mx-auto px-4 max-w-[1200px] flex gap-16 lg:gap-24 items-center justify-center min-h-[80vh]">
        
        {/* Left Side: Brand & Features (Hidden on mobile) */}
        <div className="hidden lg:flex flex-col flex-1 max-w-lg">
          <div className="flex items-center gap-4 mb-10 opacity-80">
            <Hexagon className="w-12 h-12 text-honey-500 fill-honey-500/20" />
            <span className="font-display font-black text-4xl tracking-[0.15em] bg-gradient-to-r from-white to-honey-300 bg-clip-text text-transparent">
              MELARIUM
            </span>
          </div>
          <h1 className="text-5xl font-black text-white leading-[1.1] mb-8">
            The standard for <br />
            <span className="text-honey-gradient">Agro-Investments.</span>
          </h1>
          <p className="text-xl text-white/50 font-light mb-12">
            Access institutional-grade beekeeping assets. Earn secure yields backed by the most industrious workers on earth.
          </p>
          
          <div className="space-y-6">
            <div className="flex items-center gap-4 p-4 rounded-2xl bg-white/[0.02] border border-white/5 backdrop-blur-sm">
              <div className="w-12 h-12 rounded-xl bg-emerald-500/10 flex items-center justify-center text-emerald-400">
                <ShieldCheck className="w-6 h-6" />
              </div>
              <div>
                <div className="text-white font-bold mb-1">Verified Operations</div>
                <div className="text-sm text-white/40">Every apiary is strictly vetted and monitored.</div>
              </div>
            </div>
            
            <div className="flex items-center gap-4 p-4 rounded-2xl bg-white/[0.02] border border-white/5 backdrop-blur-sm">
              <div className="w-12 h-12 rounded-xl bg-honey-500/10 flex items-center justify-center text-honey-500">
                <TrendingUp className="w-6 h-6" />
              </div>
              <div>
                <div className="text-white font-bold mb-1">High-Yield Returns</div>
                <div className="text-sm text-white/40">Average historical APY of 18-25% from honey sales.</div>
              </div>
            </div>

            <div className="flex items-center gap-4 p-4 rounded-2xl bg-white/[0.02] border border-white/5 backdrop-blur-sm">
              <div className="w-12 h-12 rounded-xl bg-blue-500/10 flex items-center justify-center text-blue-400">
                <DollarSign className="w-6 h-6" />
              </div>
              <div>
                <div className="text-white font-bold mb-1">Flexible Payouts</div>
                <div className="text-sm text-white/40">Choose between physical honey delivery or fiat cashout.</div>
              </div>
            </div>
          </div>
        </div>

        {/* Right Side: Login Form */}
        <div className="w-full max-w-md animate-[fadeInUp_0.6s_ease-out]">
          <div className="glass-panel p-10 md:p-12 rounded-[2rem] relative overflow-hidden">
            {/* Inner Glow */}
            <div className="absolute top-0 left-0 w-full h-1 bg-gradient-to-r from-transparent via-honey-500 to-transparent opacity-50"></div>
            
            <div className="lg:hidden flex items-center justify-center gap-3 mb-10">
              <Hexagon className="w-8 h-8 text-honey-500 fill-honey-500/20" />
              <span className="font-display font-black text-2xl tracking-[0.1em] text-white">MELARIUM</span>
            </div>

            <h2 className="text-3xl font-display font-bold text-white mb-2">Welcome Back</h2>
            <p className="text-white/50 mb-10 font-light">
              {step === 1 ? 'Enter your credentials to access your portfolio.' : 'Enter the 6-digit security code.'}
            </p>

            <form onSubmit={handleSubmit} className="space-y-6">
              {step === 1 ? (
                <>
                  <div className="relative group">
                    <label className="absolute left-5 -top-2.5 px-1 bg-[#101013] text-xs font-bold uppercase tracking-widest text-honey-500 rounded z-10 transition-colors">
                      Phone Number
                    </label>
                    <div className="absolute left-5 top-1/2 -translate-y-1/2 text-white/30 group-focus-within:text-honey-500 transition-colors z-10">
                      <Phone className="w-5 h-5" />
                    </div>
                    <input
                      type="tel"
                      required
                      value={phone}
                      onChange={(e) => setPhone(e.target.value)}
                      placeholder="+998 90 123 45 67"
                      className="w-full bg-[#101013] border border-white/10 focus:border-honey-500/50 rounded-xl py-4 pl-14 pr-5 text-white outline-none transition-all duration-300 relative z-0"
                    />
                  </div>
                  <button 
                    type="submit" 
                    disabled={sendOtp.isPending || phone.length < 9}
                    className="w-full btn-premium py-4 rounded-xl text-lg mt-4 disabled:opacity-50 disabled:cursor-not-allowed group"
                  >
                    {sendOtp.isPending ? 'Sending...' : 'Continue'}
                    {!sendOtp.isPending && <ArrowRight className="w-5 h-5 group-hover:translate-x-1 transition-transform" />}
                  </button>
                </>
              ) : (
                <>
                  <div className="relative group animate-[fadeInUp_0.4s_ease-out]">
                    <label className="absolute left-5 -top-2.5 px-1 bg-[#101013] text-xs font-bold uppercase tracking-widest text-honey-500 rounded z-10">
                      Security Code
                    </label>
                    <div className="absolute left-5 top-1/2 -translate-y-1/2 text-white/30 group-focus-within:text-honey-500 transition-colors z-10">
                      <Mail className="w-5 h-5" />
                    </div>
                    <input
                      type="text"
                      required
                      maxLength={6}
                      value={otp}
                      onChange={(e) => setOtp(e.target.value)}
                      placeholder="• • • • • •"
                      className="w-full bg-[#101013] border border-white/10 focus:border-honey-500/50 rounded-xl py-4 pl-14 pr-5 text-white outline-none transition-all duration-300 text-center text-xl tracking-[0.5em] font-bold"
                    />
                  </div>
                  
                  <div className="flex justify-between items-center text-sm px-2 animate-[fadeInUp_0.4s_ease-out_0.1s_both]">
                    <button type="button" onClick={() => setStep(1)} className="text-white/40 hover:text-white transition-colors">
                      Change number
                    </button>
                    <button type="button" onClick={() => sendOtp.mutate()} className="text-honey-400 hover:text-honey-300 font-semibold transition-colors">
                      Resend Code
                    </button>
                  </div>

                  <button 
                    type="submit" 
                    disabled={verifyOtp.isPending || otp.length < 4}
                    className="w-full btn-premium py-4 rounded-xl text-lg mt-4 disabled:opacity-50 disabled:cursor-not-allowed group animate-[fadeInUp_0.4s_ease-out_0.2s_both]"
                  >
                    {verifyOtp.isPending ? 'Verifying...' : 'Access Portfolio'}
                    {!verifyOtp.isPending && <ArrowRight className="w-5 h-5 group-hover:translate-x-1 transition-transform" />}
                  </button>
                </>
              )}
            </form>

            <div className="mt-10 text-center text-sm text-white/30">
              By proceeding, you agree to the <br/> <a href="#" className="text-white/50 hover:text-honey-400 transition-colors underline underline-offset-4">Terms of Service</a> & <a href="#" className="text-white/50 hover:text-honey-400 transition-colors underline underline-offset-4">Privacy Policy</a>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}
