# Nodes Pipeline / Node Canvas

Local-first node editor in a single HTML file.

This repo is an experiment in building a “wire APIs together like Lego” canvas from scratch, **without** React, canvas frameworks, or a backend. Everything lives in the browser: projects, history, and the SVG node graph itself.

> Goal: a small, understandable codebase that can evolve into a visual workflow / API-orchestration tool.

# Early Demo:
https://github.com/user-attachments/assets/1081b590-cb32-40ee-9492-2628b7f04b81




---

## What’s inside right now

### Core concepts

- **Projects (local-first)**
  - Create / open / duplicate / delete projects.
  - Metadata + palette stored in IndexedDB (`projects` store).
  - Each project has its own graph state and history.

- **Graph editor (SVG)**
  - Click empty canvas to create a node.
  - Drag nodes to move them; links follow.
  - Connect nodes:
    - Desktop: hover a node and press **`N`**, or use the node menu → **Start connection**.
    - Touch: start connection and lift on the target node.
  - Links are simple lines (`from` → `to`) with a per-link color.

- **Node actions**
  - **Rename** node (modal).
  - **Description** per node (modal, free-form text).
  - **Duplicate** node.
  - **Delete** node.
  - Context menu on desktop (right-click / long-press).

- **History & persistence**
  - Project snapshots stored in `states` store: `{ projectId, rev, state }`.
  - Append-only action log in `history` store: `{ projectId, seq, action }`.
  - Undo / redo stacks are rebuilt from the stored state/history.
  - **Save** writes a new snapshot revision for the current project.

- **Per-project color palette**
  - 4 swatches + a `+` color picker.
  - Palette stored per project; changing it updates metadata.
  - Hovered node can be recolored from the palette.
  - Palette picker is anchored visually but uses an off-screen `<input type="color">` for mobile friendliness.

---

## Desktop UX

- **Canvas**
  - Click empty space → create node (guarded so clicks near existing nodes don’t spawn clones).
  - Drag node → moves it; links update.
  - Status pill at bottom left shows node/link count and current mode.

- **Keyboard shortcuts**
  - **Undo**: `Ctrl/Cmd + Z`
  - **Redo**: `Ctrl/Cmd + Y`
  - **Save**: `Ctrl/Cmd + S`
  - **Start link from hovered node**: `N`
  - **Delete hovered node**: `X`
  - **Duplicate hovered node**: `Shift + D`
  - **Escape**:
    - Close projects modal
    - Close rename / description overlays
    - Cancel linking
    - Close context menu

- **Node menu (context)**
  - Right-click or long-press stationary node.
  - Actions:
    - Start connection
    - Rename…
    - Description…
    - Duplicate
    - Delete

- **Top bar**
  - `?` → toggle help sidebar.
  - `Open…` → project list.
  - `New…` → create project.
  - `Duplicate…` → duplicate current project (with history/state).
  - `Delete` → delete current project.

---

## Mobile UX

The editor is designed to be usable on touch screens (no tiny hit-targets).

- **Hamburger menu**
  - `Hint` → show help sidebar.
  - `Open` / `New` / `Duplicate` / `Delete` → project actions.
  - `Save` → persist snapshot.

- **Tool rail (left side)**
  - **Lines mode**
    - Tap first node → chain start.
    - Tap second node → create link.
    - Chain continues from the last tapped node.
  - **Edit mode**
    - Tap node → open node menu (same actions as desktop).
  - **Delete mode**
    - Tap node → delete.

- **Node menu on touch**
  - Long-press (or two-finger long-press) to open.
  - Same actions as desktop.

- **Mobile undo / redo / save**
  - Floating buttons at bottom right:
    - Undo
    - Redo
    - Save

---

## Storage model

IndexedDB is used with three object stores:

- **`projects`**
  - `id` (PK, auto-increment)
  - `name`
  - `createdAt`, `updatedAt`
  - `pointer` (current revision)
  - `palette` (colors + selected index)

- **`states`**
  - Key: `[projectId, rev]`
  - `state` → `{ nodes, links, nextId }`

- **`history`**
  - Key: `[projectId, seq]`
  - `action` → e.g. `ADD_NODE`, `MOVE_NODE`, `CONNECT`, `RENAME_NODE`, `SET_DESCRIPTION`, `STYLE_NODE`, etc.

This keeps the UI relatively dumb: UI operations produce actions; snapshots + actions are written to IndexedDB.

---

## How to run

No build step, no backend. Just open in a modern browser.

```bash
git clone git@github.com:sylwesterdigital/nodes-pipe-line.git
cd nodes-pipe-line

# Option 1: open directly
# Open index.html in your browser (Chrome/Edge/Firefox)

# Option 2 (recommended): serve via a tiny static server
python -m http.server 8000
# then go to http://localhost:8000 in the browser
````

> Note: IndexedDB is required. Use a modern desktop or mobile browser.

---

## Roadmap / next steps

Short-term ideas for this repo:

* **Infinite canvas + panning**

  * Pan the graph with trackpad / mouse drag / two-finger touch.
  * Nodes stay at logical coordinates; viewBox handles movement/zoom.

* **Node types**

  * Visual grouping into:

    * Source (e.g. HTTP / Webhook / scraper)
    * Transform (e.g. LLM, mapping, filters)
    * Action (e.g. send email, push to API)

* **Execution engine**

  * Simple runner that:

    * Walks the graph from entry nodes.
    * Executes node functions in order.
    * Logs per-node outputs in a console panel.

* **Real integrations**

  * HTTP request node (configurable method / URL / body).
  * LLM transform node (prompt + input template).
  * Basic validation of links (no impossible cycles for simple flows).

* **Import / export**

  * JSON export of a project (nodes + links + palette + history).
  * Import into another browser / device.

---

## Status

This is still a **UI + persistence playground**, not a finished workflow engine.


## License
[GNU LESSER GENERAL PUBLIC LICENSE Version 2.1, February 1999](LICENSE)
