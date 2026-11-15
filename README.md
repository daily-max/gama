# GAMA — Neon Sentinel

A tiny arcade survival shooter that runs in the browser. One file, no build step, no dependencies, no assets — every ship, drone and explosion is drawn on a `<canvas>` at runtime.

Your ship fires on its own. You fly, line up the shot, and try to stay alive as the waves get heavier.

## Play

Open `index.html` in any modern browser — double-clicking it is enough.

Or serve it locally:

```bash
python3 -m http.server 8000
# then open http://localhost:8000
```

### Play it on GitHub Pages

1. Repo **Settings → Pages**
2. Source: **Deploy from a branch**
3. Branch: `main`, folder: `/ (root)` → **Save**

The game goes live at `https://daily-max.github.io/gama/` within a minute or so.

### Run with Docker

The repo has a `Dockerfile` at its root, so a build from the repo root works out of the box:

```bash
docker build -t gama .
docker run --rm -p 8080:8080 gama
# then open http://localhost:8080
```

The container listens on `PORT`, which defaults to `8080`. On a platform that hands you a port, pass it in:

```bash
docker run --rm -e PORT=3000 -p 3000:3000 gama
```

It is `nginx:1.27-alpine` with two files copied in — the game and an nginx site config rendered from `nginx/default.conf.template`. No Node, no build step, no dependencies.

> Building with `docker build .` from anywhere other than the repo root fails with `failed to read dockerfile: open Dockerfile: no such file or directory` — the context must contain the `Dockerfile`. Either `cd` into the repo or point at it: `docker build -f /path/to/gama/Dockerfile /path/to/gama`.

## Controls

| Action | Keyboard / mouse | Touch |
| --- | --- | --- |
| Move | `WASD` or arrow keys | drag anywhere |
| Steer with pointer | move the mouse — the ship follows | — |
| Fire | automatic | automatic |
| Pause / resume | `P` or `Esc` | — |
| Restart | `R` | — |
| Mute | `M` | — |
| Start | `Space` / `Enter` | tap **Start** |

The ship follows whichever you touched last: press a key to switch to keyboard control, move the mouse to switch back to pointer control.

## How it plays

- **Waves.** Every 10 kills pushes you into the next wave. Spawns get faster and enemies get tougher with each one.
- **Enemies.**
  - *Drifter* — slow triangle, drifts down, takes a few hits.
  - *Weaver* — fast, weaves sideways, fragile.
  - *Gunner* — fires aimed shots at you.
  - *Sentinel* — the big hexagonal boss that shows up every 5th wave, sits at the top and sprays radial bursts until you break it.
- **Pickups.** Dropped by drones and bosses, they fall slowly — catch them:
  - `R` rapid fire (8s)
  - `T` triple shot (10s)
  - `S` shield, absorbs one hit (9s)
  - `+` repairs one hull bar
- **Lives.** Three hull bars. A hit costs one and gives you a short window of invulnerability. Colliding with a drone hurts both of you.
- **Score** is per kill, with bosses worth far more. Your best run is saved in `localStorage`.

## Code map

Everything lives in `index.html`:

- `resize()` — DPR-aware canvas sizing
- `game` — mode, score, wave, timers
- `spawnEnemy()` / `spawnSentinel()` — wave composition and difficulty curve
- `updatePlayer()` / `updateEnemies()` / `updateBullets()` / `updateDrops()` — simulation, all delta-timed
- `draw*()` — the vector artwork: hulls, glow, particles, parallax starfield
- `frame()` — the `requestAnimationFrame` loop, delta clamped to 50 ms so a stalled tab can't teleport anything

Tuning knobs worth playing with: `maxSpeed` in `updatePlayer()`, the spawn interval in `update()`, and the `hp` / `value` numbers in `spawnEnemy()`.

## Browser support

Chrome, Edge, Firefox and Safari, desktop and mobile. Uses `canvas 2d`, `localStorage` and the Web Audio API; sound is optional and the game runs fine if audio is blocked.
