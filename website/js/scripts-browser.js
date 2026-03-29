/*
Copyright (c) 2016-2026. Jericho Crosby (Chalwk)
*/

const repoOwner = "Chalwk";
const repoName = "HALO-SCRIPT-PROJECTS";
const metadataURL = `https://raw.githubusercontent.com/${repoOwner}/${repoName}/master/metadata.json`;
const rawBase = `https://raw.githubusercontent.com/${repoOwner}/${repoName}/master/`;

const statusEl = document.getElementById("status");
const gridEl = document.getElementById("scriptsGrid");
const searchEl = document.getElementById("searchScript");
const categoryEl = document.getElementById("categoryFilter");

const modal = document.getElementById("modal");
const modalTitle = document.getElementById("modalTitle");
const modalCode = document.getElementById("modalCode");
const modalClose = document.getElementById("modalClose");
const modalCopy = document.getElementById("modalCopy");
const modalDownload = document.getElementById("modalDownload");

let scripts = [];
let cache = {};

function showStatus(text) {
    if (statusEl) statusEl.textContent = text;
}

async function loadMetadata() {
    const res = await fetch(metadataURL);
    if (!res.ok) throw new Error("Failed to load metadata.json from repository");
    return await res.json();
}

function buildIndex(metadata) {
    const out = [];
    for (const category of Object.keys(metadata)) {
        for (const key of Object.keys(metadata[category])) {
            const entry = metadata[category][key];
            out.push({
                category: category,
                key: key,
                title: entry.title || key,
                description: entry.description || entry.shortDescription || "",
                filename: entry.filename || `${key}.lua`
            });
        }
    }
    return out;
}

async function getScriptContent(path) {
    if (cache[path]) return cache[path];
    const res = await fetch(rawBase + path);
    if (!res.ok) throw new Error(`File not found: ${path}`);
    const text = await res.text();
    cache[path] = text;
    return text;
}

function renderGrid() {
    if (!gridEl) return;
    gridEl.innerHTML = "";

    const query = searchEl.value.toLowerCase();
    const selectedCat = categoryEl.value;

    let filtered = scripts.slice();

    if (selectedCat !== "all") {
        filtered = filtered.filter(s => s.category === selectedCat);
    }

    if (query) {
        filtered = filtered.filter(s => s.title.toLowerCase().includes(query) || s.description.toLowerCase().includes(query) || s.filename.toLowerCase().includes(query));
    }

    if (filtered.length === 0) {
        gridEl.innerHTML = '<p style="text-align:center; grid-column:1/-1;">No scripts found matching your criteria.</p>';
        return;
    }

    for (const script of filtered) {
        const path = `sapp/${script.category}/${script.filename}`;
        const card = document.createElement("div");
        card.className = "script-card";

        card.innerHTML = `
            <h3><i class="fas fa-file-code"></i> ${escapeHtml(script.title)}</h3>
            <div class="desc">${escapeHtml(script.description)}</div>
            <div class="script-actions">
                <button class="btn view-btn" data-path="${path}" data-title="${script.title}" data-filename="${script.filename}"><i class="fas fa-eye"></i> View</button>
                <button class="btn copy-btn" data-path="${path}"><i class="fas fa-copy"></i> Copy</button>
                <button class="btn download-btn" data-path="${path}" data-filename="${script.filename}"><i class="fas fa-download"></i> Download</button>
            </div>
        `;

        const viewBtn = card.querySelector(".view-btn");
        const copyBtn = card.querySelector(".copy-btn");
        const downloadBtn = card.querySelector(".download-btn");

        viewBtn.addEventListener("click", async () => {
            const path = viewBtn.dataset.path;
            const title = viewBtn.dataset.title;
            const filename = viewBtn.dataset.filename;
            try {
                const code = await getScriptContent(path);
                modalTitle.textContent = `${title} — ${filename}`;
                modalCode.textContent = code;
                Prism.highlightElement(modalCode);
                const blob = new Blob([code], {type: "text/plain"});
                modalDownload.href = URL.createObjectURL(blob);
                modalDownload.download = filename;
                modal.classList.remove("hidden");
            } catch (err) {
                console.error(err);
                showStatus("Error loading script");
            }
        });

        copyBtn.addEventListener("click", async () => {
            const path = copyBtn.dataset.path;
            try {
                const code = await getScriptContent(path);
                await navigator.clipboard.writeText(code);
                showStatus("Copied to clipboard!");
                setTimeout(() => showStatus(""), 2000);
            } catch (err) {
                console.error(err);
                showStatus("Copy failed");
            }
        });

        downloadBtn.addEventListener("click", async () => {
            const path = downloadBtn.dataset.path;
            const filename = downloadBtn.dataset.filename;
            try {
                const code = await getScriptContent(path);
                const blob = new Blob([code], {type: "text/plain"});
                const url = URL.createObjectURL(blob);
                const a = document.createElement("a");
                a.href = url;
                a.download = filename;
                a.click();
                URL.revokeObjectURL(url);
            } catch (err) {
                console.error(err);
                showStatus("Download failed");
            }
        });

        gridEl.appendChild(card);
    }
}

function escapeHtml(str) {
    if (!str) return "";
    return str.replace(/[&<>]/g, function (m) {
        if (m === '&') return '&amp;';
        if (m === '<') return '&lt;';
        if (m === '>') return '&gt;';
        return m;
    }).replace(/[\uD800-\uDBFF][\uDC00-\uDFFF]/g, function (c) {
        return c;
    });
}

if (searchEl) searchEl.addEventListener("input", renderGrid);
if (categoryEl) categoryEl.addEventListener("change", renderGrid);

function closeModal() {
    modal.classList.add("hidden");
    if (modalDownload.href) URL.revokeObjectURL(modalDownload.href);
}

modalClose.addEventListener("click", closeModal);
modal.addEventListener("click", (e) => {
    if (e.target === modal) closeModal();
});

modalCopy.addEventListener("click", async () => {
    const code = modalCode.textContent;
    if (code) {
        await navigator.clipboard.writeText(code);
        showStatus("Copied to clipboard!");
        setTimeout(() => showStatus(""), 2000);
    }
});

(async function init() {
    try {
        const metadata = await loadMetadata();
        scripts = buildIndex(metadata);
        renderGrid();
        showStatus(`${scripts.length} scripts loaded`);
    } catch (err) {
        console.error(err);
        showStatus("Failed to load scripts. Please try again later.");
        gridEl.innerHTML = '<p style="text-align:center; grid-column:1/-1;">Error loading scripts from GitHub. Make sure metadata.json exists and the repository is accessible.</p>';
    }
})();