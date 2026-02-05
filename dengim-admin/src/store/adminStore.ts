import { create } from 'zustand';
import { User, Report, DashboardStats, Notification, SupportTicket } from '@/types';

interface AdminState {
    // Auth
    currentAdmin: {
        id: string;
        name: string;
        email: string;
        avatar?: string;
        role: 'super_admin' | 'admin' | 'moderator' | 'support';
    } | null;

    // UI State
    sidebarOpen: boolean;
    darkMode: boolean;

    // Data
    dashboardStats: DashboardStats | null;
    notifications: Notification[];
    unreadNotificationCount: number;

    // Selected Items
    selectedUsers: string[];
    selectedReports: string[];

    // Actions
    setSidebarOpen: (open: boolean) => void;
    toggleSidebar: () => void;
    setDarkMode: (dark: boolean) => void;
    toggleDarkMode: () => void;
    setDashboardStats: (stats: DashboardStats) => void;
    addNotification: (notification: Notification) => void;
    markNotificationRead: (id: string) => void;
    markAllNotificationsRead: () => void;
    setSelectedUsers: (ids: string[]) => void;
    toggleUserSelection: (id: string) => void;
    clearUserSelection: () => void;
    setSelectedReports: (ids: string[]) => void;
    toggleReportSelection: (id: string) => void;
    clearReportSelection: () => void;
    setCurrentAdmin: (admin: AdminState['currentAdmin']) => void;
    logout: () => void;
}

export const useAdminStore = create<AdminState>((set) => ({
    // Initial State
    currentAdmin: null,
    sidebarOpen: true,
    darkMode: true,
    dashboardStats: null,
    notifications: [],
    unreadNotificationCount: 0,
    selectedUsers: [],
    selectedReports: [],

    // Actions
    setSidebarOpen: (open) => set({ sidebarOpen: open }),
    toggleSidebar: () => set((state) => ({ sidebarOpen: !state.sidebarOpen })),
    setDarkMode: (dark) => set({ darkMode: dark }),
    toggleDarkMode: () => set((state) => ({ darkMode: !state.darkMode })),

    setDashboardStats: (stats) => set({ dashboardStats: stats }),

    addNotification: (notification) => set((state) => ({
        notifications: [notification, ...state.notifications],
        unreadNotificationCount: state.unreadNotificationCount + 1,
    })),

    markNotificationRead: (id) => set((state) => ({
        notifications: state.notifications.map(n =>
            n.id === id ? { ...n, read: true } : n
        ),
        unreadNotificationCount: Math.max(0, state.unreadNotificationCount - 1),
    })),

    markAllNotificationsRead: () => set((state) => ({
        notifications: state.notifications.map(n => ({ ...n, read: true })),
        unreadNotificationCount: 0,
    })),

    setSelectedUsers: (ids) => set({ selectedUsers: ids }),

    toggleUserSelection: (id) => set((state) => ({
        selectedUsers: state.selectedUsers.includes(id)
            ? state.selectedUsers.filter(uid => uid !== id)
            : [...state.selectedUsers, id],
    })),

    clearUserSelection: () => set({ selectedUsers: [] }),

    setSelectedReports: (ids) => set({ selectedReports: ids }),

    toggleReportSelection: (id) => set((state) => ({
        selectedReports: state.selectedReports.includes(id)
            ? state.selectedReports.filter(rid => rid !== id)
            : [...state.selectedReports, id],
    })),

    clearReportSelection: () => set({ selectedReports: [] }),

    setCurrentAdmin: (admin) => set({ currentAdmin: admin }),

    logout: () => set({ currentAdmin: null }),
}));

// Selectors
export const selectIsAuthenticated = (state: AdminState) => state.currentAdmin !== null;
export const selectIsSuperAdmin = (state: AdminState) => state.currentAdmin?.role === 'super_admin';
export const selectCanModerate = (state: AdminState) =>
    ['super_admin', 'admin', 'moderator'].includes(state.currentAdmin?.role || '');
