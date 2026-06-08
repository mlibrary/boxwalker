# Dev Container — RubyMine Remote Development

This project runs in a JetBrains [Dev Container](https://www.jetbrains.com/help/idea/connect-to-devcontainer.html)
with **RubyMine** as the backend IDE (see [`devcontainer.json`](./devcontainer.json)).

## What's installed

Beyond the RubyMine backend, the dev container provisions some tooling that the
production `Dockerfile` deliberately omits (it's built for production, not
development):

- **git**, **GitHub CLI (`gh`)** — via Dev Container Features.
- **Node.js 26 + Yarn** (Yarn classic, via Corepack) — required to build the
  app's CSS (`yarn build:css` / `bin/dev`'s `css` process); the production image
  only has Node in its throwaway build stage.
- **vim** — via the `apt-get-packages` feature (add more CLI tools to that
  `packages` array as needed).

On container create, `bin/setup --skip-server` runs `bundle install`,
`yarn install`, and `bin/rails db:prepare`. Start the app with **`bin/dev`**
(runs the Rails server on port 3000 plus the CSS watcher). Solr's admin UI is
forwarded on port **8983**.

## Portability note (macOS only)

The JetBrains settings mount in `devcontainer.json`:

```
source=${localEnv:HOME}/Library/Application Support/JetBrains
```

is **macOS-specific**. On Linux the equivalent is `~/.config/JetBrains`, and
Windows differs again — there's no single cross-platform expression for it in
`devcontainer.json`. If you're contributing from Linux/Windows and the mount
comes up empty, adjust that `source` path locally (or drop the mount).

## How the IDE is split

JetBrains remote development runs the IDE in two halves:

- **Backend (Host)** — RubyMine running *inside* this container. This is what
  `devcontainer.json` can configure (`backend`, `plugins`, settings, …).
- **Remote Client** — the JetBrains thin client running on *your local machine*.
  This is the UI you actually interact with.

Plugins are tagged to run on the backend, the client, or both. **A
`devcontainer.json` can only install plugins onto the backend — never onto the
client.** See the JetBrains
[docs](https://www.jetbrains.com/help/idea/customizing-devcontainer-json-file.html)
and [KB article](https://youtrack.jetbrains.com/articles/SUPPORT-A-737/How-to-set-up-automatical-plugin-installation-inside-the-dev-container):

> The settings in the devcontainer.json allow installing plugins on the Host
> (IDE backend) only. Some plugins must also be installed on the Client.

## GitHub Copilot

We declare the Copilot plugin in `devcontainer.json` so the **backend** half is
provisioned automatically:

```jsonc
"customizations": {
  "jetbrains": {
    "backend": "RubyMine",
    "plugins": ["com.github.copilot"]
  }
}
```

But Copilot's completion/chat UI is a **client-side** component, so it can't be
auto-installed by the dev container. You have to add it to the **Remote Client**
manually — that's why Copilot can look "missing" in the remote client even
though the project is configured for it.

### Manual setup in the Remote Client

1. In the **JetBrains Client** (the local window, not the container backend),
   open **Settings → Plugins → Marketplace**.
2. Search for **GitHub Copilot** and install it **on the client**.
3. Restart the client when prompted.
4. Sign in: **Tools → GitHub Copilot → Login to GitHub Copilot** and follow the
   device-code flow in your browser.

### Known issue: backend/client interference

When Copilot is active on **both** the backend and the client, the two copies
interfere and inline completions silently fail
([GTW-3086](https://youtrack.jetbrains.com/projects/GTW/issues/GTW-3086)). For
reliable **inline completions**, the consistently reported configuration is:

- Keep Copilot **on the client only**.
- **Fully uninstall** (not just disable) Copilot from the **backend** — and turn
  off settings sync so it isn't re-pushed into the container.

> The `plugins` entry above provisions the backend copy for convenience. If you
> hit the interference bug, remove `"com.github.copilot"` from
> `devcontainer.json` (or uninstall it from the backend) and run Copilot from
> the client only.

### Known issue: recent plugin regressions

Copilot **1.9.x / 1.10.x** (May–June 2026) regressed in remote/Gateway setups —
the UI fails to load and completions/chat go silent
([#1727](https://github.com/microsoft/copilot-intellij-feedback/issues/1727),
[#1786](https://github.com/microsoft/copilot-intellij-feedback/issues),
[#1627](https://github.com/microsoft/copilot-intellij-feedback/issues/1627)).
If completions or chat are dead, **downgrade the client plugin** to a known-good
build — **`1.8.2-243`** is the most-cited stable version.

### Limitations

- **Agent / edit modes** are largely broken in remote dev because Copilot
  doesn't resolve JetBrains' `cwm://` remote URI scheme
  ([#1643](https://github.com/microsoft/copilot-intellij-feedback/issues/1643)).
  Inline suggestions are the reliable feature in this environment.

Copilot is a third-party plugin; report bugs to
[microsoft/copilot-intellij-feedback](https://github.com/microsoft/copilot-intellij-feedback/issues).
