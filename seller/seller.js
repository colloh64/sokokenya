// Minimal seller JS to avoid 404 errors. Core seller logic lives in seller.html inline script.
console.log('seller.js loaded');

// Provide a no-op for functions that might be referenced externally
function contactAdmin(){ window.location.href = 'mailto:globalventures809@gmail.com'; }
