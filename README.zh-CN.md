# dsh-launcher — DeepSeek Harness 一键启动器

> **简体中文** | [English](./README.md)

双击即可启动 [DeepSeek Harness](https://github.com/deepseek-ai/dsh) Web 界面：会先弹出一个小命令行窗口显示启动状态（查端口 → 查更新 → 启动中 → 就绪），自动确认更新、打开浏览器，然后**窗口自动关闭，服务在后台继续运行**。并配备一键停止脚本。

![platform](https://img.shields.io/badge/platform-Windows-green)
![license](https://img.shields.io/badge/license-MIT-blue)

---

## 特性

- **一键启动** — 双击 `启动-DeepSeek-Harness.vbs` 即可：无需打开命令行、无需敲命令。
- **智能状态窗口** — 命令行窗口逐步显示流程，**浏览器打开后窗口自动关闭**。
- **自动更新** — `npx --yes` 自动应答 "Ok to proceed?" 提示；发现新版本时窗口显示 `update found: X -> Y` 并自动更新。
- **自动打开网页** — 就绪后自动打开 `http://127.0.0.1:3080`。
- **关窗不断服务** — 关闭启动窗口不影响后台服务，服务保持运行直到你主动停止。
- **不重复启动** — 已运行时仅打开网页，不重复拉起服务。
- **独立停止** — 双击 `停止-Harness.vbs` 一键停止服务。
- **通用发布、编码安全** — 所有脚本为纯 ASCII + CRLF；中文文件名在运行时拼接，任何 Windows 区域设置都不会乱码。

---

## 它做了什么

**启动链路** — 双击 `启动-DeepSeek-Harness.vbs`（打开正常命令行窗口）：

1. 以正常窗口方式运行 `启动-DeepSeek-Harness.bat`。
2. 检测 `3080` 端口是否有 Harness 在运行：
   - 已在运行 → 直接打开浏览器并退出；
   - 未运行 → 继续。
3. 检查更新（5 秒限时查 registry，离线安全）：
   - 连不上 registry → `cannot reach the registry - using the cached version`；
   - 本地还没有安装 → `first run detected - downloading and installing`；
   - 有新版 → `update found: X -> Y`，在当前状态窗口中**可见地**下载并安装更新（大版本首次更新可能需几分钟）；
   - 已是最新 → `already the latest version`。
4. 以**独立隐藏控制台**启动服务（与启动窗口脱离）：
   ```bat
   powershell -NoProfile -Command "Start-Process -FilePath 'cmd.exe' -ArgumentList '/d','/c','npx --yes @deepseek-ai/dsh@<detected-version> web' -WindowStyle Hidden -PassThru"
   ```
   `--yes` 自动确认 npx 的安装/更新提示。服务运行在独立的隐藏控制台里，启动窗口关闭不影响它。
5. 轮询端口 `3080`（最长约 600 秒，每 30 秒提示一次；若服务进程提前退出会直接报错，不会假装成功），就绪后自动打开浏览器。
6. 窗口提示 `this window closes now...` 后退出 —— **服务继续在后台运行**。

**停止链路** — 双击 `停止-Harness.vbs`：找到监听 `3080` 的进程并结束其整个进程树；约 2 秒后窗口自动关闭。

用到的核心命令（DeepSeek Harness 官方标准）：
```bat
npx --yes @deepseek-ai/dsh web
```

---

## 前置要求

- **Windows 系统**
- 已安装 **Node.js（含 npm / npx）** —— 必装。用 `npx --version` 校验。

> `npx` 首次会自动下载 `@deepseek-ai/dsh`，无需手动安装。

---

## 使用方法

1. 克隆 / 下载本仓库。
2. **启动**：双击 `启动-DeepSeek-Harness.vbs` → 等待浏览器自动打开 `http://127.0.0.1:3080`。
3. **停止**：双击 `停止-Harness.vbs`。

> 若系统禁用 VBS，可直接双击对应的 `.bat`，或运行 `cscript 启动-DeepSeek-Harness.vbs` 查错。

---

## 目录结构

```
dsh-launcher/
├── 启动-DeepSeek-Harness.vbs   # 启动：打开正常窗口，运行启动脚本
├── 启动-DeepSeek-Harness.bat   # 启动工序：查更新 + 隐藏启动 + 探活 + 打开浏览器
├── 停止-Harness.vbs            # 停止：打开正常窗口，运行停止脚本
├── 停止-Harness.bat            # 停止工序：结束端口上的进程树
├── README.md
├── README.zh-CN.md
└── LICENSE
```

---

## 常见问题

**Q：双击 `.vbs` 没反应，或被安全软件拦截？**
**A** 可直接双击对应的 `.bat`，或用 `cscript 启动-DeepSeek-Harness.vbs` 排查报错。

**Q：启动时会弹出一个黑窗口，正常吗？**
**A** 正常。那是启动状态窗口，浏览器打开后它会自动关闭；服务仍在后台运行，只有 `停止-Harness.vbs` 才能真正停止它。

**Q：双击后一闪而过但浏览器没弹出来？**
**A** 多半是没装 Node.js——用 `npx --version` 校验；装了仍不行，是 3080 被其他程序占用，先关掉它。想看到详细报错，可在一个终端里手动运行 `npx --yes @deepseek-ai/dsh web`。

**Q：想改端口？**
**A** 把 `启动-DeepSeek-Harness.bat` 和 `停止-Harness.bat` 里的 `set "PORT=3080"` 都改成同一个端口。

**Q：服务日志去哪了？**
**A** 服务运行在隐藏控制台里，输出不可见。想观察日志，可在终端里手动运行 `npx --yes @deepseek-ai/dsh web`。

---

## 技术细节

- **端口判断**：`netstat -an | findstr /R ":%PORT%[^0-9].*LISTENING"`（单一无空格模式，避免 `findstr` 按空格拆分参数导致误判）。
- **更新检测**：`npm view @deepseek-ai/dsh version --fetch-timeout=5000 --fetch-retries=0` 查 registry 最新版；本地版本从 npx 缓存（`%LOCALAPPDATA%\npm-cache\_npx\*`）中**最新**的 package.json 读取（历史缓存可能残留多个版本，取最新避免误判）；两者用内联 `node` 脚本逐段数字比较（能正确判断 `1.10.0 > 1.9.5`）。
- **自动更新**：`npx --yes @deepseek-ai/dsh@<检测到的版本> web` —— 固定使用检测到的最新版本号，`--yes` 等价于在 "Ok to proceed?" 提示处自动输入 `y`。
- **隐藏后台启动**：PowerShell `Start-Process ... -WindowStyle Hidden` 让服务拥有**独立隐藏控制台**，与启动窗口脱离——启动窗口关闭不影响服务；外层 `powershell` 调用不带 `-WindowStyle Hidden`，避免把启动窗口一起隐藏。
- **停止**：`for /f "tokens=5"` 取监听 PID → `taskkill /PID <pid> /T /F`。
- **编码**：所有脚本为**纯 ASCII + CRLF**；VBS 里的中文文件名用 `ChrW(...)` 在运行时拼接——任何 Windows 区域设置都不会乱码。

---

## 开源许可

[MIT](./LICENSE) — 欢迎任意使用、修改、二次发布。

---

*本工具仅为 DeepSeek Harness 的第三方启动壳，与 deepseek-ai/dsh 官方项目无附属关系。`dsh`、`DeepSeek Harness` 商标归其各自所有者所有。*