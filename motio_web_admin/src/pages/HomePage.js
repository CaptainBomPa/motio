import React from 'react';
import {Link, Navigate, Route, Routes, useNavigate} from 'react-router-dom';
import {Box, Button, List, ListItem, ListItemText, Paper} from '@mui/material';
import StatusPage from '../components/StatusPage';
import MealCategoryPage from '../components/MealCategoryPage';
import SystemInfoPage from '../components/SystemInfoPage';

const listItemStyle = {
    fontWeight: 'bold',
    border: '1px solid #9c27b0',
    borderRadius: '8px',
    marginBottom: '10px',
    color: '#9c27b0',
    '&:hover': {
        backgroundColor: '#f3e5f5',
    },
};

export default function HomePage() {
    const navigate = useNavigate();

    const handleLogout = () => {
        localStorage.removeItem('accessToken');
        localStorage.removeItem('refreshToken');
        navigate('/login');
    };

    return (
        <Box display="flex">
            <Paper style={{width: '200px', padding: '20px'}}>
                <List>
                    <ListItem component={Link} to="/home/status" sx={listItemStyle}>
                        <ListItemText primary="Status" primaryTypographyProps={{fontWeight: 'bold', color: '#9c27b0'}}/>
                    </ListItem>
                    <ListItem component={Link} to="/home/meal-category" sx={listItemStyle}>
                        <ListItemText primary="Meal Category" primaryTypographyProps={{fontWeight: 'bold', color: '#9c27b0'}}/>
                    </ListItem>
                    <ListItem component={Link} to="/home/system-info" sx={listItemStyle}>
                        <ListItemText primary="System Info" primaryTypographyProps={{fontWeight: 'bold', color: '#9c27b0'}}/>
                    </ListItem>
                    <ListItem component={Button} sx={listItemStyle} onClick={handleLogout}>
                        <ListItemText primary="Wyloguj" primaryTypographyProps={{fontWeight: 'bold', color: '#9c27b0'}}/>
                    </ListItem>
                </List>
            </Paper>
            <Box flexGrow={1} padding="20px">
                <Routes>
                    <Route path="status" element={<StatusPage/>}/>
                    <Route path="meal-category" element={<MealCategoryPage/>}/>
                    <Route path="system-info" element={<SystemInfoPage/>}/> {/* Nowy route */}
                    <Route path="/" element={<Navigate to="status"/>}/>
                </Routes>
            </Box>
        </Box>
    );
}
