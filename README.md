# dsh-launcher — DeepSeek Harness One-Click Launcher / 一键启动器

> **EN** Double-click to launch the [DeepSeek Harness](https://github.com/deepseek-ai/dsh) Web UI and auto-open the browser — zero console windows, plus a one-click stopper.
>
> **中文** 双击即可启动 [DeepSeek Harness](https://github.com/deepseek-ai/dsh) Web 界面并自动打开浏览器。**全程零黑窗口**，并配备一键停止脚本。

![platform](https://img.shields.io/badge/platform-Windows-green)
![license](https://img.shields.io/badge/license-MIT-blue)

---

## Features / 特性

- **EN** One click to start: double-click `启动-DeepSeek-Harness.vbs` — no CMD, no typing.
- **中文** 双击启动：双击 `启动-DeepSeek-Harness.vbs` 即可，无需打开命令行、无需敲命令。
- **EN** Fully hidden: no black console windows appear during startup (VBS invokes the batch hidden).
- **中文** 完全隐藏：启动过程不弹任何黑色命令行窗口（通过 VBS 隐藏调用）。
- **EN** Auto-open browser: opens `http://127.0.0.1:3080` once ready.
- **中文** 自动打开网页：就绪后自动打开 `http://127.0.0.1:3080`。
- **EN** No duplicate start: if already running, only opens the page.
- **中文** 不重复启动：已运行时仅打开网页，不重复拉起服务。
- **EN** Independent stopper: double-click `停止-Harness.vbs` to stop.
- **中文** 独立停止：双击 `停止-Harness.vbs` 一键停止服务。
- **EN** Portable: no hard-coded local paths; works anywhere Node.js is installed.
- **中文** 通用发布：无任何本机写死路径，装了 Node.js 即可使用。

---

## How it works / 它做了什么

**EN** Start flow — double-click `启动-DeepSeek-Harness.vbs`:
1. Invokes `启动-DeepSeek-Harness.bat` in hidden mode.
2. Checks whether a Harness is listening on port `3080`:
   - Already running → just open the browser.
   - Not running → launch the official command `npx @deepseek-ai/dsh web` in the background (no window).
3. Polls the port; as soon as it is ready, opens the browser.

**中文** 启动链路——双击 `启动-DeepSeek-Harness.vbs`：
1. 以隐藏方式调用 `启动-DeepSeek-Harness.bat`。
2. 检测 `3080` 端口是否有 Harness 在运行：
   - 已在运行 → 直接打开浏览器；
   - 未运行 → 后台（无窗口）执行官方命令 `npx @deepseek-ai/dsh web`。
3. 轮询端口，一就绪即自动打开浏览器。

**EN** Stop flow — double-click `停止-Harness.vbs`: finds the process listening on `3080` and ends its whole process tree.
**中文** 停止链路——双击 `停止-Harness.vbs`：找到监听 `3080` 的进程并结束其整个进程树。

Core command (official DeepSeek Harness):
```bat
npx @deepseek-ai/dsh web
```

---

## Requirements / 前置要求

- **EN** Windows; **Node.js** (with npm/npx) installed — required. Verify with `npx --version`.
- **中文** Windows 系统；已安装 **Node.js（含 npm / npx）**——必装。用 `npx --version` 校验。

> **EN** `npx` auto-downloads `@deepseek-ai/dsh` on first run — no manual install needed.
> **中文** `npx` 首次会自动下载 `@deepseek-ai/dsh`，无需手动安装。

---

## Usage / 使用方法

**EN**
1. Clone / download this repo.
2. **Start**: double-click `启动-DeepSeek-Harness.vbs` → browser opens `http://127.0.0.1:3080`.
3. **Stop**: double-click `停止-Harness.vbs`.

**中文**
1. 克隆 / 下载本仓库。
2. **启动**：双击 `启动-DeepSeek-Harness.vbs` → 浏览器自动打开 `http://127.0.0.1:3080`。
3. **停止**：双击 `停止-Harness.vbs`。

> **EN** If VBS is blocked by system policy, double-click the `.bat` instead, or run `cscript 启动-DeepSeek-Harness.vbs` to see errors.
> **中文** 若系统禁用 VBS，可直接双击 `.bat`，或运行 `cscript 启动-DeepSeek-Harness.vbs` 查错。

---

## Directory structure / 目录结构

```
dsh-launcher/
├── 启动-DeepSeek-Harness.vbs   # start (hidden) / 启动（全隐藏）
├── 启动-DeepSeek-Harness.bat   # start worker / 启动工序脚本
├── 停止-Harness.vbs            # stop (hidden) / 停止（全隐藏）
├── 停止-Harness.bat            # stop worker / 停止工序脚本
├── README.md
└── LICENSE
```

---

## FAQ / 常见问题

**Q (EN) Double-clicking the `.vbs` does nothing or is blocked by an antivirus?**
**A** Double-click the `.bat` instead (a console flashes briefly but it works), or run `cscript 启动-DeepSeek-Harness.vbs` to check errors.

**Q (中文) 双击 `.vbs` 没反应，或被安全软件拦截？**
**A** 可直接双击对应的 `.bat`（会短暂闪一个黑窗但功能正常），或用 `cscript 启动-DeepSeek-Harness.vbs` 排查报错。

**Q (EN) It flashes and exits but the browser doesn't open?**
**A** Usually Node.js is missing — verify with `npx --version`. If installed, port 3080 may be occupied by another program; close it first.

**Q (中文) 双击后一闪而过但浏览器没弹出来？**
**A** 多半是没装 Node.js——用 `npx --version` 校验；装了仍不行，是 3080 被其他程序占用，先关掉它。

**Q (EN) Want a different port?**
**A** Change `set "PORT=3080"` to the same port in both `启动-DeepSeek-Harness.bat` and `停止-Harness.bat`.

**Q (中文) 想改端口？**
**A** 把 `启动-DeepSeek-Harness.bat` 和 `停止-Harness.bat` 里的 `set "PORT=3080"` 都改成同一个端口。

---

## Technical details / 技术细节

- **EN** Port check: `netstat -ano | findstr /R ":%PORT%.*LISTENING"` (single no-space pattern to avoid `findstr` splitting args and misjudging).
- **中文** 端口判断：`netstat -ano | findstr /R ":%PORT%.*LISTENING"`（单一无空格模式，避免 `findstr` 按空格拆分参数导致误判）。
- **EN** Hidden start: VBS `WScript.Shell.Run(..., 0, False)` + `.bat` `start "" /b`.
- **中文** 隐藏启动：VBS `WScript.Shell.Run(..., 0, False)` + `.bat` 内 `start "" /b`。
- **EN** Stop: `for /f "tokens=5"` grabs the listening PID → `taskkill /PID <pid> /T /F`.
- **中文** 停止：`for /f "tokens=5"` 取监听 PID → `taskkill /PID <pid> /T /F`。
- **EN** Encoding: GBK + CRLF to avoid mojibake / batch flash-exit on Chinese Windows.
- **中文** 编码：GBK + CRLF，避免中文乱码 / 批处理闪退。

---

## License / 开源许可

[MIT](./LICENSE) — free to use, modify & re-distribute.

---

*EN This is a third-party launcher for DeepSeek Harness; not affiliated with deepseek-ai/dsh. `dsh` and `DeepSeek Harness` are trademarks of their respective owners.*
*中文 本工具仅为 DeepSeek Harness 的第三方启动壳，与 deepseek-ai/dsh 官方项目无附属关系。`dsh`、`DeepSeek Harness` 商标归其各自所有者所有。*
