import {authApi} from "../api/axiosInstances";

export interface LoginRequest {
    username: string;
    password: string;
}

export interface JwtResponse {
    accessToken: string;
    refreshToken: string;
}

export interface RegisterRequest {
    username: string;
    firstName: string;
    lastName: string;
    password: string;
    email: string;
}

export interface UserResponse {
    id: string;
    username: string;
    firstName: string;
    lastName: string;
    email: string;
}

export const login = async (data: LoginRequest): Promise<JwtResponse> => {
    const response = await authApi.post<JwtResponse>("/v1.0/api/auth/login", data);
    const {accessToken, refreshToken} = response.data;

    localStorage.setItem("accessToken", accessToken);
    localStorage.setItem("refreshToken", refreshToken);

    return response.data;
};

export const registerUser = async (data: RegisterRequest): Promise<UserResponse> => {
    const response = await authApi.post<UserResponse>("/v1.0/api/auth/register", {
        ...data,
        role: "USER",
    });
    return response.data;
};


export const logout = () => {
    localStorage.removeItem("accessToken");
    localStorage.removeItem("refreshToken");
};
