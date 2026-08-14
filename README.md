# dsh-launcher — DeepSeek Harness One-Click Launcher

> [简体中文](./README.zh-CN.md) | **English**

Double-click to launch the [DeepSeek Harness](https://github.com/deepseek-ai/dsh) Web UI and auto-open the browser — **zero console windows**, plus a one-click stopper.

![platform](https://img.shields.io/badge/platform-Windows-green)
![license](https://img.shields.io/badge/license-MIT-blue)

---

## Features

- **One click to start** — double-click `启动-DeepSeek-Harness.vbs`: no CMD, no typing.
- **Fully hidden** — no black console windows appear during startup (VBS invokes the batch in hidden mode).
- **Auto-open browser** — opens `http://127.0.0.1:3080` as soon as it is ready.
- **No duplicate start** — if already running, only opens the page.
- **Independent stopper** — double-click `停止-Harness.vbs` to stop.
- **Portable** — no hard-coded local paths; works anywhere Node.js is installed.

---

## How it works

**Start flow** — double-click `启动-DeepSeek-Harness.vbs`:

1. Invokes `启动-DeepSeek-Harness.bat` in hidden mode.
2. Checks whether a Harness is listening on port `3080`:
   - Already running → just open the browser.
   - Not running → launch the official command `npx @deepseek-ai/dsh web` in the background (no window).
3. Polls the port; as soon as it is ready, opens the browser.

**Stop flow** — double-click `停止-Harness.vbs`: finds the process listening on `3080` and ends its whole process tree.

Core command (official DeepSeek Harness):
```bat
npx @deepseek-ai/dsh web
```

---

## Requirements

- **Windows**
- **Node.js** (with npm / npx) installed — required. Verify with `npx --version`.

> `npx` auto-downloads `@deepseek-ai/dsh` on first run — no manual installation needed.

---

## Usage

1. Clone / download this repo.
2. **Start**: double-click `启动-DeepSeek-Harness.vbs` → browser opens `http://127.0.0.1:3080`.
3. **Stop**: double-click `停止-Harness.vbs`.

> If VBS is blocked by system policy, double-click the `.bat` instead, or run `cscript 启动-DeepSeek-Harness.vbs` to see errors.

---

## Directory structure

```
dsh-launcher/
├── 启动-DeepSeek-Harness.vbs   # start (hidden)
├── 启动-DeepSeek-Harness.bat   # start worker
├── 停止-Harness.vbs            # stop (hidden)
├── 停止-Harness.bat            # stop worker
├── README.md
├── README.zh-CN.md
└── LICENSE
```

---

## FAQ

**Q: Double-clicking the `.vbs` does nothing or is blocked by an antivirus?**
**A** Double-click the `.bat` instead (a console flashes briefly but it works), or run `cscript 启动-DeepSeek-Harness.vbs` to check errors.

**Q: It flashes and exits but the browser doesn't open?**
**A** Usually Node.js is missing — verify with `npx --version`. If installed, port 3080 may be occupied by another program; close it first.

**Q: Want a different port?**
**A** Change `set "PORT=3080"` to the same port in both `启动-DeepSeek-Harness.bat` and `停止-Harness.bat`.

---

## Technical details

- **Port check**: `netstat -ano | findstr /R ":%PORT%.*LISTENING"` (a single no-space pattern to avoid `findstr` splitting arguments and misjudging).
- **Hidden start**: VBS `WScript.Shell.Run(..., 0, False)` + `.bat` `start "" /b`.
- **Stop**: `for /f "tokens=5"` grabs the listening PID → `taskkill /PID <pid> /T /F`.
- **Encoding**: GBK + CRLF to avoid mojibake / batch flash-exit on Chinese Windows.

---

## License

[MIT](./LICENSE) — free to use, modify and re-distribute.

---

*This is a third-party launcher for DeepSeek Harness; not affiliated with deepseek-ai/dsh. `dsh` and `DeepSeek Harness` are trademarks of their respective owners.*
