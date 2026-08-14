# dsh-launcher — DeepSeek Harness 一键启动器

> **简体中文** | [English](./README.md)

双击即可启动 [DeepSeek Harness](https://github.com/deepseek-ai/dsh) Web 界面并自动打开浏览器。**全程零黑窗口**，并配备一键停止脚本。

![platform](https://img.shields.io/badge/platform-Windows-green)
![license](https://img.shields.io/badge/license-MIT-blue)

---

## 特性

- **一键启动** — 双击 `启动-DeepSeek-Harness.vbs` 即可：无需打开命令行、无需敲命令。
- **完全隐藏** — 启动过程不弹任何黑色命令行窗口（通过 VBS 隐藏调用批处理）。
- **自动打开网页** — 就绪后自动打开 `http://127.0.0.1:3080`。
- **不重复启动** — 已运行时仅打开网页，不重复拉起服务。
- **独立停止** — 双击 `停止-Harness.vbs` 一键停止服务。
- **通用发布** — 无任何本机写死路径，装了 Node.js 即可使用。

---

## 它做了什么

**启动链路** — 双击 `启动-DeepSeek-Harness.vbs`：

1. 以隐藏方式调用 `启动-DeepSeek-Harness.bat`。
2. 检测 `3080` 端口是否有 Harness 在运行：
   - 已在运行 → 直接打开浏览器；
   - 未运行 → 后台（无窗口）执行官方命令 `npx @deepseek-ai/dsh web`。
3. 轮询端口，一就绪即自动打开浏览器。

**停止链路** — 双击 `停止-Harness.vbs`：找到监听 `3080` 的进程并结束其整个进程树。

用到的核心命令（DeepSeek Harness 官方标准）：
```bat
npx @deepseek-ai/dsh web
```

---

## 前置要求

- **Windows 系统**
- 已安装 **Node.js（含 npm / npx）** —— 必装。用 `npx --version` 校验。

> `npx` 首次会自动下载 `@deepseek-ai/dsh`，无需手动安装。

---

## 使用方法

1. 克隆 / 下载本仓库。
2. **启动**：双击 `启动-DeepSeek-Harness.vbs` → 浏览器自动打开 `http://127.0.0.1:3080`。
3. **停止**：双击 `停止-Harness.vbs`。

> 若系统禁用 VBS，可直接双击对应的 `.bat`，或运行 `cscript 启动-DeepSeek-Harness.vbs` 查错。

---

## 目录结构

```
dsh-launcher/
├── 启动-DeepSeek-Harness.vbs   # 启动（全隐藏）
├── 启动-DeepSeek-Harness.bat   # 启动工序脚本
├── 停止-Harness.vbs            # 停止（全隐藏）
├── 停止-Harness.bat            # 停止工序脚本
├── README.md
├── README.zh-CN.md
└── LICENSE
```

---

## 常见问题

**Q：双击 `.vbs` 没反应，或被安全软件拦截？**
**A** 可直接双击对应的 `.bat`（会短暂闪一个黑窗但功能正常），或用 `cscript 启动-DeepSeek-Harness.vbs` 排查报错。

**Q：双击后一闪而过但浏览器没弹出来？**
**A** 多半是没装 Node.js——用 `npx --version` 校验；装了仍不行，是 3080 被其他程序占用，先关掉它。

**Q：想改端口？**
**A** 把 `启动-DeepSeek-Harness.bat` 和 `停止-Harness.bat` 里的 `set "PORT=3080"` 都改成同一个端口。

---

## 技术细节

- **端口判断**：`netstat -ano | findstr /R ":%PORT%.*LISTENING"`（单一无空格模式，避免 `findstr` 按空格拆分参数导致误判）。
- **隐藏启动**：VBS `WScript.Shell.Run(..., 0, False)` + `.bat` 内 `start "" /b`。
- **停止**：`for /f "tokens=5"` 取监听 PID → `taskkill /PID <pid> /T /F`。
- **编码**：GBK + CRLF，避免中文乱码 / 批处理闪退。

---

## 开源许可

[MIT](./LICENSE) — 欢迎任意使用、修改、二次发布。

---

*本工具仅为 DeepSeek Harness 的第三方启动壳，与 deepseek-ai/dsh 官方项目无附属关系。`dsh`、`DeepSeek Harness` 商标归其各自所有者所有。*
