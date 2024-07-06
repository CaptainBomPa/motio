import React, {useState} from 'react';
import {useNavigate} from 'react-router-dom';
import {Box, Button, Grid, Paper, TextField} from '@mui/material';
import axios from '../axios';
import logo from '../logo.png';

export default function LoginPage() {
    const [username, setUsername] = useState('');
    const [password, setPassword] = useState('');
    const navigate = useNavigate();

    const isAuthenticated = !!localStorage.getItem('accessToken');
    if (isAuthenticated) {
        navigate('/home/status');
    }

    const handleLogin = async () => {
        try {
            const response = await axios.post('/auth/login/admin', {username, password});
            localStorage.setItem('accessToken', response.data.accessToken);
            localStorage.setItem('refreshToken', response.data.refreshToken);
            navigate('/home/status');
        } catch (error) {
            alert('Nie udało się zalogować. Sprawdź swoje dane lub uprawnienia.');
        }
    };

    return (
        <Box display="flex" justifyContent="center" alignItems="center" minHeight="100vh" bgcolor="background.default">
            <Paper elevation={3} style={{width: '70%', display: 'flex'}}>
                <Grid container>
                    <Grid item xs={6} style={{display: 'flex', justifyContent: 'center', alignItems: 'center'}}>
                        <img src={logo} alt="Logo" style={{width: '80%', padding: 20}}/>
                    </Grid>
                    <Grid item xs={6} style={{display: 'flex', flexDirection: 'column', justifyContent: 'center', alignItems: 'center', padding: 20}}>
                        <TextField
                            label="Login"
                            variant="outlined"
                            value={username}
                            onChange={e => setUsername(e.target.value)}
                            style={{marginBottom: 20, width: '100%'}}
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
                        <TextField
                            label="Hasło"
                            type="password"
                            variant="outlined"
                            value={password}
                            onChange={e => setPassword(e.target.value)}
                            style={{marginBottom: 20, width: '100%'}}
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
                        <Button
                            variant="contained"
                            style={{backgroundColor: '#9c27b0', color: '#fff', width: '100%'}}
                            onClick={handleLogin}
                        >
                            ZALOGUJ
                        </Button>
                    </Grid>
                </Grid>
            </Paper>
        </Box>
    );
}
