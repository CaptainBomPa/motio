import React from 'react';
import {Box} from '@mui/material';
import StatusBox from './StatusBox';
import config from '../config';

const StatusPage = () => {
    return (
        <Box display="flex" justifyContent="center" flexWrap="wrap">
            <StatusBox serviceName="motio-auth" apiUrl={`${config.authApiUrl}/health/status`} containerId="motio-auth"/>
            <StatusBox serviceName="motio-core" apiUrl={`${config.coreApiUrl}/health/status`} containerId="motio-core"/>
            <StatusBox serviceName="motio-admin" apiUrl={`${config.adminApiUrl}/health/status`} containerId="motio-admin"/>
            <StatusBox serviceName="motio-notification" apiUrl={`${config.notificationApiUrl}/health/status`} containerId="motio-notification"/>
        </Box>
    );
};

export default StatusPage;
