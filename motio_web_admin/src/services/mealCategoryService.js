import axiosInstance from '../axios';
import config from '../config';

const API_URL = `${config.coreApiUrl}/mealCategories`;

const getAllMealCategories = async () => {
    try {
        const response = await axiosInstance.get(API_URL);
        return response.data;
    } catch (error) {
        console.error("Error fetching meal categories", error);
        throw error;
    }
};

const createMealCategory = async (name) => {
    try {
        const response = await axiosInstance.post(API_URL, {name});
        return response.data;
    } catch (error) {
        console.error("Error creating meal category", error);
        throw error;
    }
};

const uploadImage = async (name, file) => {
    try {
        const formData = new FormData();
        formData.append('file', file);

        const response = await axiosInstance.post(`${API_URL}/${name}/image`, formData, {
            headers: {
                'Content-Type': 'multipart/form-data',
            },
        });
        return response.data;
    } catch (error) {
        console.error("Error uploading image", error);
        throw error;
    }
};

const mealCategoryService = {
    getAllMealCategories,
    createMealCategory,
    uploadImage,
};

export default mealCategoryService;
