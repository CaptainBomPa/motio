import React, {useEffect, useState} from 'react';
import {Box, CircularProgress, LinearProgress, Typography} from '@mui/material';
import axios from '../axios';
import config from '../config';

const SystemInfoPage = () => {
    const [systemInfo, setSystemInfo] = useState(null);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);

    const fetchSystemInfo = async () => {
        try {
            const response = await axios.get(`${config.adminApiUrl}/system/info`);
            setSystemInfo(response.data);
            setLoading(false);
        } catch (error) {
            setError(error);
            setLoading(false);
        }
    };

    useEffect(() => {
        fetchSystemInfo();
        const intervalId = setInterval(fetchSystemInfo, 5000); // Odświeżaj dane co 5 sekund
        return () => clearInterval(intervalId); // Wyczyść interwał przy odmontowaniu komponentu
    }, []);

    if (loading) {
        return <Box display="flex" justifyContent="center" alignItems="center" height="100vh"><CircularProgress/></Box>;
    }

    if (error) {
        return <Typography color="error">Error: {error.message}</Typography>;
    }

    const totalMemoryBytes = systemInfo.totalPhysicalMemorySize || systemInfo.jvmTotalMemory;
    const freeMemoryBytes = systemInfo.freePhysicalMemorySize || systemInfo.jvmFreeMemory;
    const usedMemoryBytes = totalMemoryBytes - freeMemoryBytes;
    const memoryUsage = (usedMemoryBytes / totalMemoryBytes) * 100;

    const bytesToMegabytes = (bytes) => (bytes / (1024 * 1024)).toFixed(2);

    return (
        <Box padding="20px">
            <Typography variant="h4" gutterBottom>System Information</Typography>
            <Box marginBottom="20px">
                <Typography variant="h6">Available Processors: {systemInfo.availableProcessors}</Typography>
                <Typography variant="h6">System Load Average: {systemInfo.systemLoadAverage}</Typography>
            </Box>
            <Box marginBottom="20px">
                <Typography variant="h6">Memory Usage</Typography>
                <Typography variant="body1">Total Memory: {bytesToMegabytes(totalMemoryBytes)} MB</Typography>
                <Typography variant="body1">Free Memory: {bytesToMegabytes(freeMemoryBytes)} MB</Typography>
                <Typography variant="body1">Used Memory: {bytesToMegabytes(usedMemoryBytes)} MB</Typography>
                <LinearProgress variant="determinate" value={memoryUsage}/>
                <Typography variant="body2" color="textSecondary">{memoryUsage.toFixed(2)}% used</Typography>
            </Box>
            {systemInfo.jvmTotalMemory && (
                <Box marginBottom="20px">
                    <Typography variant="h6">JVM Memory Usage</Typography>
                    <Typography variant="body1">JVM Total Memory: {bytesToMegabytes(systemInfo.jvmTotalMemory)} MB</Typography>
                    <Typography variant="body1">JVM Free Memory: {bytesToMegabytes(systemInfo.jvmFreeMemory)} MB</Typography>
                    <Typography variant="body1">JVM Max Memory: {bytesToMegabytes(systemInfo.jvmMaxMemory)} MB</Typography>
                </Box>
            )}
        </Box>
    );
};

export default SystemInfoPage;
