# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository context

This is the `italia` branch/fork of [Podoma](https://github.com/osm-fr/podoma), running the Italian "Progetto del Mese" (Project of the Month) instance at https://osmit-podoma.wmcloud.org. Podoma is an engine that computes and displays statistics about OpenStreetMap community contributions to thematic mapping campaigns.

Most day-to-day work in this branch is adding/updating monthly project definitions under `projects/`, not touching the engine itself. `config.italia.json` holds this instance's config (Italy PBF/OSH sources, map center, GeoJSON bounds, etc.); `config.json` is the active config actually loaded at runtime.

## Commands

There is no test suite (`npm test` is a placeholder) and no linter configured.

```bash
npm install                # install deps
npm run start               # start the web server (reads config.json + DB_URL env var)
npm run features:update     # (re)generates db/11_features_update_tmp.sh (+ imposm yaml/scripts)
npm run changes:update      # (re)generates db/21_changes_update_tmp.sh
npm run projects:update     # (re)generates db/31_projects_update_tmp.sh
```

Each `*:update` npm script only *generates* a shell script from the current `projects/*/info.json` files; the generated `db/*_tmp.sh` must then be executed (with `init` or `update` as first arg where applicable) to actually touch the database. `dockerfiles/docker-entrypoint.sh` shows the canonical command sequences (`install`, `init`, `run`, `update_daily`, `update_features`, `update_changes`, `update_projects`, `update_imposm`, `uninstall`).

Local Postgres/PostGIS setup:
```bash
psql -c "CREATE DATABASE pdm"
psql -c "CREATE EXTENSION IF NOT EXISTS postgis"
psql -c "CREATE EXTENSION IF NOT EXISTS hstore"
psql -d pdm -f db/01_setup_schema.sql
export DB_URL="postgres://user:password@host:5432/database"
```

Full setup/build/Docker/pg_tileserv instructions are in [docs/DEVELOP.md](docs/DEVELOP.md) — read it before touching the data pipeline or deployment.

**`docs/DEVELOP.md` and `docs/DEVELOP.fr.md` must stay in sync.** Whenever one is edited (new/changed config key, section, instruction, etc.), apply the equivalent change to the other (translated) — never edit just one.

## Architecture

### Monthly projects (`projects/<YYYY-MM>_<slug>/`)

Each subdirectory is one thematic campaign, identified by name `<YYYY-MM>_<slug>` (e.g. `2026-07_itoutdoor`) and contains:
- `info.json` — metadata: dates, links, `database` (perimeter filter + imposm mapping), `datasources` (map layers), `statistics`, `editors` (embedded editor form config), optional `teams`. Full schema is documented in [docs/DEVELOP.md](docs/DEVELOP.md) ("Project configuration" section) — read it before editing `info.json`.
- `howto.md` — Markdown description of what to map, shown on the project page, rendered via `marked`. Keep it aligned with `database.osmium_tag_filter`/`imposm.mapping` in `info.json` whenever either is edited — a tag added/removed from one but not the other silently drifts the documented scope away from what's actually tracked. **Rule: every OSM tag presented in `howto.md` as something to map must be reachable through `info.json`'s perimeter** — either it's itself an anchor tag in `database.osmium_tag_filter`/`imposm.mapping`, or it's a detail/attribute tag that rides along on an object already captured by another anchor tag in the same filter (e.g. `restriction=*`/`except=*` on a relation already selected via `r/type=restriction` — the whole object, all its tags, is captured, not just the matched key). Only the second case is fine to leave out of the filter; a tag that would need to stand as its own anchor (e.g. it can appear on objects that don't carry any other filtered tag) but isn't listed anywhere is a real drift and must be added.
- `contribs.sql` (optional) — SQL `UPDATE` statements against `pdm_features` to classify contributions and award points.
- `extract.sh` (optional) — produces a downloadable CSV export.

A single month can host more than one concurrent project when the topic naturally splits (e.g. `2025-12_itaed` + `2025-12_ithydrant`, or `2026-08_itsigns`/`itlanes`/`itdestination`) — each still needs its own unique `id` and its own badge (see below).

**When adding a new project**, also add `website/images/badges/<slug>.svg` (the part of `name` after the last `_`) — `website/projects.js` sets `project.icon` to that path unconditionally, so a missing file is a broken image on the project/user/badges pages. Match the existing badges' style: `132.39×132.39` viewBox `0 0 35.028 35.028`, a full-circle background (solid or diagonally split two-tone), and a small hand-drawn flat-shape icon for the theme — no raster images or external fonts/icons.

Key perimeter-filtering rule (from docs/DEVELOP.md): `database.osmium_tag_filter` (Osmium tags-filter syntax, `!=` unsupported) and `database.imposm.mapping` should stay selective — focus on the main/anchor tags for the topic, not every possible detail tag, since Osmium/Imposm select "objects existing in OSM" for both the perimeter and for feature counts. Use `database.labels` (Postgres JSON-path over feature tags) to further classify a wide perimeter into sub-populations instead of narrowing the base filter.

`website/projects.js` loads and precomputes every `projects/*/info.json` + `howto.md` into memory once at server startup (no hot reload) — restart the server after editing a project.

### Data pipeline (`db/`)

Numbered scripts represent an ordered pipeline, split between Node.js generators and the SQL/shell scripts they produce and invoke:
- `10_features_update.js` → generates `11_features_update_tmp.sh` + an Imposm YAML config: downloads/updates the OSM PBF, maintains Imposm live tables and the `pdm_boundary*` administrative boundary tables.
- `20_changes_update.js` → generates `21_changes_update_tmp.sh`: turns OSM history/diffs into each project's changelog tables (`pdm_features_<slug>*`) using Osmium, `opl2features.awk` (applies each project's `osmium_tag_filter`), and the `22_*`–`27_*` SQL scripts (init, populate, boundary, members, geometry, labels).
- `30_projects_update.js` → generates `31_projects_update_tmp.sh`: daily statistics — feature/mapper counts (`32_projects_counts.sql`), contribution tagging/points (`33_projects_contribs.sql`), project init (`34_projects_init.sql`), and OSM Notes counts fetched live from the OSM API.

Contribution tagging model (project level): `add`, `edit-in`, `edit`, `edit-out`, `delete`; at label level: `edit-in`, `edit`. This feeds points/gamification (badges) and the per-team/per-mapper KPIs.

Because daily diffs only contain features actually touched that day, referenced-but-untouched way/relation members are fetched via Overpass (`OVERPASS_URL`) to keep geometries complete; set it to `null` to disable. `database.live` per-project additionally sources missing features from a live-updated table when available — the two mechanisms are combined, not alternatives.

### Website (`website/`)

Express + Pug server:
- `index.js` — all routes (project pages, map, stats/counts/contrib/mappers JSON API described in [docs/API.md](docs/API.md), user contribution/ignore endpoints, static/library serving).
- `projects.js` — loads all projects at boot (see above) and precomputes derived fields (`slug`, `howto` HTML, `tagFilterFeatures`, Osmose label/button maps, iD/JOSM changeset params, NSI brand fields).
- `utils.js` — shared helpers (map style generation, query param building, i18n-aware helpers).
- `templates/` — Pug views: `layout.pug` (root layout + CSS), `common/` (head/header/footer shared across pages), `components/` (map, stats blocks, etc.), `pages/` (one file per route).
- `locales/{en,fr,it}.json` — i18n strings (`i18n` package, default locale `en`).

### Database

PostgreSQL + PostGIS + hstore. Per-project tables/views are named from the project slug (the part after the last `_` in the project's `name`), e.g. `pdm_features_<slug>`, `pdm_features_<slug>_changes`, `pdm_project_<slug>` (live Imposm-backed view), plus shared tables `pdm_feature_counts`, `pdm_mapper_counts`, `pdm_user_contribs`, `pdm_boundary`. See [docs/QUERIES.md](docs/QUERIES.md) for example analytical queries and [docs/DEVELOP.md](docs/DEVELOP.md) for the full table conventions if replacing Imposm with another live-updated source.

### Editor integration

`info.json`'s `editors.pdm.fields` defines the embedded-editor form (types: `hidden`, `text`/`number`/`email`, `textarea`, `select`, `2states`/`3states`, `nsi`, `icons`); `editors.all`/`editors.iD`/`editors.JOSM` configure changeset comment/hashtags passed to each editor. See docs/DEVELOP.md "Integrated editor" section for the full field syntax before adding/editing form fields.
