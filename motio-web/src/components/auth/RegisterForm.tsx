import React, {useState} from "react";
import {Alert, Box, Button, Collapse, IconButton, Paper, TextField} from "@mui/material";
import CloseIcon from "@mui/icons-material/Close";
import {useForm} from "react-hook-form";
import {yupResolver} from "@hookform/resolvers/yup";
import * as yup from "yup";
import {registerUser} from "../../services/authService";

const schema = yup.object({
    username: yup.string().required("Nazwa użytkownika jest wymagana"),
    firstName: yup.string().required("Imię jest wymagane"),
    lastName: yup.string().required("Nazwisko jest wymagane"),
    email: yup.string().email("Nieprawidłowy email").required("Email jest wymagany"),
    password: yup.string().min(8, "Hasło musi mieć min. 8 znaków").required("Hasło jest wymagane"),
    confirmPassword: yup
        .string()
        .oneOf([yup.ref("password")], "Hasła muszą być takie same")
        .required("Powtórz hasło"),
});

interface RegisterFormProps {
    setIsLoading: (value: boolean) => void;
    switchToLogin: () => void;
}

const RegisterForm = ({setIsLoading, switchToLogin}: RegisterFormProps) => {
    const [loading, setLoading] = useState(false);
    const [errorMessage, setErrorMessage] = useState("");
    const [successMessage, setSuccessMessage] = useState("");

    const {
        register,
        handleSubmit,
        formState: {errors, isValid},
    } = useForm({
        resolver: yupResolver(schema),
        mode: "onChange",
    });

    const onLoading = (state: boolean) => {
        setIsLoading(state);
        setLoading(state);
    };

    const onSubmit = async (data: any) => {
        onLoading(true);
        setErrorMessage("");
        try {
            await registerUser({
                username: data.username,
                firstName: data.firstName,
                lastName: data.lastName,
                email: data.email,
                password: data.password,
            });
            setSuccessMessage("Rejestracja przebiegła pomyślnie. Zostaniesz przekierowany do formularza Logowania");
            setTimeout(() => switchToLogin(), 3000);
        } catch (err: any) {
            setErrorMessage("Coś poszło nie tak. Spróbuj ponownie później.");
        } finally {
            onLoading(false);
        }
    };

    return (
        <Paper elevation={4} sx={{p: 6, borderRadius: 4, width: "100%", maxWidth: 500}}>
            <Collapse in={!!errorMessage || !!successMessage}>
                <Alert
                    severity={successMessage ? "success" : "error"}
                    sx={{mb: 3, minHeight: 56}}
                    action={
                        <IconButton
                            aria-label="close"
                            color="inherit"
                            size="small"
                            onClick={() => {
                                setErrorMessage("");
                                setSuccessMessage("");
                            }}
                        >
                            <CloseIcon fontSize="inherit"/>
                        </IconButton>
                    }
                >
                    {errorMessage || successMessage}
                </Alert>
            </Collapse>
            <Box
                component="form"
                onSubmit={handleSubmit(onSubmit)}
                sx={{display: "flex", flexDirection: "column", gap: 3}}
            >
                <TextField label="Nazwa użytkownika" fullWidth color="secondary" {...register("username")} error={!!errors.username} helperText={errors.username?.message}/>
                <TextField label="Imię" fullWidth color="secondary" {...register("firstName")} error={!!errors.firstName} helperText={errors.firstName?.message}/>
                <TextField label="Nazwisko" fullWidth color="secondary" {...register("lastName")} error={!!errors.lastName} helperText={errors.lastName?.message}/>
                <TextField label="Email" fullWidth color="secondary" {...register("email")} error={!!errors.email} helperText={errors.email?.message}/>
                <TextField label="Hasło" type="password" fullWidth color="secondary" {...register("password")} error={!!errors.password} helperText={errors.password?.message}/>
                <TextField label="Powtórz hasło" type="password" fullWidth color="secondary" {...register("confirmPassword")} error={!!errors.confirmPassword} helperText={errors.confirmPassword?.message}/>
                <Button
                    type="submit"
                    variant="contained"
                    color="secondary"
                    disabled={!isValid || loading}
                    sx={{mt: 1, py: 1.5, fontWeight: 600}}
                >
                    {loading ? "Rejestrowanie..." : "Zarejestruj się"}
                </Button>
                <Button
                    variant="outlined"
                    color="inherit"
                    onClick={switchToLogin}
                    sx={{mt: 0, py: 1.5, fontWeight: 600}}
                >
                    Mam już konto
                </Button>
            </Box>
        </Paper>
    );
};

export default RegisterForm;
