import { useState } from 'react'
import { useParams, useNavigate, Link } from 'react-router-dom'
import { useQuery } from '@tanstack/react-query'
import { colonyApi, investmentApi } from '../api/axios'
import { useAuthStore } from '../store/authStore'
import toast from 'react-hot-toast'
import { MapPin, TrendingUp, Thermometer, Droplets, Weight, ShieldCheck, ArrowLeft, Users, Hexagon } from 'lucide-react'

// Mock data (same as Marketplace)
const MOCK_COLONIES = {
  1: { id: 1, name: 'Toshkent Oltin Asalxona', location: 'Toshkent viloyati', status: 'AVAILABLE', pricePerShare: 150000, expectedRoiPct: 22, totalShares: 100, availableShares: 35, isVerified: true, beekeeperName: 'Jasurbek Karimov', temperatureCelsius: 34.5, humidityPct: 62, weightKg: 28.3, description: 'Toshkent viloyatidagi eng yirik asalxonalardan biri. 100 ta ari oilasidan iborat. Professional asalarichi tomonidan boshqariladi.' },
  2: { id: 2, name: "Bo'stonliq Tog' Asalxonasi", location: "Bo'stonliq tumani", status: 'ACTIVE', pricePerShare: 220000, expectedRoiPct: 28, totalShares: 80, availableShares: 12, isVerified: true, beekeeperName: 'Anvar Toshmatov', temperatureCelsius: 32.1, humidityPct: 58, weightKg: 35.7, description: "Tog'li hududda joylashgan ekologik toza asalxona. Tog' gullari asali ishlab chiqaradi." },
  3: { id: 3, name: 'Samarqand Vodiysi', location: 'Samarqand viloyati', status: 'HARVESTING', pricePerShare: 180000, expectedRoiPct: 19, totalShares: 120, availableShares: 0, isVerified: true, beekeeperName: 'Bobur Ahmedov', temperatureCelsius: 36.2, humidityPct: 55, weightKg: 42.1, description: "Samarqand vodiysi — asal yig'im mavsumida. Investorlar tez orada daromad oladi." },
  4: { id: 4, name: "Farg'ona Premium", location: "Farg'ona viloyati", status: 'AVAILABLE', pricePerShare: 300000, expectedRoiPct: 32, totalShares: 60, availableShares: 42, isVerified: false, beekeeperName: 'Rustam Umarov', temperatureCelsius: 33.8, humidityPct: 60, weightKg: 22.5, description: "Farg'ona vodiysining premium asalxonasi. Yuqori sifatli oq asal ishlab chiqaradi." },
  5: { id: 5, name: 'Buxoro Klassik Asalxona', location: 'Buxoro viloyati', status: 'AVAILABLE', pricePerShare: 120000, expectedRoiPct: 17, totalShares: 150, availableShares: 88, isVerified: true, beekeeperName: 'Sanjar Yuldashev', temperatureCelsius: 37.1, humidityPct: 48, weightKg: 31.0, description: "Buxoroning issiq iqlimida yetishtirilgan tabiiy asal. Arzon narxda investitsiya imkoniyati." },
  6: { id: 6, name: "Namangan Tog' Asali", location: 'Namangan viloyati', status: 'ACTIVE', pricePerShare: 250000, expectedRoiPct: 25, totalShares: 90, availableShares: 28, isVerified: true, beekeeperName: 'Olim Nazarov', temperatureCelsius: 31.5, humidityPct: 65, weightKg: 38.9, description: "Namangan tog'laridan keladigan sofiston asal. Faol ishlab chiqarish bosqichida." },
  7: { id: 7, name: 'Xorazm Tabiiy Asal', location: 'Xorazm viloyati', status: 'COMPLETED', pricePerShare: 160000, expectedRoiPct: 21, totalShares: 100, availableShares: 0, isVerified: true, beekeeperName: 'Dilshod Raximov', temperatureCelsius: 35.0, humidityPct: 52, weightKg: 45.2, description: "Xorazm viloyatidagi koloniya to'liq davrini yakunladi. Investorlar daromad oldi." },
  8: { id: 8, name: 'Surxondaryo Qishloq Asalxonasi', location: 'Surxondaryo viloyati', status: 'AVAILABLE', pricePerShare: 140000, expectedRoiPct: 20, totalShares: 110, availableShares: 65, isVerified: false, beekeeperName: 'Kamol Ibragimov', temperatureCelsius: 38.2, humidityPct: 45, weightKg: 26.7, description: "Surxondaryoning issiq iqlimida qishloq asalxonasi. Tabiiy sharoitda parvarishlangan." },
  9: { id: 9, name: 'Qashqadaryo Ekologik', location: 'Qashqadaryo viloyati', status: 'HARVESTING', pricePerShare: 200000, expectedRoiPct: 24, totalShares: 70, availableShares: 0, isVerified: true, beekeeperName: 'Sherzod Turgunov', temperatureCelsius: 34.0, humidityPct: 57, weightKg: 40.5, description: "Ekologik toza usulda yetishtirilgan asal. Yig'im bosqichi — tez orada natija." },
}

const STATUS_LABELS = {
  AVAILABLE: 'Sotuvda', ACTIVE: 'Faol', HARVESTING: "Yig'im", COMPLETED: 'Tugallangan', SUSPENDED: "To'xtatilgan",
}

export default function ColonyDetail() {
  const { id } = useParams()
  const navigate = useNavigate()
  const user = useAuthStore((s) => s.user)
  const accessToken = useAuthStore((s) => s.accessToken)
  const [shares, setShares] = useState(1)
  const [buying, setBuying] = useState(false)

  const { data: apiColony, isLoading } = useQuery({
    queryKey: ['colony', id],
    queryFn: async () => { const { data } = await colonyApi.getById(id); return data },
    retry: false,
  })

  // Use mock data if API fails
  const colony = apiColony || MOCK_COLONIES[id]

  if (isLoading) return (
    <div className="flex items-center justify-center py-32">
      <div className="relative w-16 h-16">
        <div className="absolute inset-0 rounded-full border-t-2 border-honey-500 animate-spin" />
        <Hexagon className="absolute inset-0 m-auto w-6 h-6 text-honey-500/50" />
      </div>
    </div>
  )

  if (!colony) return (
    <div className="py-32 text-center max-w-md mx-auto">
      <div className="text-7xl mb-6">🍯</div>
      <h2 className="font-display text-2xl font-bold mb-3">Koloniya topilmadi</h2>
      <p className="text-white/40 mb-8">Bu koloniya mavjud emas yoki o'chirilgan.</p>
      <Link to="/marketplace" className="btn-premium">Bozorga qaytish</Link>
    </div>
  )

  const formatPrice = (n) => n.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ' ')
  const totalCost = colony.pricePerShare * shares
  const expectedReturn = Math.round(totalCost * colony.expectedRoiPct / 100)
  const soldPct = Math.round(((colony.totalShares - colony.availableShares) / colony.totalShares) * 100)

  const handleBuy = async () => {
    if (!accessToken) { navigate('/login'); return }
    setBuying(true)
    try {
      await investmentApi.buy({ colonyId: colony.id, sharesCount: shares })
      toast.success(`${shares} ta ulush muvaffaqiyatli sotib olindi!`)
      navigate('/dashboard')
    } catch (err) {
      toast.error(err.response?.data?.message || 'Xatolik yuz berdi')
    } finally {
      setBuying(false)
    }
  }

  return (
    <div className="pt-28 pb-24 min-h-screen">
      <div className="max-w-[1200px] mx-auto px-6 md:px-12">

        {/* Back */}
        <Link to="/marketplace" className="inline-flex items-center gap-2 text-sm text-white/40 hover:text-white mb-8 transition-colors">
          <ArrowLeft className="w-4 h-4" /> Bozorga qaytish
        </Link>

        <div className="grid lg:grid-cols-[1fr_400px] gap-8 items-start">

          {/* ── LEFT ── */}
          <div>
            {/* Image */}
            <div className="h-72 rounded-3xl bg-gradient-to-br from-honey-900/30 via-[#0a0a0c] to-[#0a0a0c] border border-white/5 flex items-center justify-center mb-8 relative overflow-hidden">
              <span className="text-[120px] drop-shadow-[0_20px_40px_rgba(0,0,0,0.8)]">🐝</span>
              <div className="absolute top-5 right-5">
                <span className="px-3 py-1.5 rounded-lg text-xs font-bold bg-honey-500/10 text-honey-400 border border-honey-500/20">
                  {STATUS_LABELS[colony.status] || colony.status}
                </span>
              </div>
              {colony.isVerified && (
                <div className="absolute top-5 left-5">
                  <span className="flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-xs font-bold bg-white/10 text-white border border-white/20 backdrop-blur-md">
                    <ShieldCheck className="w-3.5 h-3.5 text-honey-400" /> Tasdiqlangan
                  </span>
                </div>
              )}
            </div>

            {/* Title */}
            <h1 className="font-display text-3xl md:text-4xl font-black mb-3">{colony.name}</h1>
            <div className="flex items-center gap-2 text-white/50 mb-6">
              <MapPin className="w-4 h-4 text-honey-500" />
              <span className="text-sm">{colony.location}</span>
            </div>

            <p className="text-white/50 leading-relaxed mb-10">
              {colony.description || 'Professional asalarichi tomonidan boshqariladigan premium asalxona. Ulush sotib oling va asal ishlab chiqarishdan daromad oling.'}
            </p>

            {/* IoT Panel */}
            <div className="glass-panel rounded-2xl p-6 mb-8">
              <h3 className="font-display text-lg font-bold mb-6 flex items-center gap-2">
                🌡️ Jonli IoT ma'lumotlar
              </h3>
              <div className="grid grid-cols-3 gap-4">
                <div className="bg-black/30 rounded-xl p-5 text-center border border-white/5">
                  <Thermometer className="w-6 h-6 text-honey-400 mx-auto mb-3" />
                  <div className="text-2xl font-bold">{colony.temperatureCelsius ?? '—'}°C</div>
                  <div className="text-xs text-white/30 mt-1 font-semibold">Harorat</div>
                </div>
                <div className="bg-black/30 rounded-xl p-5 text-center border border-white/5">
                  <Droplets className="w-6 h-6 text-blue-400 mx-auto mb-3" />
                  <div className="text-2xl font-bold">{colony.humidityPct ?? '—'}%</div>
                  <div className="text-xs text-white/30 mt-1 font-semibold">Namlik</div>
                </div>
                <div className="bg-black/30 rounded-xl p-5 text-center border border-white/5">
                  <Weight className="w-6 h-6 text-emerald-400 mx-auto mb-3" />
                  <div className="text-2xl font-bold">{colony.weightKg ?? '—'} kg</div>
                  <div className="text-xs text-white/30 mt-1 font-semibold">Vazn</div>
                </div>
              </div>
            </div>

            {/* Beekeeper */}
            <div className="glass-panel rounded-2xl p-6">
              <h3 className="font-display text-lg font-bold mb-4">Asalarichi</h3>
              <div className="flex items-center gap-4">
                <div className="w-12 h-12 rounded-full bg-gradient-to-br from-honey-400 to-honey-600 flex items-center justify-center text-black font-bold text-lg">
                  {colony.beekeeperName?.charAt(0) || 'A'}
                </div>
                <div>
                  <div className="font-semibold">{colony.beekeeperName || 'Asalarichi'}</div>
                  <div className="text-xs text-white/30">Professional asalarichi</div>
                </div>
              </div>
            </div>
          </div>

          {/* ── RIGHT: BUY PANEL ── */}
          <div className="glass-panel rounded-2xl p-8 sticky top-24">
            {/* Price */}
            <div className="mb-6">
              <div className="text-xs text-white/40 font-bold uppercase tracking-widest mb-2">Ulush narxi</div>
              <div className="text-3xl font-black text-honey-400">{formatPrice(colony.pricePerShare)} <span className="text-base">UZS</span></div>
            </div>

            {/* Stats */}
            <div className="grid grid-cols-2 gap-3 mb-6">
              <div className="bg-emerald-500/10 border border-emerald-500/20 rounded-xl p-4 text-center">
                <TrendingUp className="w-5 h-5 text-emerald-400 mx-auto mb-2" />
                <div className="text-xl font-bold text-emerald-400">{colony.expectedRoiPct}%</div>
                <div className="text-[10px] text-white/40 font-bold">Kutilgan ROI</div>
              </div>
              <div className="bg-honey-500/10 border border-honey-500/20 rounded-xl p-4 text-center">
                <Users className="w-5 h-5 text-honey-400 mx-auto mb-2" />
                <div className="text-xl font-bold text-honey-400">{colony.availableShares}</div>
                <div className="text-[10px] text-white/40 font-bold">Qolgan ulush</div>
              </div>
            </div>

            {/* Progress */}
            <div className="mb-6">
              <div className="flex justify-between text-xs font-bold text-white/40 mb-2">
                <span>Moliyalashtirilgan</span>
                <span>{soldPct}%</span>
              </div>
              <div className="h-2 bg-black/50 rounded-full overflow-hidden border border-white/5">
                <div className="h-full bg-gradient-to-r from-honey-600 to-honey-400 rounded-full" style={{ width: `${soldPct}%` }} />
              </div>
            </div>

            {/* Shares input */}
            <div className="mb-4">
              <label className="block text-xs text-white/40 font-bold mb-2">Ulushlar soni</label>
              <input
                type="number"
                min={1}
                max={colony.availableShares || 1}
                value={shares}
                onChange={(e) => setShares(Math.max(1, parseInt(e.target.value) || 1))}
                className="w-full px-4 py-3 rounded-xl bg-white/[0.03] border border-white/[0.06] text-white text-lg font-bold focus:border-honey-500/30 focus:outline-none"
              />
            </div>

            {/* Summary */}
            <div className="bg-white/[0.02] rounded-xl p-4 mb-6 space-y-3">
              <div className="flex justify-between text-sm">
                <span className="text-white/40">Jami investitsiya</span>
                <span className="font-bold">{formatPrice(totalCost)} UZS</span>
              </div>
              <div className="flex justify-between text-sm">
                <span className="text-white/40">Kutilgan daromad</span>
                <span className="font-bold text-emerald-400">+{formatPrice(expectedReturn)} UZS</span>
              </div>
            </div>

            {/* Buy button */}
            <button
              onClick={handleBuy}
              disabled={buying || colony.availableShares === 0}
              className="w-full py-4 rounded-xl font-bold text-black bg-gradient-to-r from-honey-400 to-honey-600 hover:from-honey-300 hover:to-honey-500 transition-all shadow-[0_0_20px_rgba(238,176,18,0.3)] disabled:opacity-40 disabled:cursor-not-allowed"
            >
              {buying ? 'Jarayonda...' : colony.availableShares === 0 ? 'To\'liq moliyalashtirilgan' : `Investitsiya qilish — ${formatPrice(totalCost)} UZS`}
            </button>

            {!accessToken && (
              <p className="text-center mt-4 text-xs text-white/30">
                Investitsiya uchun <Link to="/login" className="text-honey-400 hover:underline">tizimga kiring</Link>
              </p>
            )}
          </div>
        </div>
      </div>
    </div>
  )
}
