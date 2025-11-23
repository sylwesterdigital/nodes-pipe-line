# DOC-STRUCTURE.md

Data format used for **Node Canvas** import / export.

The app stores all persistent data in IndexedDB and exports / imports it as a single JSON object.  
There are two variants:

- **Full backup** – contains *all* projects (`exportAllData` / “Export data (JSON)”).
- **Single-project export** – contains only one project and its data (`exportSingleProject` / per-project “Export”).

Both variants share the *same* JSON schema; the single-project export just has arrays with one project.

---

## 1. Top-level JSON shape

```ts
interface BackupFile {
  dbName: string;          // "node-editor"
  version: number;         // IndexedDB schema version, currently 1
  exportedAt: string;      // ISO timestamp of when the file was created

  projects: ProjectRecord[];
  states: StateRecord[];
  history: HistoryRecord[];
}
````

* `dbName` and `version` are used for sanity checks and future migrations.
* `exportedAt` is informational only.

---

## 2. Projects

Projects map directly to rows in the IndexedDB `projects` object store.

```ts
interface Palette {
  colors: string[];   // HEX colors, e.g. ["#3b82f6","#22c55e",...]
  selected: number;   // index into `colors` (0-based)
}

interface ProjectRecord {
  id: number;         // numeric project id (primary key)
  name: string;

  createdAt: number;  // ms since Unix epoch
  updatedAt: number;  // ms since Unix epoch

  pointer: number;    // latest saved revision number in `states`
  palette: Palette;   // per-project color palette
}
```

**Notes**

* `pointer` is the last snapshot revision (`rev`) that the project currently points to.
* The app expects project ids to be unique integers within this file.

---

## 3. State snapshots

The current graph for a project is stored as diff-friendly snapshots in the `states` store.

```ts
interface StateRecord {
  projectId: number;  // foreign key → ProjectRecord.id
  rev: number;        // revision number (0, 1, 2, ...)

  state: GraphState;
}

interface GraphState {
  nodes: NodeRecord[];
  links: LinkRecord[];
  nextId: number;     // next node id to allocate in this project
}
```

### 3.1 Nodes

```ts
type NodeShape = "pill" | "rect" | "triangle" | "circle" | undefined;

interface NodeStyle {
  shape?: NodeShape;  // default: "pill"
  fill: string;       // HEX color
  stroke: string;     // HEX color
}

interface NodeRecord {
  id: number;         // node identifier (unique *within* a project state)
  x: number;          // SVG-space x coordinate
  y: number;          // SVG-space y coordinate

  label: string;      // short text inside the node

  style?: NodeStyle;  // optional, falls back to default if missing

  // optional free-text description edited in the “Description” modal
  description?: string;
}
```

**Notes**

* `id` is local to the project; different projects can reuse the same node ids.
* `description` is a plain string, may be absent or empty.

### 3.2 Links

```ts
interface LinkStyle {
  color: string;      // HEX color of the line
}

interface LinkRecord {
  from: number;       // NodeRecord.id
  to: number;         // NodeRecord.id
  style?: LinkStyle;
}
```

**Notes**

* Links are directional (`from` → `to`), but layout and rendering treat them visually as undirected straight lines.
* If `style` is missing, the link uses the currently selected palette color when created.

---

## 4. History log

The `history` store keeps an append-only log of actions performed in a project.
This powers undo/redo and is useful for debugging, but imports do not need to understand every action type to be valid.

```ts
interface HistoryRecord {
  projectId: number;   // foreign key → ProjectRecord.id
  seq: number;         // sequence number (1, 2, 3, ...) within project

  action: HistoryAction;
}
```

`HistoryAction` is a discriminated union. The app currently writes (non-exhaustive list):

```ts
type HistoryAction =
  | { type: "INIT"; at: number }
  | { type: "ADD_NODE"; at: number; node: NodeRecord }
  | { type: "MOVE_NODE"; at: number; id: number; x: number; y: number }
  | { type: "DELETE_NODE"; at: number; id: number }
  | { type: "DUPLICATE_NODE"; at: number; from: number; to: number }
  | { type: "CONNECT"; at: number; from: number; to: number; color: string }
  | { type: "CLEAR_LINKS"; at: number }
  | { type: "CLEAR_ALL"; at: number }
  | { type: "RENAME_NODE"; at: number; id: number; from: string; to: string }
  | { type: "STYLE_NODE"; at: number; id: number; patch: Partial<NodeStyle> }
  | { type: "SET_DESCRIPTION"; at: number; id: number; from: string; to: string }
  | { type: "APPLY_LAYOUT"; at: number; direction: string; rootLabel?: string }
  | { type: "SPLIT_LINK"; at: number; from: number; to: number; via: number; color: string }
  | { type: "DELETE_LINK"; at: number; from: number; to: number }
  | { type: "SPLIT_LINK_WITH_EXISTING_NODE"; at: number; via: number; from: number; to: number; color: string }
  // + possible future actions
```

**Rules**

* `at` is a timestamp in ms since epoch.
* Actions refer to node ids valid in the corresponding project’s snapshots.
* Unknown `type` values should be preserved as opaque objects if re-exported.

---

## 5. Single-project export

The *per-project* export produced by `exportSingleProject(projectId)` uses the same `BackupFile` structure, but only includes data for one project:

* `projects` – array with **one** `ProjectRecord`.
* `states` – all `StateRecord`s whose `projectId` is that project.
* `history` – all `HistoryRecord`s whose `projectId` is that project.

This means the same import code can accept either a full backup or a single-project export.

---

## 6. Import behaviour

Imports are handled by `importBackupData(data, mode)` where `mode` is:

* `"replace"` – **wipe** existing data and replace it with the file.
* `"merge"` – **add** projects from the file next to existing ones.

### 6.1 Replace mode

Steps:

1. Delete the entire IndexedDB database (`node-editor`).
2. Recreate it with the current schema (`version: 1`).
3. Write all `projects`, `states`, `history` from the file *as is*.

Result: the app contains **exactly** the data from the backup.

### 6.2 Merge mode

Goal: keep existing projects and append imported ones, avoiding id collisions.

Algorithm (simplified):

1. Read all existing projects and find `maxId` among their `id`s.
2. Define `offset = maxId`.
3. For every imported `ProjectRecord`:

   * New id = `oldId + offset`.
   * Store project under this new id.
   * Record mapping `idMap[oldId] = newId`.
4. For every imported `StateRecord` and `HistoryRecord`:

   * Remap `projectId` using `idMap`.
   * If an imported projectId was not seen in `projects`, fall back to `oldId + offset` (and record it).
   * Store records with the new `projectId`.

Notes:

* Node ids *inside* each project are unchanged.
* If the backup contains projects whose ids overlap with existing ones, they still import fine due to the `offset`.
* After a merge, `projects-list` shows a combined list of existing and imported projects.

---

## 7. Compatibility guidelines

When generating or transforming this JSON manually:

* Keep `dbName: "node-editor"` and `version: 1` for maximum compatibility.
* Ensure every `ProjectRecord.id` is a positive integer and unique within the file.
* For each project that appears in `states` or `history`, ensure there is a matching `ProjectRecord`.
* `rev` and `seq` are expected to be non-negative integers and usually monotonic within a project, but imports do not strictly depend on this.
* Extra properties on any object are ignored by the app but preserved if the file is re-exported.

This document describes the format used by the current application version; future versions may extend it, but should continue to accept files that conform to this schema.
