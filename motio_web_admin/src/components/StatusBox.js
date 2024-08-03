import React, {useEffect, useState} from 'react';
import {Box, Button, CircularProgress, Typography} from '@mui/material';
import CheckCircleIcon from '@mui/icons-material/CheckCircle';
import ErrorIcon from '@mui/icons-material/Error';
import ReplayIcon from '@mui/icons-material/Replay';
import axios from '../axios';
import DockerLogo from '../docker-logo.png';
import config from '../config';

const StatusBox = ({serviceName, apiUrl, containerId}) => {
    const [status, setStatus] = useState('loading');
    const [responseTime, setResponseTime] = useState(null);
    const [isDockerManaged, setIsDockerManaged] = useState(false);

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
                setResponseTime("-");
            }
        };

        const checkDockerManagement = async () => {
            try {
                const response = await axios.get(`${config.adminApiUrl}/docker/list`);
                const managedContainers = response.data;
                setIsDockerManaged(managedContainers.includes(containerId));
            } catch (error) {
                console.error('Failed to fetch docker containers:', error);
                setIsDockerManaged(false);
            }
        };

        checkStatus();
        checkDockerManagement();
        const intervalId = setInterval(() => {
            checkStatus();
            checkDockerManagement();
        }, 5000);
        return () => clearInterval(intervalId);
    }, [apiUrl, containerId]);

    const handleRestart = async () => {
        try {
            await axios.get(`${config.adminApiUrl}/docker/stop/${containerId}`);
            setStatus('loading');
        } catch (error) {
            console.error('Failed to restart container:', error);
        }
    };

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
            <Box display="flex" justifyContent="center" alignItems="center" my={2}>
                {isDockerManaged ? (
                    <>
                        <Typography variant="body2" sx={{marginRight: '8px', color: 'green'}}>
                            Uruchomione w Docker
                        </Typography>
                        <img src={DockerLogo} alt="Docker Logo" style={{width: '20px', height: '20px'}}/>
                    </>
                ) : (
                    <Typography variant="body2" sx={{color: 'red'}}>
                        Nie uruchomiono w Docker!
                    </Typography>
                )}
            </Box>
            <Box display="flex" justifyContent="center" mt={2}>
                <Button
                    variant="contained"
                    color="primary"
                    startIcon={<ReplayIcon/>}
                    onClick={handleRestart}
                    disabled={!isDockerManaged || status === 'loading'}
                >
                    Restart
                </Button>
            </Box>
        </Box>
    );
};

export default StatusBox;
