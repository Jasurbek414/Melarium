import { useRef, useEffect } from 'react'

export default function AnimatedBackground() {
  const canvasRef = useRef(null)

  useEffect(() => {
    const canvas = canvasRef.current
    if (!canvas) return
    const ctx = canvas.getContext('2d')

    let width = window.innerWidth
    let height = window.innerHeight
    let mouseX = width / 2
    let mouseY = height / 2
    let animationId

    canvas.width = width
    canvas.height = height

    const resize = () => {
      width = window.innerWidth
      height = window.innerHeight
      canvas.width = width
      canvas.height = height
    }

    const onMouse = (e) => {
      mouseX = e.clientX
      mouseY = e.clientY
    }

    window.addEventListener('resize', resize)
    window.addEventListener('mousemove', onMouse)

    // ── HEXAGON GRID ──
    const hexSize = 40
    const hexHeight = hexSize * Math.sqrt(3)
    const hexWidth = hexSize * 2

    function drawHexagon(cx, cy, size, alpha) {
      ctx.beginPath()
      for (let i = 0; i < 6; i++) {
        const angle = (Math.PI / 3) * i - Math.PI / 6
        const x = cx + size * Math.cos(angle)
        const y = cy + size * Math.sin(angle)
        if (i === 0) ctx.moveTo(x, y)
        else ctx.lineTo(x, y)
      }
      ctx.closePath()
      ctx.strokeStyle = `rgba(238, 176, 18, ${alpha})`
      ctx.lineWidth = 0.6
      ctx.stroke()
    }

    // ── PARTICLES ──
    const particles = Array.from({ length: 40 }, () => ({
      x: Math.random() * width,
      y: Math.random() * height,
      vx: (Math.random() - 0.5) * 0.4,
      vy: (Math.random() - 0.5) * 0.4 - 0.2,
      size: Math.random() * 3 + 1,
      alpha: Math.random() * 0.6 + 0.2,
      pulse: Math.random() * Math.PI * 2,
    }))

    // ── FLOATING HEXAGONS ──
    const floatingHexes = Array.from({ length: 8 }, () => ({
      x: Math.random() * width,
      y: Math.random() * height,
      size: Math.random() * 20 + 15,
      vx: (Math.random() - 0.5) * 0.3,
      vy: (Math.random() - 0.5) * 0.3,
      rotation: Math.random() * Math.PI,
      rotSpeed: (Math.random() - 0.5) * 0.005,
      alpha: Math.random() * 0.15 + 0.05,
    }))

    let time = 0

    function animate() {
      time += 0.01
      ctx.clearRect(0, 0, width, height)

      // ── 1. BACKGROUND GRADIENT ──
      const bgGrad = ctx.createRadialGradient(width / 2, height / 2, 0, width / 2, height / 2, width * 0.7)
      bgGrad.addColorStop(0, 'rgba(20, 15, 5, 0.3)')
      bgGrad.addColorStop(1, 'rgba(5, 5, 7, 0)')
      ctx.fillStyle = bgGrad
      ctx.fillRect(0, 0, width, height)

      // ── 2. HEXAGON GRID ──
      const cols = Math.ceil(width / (hexWidth * 0.75)) + 2
      const rows = Math.ceil(height / hexHeight) + 2

      for (let row = -1; row < rows; row++) {
        for (let col = -1; col < cols; col++) {
          const x = col * hexWidth * 0.75
          const y = row * hexHeight + (col % 2 === 0 ? 0 : hexHeight / 2)

          // Distance from mouse
          const dx = x - mouseX
          const dy = y - mouseY
          const dist = Math.sqrt(dx * dx + dy * dy)

          // Base alpha + mouse proximity boost
          let alpha = 0.04 + Math.sin(time + col * 0.3 + row * 0.2) * 0.02
          if (dist < 300) {
            alpha += (1 - dist / 300) * 0.15
          }

          drawHexagon(x, y, hexSize, alpha)

          // Fill hexagons close to mouse with subtle glow
          if (dist < 200) {
            ctx.fillStyle = `rgba(238, 176, 18, ${(1 - dist / 200) * 0.04})`
            ctx.fill()
          }
        }
      }

      // ── 3. MOUSE GLOW ──
      const glowGrad = ctx.createRadialGradient(mouseX, mouseY, 0, mouseX, mouseY, 250)
      glowGrad.addColorStop(0, 'rgba(238, 176, 18, 0.08)')
      glowGrad.addColorStop(0.5, 'rgba(238, 176, 18, 0.03)')
      glowGrad.addColorStop(1, 'rgba(238, 176, 18, 0)')
      ctx.fillStyle = glowGrad
      ctx.fillRect(mouseX - 250, mouseY - 250, 500, 500)

      // ── 4. AMBIENT GLOW ORBS ──
      const orbs = [
        { x: width * 0.2, y: height * 0.3, r: 300, phase: 0 },
        { x: width * 0.8, y: height * 0.6, r: 250, phase: 2 },
        { x: width * 0.5, y: height * 0.8, r: 200, phase: 4 },
      ]
      orbs.forEach(orb => {
        const ox = orb.x + Math.sin(time * 0.5 + orb.phase) * 50
        const oy = orb.y + Math.cos(time * 0.3 + orb.phase) * 40
        const orbGrad = ctx.createRadialGradient(ox, oy, 0, ox, oy, orb.r)
        orbGrad.addColorStop(0, 'rgba(238, 176, 18, 0.06)')
        orbGrad.addColorStop(1, 'rgba(238, 176, 18, 0)')
        ctx.fillStyle = orbGrad
        ctx.beginPath()
        ctx.arc(ox, oy, orb.r, 0, Math.PI * 2)
        ctx.fill()
      })

      // ── 5. PARTICLES ──
      particles.forEach(p => {
        p.x += p.vx
        p.y += p.vy
        p.pulse += 0.03

        // Wrap around
        if (p.x < 0) p.x = width
        if (p.x > width) p.x = 0
        if (p.y < 0) p.y = height
        if (p.y > height) p.y = 0

        const currentAlpha = p.alpha * (0.5 + Math.sin(p.pulse) * 0.5)
        const currentSize = p.size * (0.8 + Math.sin(p.pulse) * 0.2)

        ctx.beginPath()
        ctx.arc(p.x, p.y, currentSize, 0, Math.PI * 2)
        ctx.fillStyle = `rgba(238, 176, 18, ${currentAlpha})`
        ctx.fill()

        // Glow
        const pGrad = ctx.createRadialGradient(p.x, p.y, 0, p.x, p.y, currentSize * 4)
        pGrad.addColorStop(0, `rgba(238, 176, 18, ${currentAlpha * 0.3})`)
        pGrad.addColorStop(1, 'rgba(238, 176, 18, 0)')
        ctx.fillStyle = pGrad
        ctx.beginPath()
        ctx.arc(p.x, p.y, currentSize * 4, 0, Math.PI * 2)
        ctx.fill()
      })

      // ── 6. FLOATING HEXAGONS ──
      floatingHexes.forEach(h => {
        h.x += h.vx
        h.y += h.vy
        h.rotation += h.rotSpeed

        if (h.x < -50) h.x = width + 50
        if (h.x > width + 50) h.x = -50
        if (h.y < -50) h.y = height + 50
        if (h.y > height + 50) h.y = -50

        ctx.save()
        ctx.translate(h.x, h.y)
        ctx.rotate(h.rotation)

        ctx.beginPath()
        for (let i = 0; i < 6; i++) {
          const angle = (Math.PI / 3) * i
          const px = h.size * Math.cos(angle)
          const py = h.size * Math.sin(angle)
          if (i === 0) ctx.moveTo(px, py)
          else ctx.lineTo(px, py)
        }
        ctx.closePath()
        ctx.strokeStyle = `rgba(238, 176, 18, ${h.alpha})`
        ctx.lineWidth = 1
        ctx.stroke()

        ctx.restore()
      })

      // ── 7. CONNECTION LINES (near mouse) ──
      const nearParticles = particles.filter(p => {
        const dx = p.x - mouseX
        const dy = p.y - mouseY
        return Math.sqrt(dx * dx + dy * dy) < 200
      })
      nearParticles.forEach(p => {
        ctx.beginPath()
        ctx.moveTo(mouseX, mouseY)
        ctx.lineTo(p.x, p.y)
        const dx = p.x - mouseX
        const dy = p.y - mouseY
        const dist = Math.sqrt(dx * dx + dy * dy)
        ctx.strokeStyle = `rgba(238, 176, 18, ${(1 - dist / 200) * 0.1})`
        ctx.lineWidth = 0.5
        ctx.stroke()
      })

      animationId = requestAnimationFrame(animate)
    }

    animate()

    return () => {
      cancelAnimationFrame(animationId)
      window.removeEventListener('resize', resize)
      window.removeEventListener('mousemove', onMouse)
    }
  }, [])

  return (
    <canvas
      ref={canvasRef}
      className="fixed inset-0 pointer-events-none"
      style={{ zIndex: 0 }}
    />
  )
}
