# Node Pipeline Canvas (POC)

Saw someone on LinkedIn claiming they built their own SaaS – with no programming knowledge – just using a visual tool wiring web/social APIs together as nodes and lines. It looks like a child’s game: stack blocks, add conditions, and suddenly there’s automation.

People clearly love this pattern: mind maps, Miro, Unreal Blueprints, n8n, AI “pipelines” from OpenAI/Google, etc. Underneath, it’s all node graphs. The goal here is to own that layer and build a UI that’s simple, fast, and hackable.

This repository is a browser-only proof of concept for that idea.

> Repo: `git@github.com:sylwesterdigital/nodes-pipe-line.git`  
> Tech: pure HTML/CSS/JS, single `index.html`, no backend.

---

## What works right now

### Projects & persistence (IndexedDB)

- Local projects stored in the browser:
  - Create, open, duplicate, delete projects.
  - Per-project metadata: name, timestamps, palette, revision pointer.
- State snapshots:
  - Graph state (`nodes`, `links`, `nextId`) stored per revision.
  - History log stored per project with action records.
- Opening a project restores:
  - Full graph (nodes + links).
  - Palette and project metadata.
  - Undo/redo baseline from history.

### SVG node canvas

- Click empty canvas to **add a node**.
- Drag a node to **move it**; all attached links follow.
- Node shapes are pill-style by default, with dynamic width based on label.
- Status pill (top-left) shows current mode and counts: `Nodes: X | Links: Y`.

### Infinite canvas, pan & zoom

- Canvas implemented via SVG `viewBox` for an “infinite” feeling.
- **Desktop:**
  - Hold **Space + drag** on empty canvas to pan.
  - **Middle mouse drag** on empty canvas to pan.
  - **Trackpad / wheel**:
    - Scroll to pan the view.
    - Hold **Ctrl/⌘ + scroll** to zoom in/out at the cursor position.
- **Touch / mobile:**
  - **Two-finger drag** on empty canvas to pan.
  - **Pinch-to-zoom** around the midpoint of the two fingers.
- Zoom controls (bottom-left):
  - `+` / `−` buttons.
  - `100%` button to reset zoom to 1:1 and recenter.
  - `⤢` button to “fit all nodes” into view.
- Zoom label always shows the current zoom percentage.

### Nodes, links, and gateway behavior

- Node context menu (desktop right-click or long-press / gestures on mobile):
  - **Start connection**
  - **Rename…**
  - **Description…**
  - **Duplicate**
  - **Delete**
- Linking:
  - Desktop:
    - Hover a node and press `N` to start a connection.
    - Move pointer and click a target node to finish.
  - Touch:
    - Start connection on a node, touch canvas to start the guide line, lift on target node.
- Link editing / gateway nodes:
  - Hovering near a line shows a **white dot** exactly on the closest point of the link segment.
  - Click background near a link (and not near its endpoints) to:
    - Create a **new node directly on that link**.
    - Automatically **split the link into two** segments with the same color.
  - Drag an existing node onto a link:
    - While dragging, the white dot shows where it would be inserted.
    - Dropping the node on the link:
      - Removes the original link.
      - Creates **two new links** passing through that node.
- Keyboard shortcuts (desktop):
  - `N` — start connection from hovered node.
  - `X` — delete hovered node.
  - `Shift + D` — duplicate hovered node (keeps label with a suffix).
  - `Esc` — cancel linking, close modals, close project gate, etc.

### Node metadata (rename + description)

- **Rename dialog:**
  - Open from node context menu (“Rename…”).
  - Inline modal with text input; `Enter` to confirm, `Esc` to cancel.
- **Description dialog:**
  - Open from node context menu (“Description…”).
  - Multi-line textarea for free-form description per node.
  - Stored on the node as `description`.

### Undo / Redo / Save & history

- Undo / redo stacks in memory plus persisted snapshots.
- Keyboard:
  - `Ctrl/⌘ + Z` — Undo
  - `Ctrl/⌘ + Y` — Redo
  - `Ctrl/⌘ + S` — Save snapshot
- History entries are appended for:
  - Add / move / delete / duplicate node.
  - Connect nodes.
  - Rename node.
  - Style changes.
  - Link splitting (new or existing node).
  - Description changes.
- Persistence:
  - Saving creates a new revision in the `states` store.
  - Project metadata is updated with the latest revision pointer and palette.

### Per-project color palette

- Palette widget (bottom-right):
  - 4 swatches per project.
  - One “+” swatch that opens a native color picker.
- Behavior:
  - Clicking a swatch selects it, updates current palette index.
  - Hovering a node and clicking a swatch updates that node’s fill/stroke.
  - Color picker:
    - `input` event previews the color on hovered node and swatch.
    - `change` event persists the color to the project palette in IndexedDB.

### Mobile-friendly UI

- **Hamburger menu** (top-right):
  - Hint (show sidebar help)
  - Open
  - New
  - Duplicate
  - Delete
  - Save
- **Mobile undo/redo/save bar** (bottom-right):
  - Buttons for Undo, Redo, Save.
- **Tool rail** (left side):
  - **Lines** mode:
    - Tap a node to start a chain.
    - Tap another node to create a link.
    - Keeps chaining from the last tapped node.
  - **Edit** mode:
    - Tap a node to open its context menu.
  - **Delete** mode:
    - Tap a node to delete it.
- **Gestures:**
  - Long-press / two-finger interactions to open menus.
  - Two-finger pan and pinch-zoom on the canvas.

---

## Roadmap (next steps)

Planned next steps:

- Introduce basic **node types**:
  - `Source` → `Transform` → `Action`.
- MVP **runner**:
  - Execute the graph.
  - Show per-node status/logs (success/error, timing, payload snippets).
- First integrations:
  - HTTP / Webhook node.
  - Simple LLM transform node (e.g., prompt in, text out).
- Visual polish:
  - Better shapes and icons per node type.
  - Inline indicators for running/completed/failed nodes.

---

## Running the POC

No build step, no backend.

```bash
git clone git@github.com:sylwesterdigital/nodes-pipe-line.git
cd nodes-pipe-line
````

Then either:

* Open `index.html` directly in a modern browser, or
* Serve it with any static file server, e.g.:

```bash
python -m http.server 8000
# then open http://localhost:8000 in a browser
```

Projects and history are stored locally in the browser via IndexedDB, so everything is sandboxed to the machine and browser profile.

---

If node-based “wiring APIs together” is interesting, clone the repo, open the canvas, and start breaking things.