import { create } from 'zustand'
import { persist } from 'zustand/middleware'

export const useAuthStore = create(
  persist(
    (set) => ({
      accessToken:  null,
      refreshToken: null,
      user:         null,   // { id, phone, fullName, role }

      setAuth: (authResponse) => set({
        accessToken:  authResponse.accessToken,
        refreshToken: authResponse.refreshToken,
        user: {
          id:       authResponse.userId,
          phone:    authResponse.phone,
          fullName: authResponse.fullName,
          role:     authResponse.role,
        },
      }),

      setTokens: (accessToken, refreshToken) => set({ accessToken, refreshToken }),

      logout: () => set({ accessToken: null, refreshToken: null, user: null }),

      isAuthenticated: () => {
        // Zustand computed — call as a selector
        return Boolean(useAuthStore.getState().accessToken)
      },
    }),
    {
      name: 'melarium-auth',
      partialize: (state) => ({
        accessToken:  state.accessToken,
        refreshToken: state.refreshToken,
        user:         state.user,
      }),
    }
  )
)
