/** @type {import('tailwindcss').Config} */
module.exports = {
    content: ["./src/**/*.{js,ts,jsx,tsx}"],
    theme: {
        extend: {
            fontFamily: {
                sans: ["Rubik", "sans-serif"], // to sprawi że `font-sans` = Rubik
            },
        },
    },
    plugins: [],
};
