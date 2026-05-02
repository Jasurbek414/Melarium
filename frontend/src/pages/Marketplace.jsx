import { useState, useRef, useEffect } from 'react'
import { useQuery } from '@tanstack/react-query'
import { Link } from 'react-router-dom'
import { colonyApi } from '../api/axios'
import { MapPin, TrendingUp, Search, ShieldCheck, ArrowRight, Hexagon, Filter, ChevronDown, Check } from 'lucide-react'

const STATUS_CONFIG = {
  AVAILABLE:  { color: 'text-emerald-400', bg: 'bg-emerald-400/10', border: 'border-emerald-400/20' },
  ACTIVE:     { color: 'text-honey-400', bg: 'bg-honey-400/10', border: 'border-honey-400/20' },
  HARVESTING: { color: 'text-blue-400', bg: 'bg-blue-400/10', border: 'border-blue-400/20' },
  COMPLETED:  { color: 'text-white/60', bg: 'bg-white/5', border: 'border-white/10' },
  SUSPENDED:  { color: 'text-red-400', bg: 'bg-red-400/10', border: 'border-red-400/20' },
}

const FILTER_OPTIONS = [
  { value: '', label: 'All Lifecycle Stages' },
  { value: 'AVAILABLE', label: 'Available for Investment' },
  { value: 'ACTIVE', label: 'Actively Producing' },
  { value: 'HARVESTING', label: 'Harvesting Phase' },
  { value: 'COMPLETED', label: 'Cycle Completed' },
]

export default function Marketplace() {
  const [search, setSearch] = useState('')
  const [status, setStatus] = useState('')
  const [page, setPage] = useState(0)
  const [dropdownOpen, setDropdownOpen] = useState(false)
  const dropdownRef = useRef(null)

  useEffect(() => {
    function handleClickOutside(event) {
      if (dropdownRef.current && !dropdownRef.current.contains(event.target)) {
        setDropdownOpen(false)
      }
    }
    document.addEventListener("mousedown", handleClickOutside)
    return () => document.removeEventListener("mousedown", handleClickOutside)
  }, [])

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

  const currentStatusLabel = FILTER_OPTIONS.find(opt => opt.value === status)?.label

  return (
    <div className="pt-32 pb-24 min-h-screen">
      <div className="max-w-[1400px] mx-auto px-6 md:px-12">
        
        {/* HERO SECTION */}
        <div className="relative text-center max-w-4xl mx-auto mb-20 animate-[fadeInUp_1s_ease-out]">
          <div className="inline-flex items-center gap-3 px-5 py-2 rounded-full glass-panel mb-8 border-honey-500/30 text-honey-400 text-xs font-bold tracking-widest uppercase">
            <span className="relative flex w-2 h-2">
              <span className="absolute inline-flex w-full h-full rounded-full bg-honey-400 opacity-75 animate-ping"></span>
              <span className="relative inline-flex rounded-full w-2 h-2 bg-honey-400"></span>
            </span>
            Live Colony Marketplace
          </div>
          
          <h1 className="text-5xl md:text-7xl font-black leading-[1.1] mb-8 text-gradient">
            Invest in the Future of <br className="hidden md:block"/>
            <span className="text-honey-gradient relative inline-block mt-2">
              Sustainable Apiculture
              <svg className="absolute w-full h-4 -bottom-2 left-0 text-honey-500/30" viewBox="0 0 100 10" preserveAspectRatio="none"><path d="M0 5 Q 50 10 100 5" fill="none" stroke="currentColor" strokeWidth="4" strokeLinecap="round"/></svg>
            </span>
          </h1>
          
          <p className="text-xl text-white/50 leading-relaxed max-w-2xl mx-auto font-light">
            Discover curated beekeeping colonies, acquire digital shares, and earn premium returns backed by actual global honey production.
          </p>
        </div>

        {/* FILTERS & SEARCH */}
        <div className="glass-panel rounded-3xl p-4 md:p-6 mb-16 flex flex-col md:flex-row gap-4 items-center animate-[fadeInUp_1s_ease-out_0.2s_both] relative z-20">
          <div className="relative flex-1 w-full group">
            <Search className="absolute left-6 top-1/2 -translate-y-1/2 w-5 h-5 text-white/30 group-focus-within:text-honey-400 transition-colors" />
            <input
              className="w-full bg-white/[0.03] hover:bg-white/[0.05] focus:bg-white/[0.08] border border-white/5 focus:border-honey-500/50 rounded-2xl py-4 pl-14 pr-6 text-white placeholder:text-white/30 outline-none transition-all duration-300"
              placeholder="Search premium colonies by location..."
              value={search}
              onChange={(e) => { setSearch(e.target.value); setPage(0) }}
            />
          </div>
          
          <div className="w-full md:w-px h-px md:h-12 bg-white/10"></div>
          
          {/* CUSTOM DROPDOWN */}
          <div className="relative w-full md:w-[280px]" ref={dropdownRef}>
            <button
              type="button"
              onClick={() => setDropdownOpen(!dropdownOpen)}
              className="w-full bg-white/[0.03] hover:bg-white/[0.05] border border-white/5 focus:border-honey-500/50 rounded-2xl py-4 px-6 text-white outline-none transition-all duration-300 flex items-center justify-between group"
            >
              <div className="flex items-center gap-3">
                <Filter className={`w-5 h-5 transition-colors ${dropdownOpen || status ? 'text-honey-400' : 'text-white/30 group-hover:text-white/50'}`} />
                <span>{currentStatusLabel}</span>
              </div>
              <ChevronDown className={`w-4 h-4 text-white/40 transition-transform duration-300 ${dropdownOpen ? 'rotate-180' : ''}`} />
            </button>

            {dropdownOpen && (
              <div className="absolute top-[calc(100%+8px)] left-0 w-full bg-[#111116] border border-white/10 rounded-2xl p-2 shadow-[0_15px_40px_rgba(0,0,0,0.6)] backdrop-blur-xl z-50 animate-[fadeInUp_0.2s_ease-out]">
                {FILTER_OPTIONS.map((opt) => (
                  <button
                    key={opt.value}
                    onClick={() => {
                      setStatus(opt.value)
                      setPage(0)
                      setDropdownOpen(false)
                    }}
                    className={`w-full text-left px-4 py-3 rounded-xl flex items-center justify-between transition-all duration-200 ${
                      status === opt.value 
                        ? 'bg-honey-500/10 text-honey-400 font-semibold' 
                        : 'text-white/70 hover:bg-white/5 hover:text-white'
                    }`}
                  >
                    {opt.label}
                    {status === opt.value && <Check className="w-4 h-4" />}
                  </button>
                ))}
              </div>
            )}
          </div>
        </div>

        {/* GRID */}
        <div className="relative z-10">
          {isLoading ? (
            <div className="py-32 flex flex-col items-center justify-center gap-6">
              <div className="relative w-20 h-20">
                <div className="absolute inset-0 rounded-full border-t-2 border-honey-500 animate-spin"></div>
                <div className="absolute inset-2 rounded-full border-r-2 border-honey-400 animate-spin" style={{ animationDirection: 'reverse', animationDuration: '1.5s' }}></div>
                <Hexagon className="absolute inset-0 m-auto w-6 h-6 text-honey-500/50" />
              </div>
              <div className="text-white/50 font-medium tracking-widest uppercase text-sm animate-pulse">Synchronizing Data...</div>
            </div>
          ) : data?.content?.length === 0 ? (
            <div className="py-32 text-center glass-panel rounded-3xl animate-[fadeInUp_0.5s_ease-out]">
              <div className="text-7xl mb-6 opacity-20 filter grayscale">🍯</div>
              <h3 className="text-2xl font-bold text-white mb-2">No colonies found</h3>
              <p className="text-white/50">Try adjusting your filters or search criteria to discover more opportunities.</p>
            </div>
          ) : (
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
              {data?.content?.map((colony, i) => (
                <div key={colony.id} className="animate-[fadeInUp_0.8s_ease-out_both]" style={{ animationDelay: `${0.1 * i}s` }}>
                  <ColonyCard colony={colony} />
                </div>
              ))}
            </div>
          )}
        </div>

        {/* PAGINATION */}
        {data && data.totalPages > 1 && (
          <div className="flex justify-center items-center gap-6 mt-20">
            <button 
              className="px-6 py-3 rounded-xl glass-panel hover:bg-white/5 text-white/70 hover:text-white transition-all disabled:opacity-30 disabled:cursor-not-allowed font-semibold"
              disabled={page === 0} 
              onClick={() => setPage((p) => p - 1)}
            >
              Previous
            </button>
            <div className="flex items-center gap-2">
              {[...Array(data.totalPages)].map((_, i) => (
                <button
                  key={i}
                  onClick={() => setPage(i)}
                  className={`w-3 h-3 rounded-full transition-all duration-300 ${page === i ? 'w-8 bg-honey-500' : 'bg-white/20 hover:bg-white/40'}`}
                />
              ))}
            </div>
            <button 
              className="px-6 py-3 rounded-xl glass-panel hover:bg-white/5 text-white/70 hover:text-white transition-all disabled:opacity-30 disabled:cursor-not-allowed font-semibold"
              disabled={page >= data.totalPages - 1} 
              onClick={() => setPage((p) => p + 1)}
            >
              Next
            </button>
          </div>
        )}
      </div>
    </div>
  )
}

function ColonyCard({ colony }) {
  const soldPct = Math.max(0, Math.round(((colony.totalShares - colony.availableShares) / colony.totalShares) * 100))
  const statusConfig = STATUS_CONFIG[colony.status] || STATUS_CONFIG.COMPLETED
  
  return (
    <Link to={`/colony/${colony.id}`} className="block group">
      <div className="glass-card h-full flex flex-col">
        
        {/* Glow Effect */}
        <div className="absolute inset-0 bg-gradient-to-br from-honey-500/0 via-transparent to-honey-500/0 group-hover:from-honey-500/10 group-hover:to-honey-500/5 transition-all duration-700 pointer-events-none"></div>
        
        {/* TOP IMAGE AREA */}
        <div className="h-56 relative bg-[#0a0a0c] border-b border-white/5 overflow-hidden flex items-center justify-center">
          {/* Abstract background inside image area */}
          <div className="absolute inset-0 bg-[radial-gradient(ellipse_at_center,_var(--tw-gradient-stops))] from-honey-900/40 via-[#0a0a0c] to-[#0a0a0c] opacity-50 group-hover:scale-110 transition-transform duration-1000"></div>
          
          <span className="text-8xl drop-shadow-[0_20px_30px_rgba(0,0,0,0.8)] group-hover:-translate-y-2 group-hover:rotate-6 transition-all duration-500 relative z-10">
            🐝
          </span>
          
          <div className="absolute top-5 right-5 z-20">
            <span className={`flex items-center gap-2 px-3 py-1.5 rounded-lg text-xs font-bold tracking-wider ${statusConfig.bg} ${statusConfig.color} border ${statusConfig.border} backdrop-blur-md`}>
              <span className="w-1.5 h-1.5 rounded-full bg-current shadow-[0_0_8px_currentColor]"></span>
              {colony.status}
            </span>
          </div>
          
          {colony.isVerified && (
            <div className="absolute top-5 left-5 z-20">
              <span className="flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-xs font-bold tracking-wider bg-white/10 text-white border border-white/20 backdrop-blur-md shadow-lg">
                <ShieldCheck className="w-3.5 h-3.5 text-honey-400" /> Verified
              </span>
            </div>
          )}
        </div>

        {/* CONTENT AREA */}
        <div className="p-6 md:p-8 flex-1 flex flex-col relative z-20">
          <h3 className="text-2xl font-display font-bold text-white mb-3 group-hover:text-honey-400 transition-colors duration-300 line-clamp-1">{colony.name}</h3>
          
          <div className="flex items-center gap-2 mb-8 text-white/50">
            <MapPin className="w-4 h-4 text-honey-500" />
            <span className="text-sm font-medium">{colony.location}</span>
          </div>

          {/* STATS */}
          <div className="grid grid-cols-2 gap-4 mb-8">
            <div className="bg-black/40 rounded-2xl p-4 border border-white/5">
              <div className="text-[10px] uppercase tracking-widest text-white/40 mb-2 font-bold">Share Price</div>
              <div className="text-2xl font-bold text-white flex items-baseline gap-1">
                <span className="text-honey-500 text-lg">$</span>
                {colony.pricePerShare}
              </div>
            </div>
            <div className="bg-black/40 rounded-2xl p-4 border border-white/5">
              <div className="text-[10px] uppercase tracking-widest text-white/40 mb-2 font-bold">Est. Yield</div>
              <div className="text-2xl font-bold text-emerald-400 flex items-center gap-2">
                <TrendingUp className="w-5 h-5" />
                {colony.expectedRoiPct}%
              </div>
            </div>
          </div>

          <div className="mt-auto">
            <div className="flex justify-between items-end mb-3">
              <span className="text-xs font-bold uppercase tracking-widest text-white/40">Funding</span>
              <span className="text-sm font-bold text-white">{soldPct}%</span>
            </div>
            <div className="h-2 w-full bg-black/50 rounded-full overflow-hidden border border-white/5">
              <div 
                className="h-full bg-gradient-to-r from-honey-600 to-honey-400 rounded-full relative"
                style={{ width: `${soldPct}%` }}
              >
                <div className="absolute inset-0 w-full h-full bg-[linear-gradient(90deg,transparent,rgba(255,255,255,0.5),transparent)] -translate-x-full animate-[shimmer_2s_infinite]"></div>
              </div>
            </div>
            <div className="mt-3 text-right text-xs font-semibold text-white/30">
              {colony.availableShares} shares remaining
            </div>
          </div>
        </div>

        {/* FOOTER AREA */}
        <div className="px-6 md:px-8 py-5 border-t border-white/5 bg-white/[0.01] flex items-center justify-between">
          <div className="flex items-center gap-3">
            <div className="w-8 h-8 rounded-full bg-gradient-to-br from-honey-400 to-honey-600 flex items-center justify-center text-black font-bold text-sm shadow-lg">
              {colony.beekeeperName ? colony.beekeeperName.charAt(0).toUpperCase() : 'M'}
            </div>
            <span className="text-sm font-medium text-white/60">
              {colony.beekeeperName || 'Master Beekeeper'}
            </span>
          </div>
          <div className="w-10 h-10 rounded-full bg-white/5 flex items-center justify-center group-hover:bg-honey-500 group-hover:text-black transition-colors duration-300">
            <ArrowRight className="w-4 h-4" />
          </div>
        </div>
      </div>
    </Link>
  )
}
