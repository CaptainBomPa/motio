import React from 'react';
import {BrowserRouter as Router, Navigate, Route, Routes} from 'react-router-dom';
import LoginPage from './components/LoginPage';
import HomePage from './pages/HomePage';
import './App.css';

function App() {
    const isAuthenticated = !!localStorage.getItem('accessToken');

    return (
        <Router>
            <Routes>
                <Route path="/login" element={<LoginPage/>}/>
                <Route path="/home/*" element={isAuthenticated ? <HomePage/> : <Navigate to="/login"/>}/>
                <Route path="/" element={<Navigate to={isAuthenticated ? "/home" : "/login"}/>}/>
            </Routes>
        </Router>
    );
}

export default App;
