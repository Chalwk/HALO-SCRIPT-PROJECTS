* [**SAPP docs (official)**](https://halo-sapp.readthedocs.io/en/latest/scripting/index.html) - SAPP's Lua API, events,
  commands, and examples.
* [**Phasor (legacy)**](https://phasor.halonet.net/) - legacy server extension/docs; helpful for older scripts and
  historical examples.
* [**Phasor V1 Docs**](http://phasor.halonet.net/archive/docs/05x.html) - Documentation for Phasor V1.
* [**Phasor V2 Docs**](http://phasor.halonet.net/archive/docs/200.html) - Documentation for Phasor V2.
* [**Halopedia - Halo: Combat Evolved (main)**](https://www.halopedia.org/Halo:_Combat_Evolved) - canonical game/tag
  behavior & weapon overviews.
* [**Halopedia - Category weapons**](https://www.halopedia.org/Halo:_Combat_Evolved#Weapons) - full list of weapons in
  Halo.
* [**Netcode (Wikipedia)**](https://en.wikipedia.org/wiki/Netcode) - general networking concepts (
  tickrate/latency/packet loss) useful for server sync debugging.
* [**Exploring the Halo 1 System Link Protocol - hllmn.net (2023-09-18)**](https://hllmn.net/blog/2023-09-18_h1x-net/) -
  deep, low-level CE networking reverse-engineering.
* [**OpenCarnage (forum & community)**](https://opencarnage.net/) - threads, HEK help, scripts, and CE community
  resources.
* [**Elite Game Servers - SAPP overview & examples**](https://www.elitegameservers.net/sapp/) - practical SAPP usage
  notes.
* [**HAC2 Map Repo**](https://maps.halonet.net/) - Custom maps for PC & CE.
* [**HaloMaps.org**](https://www.halomaps.org/hce/) - Custom maps for PC & CE.

---

# Extra references - Modding tools

**Classic HEK (Halo Editing Kit) tools**

* **HEK:** [Nexus Mods](https://www.nexusmods.com/halo/mods/6)
* **Sapien (scenario/map editor)** - in-editor placement, scenario preview & radiosity (part of HEK / CE mod tools).
* **Guerilla (tag editor)** - view/edit structured tag fields (we use Guerilla for many tag-level tweaks).
* **Tool (build/asset compiler)** - bitmap & asset conversion, map build pipeline.
* **Tag Test (`tag_test.exe`)** - test & debug maps locally (part of HEK / mod tools).
  (These are bundled with the classic HEK / CE Mod Tools; see Reclaimers / HEK resources for downloads and guides.)

**Modern & community toolchains**

* **Invader - official project page & downloads (modern, cross-platform toolkit)
  **: [Open Carnage](https://invader.opencarnage.net/) and GitHub: [SnowyMouse](https://github.com/SnowyMouse/invader).
* **Assembly (XboxChaos) - multi-generation .map editor / patcher**: [XboxChaos](https://github.com/XboxChaos/Assembly).
* **MEK / Mozz Editing Kit (MEK)** - alternate community editing suite (extractors &
  GUIs): [Sigmmma](https://github.com/Sigmmma/mek).

**Client-side mods / scripting platforms**

* **Chimera (CE client mod & Lua support)** - [Chimera](https://github.com/SnowyMouse/chimera) (client QoL + modding +
  scripting).
* **Balltze (plugin-loader / mod platform for CE)** - [MangoFizz](https://github.com/MangoFizz/balltze)
  and [Shadowmods](https://balltze.shadowmods.net/).

---

## Lua / scripting helpers & libs

* **lua-blam (Sledmine)** - memory/tag helper module for CE Lua
  scripting: [Sledmine](https://github.com/Sledmine/lua-blam).
* **Mercury (package manager for CE mods)** - [Sledmine](https://github.com/Sledmine/mercury) (helps bundle/distribute
  addons).

**Asset / model pipelines (Blender & exporters)**

* **Halo Asset Blender Development Toolset** - Blender addon for importing/exporting H1
  assets: [General-101](https://github.com/General-101/Halo-Asset-Blender-Development-Toolset).
* **Other Blender tools / importers (ekur, foundry, blender-halo-tools)** - search GitHub for `ekur`, `Foundry`, or
  `blender-halo-tools` for community add-ons and pipelines.

## Quick usage tips

* If you want a **classic HEK workflow** - use **Sapien + Guerilla + Tool + Tag Test** (HEK).
* For **modern, scriptable workflows** (batch/CI, safer extraction), use **Invader + Assembly + MEK**.
* For **client-side scripting / QoL / testing** - run **Chimera** locally and test server scripts with **SAPP** on the
  server.