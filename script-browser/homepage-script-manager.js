hljs.highlightAll();

const scriptCache = {};
let scriptMetadata = {};

// ---------------
// Load metadata from HSP GitHub repo
// ---------------
const RAW_METADATA_URL = 'https://raw.githubusercontent.com/Chalwk/HALO-SCRIPT-PROJECTS/master/metadata.json';
const RAW_REPO_BASE = 'https://raw.githubusercontent.com/Chalwk/HALO-SCRIPT-PROJECTS/master/';

// Virtual scrolling variables
let visibleCategories = new Set();
const RENDER_CHUNK_SIZE = 15; // Render scripts in chunks
let currentRenderIndex = 0;

fetch(RAW_METADATA_URL)
    .then(res => res.json())
    .then(metadata => {
    scriptMetadata = metadata;
    renderCategories();
    setupSearch();
    setupCategoryToggles();
    setupEventDelegation();
})
    .catch(err => console.error('Error loading script metadata:', err));

// ---------------
// Render only categories initially
// ---------------
function renderCategories() {
    const container = document.getElementById('scriptCategories');
    if (!container) return;

    container.innerHTML = ''; // Clear container

    for (const categoryName in scriptMetadata) {
        const categoryId = categoryName.toLowerCase().replace(/\s+/g, '-');

        const categoryElement = document.createElement('div');
        categoryElement.className = 'script-category';
        categoryElement.id = categoryId;

        const categoryHeader = document.createElement('h3');
        categoryHeader.textContent = categoryName;
        categoryHeader.setAttribute('data-category', categoryName);

        const scriptGrid = document.createElement('div');
        scriptGrid.className = 'script-grid';
        scriptGrid.style.display = 'none'; // Hide initially
        scriptGrid.setAttribute('data-category', categoryName);

        // Loading indicator
        const loadingIndicator = document.createElement('div');
        loadingIndicator.className = 'loading-indicator';
        loadingIndicator.innerHTML = '<div class="spinner"></div><span>Loading scripts...</span>';
        scriptGrid.appendChild(loadingIndicator);

        categoryElement.appendChild(categoryHeader);
        categoryElement.appendChild(scriptGrid);
        container.appendChild(categoryElement);
    }
}

// ---------------
// Lazy load scripts when category is expanded
// ---------------
function loadCategoryScripts(categoryName) {
    const categoryScripts = scriptMetadata[categoryName];
    const categoryId = categoryName.toLowerCase().replace(/\s+/g, '-');
    const scriptGrid = document.querySelector(`.script-grid[data-category="${categoryName}"]`);

    if (!scriptGrid || scriptGrid.getAttribute('data-loaded') === 'true') {
        return; // Already loaded or doesn't exist
    }

    // Remove loading indicator
    scriptGrid.innerHTML = '';
    scriptGrid.setAttribute('data-loaded', 'true');

    const scriptIds = Object.keys(categoryScripts);
    currentRenderIndex = 0;

    // Render first chunk immediately
    renderScriptChunk(categoryName, scriptIds, scriptGrid);

    // Setup intersection observer for lazy loading
    setupLazyLoading(categoryName, scriptIds, scriptGrid);
}

function renderScriptChunk(categoryName, scriptIds, scriptGrid) {
    const endIndex = Math.min(currentRenderIndex + RENDER_CHUNK_SIZE, scriptIds.length);

    for (let i = currentRenderIndex; i < endIndex; i++) {
        const scriptId = scriptIds[i];
        const meta = scriptMetadata[categoryName][scriptId];

        const card = createScriptCard(categoryName, scriptId, meta);
        scriptGrid.appendChild(card);
    }

    currentRenderIndex = endIndex;

    // Show progress for large categories
    if (scriptIds.length > RENDER_CHUNK_SIZE && currentRenderIndex < scriptIds.length) {
        showLoadingProgress(scriptGrid, currentRenderIndex, scriptIds.length);
    }
}

function createScriptCard(categoryName, scriptId, meta) {
    const card = document.createElement('div');
    card.className = 'script-card';
    card.setAttribute('data-script-path', `${categoryName}/${scriptId}`);
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
    return card;
}

function setupLazyLoading(categoryName, scriptIds, scriptGrid) {
    if (currentRenderIndex >= scriptIds.length) return;

    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                renderScriptChunk(categoryName, scriptIds, scriptGrid);

                if (currentRenderIndex >= scriptIds.length) {
                    observer.disconnect();
                    removeLoadingProgress(scriptGrid);
                }
            }
        });
    }, {
        rootMargin: '100px' // Start loading 100px before reaching the bottom
    });

    // Observe the last card to trigger loading more
    const lastCard = scriptGrid.lastElementChild;
    if (lastCard) {
        observer.observe(lastCard);
    }
}

function showLoadingProgress(container, loaded, total) {
    let progress = container.querySelector('.loading-progress');
    if (!progress) {
        progress = document.createElement('div');
        progress.className = 'loading-progress';
        container.appendChild(progress);
    }
    progress.innerHTML = `<div class="progress-text">Loaded ${loaded} of ${total} scripts...</div>`;
}

function removeLoadingProgress(container) {
    const progress = container.querySelector('.loading-progress');
    if (progress) {
        progress.remove();
    }
}

// ---------------
// Event Delegation
// ---------------
function setupEventDelegation() {
    // Delegate all button clicks to the container
    document.getElementById('scriptCategories').addEventListener('click', function(e) {
        const target = e.target;
        const button = target.closest('.view-btn, .copy-btn, .download-btn');

        if (!button) return;

        const scriptPath = button.getAttribute('data-script');
        if (!scriptPath) return;

        if (button.classList.contains('view-btn')) {
            openScriptDetail(scriptPath);
        } else if (button.classList.contains('copy-btn')) {
            getScript(scriptPath, code => {
                navigator.clipboard.writeText(code).then(() => showToast('Code copied to clipboard!'));
            });
        } else if (button.classList.contains('download-btn')) {
            handleDownload(scriptPath);
        }
    });

    // Script link clicks
    document.getElementById('scriptCategories').addEventListener('click', function(e) {
        if (e.target.classList.contains('script-link')) {
            e.preventDefault();
            const url = new URL(e.target.href);
            const scriptParam = url.searchParams.get('script');
            if (scriptParam) {
                openScriptDetail(scriptParam);
            }
        }
    });
}

function handleDownload(scriptPath) {
    const [category, scriptId] = scriptPath.split('/');
    const meta = scriptMetadata[category] && scriptMetadata[category][scriptId];
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
}

// ---------------
// Fetch script from GitHub
// ---------------
function fetchScript(scriptPath) {
    if (scriptCache[scriptPath]) {
        return Promise.resolve(scriptCache[scriptPath]);
    }

    const [category, scriptId] = scriptPath.split('/');
    const meta = scriptMetadata[category] && scriptMetadata[category][scriptId];
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
    fetchScript(scriptPath)
        .then(code => callback(code))
        .catch(err => {
        console.error('Error fetching script:', err);
        showToast('Error loading script');
    });
}

// ---------------
// Script Detail Panel
// ---------------
function openScriptDetail(scriptPath) {
    const [category, scriptId] = scriptPath.split('/');
    const meta = scriptMetadata[category] && scriptMetadata[category][scriptId];
    if (!meta) return;

    // Show loading state
    document.getElementById('scriptTitle').textContent = 'Loading...';
    document.getElementById('scriptFullDescription').textContent = '';
    document.getElementById('scriptCode').textContent = '// Loading script...';
    document.getElementById('scriptDetail').style.display = 'block';
    document.body.style.overflow = 'hidden';

    getScript(scriptPath, code => {
        document.getElementById('scriptTitle').textContent = meta.title;
        document.getElementById('scriptFullDescription').textContent = meta.description;
        document.getElementById('scriptCode').textContent = code;
        hljs.highlightElement(document.getElementById('scriptCode'));
        document.querySelector('.code-header div').textContent = meta.filename;
        document.getElementById('downloadCodeBtn').setAttribute('data-script', scriptPath);
    });
}

// Close detail panel
document.getElementById('closeDetail').addEventListener('click', () => {
    document.getElementById('scriptDetail').style.display = 'none';
    document.body.style.overflow = 'auto';
});

// Copy code from detail panel
document.getElementById('copyCodeBtn').addEventListener('click', () => {
    const code = document.getElementById('scriptCode').textContent;
    navigator.clipboard.writeText(code).then(() => showToast('Code copied to clipboard!'));
});

// Download from detail panel
document.getElementById('downloadCodeBtn').addEventListener('click', function() {
    const scriptPath = this.getAttribute('data-script');
    handleDownload(scriptPath);
});

// ---------------
// Toast Notification
// ---------------
function showToast(message) {
    const toast = document.getElementById('toast');
    const toastSpan = toast.querySelector('span');
    toastSpan.textContent = message;
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

    // Debounced search
    searchInput.addEventListener('input', () => {
        clearTimeout(searchTimeout);
        searchTimeout = setTimeout(() => {
            performSearch(searchInput.value);
        }, 300);
    });

    clearSearchBtn.addEventListener('click', () => {
        searchInput.value = '';
        performSearch('');
        searchInput.focus();
    });

    searchInput.addEventListener('keypress', (e) => {
        if (e.key === 'Enter') {
            performSearch(searchInput.value);
        }
    });
}

function performSearch(query) {
    const searchTerm = query.toLowerCase().trim();

    if (!searchTerm) {
        resetSearch();
        return;
    }

    const allCategories = document.querySelectorAll('.script-category');
    let totalMatches = 0;

    allCategories.forEach(category => {
        const categoryName = category.querySelector('h3').textContent.toLowerCase();
        const categoryMatchesSearch = categoryName.includes(searchTerm);
        let scriptMatches = 0;

        // If category name matches, show all scripts in category
        if (categoryMatchesSearch) {
            category.style.display = '';
            const grid = category.querySelector('.script-grid');
            if (grid) {
                const cards = grid.querySelectorAll('.script-card');
                cards.forEach(card => {
                    card.style.display = '';
                    scriptMatches++;
                });
                grid.style.display = 'grid';
            }
            totalMatches += scriptMatches;
        } else {
            // Otherwise, filter scripts within category
            const grid = category.querySelector('.script-grid');
            if (grid) {
                const cards = grid.querySelectorAll('.script-card');
                scriptMatches = 0;

                cards.forEach(card => {
                    const title = card.querySelector('h3').textContent.toLowerCase();
                    const desc = card.querySelector('p').textContent.toLowerCase();
                    const matches = title.includes(searchTerm) || desc.includes(searchTerm);

                    if (matches) {
                        card.style.display = '';
                        scriptMatches++;
                        totalMatches++;
                    } else {
                        card.style.display = 'none';
                    }
                });

                category.style.display = scriptMatches > 0 ? '' : 'none';
                grid.style.display = scriptMatches > 0 ? 'grid' : 'none';
            }
        }
    });

    if (totalMatches === 0) {
        showNoResultsMessage(searchTerm);
    } else {
        hideNoResultsMessage();
    }
}

function resetSearch() {
    const allCategories = document.querySelectorAll('.script-category');
    const allCards = document.querySelectorAll('.script-card');

    allCards.forEach(card => {
        card.style.display = '';
    });

    allCategories.forEach(category => {
        category.style.display = '';
        const grid = category.querySelector('.script-grid');
        if (grid && grid.getAttribute('data-loaded') === 'true') {
            grid.style.display = 'grid';
        }
    });

    hideNoResultsMessage();
}

function showNoResultsMessage(searchTerm) {
    const noResultsMsg = document.getElementById('noResultsMessage');
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
    document.getElementById('scriptCategories').addEventListener('click', function(e) {
        if (e.target.tagName === 'H3') {
            const header = e.target;
            const category = header.parentElement;
            const isCollapsed = category.classList.toggle('collapsed');
            const grid = category.querySelector('.script-grid');

            if (grid) {
                if (isCollapsed) {
                    grid.style.display = 'none';
                } else {
                    grid.style.display = 'grid';
                    // Lazy load scripts when category is expanded
                    const categoryName = header.textContent;
                    if (grid.getAttribute('data-loaded') !== 'true') {
                        loadCategoryScripts(categoryName);
                    }
                }
            }
        }
    });

    // Initially collapse all categories
    document.querySelectorAll('.script-category').forEach(category => {
        category.classList.add('collapsed');
    });
}