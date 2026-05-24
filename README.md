# 🛡️ RansomShield

**ランサムウェア防衛ツール for Windows 10/11**

[English](#english) | [日本語](#日本語)

---

## 日本語

### 概要

RansomShield は、経済産業省・IPA が推奨するランサムウェア対策を  
**ワンクリックで適用・確認・解除** できる Windows 用セキュリティツールです。

管理者権限で起動し、CLIメニューから各防衛設定を操作します。

---

### 機能一覧（5モジュール）

| # | 機能 | 内容 |
|---|------|------|
| 1 | **CFA（コントロールドフォルダーアクセス）** | ランサムウェアによる重要フォルダへの書き込みをブロック |
| 2 | **SMB / 管理共有ブロック** | 社内ネットワーク経由の横展開を防止 |
| 3 | **RDP 無効化** | リモートデスクトップ経由の侵入を遮断 |
| 4 | **USB AutoRun 無効化** | USBメモリ経由の自動実行感染を防止 |
| 5 | **UAC 最大レベル** | 権限昇格による被害拡大を抑制 |

---

### 対応する推奨対策

経済産業省・IPA「情報セキュリティ10大脅威 2024」の技術的対策項目を網羅しています。

> ランサムウェアによる被害 = **組織向け脅威 第1位**（2016年から9年連続）

---

### 使い方

#### 方法1: EXEをダブルクリック（推奨）
1. [Releases](../../releases) から `RansomShield.exe` をダウンロード
2. 右クリック → **「管理者として実行」**
3. メニューから操作

#### 方法2: PowerShellスクリプトで実行
```powershell
# 管理者PowerShellで実行
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\RansomShield.ps1
```

---

### スクリーンショット

```
========================================================
  RansomShield  ver 1.0.0
  ランサムウェア防衛ツール
========================================================

  [保護中  OK]  [1] CFA（コントロールドフォルダーアクセス）
  [保護中  OK]  [2] SMB/管理共有ブロック
  [保護中  OK]  [3] RDP 無効化
  [保護中  OK]  [4] USB AutoRun 無効化
  [保護中  OK]  [5] UAC 最大レベル

  防衛スコア: 5/5  [完全防衛]
```

---

### 動作環境

- Windows 10 / 11
- 管理者権限（自動昇格）

---

### ⚠️ 注意事項

- SMBブロックは **共有フォルダ機能** に影響します
- RDP無効化は **リモートデスクトップ接続** を使用している場合に影響します
- 企業・業務環境では必ずIT管理者と相談のうえご利用ください

詳細は [DISCLAIMER.md](DISCLAIMER.md) をご確認ください。

---

### ライセンス

[MIT License](LICENSE)

---

### 📖 このツールを作った経緯

ある日、取引先がランサムウェアに感染した。

すべてのファイルが暗号化され、業務は完全に止まった。復旧には多大な時間と人員が費やされた。その光景を目の当たりにして、「自分には関係ない」とは、もう思えなくなった。

私はIT企業の社員ではありません。20代から、IT系ではない会社の情報システム部員として働いてきた、いわば「社内のPC担当」です。華やかな技術者でも、セキュリティの専門家でもない。でも長年の現場経験を通じて、**「普通の人がどこで困るか」** を誰よりも肌で感じてきた人間です。

調べるほどに分かったことがあります。経済産業省やIPAが推奨するランサムウェア対策の多くは、**Windowsの標準機能だけで実現できる**。難しいコマンドも、高額なソフトも要らない。でも、それを知っている一般のユーザーはほとんどいない。

自分だけが知識を積んでも、自分のPCだけが守られても——それは自己満足でしかありません。人生の半ばを越えた今、積み上げてきたものを、必要としている誰かに届けたい。その一心でRansomShieldを作りました。

開発はGitHub Copilotと二人三脚で行いました。プログラマーではない私が、試行錯誤を繰り返しながら一つひとつ機能を積み上げ、Microsoftの誤検知申請まで乗り越えた記録が、このリポジトリの歴史そのものです。

コードはすべて公開しています。隠すものは何もありません。このツールが、あなたのPC一台を守る力になれれば、それだけで十分です。

> *「自分だけが助かっても意味がない。知識は、人のために使って初めて価値を持つ。」*

---

### 支援・寄付

このツールが役に立った場合、開発継続のためのご支援をいただけると幸いです。

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/fuchigami_michiaki)

📝 **[Read the development story on Qiita](https://qiita.com/fuchigami-michiaki/items/f0f054830067ecde6037)**

📝 **[開発ストーリーを Qiita で読む](https://qiita.com/fuchigami-michiaki/items/f0f054830067ecde6037)**

---

---

## English

### Overview

RansomShield is a Windows security tool that lets you **apply, check, and revert**  
ransomware countermeasures recommended by Japan's METI and IPA — in one click.

It runs with administrator privileges and provides a CLI menu for managing each defense setting.

---

### Features (5 Modules)

| # | Feature | Description |
|---|---------|-------------|
| 1 | **CFA (Controlled Folder Access)** | Blocks ransomware from writing to protected folders |
| 2 | **SMB / Admin Share Block** | Prevents lateral movement over local networks |
| 3 | **RDP Disable** | Blocks intrusion via Remote Desktop Protocol |
| 4 | **USB AutoRun Disable** | Prevents auto-execution malware via USB drives |
| 5 | **UAC Maximum Level** | Limits privilege escalation damage |

---

### Alignment with Security Guidelines

Covers all technical countermeasure items from IPA's  
"Top 10 Information Security Threats 2024":

> Ransomware damage = **#1 organizational threat** (9 consecutive years since 2016)

---

### How to Use

#### Option 1: Run EXE (Recommended)
1. Download `RansomShield.exe` from [Releases](../../releases)
2. Right-click → **"Run as administrator"**
3. Use the CLI menu

#### Option 2: Run PowerShell Script
```powershell
# Run in Administrator PowerShell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\RansomShield.ps1
```

---

### Requirements

- Windows 10 / 11
- Administrator privileges (auto-elevation included)

---

### ⚠️ Disclaimer

- SMB block affects **shared folder** functionality
- RDP disable affects active **Remote Desktop** connections
- In corporate/business environments, consult your IT administrator before use

See [DISCLAIMER.md](DISCLAIMER.md) for full details.

---

### License

[MIT License](LICENSE)

---

### 📖 Why I Built This

One day, a business partner of mine was hit by ransomware.

Every file was encrypted. Operations came to a complete halt. Enormous time and resources were spent just to recover. Watching it unfold, I could no longer tell myself, *"that's someone else's problem."*

I am not a developer at a tech company. Since my twenties, I have worked as an in-house IT staff member at a non-IT company — the person people call when their PC doesn't work. Not a celebrated engineer, not a security expert. But through years of being on the front lines, I have seen firsthand **where ordinary people struggle**.

The more I researched, the clearer it became: most of the ransomware countermeasures recommended by Japan's Ministry of Economy, Trade and Industry (METI) and IPA can be implemented **using only Windows' built-in features**. No complex commands. No expensive software. Yet almost no ordinary user knows this.

Learning it all myself, protecting only my own PC — that would be nothing more than self-satisfaction. Now past the midpoint of my life, I want to pass on what I've built to the people who need it. That is the only reason RansomShield exists.

I developed this tool alongside GitHub Copilot. As a non-programmer, I worked through countless trial-and-error cycles, building each feature one by one — including navigating Microsoft's false positive submission process. The commit history of this repository is the honest record of that journey.

Every line of code is open. There is nothing to hide. If this tool can protect even one more PC, that is enough.

> *"Surviving alone is not enough. Knowledge only has value when it serves others."*

---

### Support / Donation

If this tool helped you, consider supporting continued development.

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/fuchigami_michiaki)

📝 **[Read the development story on Qiita](https://qiita.com/fuchigami-michiaki/items/f0f054830067ecde6037)**

📝 **[Read the development story on Qiita](https://qiita.com/fuchigami-michiaki/items/f0f054830067ecde6037)**