import axios from 'axios'
import { useAuthStore } from '../store/authStore'

const api = axios.create({
  baseURL: '/api',
  headers: { 'Content-Type': 'application/json' },
  timeout: 15000,
})

// ── REQUEST INTERCEPTOR: Attach JWT ───────────────────
api.interceptors.request.use((config) => {
  const token = useAuthStore.getState().accessToken
  if (token) {
    config.headers.Authorization = `Bearer ${token}`
  }
  return config
})

// ── RESPONSE INTERCEPTOR: Handle 401 ─────────────────
api.interceptors.response.use(
  (response) => response,
  async (error) => {
    const originalRequest = error.config

    if (error.response?.status === 401 && !originalRequest._retry) {
      originalRequest._retry = true

      try {
        const refreshToken = useAuthStore.getState().refreshToken
        const { data } = await axios.post('/api/auth/refresh', { refreshToken })
        useAuthStore.getState().setTokens(data.accessToken, data.refreshToken)
        originalRequest.headers.Authorization = `Bearer ${data.accessToken}`
        return api(originalRequest)
      } catch {
        useAuthStore.getState().logout()
        window.location.href = '/login'
      }
    }

    return Promise.reject(error)
  }
)

// ── AUTH ──────────────────────────────────────────────
export const authApi = {
  sendOtp:          (phone)              => api.post('/auth/send-otp', { phone }),
  sendOtpEmail:     (email)              => api.post('/auth/send-otp-email', { email }),
  verifyOtp:        (phone, otpCode)     => api.post('/auth/verify-otp', { phone, otpCode }),
  verifyOtpEmail:   (email, otpCode)     => api.post('/auth/verify-otp-email', { email, otpCode }),
  refresh:          (refreshToken)       => api.post('/auth/refresh', { refreshToken }),
  updateEmail:      (email)              => api.put('/auth/email', { email }),
}

// ── COLONIES ──────────────────────────────────────────
export const colonyApi = {
  getMarketplace: (params) => api.get('/colonies', { params }),
  getById:        (id) => api.get(`/colonies/${id}`),
  create:         (data) => api.post('/colonies', data),
  updateStatus:   (id, status) => api.patch(`/colonies/${id}/status`, null, { params: { status } }),
  updateIot:      (id, data) => api.patch(`/colonies/${id}/iot`, null, { params: data }),
}

// ── INVESTMENTS ───────────────────────────────────────
export const investmentApi = {
  buy:          (data) => api.post('/investments', data),
  getMyPortfolio: (params) => api.get('/investments/my', { params }),
  getById:      (id) => api.get(`/investments/${id}`),
  setHoneyChoice: (id, choice) => api.patch(`/investments/${id}/honey-choice`, null, { params: { choice } }),
}

// ── HONEY REPORTS ─────────────────────────────────────
export const reportApi = {
  create:   (data) => api.post('/reports', data),
  finalize: (id) => api.post(`/reports/${id}/finalize`),
  byColony: (colonyId, params) => api.get(`/reports/colony/${colonyId}`, { params }),
}

// ── ADMIN ─────────────────────────────────────────────
export const adminApi = {
  getStats:       () => api.get('/admin/stats'),
  getUsers:       (params) => api.get('/admin/users', { params }),
  getUserById:    (id) => api.get(`/admin/users/${id}`),
  changeRole:     (id, role) => api.patch(`/admin/users/${id}/role`, null, { params: { role } }),
  toggleActive:   (id) => api.patch(`/admin/users/${id}/toggle-active`),
  verifyUser:     (id) => api.patch(`/admin/users/${id}/verify`),
  unverifyUser:   (id) => api.patch(`/admin/users/${id}/unverify`),
  addBalance:     (id, amount, description) => api.patch(`/admin/users/${id}/balance`, { amount, description }),
  deductBalance:  (id, amount, description) => api.patch(`/admin/users/${id}/deduct-balance`, { amount, description }),
  getColonies:    (params) => api.get('/admin/colonies', { params }),
  verifyColony:   (id) => api.post(`/admin/colonies/${id}/verify`),
  rejectColony:   (id) => api.post(`/admin/colonies/${id}/reject`),
  getTransactions: (params) => api.get('/admin/transactions', { params }),
  getSettings:    () => api.get('/admin/settings'),
  updateSettings: (data) => api.post('/admin/settings', data),
}

export default api
