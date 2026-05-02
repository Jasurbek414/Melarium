import { Routes, Route, Navigate } from 'react-router-dom'
import { useAuthStore } from './store/authStore'
import Login from './pages/Login'
import Marketplace from './pages/Marketplace'
import ColonyDetail from './pages/ColonyDetail'
import InvestorDashboard from './pages/InvestorDashboard'
import BeekeeperDashboard from './pages/BeekeeperDashboard'
import AdminPanel from './pages/AdminPanel'
import Layout from './components/Layout'

function ProtectedRoute({ children, roles }) {
  const user = useAuthStore((s) => s.user)
  const accessToken = useAuthStore((s) => s.accessToken)

  if (!accessToken) return <Navigate to="/login" replace />
  if (roles && !roles.includes(user?.role)) return <Navigate to="/" replace />

  return children
}

export default function App() {
  const accessToken = useAuthStore((s) => s.accessToken)

  return (
    <Routes>
      <Route path="/login" element={accessToken ? <Navigate to="/" replace /> : <Login />} />

      <Route element={<Layout />}>
        <Route path="/" element={<Marketplace />} />
        <Route path="/colony/:id" element={<ColonyDetail />} />

        <Route
          path="/dashboard"
          element={
            <ProtectedRoute roles={['INVESTOR']}>
              <InvestorDashboard />
            </ProtectedRoute>
          }
        />

        <Route
          path="/beekeeper"
          element={
            <ProtectedRoute roles={['BEEKEEPER']}>
              <BeekeeperDashboard />
            </ProtectedRoute>
          }
        />

        <Route
          path="/admin"
          element={
            <ProtectedRoute roles={['ADMIN']}>
              <AdminPanel />
            </ProtectedRoute>
          }
        />
      </Route>

      <Route path="*" element={<Navigate to="/" replace />} />
    </Routes>
  )
}
