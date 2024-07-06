import React, {useEffect, useState} from 'react';
import {Box, CircularProgress, LinearProgress, Typography} from '@mui/material';
import axios from '../axios';

const SystemInfoPage = () => {
    const [systemInfo, setSystemInfo] = useState(null);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);

    useEffect(() => {
        const fetchSystemInfo = async () => {
            try {
                const response = await axios.get('http://localhost:8060/v1.0/api/admin/system/info');
                setSystemInfo(response.data);
                setLoading(false);
            } catch (error) {
                setError(error);
                setLoading(false);
            }
        };

        fetchSystemInfo();
    }, []);

    if (loading) {
        return <Box display="flex" justifyContent="center" alignItems="center" height="100vh"><CircularProgress/></Box>;
    }

    if (error) {
        return <Typography color="error">Error: {error.message}</Typography>;
    }

    const totalMemory = systemInfo.totalMemory;
    const freeMemory = systemInfo.freeMemory;
    const usedMemory = totalMemory - freeMemory;
    const memoryUsage = (usedMemory / totalMemory) * 100;

    return (
        <Box padding="20px">
            <Typography variant="h4" gutterBottom>System Information</Typography>
            <Box marginBottom="20px">
                <Typography variant="h6">Available Processors: {systemInfo.availableProcessors}</Typography>
                <Typography variant="h6">System Load Average: {systemInfo.systemLoadAverage}</Typography>
            </Box>
            <Box>
                <Typography variant="h6">Memory Usage</Typography>
                <Typography variant="body1">Total Memory: {totalMemory} bytes</Typography>
                <Typography variant="body1">Free Memory: {freeMemory} bytes</Typography>
                <Typography variant="body1">Used Memory: {usedMemory} bytes</Typography>
                <LinearProgress variant="determinate" value={memoryUsage}/>
                <Typography variant="body2" color="textSecondary">{memoryUsage.toFixed(2)}% used</Typography>
            </Box>
        </Box>
    );
};

export default SystemInfoPage;
