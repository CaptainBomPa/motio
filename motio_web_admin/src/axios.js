import axios from 'axios';

const axiosInstance = axios.create({
    baseURL: 'http://localhost:8070/v1.0/api',
    headers: {
        'Content-Type': 'application/json'
    }
});

axiosInstance.interceptors.request.use(config => {
    const token = localStorage.getItem('accessToken');
    if (token) {
        config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
}, error => {
    return Promise.reject(error);
});

axiosInstance.interceptors.response.use(response => response, async error => {
    const originalRequest = error.config;
    if (error.response && error.response.status === 403 && !originalRequest._retry) {
        originalRequest._retry = true;
        try {
            const refreshToken = localStorage.getItem('refreshToken');
            const response = await axios.post('http://localhost:8070/v1.0/api/auth/refresh-token', {refreshToken});
            localStorage.setItem('accessToken', response.data.accessToken);
            localStorage.setItem('refreshToken', response.data.refreshToken);
            axiosInstance.defaults.headers.common['Authorization'] = `Bearer ${response.data.accessToken}`;
            originalRequest.headers['Authorization'] = `Bearer ${response.data.accessToken}`;
            return axiosInstance(originalRequest);
        } catch (err) {
            return Promise.reject(err);
        }
    }
    return Promise.reject(error);
});

export default axiosInstance;
