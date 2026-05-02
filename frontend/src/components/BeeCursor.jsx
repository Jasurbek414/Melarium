import { useEffect, useRef } from 'react'

export default function BeeCursor() {
  const cursorRef = useRef(null)
  const trailRef = useRef(null)

  useEffect(() => {
    const cursor = cursorRef.current
    const trail = trailRef.current
    if (!cursor || !trail) return

    let mouseX = 0, mouseY = 0
    let trailX = 0, trailY = 0

    const onMouseMove = (e) => {
      mouseX = e.clientX
      mouseY = e.clientY
      cursor.style.left = mouseX + 'px'
      cursor.style.top = mouseY + 'px'
    }

    // Smooth trail follow
    const animateTrail = () => {
      trailX += (mouseX - trailX) * 0.15
      trailY += (mouseY - trailY) * 0.15
      trail.style.left = trailX + 'px'
      trail.style.top = trailY + 'px'
      requestAnimationFrame(animateTrail)
    }

    const onMouseDown = () => cursor.classList.add('clicking')
    const onMouseUp = () => cursor.classList.remove('clicking')

    // Detect hovering over interactive elements
    const onMouseOver = (e) => {
      const el = e.target.closest('a, button, input, select, textarea, [role="button"], .glass-card, .btn-premium')
      if (el) {
        trail.classList.add('hovering')
      }
    }
    const onMouseOut = (e) => {
      const el = e.target.closest('a, button, input, select, textarea, [role="button"], .glass-card, .btn-premium')
      if (el) {
        trail.classList.remove('hovering')
      }
    }

    document.addEventListener('mousemove', onMouseMove)
    document.addEventListener('mousedown', onMouseDown)
    document.addEventListener('mouseup', onMouseUp)
    document.addEventListener('mouseover', onMouseOver)
    document.addEventListener('mouseout', onMouseOut)
    animateTrail()

    return () => {
      document.removeEventListener('mousemove', onMouseMove)
      document.removeEventListener('mousedown', onMouseDown)
      document.removeEventListener('mouseup', onMouseUp)
      document.removeEventListener('mouseover', onMouseOver)
      document.removeEventListener('mouseout', onMouseOut)
    }
  }, [])

  return (
    <>
      <div ref={trailRef} id="bee-trail" />
      <div ref={cursorRef} id="bee-cursor">🐝</div>
    </>
  )
}
