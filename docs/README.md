So I saw someone on LinkedIn claiming they built their own SaaS with no programming knowledge – just wiring web/social APIs together as nodes and lines. It looks like a child’s game: stack blocks, add conditions, and suddenly you’ve got automation.

People clearly love this pattern: mind maps, Miro, Unreal Blueprints, n8n, AI “pipelines” from OpenAI/Google, etc. Underneath, it’s all node graphs. So the goal is to own that layer and build a UI that’s simple, fast, and hackable.

Two days ago, with help from an LLM, this is already live in a browser:

`git@github.com:sylwesterdigital/nodes-pipe-line.git`

**What works right now**

* Local **projects with persistence** (IndexedDB): create, open, duplicate, delete.
* SVG **node canvas**: click to add nodes, drag to move, links follow.
* Node **context menu**: connect, rename, description, duplicate, delete.
* **Undo / Redo / Save** with history + keyboard shortcuts.
* Per-project **color palette** for nodes/links.
* Mobile UI: hamburger menu, tool rail (Lines / Edit / Delete), long-press actions.

**Next few days: roadmap**

* Add **infinite canvas + panning** (trackpad scroll, two-finger pan on mobile).
* Introduce basic **node types**: Source → Transform → Action.
* MVP **runner** that executes the graph and shows per-node status/logs.
* First integrations: HTTP/Webhook + simple LLM transform node.

If node-based “wiring APIs together” interests you, clone it, open the canvas, and start breaking things.
