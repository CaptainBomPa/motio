import axios from "axios";

const authApi = axios.create({
    baseURL: process.env.REACT_APP_AUTH_API_URL || "http://localhost:8070",
    withCredentials: true,
});

const coreApi = axios.create({
    baseURL: process.env.REACT_APP_CORE_API_URL || "http://localhost:8080",
    withCredentials: true,
});

export {authApi, coreApi};
