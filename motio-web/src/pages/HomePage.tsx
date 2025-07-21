import React from "react";
import {Button, Container, Typography} from "@mui/material";
import {useNavigate} from "react-router-dom";
import {logout} from "../services/authService";

const HomePage = () => {
    const navigate = useNavigate();

    const handleLogout = () => {
        logout();
        navigate("/login");
    };

    return (
        <Container maxWidth="sm" sx={{mt: 12, textAlign: "center"}}>
            <Typography variant="h4" gutterBottom>
                🎉 Udało się zalogować!
            </Typography>
            <Button variant="contained" color="secondary" onClick={handleLogout}>
                Wyloguj się
            </Button>
        </Container>
    );
};

export default HomePage;
