# nodes-pipe-line
A Simple Pipeline for Using a Custom Nodes Editor

No build step, no external dependencies.

<img width="1441" height="1123" alt="Screenshot 2025-11-18 at 21 08 44" src="https://github.com/user-attachments/assets/232a9572-4dbd-4e8b-9fc5-9c81626c04e4" />


---

## How to run

1. Save `index.html` to disk.
2. Open it in any modern desktop browser (Chrome, Edge, Firefox, Safari).

No server is required.

---

## Controls

### Create
- **Left click** empty canvas: create node at cursor.

### Move
- **Left drag** a node: move; connected links follow.

### Connect
- **Right-click / two-finger tap / long-press** a node → **Start connection**.
- Move cursor (yellow guide line follows).
- **Left click** another node to connect.
- **Esc** or **left click** empty canvas to cancel.

### Context menu actions
- **Rename…**: prompts for a new label.
- **Duplicate**: creates an offset copy.
- **Delete**: removes node and its links.

---

## Implementation notes

- SVG layers:
  - `<g id="links-layer">` for permanent link lines (with subtle shadow).
  - `<g id="nodes-layer">` for node groups (`<g>` with `<circle>` and `<text>`).
- Temporary linking uses `<line id="temp-link">` shown only during connect mode.
- Transform jitter on hover is avoided with `transform-box: fill-box; transform-origin: center;`.
- Context menu is a positioned `<div id="menu">`; shown only when not linking.

---

## Extending

- Persist graph: serialize `nodes` and `links` arrays to `localStorage` or a backend.
- Add ports: render smaller anchor circles and snap links to port positions.
- Directed edges / labels: replace `<line>` with `<path>` and add markers/text.
- Selection / multi-move: track selected node IDs and apply drag offsets in batch.
- Touch gestures: add pointer events for full pen/touch support.

---

## Browser support

Designed for current versions of Chromium, Firefox, and Safari.  
Requires standard DOM, SVG, and `addEventListener`.

---

## License

MIT
