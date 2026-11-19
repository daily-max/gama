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

The site config sends `no-cache` on `/` and `/index.html` (everything else is cacheable), adds `X-Content-Type-Options`, `X-Frame-Options`, `Referrer-Policy` and a `Content-Security-Policy`, and answers `/favicon.ico` with `204` — the icon itself is an inline `data:` URI in the page. There is no `EXPOSE`: the port is whatever `$PORT` says at run time.

> Building with `docker build .` from anywhere other than the repo root fails with `failed to read dockerfile: open Dockerfile: no such file or directory` — the context must contain the `Dockerfile`. Either `cd` into the repo or point at it: `docker build -f /path/to/gama/Dockerfile /path/to/gama`.

## Controls

| Action | Keyboard / mouse | Touch |
| --- | --- | --- |
| Move | `WASD` or arrow keys | drag anywhere |
| Steer with pointer | move the mouse — the ship follows | — |
| Fire | automatic | automatic |
| Pause / resume | `P` or `Esc` | tap the pause button, top-right |
| Restart | `R` | — |
| Exit to the title screen | **Exit** on the paused panel (`Tab`, then `Enter`) | tap **Exit** on the paused panel |
| Mute | `M` | — |
| Start | `Space` / `Enter` | tap **Start** |

The ship follows whichever you touched last: press a key to switch to keyboard control, move the mouse to switch back to pointer control. Restarting mid-run with `R` saves a new personal best before it resets.

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
- **Resuming.** Coming back from a pause always runs a 3-2-1 countdown with the simulation frozen, so a drone mid-dive or a boss burst cannot land before you have the controls back. Hold a direction during it and you fly that way the moment it hits zero; press `P`, `Esc` or the corner button to cancel it and go back to paused.
- **Exiting.** The paused panel offers **Exit**: it banks your best score and drops you back on the title screen, exactly as a mid-run restart banks it.
- **Score** is per kill, with bosses worth far more. Your best run is saved in `localStorage`.

## Code map

Everything lives in `index.html`:

- `resize()` — DPR-aware canvas sizing
- `game` — mode, score, wave, timers
- `spawnEnemy()` / `spawnSentinel()` — wave composition and difficulty curve
- `updatePlayer()` / `updateEnemies()` / `updateBullets()` / `updateDrops()` — simulation, all delta-timed
- `draw*()` — the vector artwork: hulls, glow, particles, parallax starfield
- `togglePause()` / `drawCountdown()` — pause, and the 3-2-1 resume countdown: a `resuming` mode that ticks only the clock and leaves the simulation frozen
- `frame()` — the `requestAnimationFrame` loop: a fixed 120 Hz simulation step with a bounded catch-up (12 steps max), so the game plays identically at 30, 60 or 144 Hz and a stalled tab can't teleport anything
- `smooth()` — frame-rate independent smoothing, used for pointer steering
- `damagePlayer()` — returns `true` only when a hit actually lands; enemy body contact is rate-limited by `contactCool` so ramming can't drain or delete anything per frame
- `say()` — polite live-region announcements for wave changes, hull hits and game over

Tuning knobs worth playing with: `maxSpeed` in `updatePlayer()`, the spawn interval in `update()`, and the `hp` / `value` numbers in `spawnEnemy()`.

## Browser support

Chrome, Edge, Firefox and Safari, desktop and mobile. Uses `canvas 2d`, `localStorage` and the Web Audio API; sound is optional and the game runs fine if audio is blocked.

## Accessibility

- The canvas carries a description, and wave changes, hull hits and game over are announced through a polite live region. The score HUD stays silent on purpose, so a kill every few hundred milliseconds can't flood a screen reader.
- Pinch-zoom is left enabled.
- Screen shake and the damage flash are skipped when the OS asks for reduced motion (`prefers-reduced-motion: reduce`).
- Every action has a keyboard equivalent — start, pause, mute, restart — and nothing is pointer-only.

## Performance notes

The background and vignette gradients are built once per resize rather than twice per frame, bullets are drawn in grouped passes so the canvas shadow state is set a handful of times instead of once per bullet, and the particle list is capped at 900 so a long boss fight can't grow it without bound.
