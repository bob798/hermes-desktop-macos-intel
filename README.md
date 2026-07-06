# Hermes Desktop for Intel Macs (unofficial builds)

**English** | [中文](#中文说明)

Unofficial **x86_64 (Intel) macOS builds** of [Hermes Desktop](https://github.com/NousResearch/hermes-agent/tree/main/apps/desktop), the open-source desktop app for [Hermes Agent](https://github.com/NousResearch/hermes-agent) by Nous Research.

## Why this repo exists

The official installer at [hermes-agent.nousresearch.com](https://hermes-agent.nousresearch.com/) ships an **arm64-only** (Apple Silicon) binary. On an Intel Mac, macOS refuses to open it ("You can't use this version of the application..."), and Rosetta can't help — it only translates in the other direction.

Hermes Desktop itself is MIT-licensed open source and builds fine for Intel. This repo provides prebuilt Intel binaries so you don't have to build them yourself.

## How releases are built

Releases are **fully automated**: a [GitHub Actions workflow](.github/workflows/auto-release.yml) checks the [upstream stable releases](https://github.com/NousResearch/hermes-agent/releases) every 6 hours. When a new one ships, it checks out that exact release tag, builds the app for x86_64 on GitHub's `macos-15-intel` runner (a clean cloud machine — no local environment involved), verifies that the main binary **and every native module** are Intel-only, runs `hdiutil verify` on the DMG, and publishes DMG + ZIP + `SHA256SUMS.txt`. Each release notes the upstream tag and commit it was built from.

This repo intentionally does not vendor the upstream source tree — audit the complete source in the [official repository](https://github.com/NousResearch/hermes-agent).

## Install

1. Download the latest `Hermes-<version>-mac-x64.dmg` from [Releases](../../releases)
2. Open the DMG and drag **Hermes.app** to Applications
3. **First launch** (the app is not notarized — see [Security notes](#security-notes)):
   - Right-click Hermes.app → **Open** → **Open** in the dialog, or
   - Run `xattr -cr /Applications/Hermes.app` in Terminal, then open normally
4. On first run the app bootstraps its backend automatically (downloads the official `install.sh` from Nous Research and installs the Hermes CLI to `~/.hermes`), then walks you through provider/model setup

## Build it yourself (recommended if you don't want to trust our binaries)

The whole build is two commands on any Intel Mac:

```bash
curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash -s -- --skip-setup
~/.local/bin/hermes desktop --build-only
# app lands in ~/.hermes/hermes-agent/apps/desktop/release/mac/Hermes.app
```

Or use [`scripts/build.sh`](scripts/build.sh), which does the above plus DMG packaging.

## Security notes

- Builds are **ad-hoc signed** (no Apple Developer ID, no notarization). Gatekeeper will warn on first launch — that's expected for unsigned open-source builds.
- Each release notes the exact upstream commit it was built from. Verify by rebuilding from that commit and comparing.
- Releases are scanned before upload: no credentials, no API keys, no user-specific paths are embedded (config lives in `~/.hermes`, outside the app bundle).
- This repo contains **no modified code** — it packages the unmodified upstream source for a different CPU architecture.

## Updating

`hermes update` updates the backend. For the app itself, grab a newer release here or rebuild locally. (The in-app updater targets official builds and may re-download the arm64 version — prefer this repo's releases on Intel.)

## Relationship to upstream

This is an **unofficial community effort**, not affiliated with or endorsed by Nous Research. Hermes Agent and Hermes Desktop are © Nous Research, released under the [MIT License](https://github.com/NousResearch/hermes-agent/blob/main/LICENSE). This repo redistributes builds under the same license. If Nous Research ships official Intel builds, use those instead — and this repo will be archived.

---

## 中文说明

这是 [Hermes Desktop](https://github.com/NousResearch/hermes-agent/tree/main/apps/desktop)（Nous Research 出品的开源 AI Agent 桌面版）的**非官方 Intel (x86_64) macOS 构建**。

**为什么需要这个仓库**：官网安装包只编译了 Apple Silicon (arm64) 版本，Intel Mac 打开会提示"此电脑版本无法使用"。Hermes 桌面版本身是 MIT 开源的，可以为 Intel 正常编译——这里提供编译好的版本。

**构建方式**：发布完全自动化——GitHub Actions 每 6 小时检查[上游稳定版](https://github.com/NousResearch/hermes-agent/releases)，有新版即在 GitHub 云端的 `macos-15-intel`（Intel 架构）机器上从官方 release tag 精确构建，逐一校验主程序与全部原生模块均为 x86_64，DMG 通过 `hdiutil verify` 后发布（附 SHA-256 校验文件）。每个 Release 都标注对应的上游 tag 和 commit，本仓库不复制上游源码，源码请在[官方仓库](https://github.com/NousResearch/hermes-agent)审计。

**安装**：

1. 从 [Releases](../../releases) 下载最新的 `Hermes-<版本>-mac-x64.dmg`
2. 打开 DMG，把 **Hermes.app** 拖到"应用程序"
3. 首次打开（App 未经 Apple 公证）：右键 Hermes.app → **打开** → 在弹窗中再点**打开**；或在终端执行 `xattr -cr /Applications/Hermes.app`
4. 首次运行会自动安装后端（从 Nous 官方下载 `install.sh` 装到 `~/.hermes`），然后进入配置向导选择模型和填写 key

**自己构建**（不想信任第三方二进制的话，两条命令搞定）：

```bash
curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash -s -- --skip-setup
~/.local/bin/hermes desktop --build-only
```

**安全说明**：构建为 ad-hoc 签名（无开发者证书、未公证），首次打开有 Gatekeeper 提示属正常现象；每个 Release 都标注了对应的上游 commit，可自行复现验证；发布前已扫描确认不含任何密钥、凭据或个人路径。

本仓库为社区非官方项目，与 Nous Research 无关联。代码版权归 Nous Research，MIT 协议。如官方发布 Intel 版本，请优先使用官方版，本仓库届时将归档。
