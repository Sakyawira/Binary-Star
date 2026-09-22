# GitHub Pages and iframe embedding

The `Web` export preset builds a single-threaded Godot game. It runs on static
hosting without COOP/COEP headers or a service worker, including when embedded
on another website. Godot documents this setup in its
[Web export guide](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_web.html).

## Deploy

1. In this repository's **Settings → Pages → Build and deployment**, choose
   **GitHub Actions** as the source.
2. Merge the Godot project and `.github/workflows/deploy-pages.yml` into `main`.
3. Open **Actions → Build and deploy Binary Star** to follow the first deployment.
   Later pushes to `main` publish automatically. **Run workflow** on `main` also
   rebuilds and publishes the site.

This repository is public, so GitHub Pages is available on the free plan.
Private forks require a supported paid plan; see [GitHub Pages availability](https://docs.github.com/en/pages/getting-started-with-github-pages/what-is-github-pages).
The workflow does not change repository visibility or enable Pages itself.
No personal access token or custom secret is required for deployment: the deploy
job uses the repository's automatic token and Pages OIDC permissions.

Expected URLs after the first successful deployment:

- Site with a responsive iframe: `https://sakyawira.github.io/Binary-Star/`
- Game alone, for embedding: `https://sakyawira.github.io/Binary-Star/game/`

The workflow pins Godot **4.7.2** and Ink **1.2.1**, downloads the official
releases, verifies Godot's published checksums, and caches the installed tools.
It recompiles the dialogue and fixtures, imports resources, runs the headless
game tests, and exports the Web preset. It packages only `builds/web` as the
Pages artifact. Pull requests to `main` build and validate without publishing.
Manual runs on other branches also build without replacing the live site.

The exported pack includes GDScript classes and shaders referenced from code,
not only scene dependencies. Keep `export_filter="all_resources"`; a scene-only
export omits parts of the Ink runtime and the portrait/background shaders.

The workflow uses GitHub's official
[Pages deployment actions](https://docs.github.com/en/pages/getting-started-with-github-pages/using-custom-workflows-with-github-pages).
If the repository has deployment protection rules, allow `main` in the
`github-pages` environment.

## Embed on another website

```html
<iframe
  src="https://sakyawira.github.io/Binary-Star/game/"
  title="Play Binary Star"
  style="display:block;width:100%;aspect-ratio:16/9;border:0"
  allow="autoplay; fullscreen"
></iframe>
```

Click inside the game before using the keyboard. Browsers may wait for the first
interaction before enabling audio. The exported HTML fills its iframe; all asset
URLs remain relative so the game also works under GitHub's repository subpath.
`web/index.html` is the site's wrapper and includes a full-screen control and a
direct-game link.

When checking a web build, reveal a line and wait with **Sound on**: music should
continue after the typing stops. Also check mute/unmute, restart, and act
transitions. Startup uses separate reset and story-start signals: exported scenes
can reorder connections, so starting and resetting audio from the same signal
can silence the music even when the editor version works.
Music uses Stream playback so its runtime loop settings also work on the web;
typing sounds retain the default low-latency playback.

## Local browser check

Install Godot's export templates for **4.7.2**, then run:

```sh
mkdir -p builds/web/game
godot --headless --path . --editor --import
godot --headless --path . --export-release Web builds/web/game/index.html
cp web/index.html builds/web/index.html
python3 -m http.server 8765 --bind 127.0.0.1 --directory builds/web
```

Open `http://127.0.0.1:8765/`. Serve the files over HTTP rather than opening the
HTML directly. Build outputs stay ignored by Git; Actions recreates them for
every deployment. Workflow syntax can be checked with
`actionlint .github/workflows/deploy-pages.yml`.
