const config = {
    adminApiUrl: process.env.REACT_APP_ADMIN_API_URL || 'http://localhost:8060/v1.0/api/admin',
    coreApiUrl: process.env.REACT_APP_CORE_API_URL || 'http://localhost:8080/v1.0/api/core',
    authApiUrl: process.env.REACT_APP_AUTH_API_URL || 'http://localhost:8070/v1.0/api/auth',
};

export default config;
