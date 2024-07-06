import React from 'react';
import {Box} from '@mui/material';
import StatusBox from './StatusBox';

const StatusPage = () => {
    return (
        <Box display="flex" justifyContent="center" flexWrap="wrap">
            <StatusBox serviceName="motio-auth" apiUrl="http://localhost:8070/v1.0/api/auth/health/status"/>
            <StatusBox serviceName="motio-core" apiUrl="http://localhost:8080/v1.0/api/core/health/status"/>
            <StatusBox serviceName="motio-admin" apiUrl="http://localhost:8060/v1.0/api/admin/health/status"/>
        </Box>
    );
};

export default StatusPage;
