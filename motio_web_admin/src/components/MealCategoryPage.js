import React, {useEffect, useState} from 'react';
import {Box, Button, Paper, Table, TableBody, TableCell, TableContainer, TableHead, TableRow, TextField} from '@mui/material';
import mealCategoryService from '../services/mealCategoryService';
import config from "../config";

export default function MealCategoryPage() {
    const [mealCategories, setMealCategories] = useState([]);
    const [images, setImages] = useState({});
    const [newCategoryName, setNewCategoryName] = useState('');
    const [newCategoryImage, setNewCategoryImage] = useState(null);

    useEffect(() => {
        fetchMealCategories();
    }, []);

    useEffect(() => {
        mealCategories.forEach(category => {
            fetchImageWithToken(`${config.coreApiUrl}/images/mealCategories/${category.name}`)
                .then(imgUrl => {
                    setImages(prevImages => ({...prevImages, [category.name]: imgUrl}));
                })
                .catch(error => console.error(`Failed to load image for category ${category.name}`, error));
        });
    }, [mealCategories]);

    const fetchMealCategories = async () => {
        try {
            const data = await mealCategoryService.getAllMealCategories();
            setMealCategories(data);
        } catch (error) {
            console.error(error);
        }
    };

    const handleAddCategory = async () => {
        try {
            // Dodanie nowej kategorii
            await mealCategoryService.createMealCategory(newCategoryName);

            // Przesłanie obrazka
            if (newCategoryImage) {
                await mealCategoryService.uploadImage(newCategoryName, newCategoryImage);
            }

            // Odświeżenie listy kategorii
            fetchMealCategories();
            setNewCategoryName('');
            setNewCategoryImage(null);
        } catch (error) {
            console.error("Error adding meal category", error);
        }
    };

    const handleImageChange = (event) => {
        setNewCategoryImage(event.target.files[0]);
    };

    const fetchImageWithToken = async (imageUrl) => {
        const token = localStorage.getItem('accessToken');
        const response = await fetch(imageUrl, {
            headers: {
                'Authorization': `Bearer ${token}`
            }
        });
        const blob = await response.blob();
        return URL.createObjectURL(blob);
    };

    return (
        <Box>
            <Box component={Paper} p={2} mb={2}>
                <form>
                    <TextField
                        label="Nazwa kategorii"
                        value={newCategoryName}
                        onChange={(e) => setNewCategoryName(e.target.value)}
                        fullWidth
                        margin="normal"
                        InputLabelProps={{
                            style: {color: '#9c27b0'},
                        }}
                        InputProps={{
                            style: {borderColor: '#9c27b0'},
                        }}
                        sx={{
                            '& .MuiOutlinedInput-root': {
                                '& fieldset': {
                                    borderColor: '#9c27b0',
                                },
                                '&:hover fieldset': {
                                    borderColor: '#9c27b0',
                                },
                                '&.Mui-focused fieldset': {
                                    borderColor: '#9c27b0',
                                },
                            },
                        }}
                    />
                    <input
                        type="file"
                        accept="image/*"
                        onChange={handleImageChange}
                        style={{display: 'block', margin: '10px 0'}}
                    />
                    <Button variant="contained" color="primary" onClick={handleAddCategory} style={{backgroundColor: '#9c27b0', color: '#fff', width: '100%'}}>
                        DODAJ
                    </Button>
                </form>
            </Box>
            <TableContainer component={Paper}>
                <Table>
                    <TableHead>
                        <TableRow>
                            <TableCell>Nazwa kategorii</TableCell>
                            <TableCell>Ścieżka obrazu</TableCell>
                            <TableCell>Miniatura</TableCell>
                        </TableRow>
                    </TableHead>
                    <TableBody>
                        {mealCategories.map((category) => (
                            <TableRow key={category.name}>
                                <TableCell>{category.name}</TableCell>
                                <TableCell>{category.imagePath}</TableCell>
                                <TableCell>
                                    {images[category.name] ? (
                                        <img
                                            src={images[category.name]}
                                            alt={category.name}
                                            style={{width: '50px', height: '50px'}}
                                        />
                                    ) : (
                                        'Ładowanie...'
                                    )}
                                </TableCell>
                            </TableRow>
                        ))}
                    </TableBody>
                </Table>
            </TableContainer>
        </Box>
    );
}
