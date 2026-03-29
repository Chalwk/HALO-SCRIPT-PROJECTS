<!--
Copyright (c) 2016-2026. Jericho Crosby (Chalwk)
-->

document.addEventListener('DOMContentLoaded', function () {
    const header = document.querySelector('header.header');
    if (!header) return;

    const pathSegments = window.location.pathname.split('/');
    const isInSubfolder = pathSegments.length > 2 && pathSegments[1] !== ''; // crude check
    const basePath = isInSubfolder ? '../' : './';

    const currentPage = window.location.pathname.split('/').pop() || 'index.html';

    const headerTop = document.createElement('div');
    headerTop.className = 'header-top';

    const logoDiv = document.createElement('div');
    logoDiv.className = 'header-logo-text';
    logoDiv.innerHTML = '<i class="fas fa-code"></i> <span>HSP</span>';
    headerTop.appendChild(logoDiv);

    const headerTitle = document.createElement('h1');
    headerTitle.textContent = 'Halo Script Projects';
    headerTitle.style.fontFamily = 'var(--font-header), sans-serif';

    headerTop.appendChild(headerTitle);
    header.appendChild(headerTop);

    const navHtml = `
        <nav class="main-nav" aria-label="Main navigation">
            <ul>
                <li><a href="${basePath}index.html" class="nav-link">Home</a></li>
                <li><a href="${basePath}scripts.html" class="nav-link">Scripts</a></li>
                <li><a href="${basePath}docs.html" class="nav-link">Docs</a></li>
                <li><a href="${basePath}contact.html" class="nav-link">Contact</a></li>
            </ul>
        </nav>
    `;
    header.insertAdjacentHTML('beforeend', navHtml);

    const mainNav = header.querySelector('.main-nav');
    const toggleDiv = document.createElement('div');
    toggleDiv.className = 'nav-toggle';
    toggleDiv.innerHTML = '<button aria-label="Toggle navigation"><i class="fas fa-bars"></i></button>';
    headerTop.after(toggleDiv);

    const toggleButton = toggleDiv.querySelector('button');
    toggleButton.addEventListener('click', () => {
        mainNav.classList.toggle('show');
    });

    const navLinks = mainNav.querySelectorAll('a');
    navLinks.forEach(link => {
        link.addEventListener('click', () => {
            mainNav.classList.remove('show');
        });

        const linkHref = link.getAttribute('href').split('/').pop();
        if (linkHref === currentPage) {
            link.classList.add('active');
        }
    });

    if (!document.querySelector('footer')) {
        const footer = document.createElement('footer');
        footer.innerHTML = `
            <p class="footer-copyright"></p>
            <div class="social-share">
                <a href="https://github.com/Chalwk/HALO-SCRIPT-PROJECTS" target="_blank" class="social-icon" aria-label="GitHub"><i class="fab fa-github"></i></a>
                <a href="https://discord.gg/D76H7RVPC9" target="_blank" class="social-icon" aria-label="Discord"><i class="fab fa-discord"></i></a>
                <a href="mailto:chalwk.dev@gmail.com" class="social-icon" aria-label="Email"><i class="fas fa-envelope"></i></a>
                <a href="https://www.paypal.com/ncp/payment/XUPTKDU6LKM3G" target="_blank" class="social-icon" aria-label="Donate"><i class="fas fa-heart"></i></a>
            </div>
        `;
        document.body.appendChild(footer);
    }

    const scrollBtn = document.createElement('button');
    scrollBtn.id = 'scrollToTopBtn';
    scrollBtn.className = 'scroll-to-top';
    scrollBtn.setAttribute('aria-label', 'Scroll to top');
    scrollBtn.innerHTML = '<i class="fas fa-chevron-up"></i>';
    document.body.appendChild(scrollBtn);

    window.addEventListener('scroll', () => {
        if (window.pageYOffset > 300) {
            scrollBtn.classList.add('visible');
        } else {
            scrollBtn.classList.remove('visible');
        }
    });

    scrollBtn.addEventListener('click', () => {
        window.scrollTo({top: 0, behavior: 'smooth'});
    });
});