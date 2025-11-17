const repoOwner = "Chalwk";
const repoName = "HALO-SCRIPT-PROJECTS";

const metadataURL =
`https://raw.githubusercontent.com/${repoOwner}/${repoName}/master/metadata.json`;

const rawBase =
`https://raw.githubusercontent.com/${repoOwner}/${repoName}/master/`;

const statusEl = document.getElementById("status");
const gridEl = document.getElementById("grid");
const searchEl = document.getElementById("search");
const categoryEl = document.getElementById("categoryFilter");

const modal = document.getElementById("modal");
const modalTitle = document.getElementById("modalTitle");
const modalCode = document.getElementById("modalCode");
const modalClose = document.getElementById("modalClose");
const modalCopy = document.getElementById("modalCopy");
const modalDownload = document.getElementById("modalDownload");

let scripts = [];
let cache = {};

function showStatus(t) {
    statusEl.textContent = t;
}

async function loadMetadata() {
    const res = await fetch(metadataURL);
    if (!res.ok) throw new Error("Failed to load metadata");
    return res.json();
}

function buildIndex(md) {
    const out = [];
    for (const category of Object.keys(md)) {
        for (const key of Object.keys(md[category])) {
            const e = md[category][key];
            out.push({
                category,
                key,
                title: e.title || key,
                description: e.description || "",
                short: e.shortDescription || "",
                filename: e.filename || `${key}.lua`
            });
        }
    }
    return out;
}

async function getScript(path) {
    if (cache[path]) return cache[path];
    const res = await fetch(rawBase + path);
    if (!res.ok) throw new Error("File not found");
    const txt = await res.text();
    cache[path] = txt;
    return txt;
}

function render() {
    gridEl.innerHTML = "";
    const q = searchEl.value.toLowerCase();
    const cat = categoryEl.value;

    let items = scripts.slice();

    if (cat !== "all") items = items.filter(s => s.category === cat);

    if (q) {
        items = items.filter(s =>
        s.title.toLowerCase().includes(q) ||
        s.description.toLowerCase().includes(q) ||
        s.filename.toLowerCase().includes(q)
        );
    }

    for (const it of items) {
        const path = `sapp/${it.category}/${it.filename}`;
        const card = document.createElement("article");
        card.className = "card";

        card.innerHTML = `
      <h3>${it.title}</h3>
      <p class="desc">${it.description}</p>
      <div class="actions">
        <button class="btn view"><span class="icon">👁️</span> View</button>
        <button class="btn copy"><span class="icon">📋</span> Copy</button>
        <button class="btn download"><span class="icon">⬇️</span> Download</button>
      </div>
    `;

        // View
        card.querySelector(".view").onclick = async () => {
            const text = await getScript(path);
            modalTitle.textContent = `${it.title} — ${it.filename}`;
            modalCode.textContent = text;
            Prism.highlightElement(modalCode);

            const blob = new Blob([text], { type: "text/plain" });
            modalDownload.href = URL.createObjectURL(blob);
            modalDownload.download = it.filename;

            modal.classList.remove("hidden");
        };

        // Copy
        card.querySelector(".copy").onclick = async () => {
            const text = await getScript(path);
            await navigator.clipboard.writeText(text);
            showStatus("Copied");
        };

        // Download
        card.querySelector(".download").onclick = async () => {
            const text = await getScript(path);
            const blob = new Blob([text], { type: "text/plain" });
            const url = URL.createObjectURL(blob);
            const a = document.createElement("a");
            a.href = url;
            a.download = it.filename;
            a.click();
            URL.revokeObjectURL(url);
        };

        gridEl.appendChild(card);
    }
}

modalClose.onclick = () => modal.classList.add("hidden");
modal.addEventListener("click", e => {
    if (e.target === modal) modal.classList.add("hidden");
});

searchEl.oninput = render;
categoryEl.onchange = render;

(async function init() {
    try {
        const md = await loadMetadata();
        scripts = buildIndex(md);
        render();
        showStatus("");
    } catch (err) {
        console.error(err);
        showStatus("Failed to load");
    }
})();
