// hr-actions.js
// Handles interactive elements for the HR Portal

document.addEventListener('DOMContentLoaded', function () {
    initializeTabs();
    initializeToasts();
});

/* --- 1. Tab Switching Logic (for Leaves Page) --- */
function initializeTabs() {
    const tabs = document.querySelectorAll('.hr-tab-link');

    tabs.forEach(tab => {
        tab.addEventListener('click', function (e) {
            e.preventDefault();

            // 1. Remove active class from all tabs
            tabs.forEach(t => t.classList.remove('active'));

            // 2. Hide all tab content
            document.querySelectorAll('.hr-tab-content').forEach(c => c.style.display = 'none');

            // 3. Activate clicked tab
            this.classList.add('active');

            // 4. Show target content
            const targetId = this.getAttribute('data-target');
            const targetContent = document.getElementById(targetId);
            if (targetContent) {
                targetContent.style.display = 'block';
                targetContent.style.animation = 'fadeIn 0.3s ease-in-out';
            }
        });
    });
}

/* --- 2. Toast Notification Logic --- */
// Call showToast('success', 'Operation Complete') from your Razor Pages
function showToast(type, message) {
    // Create toast container if it doesn't exist
    let container = document.getElementById('toast-container');
    if (!container) {
        container = document.createElement('div');
        container.id = 'toast-container';
        container.style.cssText = 'position: fixed; top: 20px; right: 20px; z-index: 9999;';
        document.body.appendChild(container);
    }

    // Create toast element
    const toast = document.createElement('div');
    toast.className = `toast align-items-center text-white bg-${type === 'error' ? 'danger' : 'success'} border-0`;
    toast.setAttribute('role', 'alert');
    toast.setAttribute('aria-live', 'assertive');
    toast.setAttribute('aria-atomic', 'true');
    toast.style.cssText = 'min-width: 250px; margin-bottom: 10px; padding: 15px; border-radius: 5px; box-shadow: 0 4px 6px rgba(0,0,0,0.1); display: flex; opacity: 0; transition: opacity 0.5s;';

    toast.innerHTML = `
        <div class="d-flex w-100 justify-content-between">
            <div class="toast-body">
                <i class="${type === 'error' ? 'fas fa-exclamation-circle' : 'fas fa-check-circle'} me-2"></i>
                ${message}
            </div>
            <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast" aria-label="Close" onclick="this.parentElement.parentElement.remove()"></button>
        </div>
    `;

    container.appendChild(toast);

    // Animate in
    requestAnimationFrame(() => {
        toast.style.opacity = '1';
    });

    // Auto remove after 3 seconds
    setTimeout(() => {
        toast.style.opacity = '0';
        setTimeout(() => toast.remove(), 500);
    }, 4000);
}