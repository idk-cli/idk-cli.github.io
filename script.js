document.addEventListener('DOMContentLoaded', () => {
    const currentTheme = localStorage.getItem('theme') ? localStorage.getItem('theme') : null;
    if (currentTheme) {
        document.body.classList.add('dark-mode');
    }
});

function redirectToURL(url) {
    window.location.href = url;
}