import axios from 'axios';

const api = axios.create({
    baseURL: 'http://187.127.143.43:5001/api',
});

// Add interceptor to attach token automatically
api.interceptors.request.use((config) => {
    const user = JSON.parse(localStorage.getItem('user'));
    if (user && user.token) {
        config.headers.Authorization = `Bearer ${user.token}`;
    }
    return config;
});

export default api;
