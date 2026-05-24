# RansomShield ビルド手順

## EXEのビルド方法（PS2EXE使用）

```powershell
# PS2EXE のインストール（初回のみ）
Install-Module -Name ps2exe -Scope CurrentUser -Force

# EXEビルド
Invoke-ps2exe `
  -InputFile  .\RansomShield.ps1 `
  -OutputFile .\RansomShield.exe `
  -NoConsole:$false `
  -RequireAdmin `
  -Title       "RansomShield" `
  -Description "ランサムウェア防衛ツール" `
  -Version     "1.0.0"
```

## GitHub Releases への公開手順

1. `RansomShield.exe` を VirusTotal (<https://www.virustotal.com>) でスキャン
2. 問題なければ GitHub でタグを作成: `git tag v1.0.0`
3. GitHub の Releases ページからタグを選択してリリース作成
4. `RansomShield.exe` をアセットとして添付

## VirusTotal での誤検知対応

PS2EXEで生成したEXEは「PUA (Potentially Unwanted Application)」として検知される場合があります。  
これは誤検知であり、ソースコード（RansomShield.ps1）を公開することで透明性を示せます。

- 検知率が高い場合: VirusTotalのコメント欄に「False Positive, source: [GitHubリンク]」と報告
- Microsoft への報告: <https://www.microsoft.com/en-us/wdsi/filesubmission>
