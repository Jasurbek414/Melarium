import { Link } from 'react-router-dom'
import { Hexagon, TrendingUp, Shield, Leaf, BarChart3, Users, ArrowRight, ChevronDown, Zap, Globe, Lock } from 'lucide-react'
import { useState, useEffect } from 'react'

export default function LandingPage() {
  const [scrolled, setScrolled] = useState(false)

  useEffect(() => {
    const h = () => setScrolled(window.scrollY > 20)
    window.addEventListener('scroll', h)
    return () => window.removeEventListener('scroll', h)
  }, [])

  return (
    <div className="min-h-screen bg-[#050507] text-white overflow-hidden">
      {/* ─── NAVBAR ─── */}
      <nav className={`fixed top-0 w-full z-50 transition-all duration-500 ${scrolled ? 'py-3 bg-[#050507]/90 backdrop-blur-2xl border-b border-white/5' : 'py-5 bg-transparent'}`}>
        <div className="max-w-7xl mx-auto px-6 flex items-center justify-between">
          <Link to="/" className="flex items-center gap-3 group">
            <Hexagon className="w-8 h-8 text-honey-500 fill-honey-500/20" />
            <span className="font-display font-black text-xl tracking-[0.15em]">MELARIUM</span>
          </Link>
          <div className="hidden md:flex items-center gap-8">
            <a href="#features" className="text-sm text-white/50 hover:text-white transition-colors">Imkoniyatlar</a>
            <a href="#how" className="text-sm text-white/50 hover:text-white transition-colors">Qanday ishlaydi</a>
            <a href="#stats" className="text-sm text-white/50 hover:text-white transition-colors">Statistika</a>
          </div>
          <div className="flex items-center gap-3">
            <Link to="/login" className="px-5 py-2.5 text-sm font-semibold text-white/70 hover:text-white border border-white/10 hover:border-white/20 rounded-xl transition-all">
              Kirish
            </Link>
            <Link to="/login" className="btn-premium text-sm">
              Boshlash <ArrowRight className="w-4 h-4" />
            </Link>
          </div>
        </div>
      </nav>

      {/* ─── HERO ─── */}
      <section className="relative min-h-screen flex items-center justify-center pt-20">
        {/* Background effects */}
        <div className="absolute inset-0 pointer-events-none">
          <div className="absolute top-1/4 left-1/4 w-[600px] h-[600px] rounded-full bg-honey-500/[0.04] blur-[150px] animate-blob" />
          <div className="absolute bottom-1/4 right-1/4 w-[500px] h-[500px] rounded-full bg-honey-600/[0.03] blur-[120px] animate-blob" style={{ animationDelay: '3s' }} />
          <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[800px] h-[800px] rounded-full border border-white/[0.02]" />
          <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[600px] h-[600px] rounded-full border border-white/[0.03]" />
        </div>

        <div className="relative z-10 max-w-5xl mx-auto px-6 text-center">
          <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-white/[0.03] border border-white/[0.06] text-sm text-white/60 mb-8">
            <Zap className="w-4 h-4 text-honey-500" />
            Agro-investitsiya platformasi
          </div>

          <h1 className="font-display text-5xl md:text-7xl lg:text-8xl font-black leading-[0.95] mb-6">
            <span className="text-gradient">Asal bilan</span>
            <br />
            <span className="text-honey-gradient">Kelajak quring</span>
          </h1>

          <p className="text-lg md:text-xl text-white/40 max-w-2xl mx-auto mb-10 leading-relaxed">
            Melarium — asalarichilik koloniyalariga investitsiya qiling, real vaqtda IoT ma'lumotlarini kuzating va barqaror daromad oling.
          </p>

          <div className="flex flex-col sm:flex-row items-center justify-center gap-4">
            <Link to="/marketplace" className="btn-premium text-base px-8 py-4">
              Investitsiya qilish <ArrowRight className="w-5 h-5" />
            </Link>
            <a href="#how" className="flex items-center gap-2 px-8 py-4 text-base font-semibold text-white/60 hover:text-white border border-white/10 hover:border-white/20 rounded-xl transition-all">
              Qanday ishlaydi <ChevronDown className="w-4 h-4" />
            </a>
          </div>

          {/* Trust badges */}
          <div className="flex items-center justify-center gap-8 mt-16 opacity-40">
            <div className="flex items-center gap-2 text-sm"><Shield className="w-4 h-4" /> Xavfsiz</div>
            <div className="w-px h-4 bg-white/20" />
            <div className="flex items-center gap-2 text-sm"><Globe className="w-4 h-4" /> O'zbekiston</div>
            <div className="w-px h-4 bg-white/20" />
            <div className="flex items-center gap-2 text-sm"><Lock className="w-4 h-4" /> Ishonchli</div>
          </div>
        </div>

        {/* Scroll indicator */}
        <div className="absolute bottom-8 left-1/2 -translate-x-1/2 flex flex-col items-center gap-2 animate-bounce">
          <ChevronDown className="w-5 h-5 text-white/20" />
        </div>
      </section>

      {/* ─── FEATURES ─── */}
      <section id="features" className="relative py-32">
        <div className="max-w-7xl mx-auto px-6">
          <div className="text-center mb-20">
            <p className="text-sm font-bold text-honey-500 tracking-widest uppercase mb-4">Imkoniyatlar</p>
            <h2 className="font-display text-4xl md:text-5xl font-black text-gradient">Nima uchun Melarium?</h2>
          </div>

          <div className="grid md:grid-cols-3 gap-6">
            {[
              { icon: TrendingUp, title: 'Yuqori daromad', desc: 'Yillik 15-30% ROI bilan asalarichilik koloniyalariga investitsiya qiling.', color: 'from-emerald-500/20 to-emerald-500/5' },
              { icon: BarChart3, title: 'Real-time IoT', desc: 'Harorat, namlik va vazn sensorlari orqali koloniyangizni real vaqtda kuzating.', color: 'from-blue-500/20 to-blue-500/5' },
              { icon: Shield, title: 'To\'liq shaffoflik', desc: 'Barcha tranzaksiyalar, hisobotlar va asal yig\'ish jarayoni ochiq va tekshirilgan.', color: 'from-honey-500/20 to-honey-500/5' },
              { icon: Leaf, title: 'Ekologik loyiha', desc: 'Asalarichilikni qo\'llab-quvvatlash orqali tabiatni muhofaza qilishga hissa qo\'shing.', color: 'from-green-500/20 to-green-500/5' },
              { icon: Users, title: 'Jamoaviy investitsiya', desc: 'Kichik summalarda ham ishtirok eting — koloniya ulushlari bilan.', color: 'from-purple-500/20 to-purple-500/5' },
              { icon: Zap, title: 'Tezkor to\'lovlar', desc: 'Click va Payme orqali darhol investitsiya qiling va daromad oling.', color: 'from-orange-500/20 to-orange-500/5' },
            ].map((f, i) => (
              <div key={i} className="glass-card p-8 group cursor-default">
                <div className={`w-14 h-14 rounded-2xl bg-gradient-to-br ${f.color} flex items-center justify-center mb-6 group-hover:scale-110 transition-transform duration-500`}>
                  <f.icon className="w-6 h-6 text-white" />
                </div>
                <h3 className="font-display text-xl font-bold mb-3">{f.title}</h3>
                <p className="text-white/40 text-sm leading-relaxed">{f.desc}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* ─── HOW IT WORKS ─── */}
      <section id="how" className="relative py-32">
        <div className="max-w-5xl mx-auto px-6">
          <div className="text-center mb-20">
            <p className="text-sm font-bold text-honey-500 tracking-widest uppercase mb-4">Jarayon</p>
            <h2 className="font-display text-4xl md:text-5xl font-black text-gradient">Qanday ishlaydi?</h2>
          </div>

          <div className="grid md:grid-cols-4 gap-8">
            {[
              { step: '01', title: 'Ro\'yxatdan o\'ting', desc: 'Telefon raqamingiz bilan 30 soniyada ro\'yxatdan o\'ting.' },
              { step: '02', title: 'Koloniya tanlang', desc: 'Marketplace\'dan o\'zingizga mos koloniyani toping.' },
              { step: '03', title: 'Investitsiya qiling', desc: 'Ulush sotib oling va jarayonni real vaqtda kuzating.' },
              { step: '04', title: 'Daromad oling', desc: 'Asal yig\'ilgach, daromadingizni naqd qiling yoki asal olish.' },
            ].map((s, i) => (
              <div key={i} className="text-center group">
                <div className="w-16 h-16 rounded-2xl bg-gradient-to-br from-honey-500/20 to-transparent border border-honey-500/10 flex items-center justify-center mx-auto mb-5 group-hover:border-honey-500/30 group-hover:shadow-[0_0_30px_rgba(238,176,18,0.15)] transition-all duration-500">
                  <span className="font-display text-2xl font-black text-honey-500">{s.step}</span>
                </div>
                <h3 className="font-display text-lg font-bold mb-2">{s.title}</h3>
                <p className="text-white/40 text-sm leading-relaxed">{s.desc}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* ─── STATS ─── */}
      <section id="stats" className="relative py-32">
        <div className="max-w-7xl mx-auto px-6">
          <div className="glass-panel rounded-3xl p-12 md:p-16">
            <div className="grid md:grid-cols-4 gap-8 text-center">
              {[
                { value: '500+', label: 'Investorlar' },
                { value: '120+', label: 'Faol koloniyalar' },
                { value: '25%', label: 'O\'rtacha ROI' },
                { value: '2.5T', label: 'UZS hajm' },
              ].map((s, i) => (
                <div key={i}>
                  <div className="font-display text-4xl md:text-5xl font-black text-honey-gradient mb-2">{s.value}</div>
                  <p className="text-white/40 text-sm font-semibold tracking-wide uppercase">{s.label}</p>
                </div>
              ))}
            </div>
          </div>
        </div>
      </section>

      {/* ─── CTA ─── */}
      <section className="relative py-32">
        <div className="max-w-4xl mx-auto px-6 text-center">
          <h2 className="font-display text-4xl md:text-6xl font-black text-gradient mb-6">
            Kelajakka investitsiya<br />bugundan boshlanadi
          </h2>
          <p className="text-white/40 text-lg mb-10 max-w-xl mx-auto">
            Melarium platformasiga qo'shiling va barqaror, ekologik toza daromad manbasini yarating.
          </p>
          <Link to="/login" className="btn-premium text-base px-10 py-4">
            Hozir boshlash <ArrowRight className="w-5 h-5" />
          </Link>
        </div>
      </section>

      {/* ─── FOOTER ─── */}
      <footer className="border-t border-white/5 py-12">
        <div className="max-w-7xl mx-auto px-6">
          <div className="flex flex-col md:flex-row items-center justify-between gap-6">
            <div className="flex items-center gap-3">
              <Hexagon className="w-6 h-6 text-honey-500 fill-honey-500/20" />
              <span className="font-display font-bold tracking-[0.15em] text-white/40">MELARIUM</span>
            </div>
            <div className="flex items-center gap-6 text-sm text-white/30">
              <a href="#" className="hover:text-white/60 transition-colors">Shartlar</a>
              <a href="#" className="hover:text-white/60 transition-colors">Maxfiylik</a>
              <a href="#" className="hover:text-white/60 transition-colors">Yordam</a>
            </div>
            <p className="text-sm text-white/20">© 2024 Melarium. Barcha huquqlar himoyalangan.</p>
          </div>
        </div>
      </footer>
    </div>
  )
}
