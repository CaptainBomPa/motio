import React, {useState} from "react";
import {Alert, Box, Button, Collapse, IconButton, Paper, TextField} from "@mui/material";
import CloseIcon from "@mui/icons-material/Close";
import {useForm} from "react-hook-form";
import {yupResolver} from "@hookform/resolvers/yup";
import * as yup from "yup";

const schema = yup.object({
    username: yup.string().required(),
    password: yup.string().required(),
});

interface LoginFormProps {
    setIsLoading: (value: boolean) => void;
    switchToRegister: () => void;
}

const LoginForm = ({setIsLoading, switchToRegister}: LoginFormProps) => {
    const [errorMessage, setErrorMessage] = useState("");
    const [loading, setLoading] = useState(false);

    const {
        register,
        handleSubmit,
        formState: {isValid},
    } = useForm({
        resolver: yupResolver(schema),
        mode: "onChange",
    });

    const onLoading = (loading: boolean) => {
        setIsLoading(loading);
        setLoading(loading);
    }

    const onSubmit = async (data: any) => {
        onLoading(true);
        setErrorMessage("");
        try {
            await new Promise((_, reject) => setTimeout(() => reject(new Error("timeout")), 2000));
        } catch (err: any) {
            if (err.message === "timeout") {
                setErrorMessage("Serwer nie odpowiada. Spróbuj ponownie później.");
            } else {
                setErrorMessage("Nieprawidłowa nazwa użytkownika lub hasło.");
            }
        } finally {
            onLoading(false);
        }
    };

    return (
        <Paper elevation={4} sx={{p: 6, borderRadius: 4, width: "100%", maxWidth: 500}}>
            <Collapse in={!!errorMessage}>
                <Alert
                    severity="error"
                    sx={{mb: 3, minHeight: 56}}
                    action={
                        <IconButton
                            aria-label="close"
                            color="inherit"
                            size="small"
                            onClick={() => setErrorMessage("")}
                        >
                            <CloseIcon fontSize="inherit"/>
                        </IconButton>
                    }
                >
                    {errorMessage || <span style={{visibility: "hidden"}}>.</span>}
                </Alert>
            </Collapse>
            <Box
                component="form"
                onSubmit={handleSubmit(onSubmit)}
                sx={{mt: 2, display: "flex", flexDirection: "column", gap: 3}}
            >
                <TextField
                    label="Nazwa użytkownika"
                    variant="outlined"
                    fullWidth
                    autoComplete="username"
                    color="secondary"
                    {...register("username")}
                />
                <TextField
                    label="Hasło"
                    variant="outlined"
                    type="password"
                    fullWidth
                    autoComplete="current-password"
                    color="secondary"
                    {...register("password")}
                />
                <Button
                    type="submit"
                    variant="contained"
                    color="secondary"
                    size="large"
                    sx={{mt: 1, py: 1.5, fontWeight: 600}}
                    fullWidth
                    disabled={!isValid || loading}
                >
                    {loading ? "Logowanie..." : "Zaloguj się"}
                </Button>
                <Button
                    variant="outlined"
                    color="success"
                    fullWidth
                    sx={{mt: 0, py: 1.5, fontWeight: 600}}
                    onClick={switchToRegister}
                >
                    Utwórz konto
                </Button>
            </Box>
        </Paper>
    );
};

export default LoginForm;
