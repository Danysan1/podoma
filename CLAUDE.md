# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository context

This is the `italia` branch/fork of [Podoma](https://github.com/osm-fr/podoma), running the Italian "Progetto del Mese" (Project of the Month) instance at https://osmit-podoma.wmcloud.org. Podoma is an engine that computes and displays statistics about OpenStreetMap community contributions to thematic mapping campaigns.

Most day-to-day work in this branch is adding/updating monthly project definitions under `projects/`, not touching the engine itself.

### Remotes and branch workflow

- `upstream` = osm-fr/podoma (the engine's home), `origin` = Danysan1/podoma (this fork), `wmf` = the Wikimedia Italia GitLab deployment repo.
- `italia` is a long-lived integration branch: it carries the Italian projects/badges/locale plus engine changes, and `upstream/main` is merged into it periodically.
- Engine changes (anything outside `projects/`, `website/locales/it.json`, `website/images/badges/it*.svg`) are developed on a dedicated topic branch off `main` so they can be PR'd upstream, then merged into `italia` — e.g. `OVERPASS_FATAL`, `feature/USE_SOFT_DATES`, `fix_osh_filtering`. Don't commit engine work directly onto `italia`.
- Node >= 24 is required. `.gitattributes` forces LF on `*.sh` — keep it that way, CRLF breaks the scripts once copied into the Docker image.
- **Soft dates narrow what is *read*, never what is *computed*.** The pipeline keeps producing counts and contributions over the full hard window (`start_date` → `end_date`); `soft_start_date`/`soft_end_date` are applied when querying or aggregating. Capping generation loses the post-campaign data for good and takes a reprocess to undo, and it only ever bounded the end of the window, never the start. Keep new soft-date logic on the read side.

### Configuration

`config.json` is the file actually loaded at runtime and is **gitignored** — it is a local copy of `config.italia.json` (the tracked instance config: Italy PBF/OSH sources, Italian map center/zoom, GeoJSON bounds, Matomo Tag Manager, `USE_SOFT_DATES`, `OVERPASS_FATAL`). Edit `config.italia.json` for anything that should persist, then re-copy. Every config key is documented in the "General configuration" section of [docs/DEVELOP.md](docs/DEVELOP.md).

## Commands

There is no test suite (`npm test` is a placeholder) and no linter configured.

```bash
npm install                 # install deps
npm run start               # start the web server (reads config.json + DB_URL env var)
npm run build:turf          # rebuild website/static/turf.js after bumping @turf/boolean-contains
npm run features:update     # (re)generates db/11_features_update_tmp.sh (+ imposm yaml/scripts)
npm run changes:update      # (re)generates db/21_changes_update_tmp.sh
npm run projects:update     # (re)generates db/31_projects_update_tmp.sh
```

Each `*:update` npm script only *generates* a shell script from the current `projects/*/info.json` files; the generated `db/*_tmp.sh` must then be executed (with `init` or `update` as first arg where applicable) to actually touch the database. `dockerfiles/docker-entrypoint.sh` shows the canonical command sequences (`install`, `init`, `run`, `update_daily`, `update_features`, `update_changes`, `update_projects`, `update_imposm`, `uninstall`).

Operational Docker helpers (used on the server; logs land under `logs/`):

```bash
./dockerfiles/init.sh          # compose up db, build, install schema, full init (backgrounded + tail)
./dockerfiles/update_daily.sh  # nightly: features + changes + projects update
./dockerfiles/teardown.sh      # compose down + drop the podoma_db-data / podoma_pdm-data volumes (destructive)
```

`docker-compose.yml` services: `pgsqldb` (postgis), `pdm` (this app, command `run`), `pdm-tileserv` (pg_tileserv on :7800), `pgadmin` (behind the `pgadmin` profile).

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

Conventions on this branch (follow them when adding a project):
- `id` is a unique integer allocated sequentially from the 100-block (currently up to 122); ids must never collide across projects.
- Dates follow a fixed pattern around the campaign month M: `soft_start_date` = M-01, `soft_end_date` = (M+1)-01, `start_date` = one month before `soft_start_date`, `end_date` = two months after `soft_end_date`. The hard dates widen the data-collection window; because `config.italia.json` sets `USE_SOFT_DATES: true`, the **soft** dates are what the site uses to decide past/current/next and to bound contribution counting.
- A single month can host more than one concurrent project when the topic naturally splits (e.g. `2025-12_itaed` + `2025-12_ithydrant`, or `2026-08_itsigns`/`itlanes`/`itdestination`) — each still needs its own unique `id` and its own badge (see below).

**When adding a new project**, also add `website/images/badges/<slug>.svg` (the part of `name` after the last `_`) — [projects.js:47](website/projects.js#L47) sets `project.icon` to that path unconditionally, so a missing file is a broken image on the project/user/badges pages. Match the existing badges' style: `132.39×132.39` viewBox `0 0 35.028 35.028`, a full-circle background (solid or diagonally split two-tone), and a small hand-drawn flat-shape icon for the theme — no raster images or external fonts/icons.

Key perimeter-filtering rule (from docs/DEVELOP.md): `database.osmium_tag_filter` (Osmium tags-filter syntax, `!=` unsupported) and `database.imposm.mapping` should stay selective — focus on the main/anchor tags for the topic, not every possible detail tag, since Osmium/Imposm select "objects existing in OSM" for both the perimeter and for feature counts. Use `database.labels` (Postgres JSON-path over feature tags) to further classify a wide perimeter into sub-populations instead of narrowing the base filter.

`website/projects.js` loads and precomputes every `projects/*/info.json` + `howto.md` into memory once at server startup (no hot reload) — restart the server after editing a project.

### Data pipeline (`db/`)

Numbered scripts represent an ordered pipeline, split between Node.js generators and the SQL/shell scripts they produce and invoke:
- `10_features_update.js` → generates `11_features_update_tmp.sh` + an Imposm YAML config: downloads/updates the OSM PBF, maintains Imposm live tables and the `pdm_boundary*` administrative boundary tables.
- `20_changes_update.js` → generates `21_changes_update_tmp.sh`: turns OSM history/diffs into each project's changelog tables (`pdm_features_<slug>*`) using Osmium, `opl2features.awk` (applies each project's `osmium_tag_filter`), and the `22_*`–`27_*` SQL scripts (init, populate, boundary, members, geometry, labels).
- `30_projects_update.js` → generates `31_projects_update_tmp.sh`: daily statistics — feature/mapper counts (`32_projects_counts.sql`), contribution tagging/points (`33_projects_contribs.sql`), project init (`34_projects_init.sql`), and OSM Notes counts fetched live from the OSM API.

The generated `db/*_tmp.sh` / `*_tmp.sql` are gitignored build artifacts — never edit them, edit the generator that emits them.

Contribution tagging model (project level): `add`, `edit-in`, `edit`, `edit-out`, `delete`; at label level: `edit-in`, `edit`. This feeds points/gamification (badges) and the per-team/per-mapper KPIs.

### Points, leaderboard and badges

The whole chain lives in SQL, not in the website: `pdm_user_contribs` (one row per day/user/label/contribution, written by `33_projects_contribs.sql`) → the `pdm_leaderboard` view (points summed per user+project, plus the ranking position) → the `pdm_get_badges(project, userid)` function. The last two are defined in `db/01_setup_schema.sql`; `getBadgesDetails()` in `website/utils.js` only decides which of the returned badges get displayed. Things that are easy to get wrong here:

- **`pdm_user_contribs.ts` is the closing timestamp of the aggregation bucket, not the contribution day**: an edit made on day D is stored with `ts = D+1`, because `33_projects_contribs.sql` joins `fc.ts_start BETWEEN d.ts_past AND d.ts` with `ts_past = ts - 1 day` (or `- 1 month` for the monthly buckets used on long initial ranges). A period filter must therefore be `ts > start AND ts <= end` — `BETWEEN` credits the day before the project started.
- **`USE_SOFT_DATES` is a website config key and is invisible to SQL.** It reaches the database through `20_changes_update.js`, which writes `soft_start_date`/`soft_end_date` into `pdm_projects` *only* when the setting is enabled; SQL then simply reads `COALESCE(soft_start_date, start_date)`. Consequence: toggling the setting, or editing soft dates in an `info.json`, only takes effect at the next `changes:update` run.
- **`01_setup_schema.sql` is only executed by the `install` command.** Its views and functions use `CREATE OR REPLACE`, so re-running `install` against a populated database is how you deploy a change to `pdm_leaderboard` or `pdm_get_badges` — the `CREATE TABLE` statements fail harmlessly with "already exists" and psql carries on. No reinit or data reprocessing is needed, since both are computed at query time.

Because daily diffs only contain features actually touched that day, referenced-but-untouched way/relation members are fetched via Overpass (`OVERPASS_URL`) to keep geometries complete; set it to `null` to disable. `OVERPASS_FATAL` (false on this instance) decides whether a failed Overpass request aborts `update_changes` or only logs a warning — false keeps the nightly run alive at the cost of known statistical errors. `database.live` per-project additionally sources missing features from a live-updated table when available — the mechanisms are combined, not alternatives.

### Website (`website/`)

Express + Pug server:
- `index.js` — all routes (project pages, map, stats/counts/contrib/mappers JSON API described in [docs/API.md](docs/API.md), user contribution/ignore endpoints, static/library serving).
- `projects.js` — loads all projects at boot (see above) and precomputes derived fields (`slug`, `howto` HTML, `tagFilterFeatures`, Osmose label/button maps, iD/JOSM changeset params, NSI brand fields).
- `utils.js` — shared helpers (map style generation, query param building, i18n-aware helpers, soft/hard date resolution).
- `templates/` — Pug views: `layout.pug` (root layout + CSS), `common/` (head/header/footer shared across pages), `components/` (map, stats blocks, etc.), `pages/` (one file per route).
- `locales/{en,fr,it}.json` — i18n strings (`i18n` package, default locale `en`). **`it.json` must keep exactly the same key set as `en.json`** — a new user-facing string in a template needs both. `fr.json` is upstream-maintained and may lag.

### Database

PostgreSQL + PostGIS + hstore. Per-project tables/views are named from the project slug (the part after the last `_` in the project's `name`), e.g. `pdm_features_<slug>`, `pdm_features_<slug>_changes`, `pdm_project_<slug>` (live Imposm-backed view), plus shared tables `pdm_feature_counts`, `pdm_mapper_counts`, `pdm_user_contribs`, `pdm_boundary`. See [docs/QUERIES.md](docs/QUERIES.md) for example analytical queries and [docs/DEVELOP.md](docs/DEVELOP.md) for the full table conventions if replacing Imposm with another live-updated source.

### Editor integration

`info.json`'s `editors.pdm.fields` defines the embedded-editor form (types: `hidden`, `text`/`number`/`email`, `textarea`, `select`, `2states`/`3states`, `nsi`, `icons`); `editors.all`/`editors.iD`/`editors.JOSM` configure changeset comment/hashtags passed to each editor. See docs/DEVELOP.md "Integrated editor" section for the full field syntax before adding/editing form fields.
