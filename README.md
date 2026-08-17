# dsh-launcher — DeepSeek Harness One-Click Launcher

> [简体中文](./README.zh-CN.md) | **English**

Double-click to launch the [DeepSeek Harness](https://github.com/deepseek-ai/dsh) Web UI. A small console window shows the startup status (port check → update check → starting → ready), auto-accepts updates, opens the browser, then **the window closes itself while the service keeps running in the background**. Includes a one-click stopper.

![platform](https://img.shields.io/badge/platform-Windows-green)
![license](https://img.shields.io/badge/license-MIT-blue)

---

## Features

- **One click to start** — double-click `启动-DeepSeek-Harness.vbs`: no typing, no manual commands.
- **Smart status window** — a console window shows each step and **closes itself after the browser opens**.
- **Auto-update** — `npx --yes` auto-answers the "Ok to proceed?" prompt; when a new version is found the window shows `update found: X -> Y` and updates automatically.
- **Auto-open browser** — opens `http://127.0.0.1:3080` as soon as it is ready.
- **Close window, keep the port** — closing the launcher window does NOT stop the service; it keeps running hidden in the background until you stop it.
- **No duplicate start** — if already running, only opens the page.
- **Independent stopper** — double-click `停止-Harness.vbs` to stop the service.
- **Portable & encoding-safe** — all scripts are pure ASCII + CRLF; Chinese file names are built at runtime, so everything works on any Windows locale.

---

## How it works

**Start flow** — double-click `启动-DeepSeek-Harness.vbs` (opens a normal console window):

1. Runs `启动-DeepSeek-Harness.bat` in a normal window.
2. Checks whether a Harness is already listening on port `3080`:
   - Already running → just open the browser and exit.
   - Not running → continue.
3. Checks for updates (bounded 5 s registry query, offline-safe):
   - Registry unreachable → `cannot reach the registry - using the cached version`.
   - No local copy yet → `first run detected - downloading and installing`.
   - New version available → `update found: X -> Y`, updates automatically.
   - Already latest → `already the latest version`.
4. Starts the service **detached and hidden** in its own console:
   ```bat
   powershell -NoProfile -Command "Start-Process -FilePath 'cmd.exe' -ArgumentList '/d','/c','npx --yes @deepseek-ai/dsh web' -WindowStyle Hidden"
   ```
   `--yes` auto-confirms any npx install/update prompt. The service runs in a separate hidden console, so the launcher window can close without touching it.
5. Polls port `3080` (up to ~120 s); as soon as it is ready, opens the browser.
6. The window prints `this window closes now...` and exits — **the service keeps running in the background**.

**Stop flow** — double-click `停止-Harness.vbs`: finds the process listening on `3080` and ends its whole process tree; the window closes itself after ~2 s.

Core command (official DeepSeek Harness):
```bat
npx --yes @deepseek-ai/dsh web
```

---

## Requirements

- **Windows**
- **Node.js** (with npm / npx) installed — required. Verify with `npx --version`.

> `npx` auto-downloads `@deepseek-ai/dsh` on first run — no manual installation needed.

---

## Usage

1. Clone / download this repo.
2. **Start**: double-click `启动-DeepSeek-Harness.vbs` → wait for the browser to open `http://127.0.0.1:3080`.
3. **Stop**: double-click `停止-Harness.vbs`.

> If VBS is blocked by system policy, double-click the `.bat` instead, or run `cscript 启动-DeepSeek-Harness.vbs` to see errors.

---

## Directory structure

```
dsh-launcher/
├── 启动-DeepSeek-Harness.vbs   # start: opens a normal window, runs the start worker
├── 启动-DeepSeek-Harness.bat   # start worker: update check + hidden launch + probe + browser
├── 停止-Harness.vbs            # stop: opens a normal window, runs the stop worker
├── 停止-Harness.bat            # stop worker: kills the process tree on the port
├── README.md
├── README.zh-CN.md
└── LICENSE
```

---

## FAQ

**Q: Double-clicking the `.vbs` does nothing or is blocked by an antivirus?**
**A** Double-click the `.bat` instead, or run `cscript 启动-DeepSeek-Harness.vbs` to check errors.

**Q: A black window appears while starting — is that normal?**
**A** Yes. The window shows the startup status and closes itself after the browser opens. The service keeps running in the background — only `停止-Harness.vbs` actually stops it.

**Q: It flashes and exits but the browser doesn't open?**
**A** Usually Node.js is missing — verify with `npx --version`. If installed, port 3080 may be occupied by another program; close it first. For detailed errors, run `npx --yes @deepseek-ai/dsh web` manually in a terminal.

**Q: Want a different port?**
**A** Change `set "PORT=3080"` to the same port in both `启动-DeepSeek-Harness.bat` and `停止-Harness.bat`.

**Q: Where do the service logs go?**
**A** The service runs in a hidden console, so its output is not visible. To watch logs, run `npx --yes @deepseek-ai/dsh web` manually in a terminal.

---

## Technical details

- **Port check**: `netstat -ano | findstr /R ":%PORT%.*LISTENING"` (a single no-space pattern to avoid `findstr` splitting arguments and misjudging).
- **Update check**: `npm view @deepseek-ai/dsh version --fetch-timeout=5000 --fetch-retries=0` for the registry's latest version; the local version is read from the npx cache (`%LOCALAPPDATA%\npm-cache\_npx\*`); a small inline `node` script compares the two segment-by-segment (handles `1.10.0 > 1.9.5` correctly).
- **Auto-update**: `npx --yes @deepseek-ai/dsh web` — `--yes` equals auto-typing `y` at the "Ok to proceed?" prompt.
- **Hidden background start**: PowerShell `Start-Process ... -WindowStyle Hidden` gives the service its own hidden console, detached from the launcher window — closing the launcher window does not stop the service. The outer `powershell` call carries no `-WindowStyle Hidden`, so the launcher window itself stays visible.
- **Stop**: `for /f "tokens=5"` grabs the listening PID → `taskkill /PID <pid> /T /F`.
- **Encoding**: all scripts are **pure ASCII + CRLF**; Chinese file names inside VBS are built at runtime via `ChrW(...)` — no mojibake on any Windows locale.

---

## License

[MIT](./LICENSE) — free to use, modify and re-distribute.

---

*This is a third-party launcher for DeepSeek Harness; not affiliated with deepseek-ai/dsh. `dsh` and `DeepSeek Harness` are trademarks of their respective owners.*