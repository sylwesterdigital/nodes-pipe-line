High-level summary of what exists now

The project is currently a browser-only node editor with:

Local projects + persistence via IndexedDB

Create / open / duplicate / delete projects.

Per-project history snapshots and action log.

Per-project color palette stored with metadata.

SVG node canvas with infinite pan + zoom

Click background to create nodes.

Drag nodes to move them; links follow.

Space+drag or middle mouse to pan; wheel/trackpad to pan; pinch-to-zoom and two-finger pan on touch.

Zoom controls: + / − buttons, reset to 100%, and “fit all nodes”.

Nodes, links, and “gateway” edits

Context menu on node: connect, rename, description, duplicate, delete.

Keyboard:

N → start connection from hovered node.

X → delete hovered node.

Shift+D → duplicate hovered node.

Click near a line to insert a new node on that link (splits link into two, keeps color).

Drag an existing node onto a line to insert that node into the link (also splits into two).

A small white hover dot shows the precise point on the line where insertion will happen.

Node metadata

Rename dialog for nodes.

Description dialog per node (free-form text stored on the node).

Undo / redo / save with full history

Undo / redo stacks kept in memory, plus snapshots in IndexedDB.

Keyboard: Ctrl/⌘+Z, Ctrl/⌘+Y, Ctrl/⌘+S.

Dedicated mobile buttons for Undo / Redo / Save.

Per-project color palette

Palette of 4 swatches, plus a color picker.

Palette stored per project; updating palette persists to IndexedDB.

Hovering a node and clicking a swatch updates that node’s fill/stroke.

Mobile-friendly UI

Hamburger menu for project actions (Open / New / Duplicate / Delete / Save / Hint).

Tool rail: Lines / Edit / Delete modes:

Lines: tap to chain nodes with links.

Edit: tap a node to open its menu.

Delete: tap a node to remove it.

Long-press and two-finger gestures to open menus and pan canvas.