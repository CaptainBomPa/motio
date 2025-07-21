import React, {useState} from "react";
import MotioLogo from "../components/MotioLogo";
import {AnimatePresence, motion} from "framer-motion";
import LoginForm from "../components/auth/LoginForm";
import RegisterForm from "../components/auth/RegisterForm";

const LoginPage = () => {
    const [isLoading, setIsLoading] = useState(false);
    const [isRegistering, setIsRegistering] = useState(false);

    return (
        <div className="flex min-h-screen w-full">
            <div className="w-1/2 relative bg-[#EDE9FE] flex items-center justify-center">
                <div
                    className="absolute inset-0 bg-cover bg-center opacity-30"
                    style={{backgroundImage: "url('/background.svg')"}}
                />
                <motion.div
                    className="z-10"
                    animate={isLoading ? {rotate: 360} : {rotate: 0}}
                    transition={{repeat: isLoading ? Infinity : 0, ease: "easeInOut", duration: 1}}
                >
                    <MotioLogo/>
                </motion.div>
            </div>

            <div className="w-1/2 bg-gray-100 flex items-center justify-center">
                <AnimatePresence mode="wait">
                    {!isRegistering ? (
                        <motion.div
                            key="login"
                            style={{
                                width: "100%",
                                display: "flex",
                                justifyContent: "center",
                            }}
                            initial={{opacity: 0, x: 50}}
                            animate={{opacity: 1, x: 0}}
                            exit={{opacity: 0, x: -50}}
                            transition={{duration: 0.3}}
                        >
                            <LoginForm setIsLoading={setIsLoading} switchToRegister={() => setIsRegistering(true)}/>
                        </motion.div>
                    ) : (
                        <motion.div
                            key="register"
                            style={{
                                width: "100%",
                                display: "flex",
                                justifyContent: "center",
                            }}
                            initial={{opacity: 0, x: -50}}
                            animate={{opacity: 1, x: 0}}
                            exit={{opacity: 0, x: 50}}
                            transition={{duration: 0.3}}
                        >
                            <RegisterForm setIsLoading={setIsLoading} switchToLogin={() => setIsRegistering(false)}/>
                        </motion.div>
                    )}
                </AnimatePresence>
            </div>
        </div>
    );
};


export default LoginPage;
