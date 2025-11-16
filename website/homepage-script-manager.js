hljs.highlightAll();

const scriptCache = {};
let scriptMetadata = {};

// ---------------
// Load metadata from HSP GitHub repo
// ---------------
const RAW_METADATA_URL = 'https://raw.githubusercontent.com/Chalwk/HALO-SCRIPT-PROJECTS/master/metadata.json';
const RAW_REPO_BASE = 'https://raw.githubusercontent.com/Chalwk/HALO-SCRIPT-PROJECTS/master/';

fetch(RAW_METADATA_URL)
    .then(res => res.json())
    .then(metadata => {
    scriptMetadata = metadata;
    renderScripts();
    setupSearch();
    setupCategoryToggles();
})
    .catch(err => console.error('Error loading script metadata:', err));

// ---------------
// Render scripts into categories
// ---------------
function renderScripts() {
    const container = document.getElementById('scriptCategories');
    if (!container) return;

    for (const categoryName in scriptMetadata) {
        const categoryScripts = scriptMetadata[categoryName];
        const categoryId = categoryName.toLowerCase().replace(/\s+/g, '-');

        const categoryElement = document.createElement('div');
        categoryElement.className = 'script-category';
        categoryElement.id = categoryId;

        const categoryHeader = document.createElement('h3');
        categoryHeader.textContent = categoryName;

        const scriptGrid = document.createElement('div');
        scriptGrid.className = 'script-grid';

        for (const scriptId in categoryScripts) {
            const meta = categoryScripts[scriptId];

            const card = document.createElement('div');
            card.className = 'script-card';
            card.innerHTML = `
                <div class="script-header">
                    <h3>
                        <a href="?script=${categoryName}/${scriptId}" class="script-link">
                            ${meta.title}
                        </a>
                    </h3>
                    <p>${meta.shortDescription}</p>
                </div>
                <div class="script-content">
                    <div class="script-actions">
                        <button class="btn view-btn" data-script="${categoryName}/${scriptId}">
                            <i class="fas fa-eye"></i> View
                        </button>
                        <button class="btn copy-btn" data-script="${categoryName}/${scriptId}">
                            <i class="fas fa-copy"></i> Copy
                        </button>
                        <button class="btn download-btn" data-script="${categoryName}/${scriptId}">
                            <i class="fas fa-download"></i> Download
                        </button>
                    </div>
                </div>
            `;
            scriptGrid.appendChild(card);
        }

        categoryElement.appendChild(categoryHeader);
        categoryElement.appendChild(scriptGrid);
        container.appendChild(categoryElement);
    }

    attachEventListeners();
}

// ---------------
// Fetch script from GitHub
// ---------------
function fetchScript(scriptPath) {
    const [category, scriptId] = scriptPath.split('/');
    const meta = scriptMetadata[category][scriptId];
    if (!meta) return Promise.reject('Metadata missing');

    const url = `${RAW_REPO_BASE}sapp/${category}/${meta.filename}`;

    return fetch(url)
        .then(res => res.ok ? res.text() : Promise.reject(`Network error: ${res.status}`))
        .then(data => {
        scriptCache[scriptPath] = data;
        return data;
    });
}

function getScript(scriptPath, callback) {
    if (scriptCache[scriptPath]) callback(scriptCache[scriptPath]);
    else fetchScript(scriptPath).then(code => callback(code)).catch(console.error);
}

// ---------------
// Event Listeners
// ---------------
function attachEventListeners() {
    document.querySelectorAll('.view-btn').forEach(button => {
        button.addEventListener('click', function() {
            const scriptPath = this.getAttribute('data-script');
            openScriptDetail(scriptPath);
        });
    });

    document.querySelectorAll('.copy-btn').forEach(button => {
        button.addEventListener('click', function() {
            const scriptPath = this.getAttribute('data-script');
            getScript(scriptPath, code => {
                navigator.clipboard.writeText(code).then(() => showToast('Code copied to clipboard!'));
            });
        });
    });

    document.querySelectorAll('.download-btn').forEach(button => {
        button.addEventListener('click', function() {
            const scriptPath = this.getAttribute('data-script');
            const [category, scriptId] = scriptPath.split('/');
            const meta = scriptMetadata[category][scriptId];
            if (!meta) return;

            getScript(scriptPath, code => {
                const blob = new Blob([code], { type: 'text/plain' });
                const url = URL.createObjectURL(blob);
                const a = document.createElement('a');
                a.href = url;
                a.download = meta.filename;
                document.body.appendChild(a);
                a.click();
                document.body.removeChild(a);
                URL.revokeObjectURL(url);
                showToast('Download started!');
            });
        });
    });
}

function openScriptDetail(scriptPath) {
    const [category, scriptId] = scriptPath.split('/');
    const meta = scriptMetadata[category][scriptId];
    if (!meta) return;

    getScript(scriptPath, code => {
        document.getElementById('scriptTitle').textContent = meta.title;
        document.getElementById('scriptFullDescription').textContent = meta.description;
        document.getElementById('scriptCode').textContent = code;
        hljs.highlightElement(document.getElementById('scriptCode'));
        document.querySelector('.code-header div').textContent = meta.filename;
        document.getElementById('downloadCodeBtn').setAttribute('data-script', scriptPath);
        document.getElementById('scriptDetail').style.display = 'block';
        document.body.style.overflow = 'hidden';
    });
}

document.getElementById('closeDetail').addEventListener('click', () => {
    document.getElementById('scriptDetail').style.display = 'none';
    document.body.style.overflow = 'auto';
});

document.getElementById('copyCodeBtn').addEventListener('click', () => {
    const code = document.getElementById('scriptCode').textContent;
    navigator.clipboard.writeText(code).then(() => showToast('Code copied to clipboard!'));
});

document.getElementById('downloadCodeBtn').addEventListener('click', function() {
    const scriptPath = this.getAttribute('data-script');
    const code = scriptCache[scriptPath];
    if (!code) return;
    const [category, scriptId] = scriptPath.split('/');
    const meta = scriptMetadata[category][scriptId];
    if (!meta) return;

    const blob = new Blob([code], { type: 'text/plain' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = meta.filename;
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    URL.revokeObjectURL(url);
    showToast('Download started!');
});

// ---------------
// Toast Notification
// ---------------
function showToast(message) {
    const toast = document.getElementById('toast');
    toast.querySelector('span').textContent = message;
    toast.classList.add('show');
    setTimeout(() => toast.classList.remove('show'), 3000);
}

// ---------------
// Search functionality
// ---------------
function setupSearch() {
    const searchInput = document.getElementById('scriptSearch');
    const clearSearchBtn = document.getElementById('clearSearch');
    let searchTimeout;

    searchInput.addEventListener('input', () => {
        clearTimeout(searchTimeout);
        searchTimeout = setTimeout(() => {
            performSearch(searchInput.value);
        }, 300);
    });

    clearSearchBtn.addEventListener('click', () => {
        searchInput.value = '';
        performSearch('');
    });

    // Also trigger search on Enter key
    searchInput.addEventListener('keypress', (e) => {
        if (e.key === 'Enter') {
            performSearch(searchInput.value);
        }
    });
}

function performSearch(query) {
    const searchTerm = query.toLowerCase().trim();

    // If search is empty, show all categories and cards
    if (!searchTerm) {
        resetSearch();
        return;
    }

    const allCategories = document.querySelectorAll('.script-category');
    let totalMatches = 0;

    allCategories.forEach(category => {
        const cards = category.querySelectorAll('.script-card');
        let categoryMatches = 0;

        cards.forEach(card => {
            const titleElement = card.querySelector('h3');
            const descElement = card.querySelector('p');

            if (titleElement && descElement) {
                const title = titleElement.textContent.toLowerCase();
                const desc = descElement.textContent.toLowerCase();
                const matches = title.includes(searchTerm) || desc.includes(searchTerm);

                if (matches) {
                    card.style.display = '';
                    categoryMatches++;
                    totalMatches++;
                } else {
                    card.style.display = 'none';
                }
            }
        });

        // Show/hide entire category based on matches
        if (categoryMatches > 0) {
            category.style.display = '';
            const grid = category.querySelector('.script-grid');
            if (grid) {
                grid.style.display = 'grid';
            }
        } else {
            category.style.display = 'none';
        }
    });

    // Show message if no results found
    if (totalMatches === 0) {
        showNoResultsMessage(searchTerm);
    } else {
        hideNoResultsMessage();
    }
}

function resetSearch() {
    const allCategories = document.querySelectorAll('.script-category');
    const allCards = document.querySelectorAll('.script-card');

    // Show all cards
    allCards.forEach(card => {
        card.style.display = '';
    });

    // Show all categories and ensure grids are visible
    allCategories.forEach(category => {
        category.style.display = '';
        const grid = category.querySelector('.script-grid');
        if (grid) {
            grid.style.display = 'grid'; // Force grid display
        }
    });

    hideNoResultsMessage();
}

function showNoResultsMessage(searchTerm) {
    let noResultsMsg = document.getElementById('noResultsMessage');
    if (!noResultsMsg) return;

    noResultsMsg.innerHTML = `No scripts found for "<strong>${searchTerm}</strong>"`;
    noResultsMsg.style.display = 'block';
}

function hideNoResultsMessage() {
    const noResultsMsg = document.getElementById('noResultsMessage');
    if (noResultsMsg) {
        noResultsMsg.style.display = 'none';
    }
}

// ---------------
// Category Toggles
// ---------------
function setupCategoryToggles() {
    document.querySelectorAll('.script-category h3').forEach(header => {
        const category = header.parentElement;
        const grid = category.querySelector('.script-grid');
        if (grid) {
            grid.style.display = 'none';
            category.classList.add('collapsed');
        }

        header.addEventListener('click', () => {
            const category = header.parentElement;
            const isCollapsed = category.classList.toggle('collapsed');
            const grid = category.querySelector('.script-grid');
            if (grid) {
                grid.style.display = isCollapsed ? 'none' : 'grid';
            }
        });
    });
}