import React, {useEffect, useState} from 'react';
import {Box, CircularProgress, Typography} from '@mui/material';
import CheckCircleIcon from '@mui/icons-material/CheckCircle';
import ErrorIcon from '@mui/icons-material/Error';
import axios from '../axios';

const StatusBox = ({serviceName, apiUrl}) => {
    const [status, setStatus] = useState('loading');
    const [responseTime, setResponseTime] = useState(null);

    useEffect(() => {
        const checkStatus = async () => {
            const startTime = Date.now();
            try {
                await axios.get(apiUrl);
                const endTime = Date.now();
                setStatus('ok');
                setResponseTime(endTime - startTime);
            } catch (error) {
                setStatus('error');
                const endTime = Date.now();
                setResponseTime(endTime - startTime);
            }
        };
        checkStatus();
        const intervalId = setInterval(checkStatus, 5000);
        return () => clearInterval(intervalId);
    }, [apiUrl]);

    return (
        <Box
            sx={{
                border: '1px solid black',
                borderRadius: '10px',
                padding: '16px',
                width: '300px',
                margin: '16px',
                textAlign: 'center',
                backgroundColor: '#f5f5f5',
            }}
        >
            <Typography variant="h6" fontWeight="bold">
                {serviceName}
            </Typography>
            <Box display="flex" justifyContent="center" alignItems="center" my={2}>
                <Typography variant="body1" sx={{marginRight: '8px'}}>
                    Status:
                </Typography>
                {status === 'loading' && <CircularProgress size={24}/>}
                {status === 'ok' && <CheckCircleIcon color="success"/>}
                {status === 'error' && <ErrorIcon color="error"/>}
            </Box>
            {responseTime !== null && (
                <Typography variant="body2">Czas odpowiedzi: {responseTime}ms</Typography>
            )}
        </Box>
    );
};

export default StatusBox;
