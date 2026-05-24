# ===========================================================
# RansomShield.ps1  v1.0.0
# ===========================================================
# (C) 2026  All rights reserved.
# ※ このスクリプトはPS2EXEでEXE化して配布してください
# ===========================================================

#region --- 管理者昇格 ---
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    $exe = [System.Diagnostics.Process]::GetCurrentProcess().MainModule.FileName
    if ($exe -like '*powershell*' -or $exe -like '*pwsh*') {
        Start-Process powershell -Verb RunAs -ArgumentList (
            "-NoProfile -ExecutionPolicy Bypass -File `"$($MyInvocation.MyCommand.Path)`"")
    } else {
        Start-Process -FilePath $exe -Verb RunAs
    }
    exit
}
#endregion

#region --- 定数 ---
$VERSION = '1.0.0'
$PRODUCT = 'RansomShield'
$LINE    = '=' * 56
$SEP     = '-' * 56
#endregion

#region --- ヘルパー関数 ---
function Write-Header {
    Clear-Host
    Write-Host $LINE -ForegroundColor Cyan
    Write-Host ("  {0}  ver {1}" -f $PRODUCT, $VERSION) -ForegroundColor Cyan
    Write-Host "  ランサムウェア防衛ツール" -ForegroundColor Cyan
    Write-Host $LINE -ForegroundColor Cyan
    Write-Host ""
}

function Write-Sep { Write-Host $SEP -ForegroundColor DarkGray }

function Get-YesNo([string]$label) {
    return if ($label -eq 'yes') { Write-Host "[有効]"   -ForegroundColor Green  -NoNewline }
           else                  { Write-Host "[無効]"   -ForegroundColor Red    -NoNewline }
}

function Pause-Any([string]$msg = "  何かキーを押すと戻ります...") {
    Write-Host ""
    Write-Host $msg -ForegroundColor DarkGray
    $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
}

function Write-SmbStatus {
    # SMB状態を3段階でカラー表示（左カラム形式）
    $reg = 'HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters'
    $av  = (Get-ItemProperty $reg -Name AutoShareWks -EA SilentlyContinue).AutoShareWks
    $fw  = Get-NetFirewallRule -DisplayName 'Block-SMB-Inbound-445' -EA SilentlyContinue
    $c   = Get-SmbShare -Name 'C$' -EA SilentlyContinue
    Write-Host '  ' -NoNewline
    if (($av -eq 0) -and ($null -ne $fw)) {
        if ($c) { Write-Host '[再起動待ち]  ' -NoNewline -ForegroundColor Yellow }
        else    { Write-Host '[保護中  OK]  ' -NoNewline -ForegroundColor Green  }
    } else {
        Write-Host '[未設定  !!]  ' -NoNewline -ForegroundColor Red
    }
    Write-Host '[2] SMB/管理共有ブロック'
}

function Write-StatusRow([bool]$ok, [string]$num, [string]$label) {
    $st    = if ($ok) { '[保護中  OK]' } else { '[未設定  !!]' }
    $color = if ($ok) { 'Green' }        else { 'Red' }
    Write-Host '  ' -NoNewline
    Write-Host $st -NoNewline -ForegroundColor $color
    Write-Host "  $num $label"
}
#endregion

#region --- 状態検出 ---
function Get-SmbStatus {
    $reg  = 'HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters'
    $av   = (Get-ItemProperty $reg -Name AutoShareWks -EA SilentlyContinue).AutoShareWks
    $fw   = Get-NetFirewallRule -DisplayName 'Block-SMB-Inbound-445' -EA SilentlyContinue
    # C$ はWindows が削除後も即時再作成するため条件から除外
    # AutoShareWks=0 により次回起動以降は作成されなくなる
    return ($av -eq 0) -and ($null -ne $fw)
}

function Get-CfaStatus {
    $v = (Get-MpPreference -EA SilentlyContinue).EnableControlledFolderAccess
    return ($v -eq 1)
}

function Get-RdpStatus {
    $v = (Get-ItemProperty 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name fDenyTSConnections -EA SilentlyContinue).fDenyTSConnections
    return ($v -eq 1)
}

function Get-AutoRunStatus {
    $v = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer' -Name NoDriveTypeAutoRun -EA SilentlyContinue).NoDriveTypeAutoRun
    return ($v -eq 0xFF)
}

function Get-UacStatus {
    $v = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' -Name ConsentPromptBehaviorAdmin -EA SilentlyContinue).ConsentPromptBehaviorAdmin
    return ($v -eq 2)
}

function Get-AllStatus {
    return [ordered]@{
        smb     = Get-SmbStatus
        cfa     = Get-CfaStatus
        rdp     = Get-RdpStatus
        autorun = Get-AutoRunStatus
        uac     = Get-UacStatus
    }
}

function Format-Status([bool]$v) {
    if ($v) { return "[保護中  OK]" } else { return "[未設定  !!]" }
}
#endregion

#region --- 適用/解除 関数 ---

# -- SMB/管理共有 --
function Enable-SmbHardening {
    $reg = 'HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters'
    Set-ItemProperty $reg -Name AutoShareWks -Value 0 -Type DWord
    foreach ($n in @('C$','D$','E$','F$','ADMIN$')) {
        if (Get-SmbShare -Name $n -EA SilentlyContinue) {
            Remove-SmbShare -Name $n -Force
            Write-Host ("    {0} 共有削除" -f $n)
        }
    }
    if (-not (Get-NetFirewallRule -DisplayName 'Block-SMB-Inbound-445' -EA SilentlyContinue)) {
        New-NetFirewallRule -DisplayName 'Block-SMB-Inbound-445' `
            -Direction Inbound -Protocol TCP -LocalPort 445 -Action Block -Profile Any | Out-Null
    }
    Write-Host "    SMB/管理共有ブロック 完了" -ForegroundColor Green
}

function Disable-SmbHardening {
    $reg = 'HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters'
    Remove-ItemProperty $reg -Name AutoShareWks -EA SilentlyContinue
    Remove-NetFirewallRule -DisplayName 'Block-SMB-Inbound-445' -EA SilentlyContinue
    Write-Host "    SMB/管理共有 解除完了（C$は次回起動時に復元）" -ForegroundColor Magenta
}

# -- コントロールドフォルダーアクセス --
function Enable-Cfa {
    Set-MpPreference -EnableControlledFolderAccess Enabled
    Write-Host "    コントロールドフォルダーアクセス 有効化完了" -ForegroundColor Green
}

function Disable-Cfa {
    Set-MpPreference -EnableControlledFolderAccess Disabled
    Write-Host "    コントロールドフォルダーアクセス 無効化完了" -ForegroundColor Magenta
}

# -- RDP --
function Disable-Rdp {
    $path = 'HKLM:\System\CurrentControlSet\Control\Terminal Server'
    Set-ItemProperty $path -Name fDenyTSConnections -Value 1 -Type DWord
    Disable-NetFirewallRule -DisplayGroup 'Remote Desktop' -EA SilentlyContinue
    Write-Host "    RDP 無効化完了" -ForegroundColor Green
}

function Enable-Rdp {
    $path = 'HKLM:\System\CurrentControlSet\Control\Terminal Server'
    Set-ItemProperty $path -Name fDenyTSConnections -Value 0 -Type DWord
    Enable-NetFirewallRule -DisplayGroup 'Remote Desktop' -EA SilentlyContinue
    Write-Host "    RDP 有効化完了" -ForegroundColor Magenta
}

# -- USB AutoRun --
function Disable-AutoRun {
    $path = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer'
    if (-not (Test-Path $path)) { New-Item $path -Force | Out-Null }
    Set-ItemProperty $path -Name NoDriveTypeAutoRun -Value 0xFF -Type DWord
    Write-Host "    USB AutoRun 無効化完了" -ForegroundColor Green
}

function Enable-AutoRun {
    $path = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer'
    Remove-ItemProperty $path -Name NoDriveTypeAutoRun -EA SilentlyContinue
    Write-Host "    USB AutoRun 解除完了" -ForegroundColor Magenta
}

# -- UAC --
function Set-UacMax {
    $path = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
    Set-ItemProperty $path -Name ConsentPromptBehaviorAdmin -Value 2 -Type DWord
    Set-ItemProperty $path -Name PromptOnSecureDesktop      -Value 1 -Type DWord
    Write-Host "    UAC 最大レベル設定完了" -ForegroundColor Green
}

function Reset-Uac {
    $path = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
    Set-ItemProperty $path -Name ConsentPromptBehaviorAdmin -Value 5 -Type DWord
    Set-ItemProperty $path -Name PromptOnSecureDesktop      -Value 1 -Type DWord
    Write-Host "    UAC 標準レベルに戻しました" -ForegroundColor Magenta
}
#endregion

#region --- メニュー画面 ---

# 診断画面
function Show-Diagnosis {
    Write-Header
    $s = Get-AllStatus
    $score = ($s.Values | Where-Object { $_ }).Count
    Write-Host "  ■ 現在のセキュリティ診断結果" -ForegroundColor Yellow
    Write-Sep
    Write-Host "  状態            No  内容" -ForegroundColor DarkGray
    Write-Sep
    $cfaSt    = if ($s.cfa) { '[保護中  OK]' } else { '[未設定  !!]' }
    $cfaColor = if ($s.cfa) { 'Green' }        else { 'Red' }
    Write-Host '  ' -NoNewline
    Write-Host $cfaSt -NoNewline -ForegroundColor $cfaColor
    Write-Host '  [1] CFA 暗号化ブロック  ' -NoNewline
    Write-Host '<<核心防御>>' -ForegroundColor Magenta
    Write-SmbStatus
    Write-StatusRow $s.rdp     '[3]' 'RDP 無効化'
    Write-StatusRow $s.autorun '[4]' 'USB AutoRun 無効化'
    Write-StatusRow $s.uac     '[5]' 'UAC 最大レベル'
    Write-Sep
    $color = if ($score -ge 4) { 'Green' } elseif ($score -ge 2) { 'Yellow' } else { 'Red' }
    Write-Host ("  防衛スコア: {0}/5  " -f $score) -NoNewline
    $label = switch ($score) {
        5 { "[完全防衛]" } 4 { "[ほぼ安全]" } 3 { "[要改善  ]" } default { "[危険    ]" }
    }
    Write-Host $label -ForegroundColor $color
    Write-Host ""
    Pause-Any
}

# 一括適用
function Invoke-ApplyAll {
    Write-Header
    Write-Host "  ■ 全防衛設定を適用します" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  【注意事項】" -ForegroundColor Red
    Write-Host "  ・コントロールドフォルダー有効時、一部アプリが保護フォルダへ"
    Write-Host "    書き込めなくなる場合があります（Windows Defender設定から許可可能）"
    Write-Host "  ・RDP無効化後はリモートデスクトップ接続ができなくなります"
    Write-Host "  ・SMB設定は次回PC起動後に完全反映されます"
    Write-Host "  ・本ツール使用による損害について作者は責任を負いません"
    Write-Host ""
    $c = Read-Host "  続行しますか？ (Y/N)"
    if ($c.ToUpper() -ne 'Y') { return }
    Write-Host ""
    Enable-SmbHardening
    Enable-Cfa
    Disable-Rdp
    Disable-AutoRun
    Set-UacMax
    Write-Host ""
    Write-Host "  >> 全防衛設定の適用が完了しました。" -ForegroundColor Green
    Pause-Any
}

# 一括解除
function Invoke-UndoAll {
    Write-Header
    Write-Host "  ■ 全防衛設定を解除します" -ForegroundColor Magenta
    Write-Host ""
    Write-Host "  【警告】解除するとPCがランサムウェアの攻撃を受けやすくなります。" -ForegroundColor Red
    Write-Host "  本当に解除してよい場合のみ続行してください。"
    Write-Host ""
    $c = Read-Host "  解除を続行しますか？ (Y/N)"
    if ($c.ToUpper() -ne 'Y') { return }
    Write-Host ""
    Disable-SmbHardening
    Disable-Cfa
    Enable-Rdp
    Enable-AutoRun
    Reset-Uac
    Write-Host ""
    Write-Host "  設定解除が完了しました。" -ForegroundColor Magenta
    Pause-Any
}

# 個別設定メニュー
function Show-IndividualMenu {
    while ($true) {
        Write-Header
        $s = Get-AllStatus
        Write-Host "  ■ 個別設定" -ForegroundColor Yellow
        Write-Sep
        Write-Host "  状態            No  内容" -ForegroundColor DarkGray
        Write-Sep
        $cfaSt2    = if ($s.cfa) { '[保護中  OK]' } else { '[未設定  !!]' }
        $cfaColor2 = if ($s.cfa) { 'Green' }        else { 'Red' }
        Write-Host '  ' -NoNewline
        Write-Host $cfaSt2 -NoNewline -ForegroundColor $cfaColor2
        Write-Host '  [1] CFA 暗号化ブロック  ' -NoNewline
        Write-Host '<<核心防御>>' -ForegroundColor Magenta
        Write-SmbStatus
        Write-StatusRow $s.rdp     '[3]' 'RDP 無効化'
        Write-StatusRow $s.autorun '[4]' 'USB AutoRun 無効化'
        Write-StatusRow $s.uac     '[5]' 'UAC 最大レベル'
        Write-Sep
        Write-Host "  [B] 戻る"
        Write-Host ""
        $c = Read-Host "  番号を選択"
        switch ($c.ToUpper()) {
            '1' {
                if ($s.cfa) { Disable-Cfa } else {
                    Write-Host "  【注意】一部アプリが保護フォルダーに書き込めなくなる場合があります。" -ForegroundColor Yellow
                    Enable-Cfa
                }
                Pause-Any
            }
            '2' {
                if ($s.smb) { Disable-SmbHardening } else { Enable-SmbHardening }
                Pause-Any
            }
            '3' {
                if ($s.rdp) { Enable-Rdp } else {
                    Write-Host "  【注意】無効化後はリモートデスクトップ接続ができなくなります。" -ForegroundColor Yellow
                    Disable-Rdp
                }
                Pause-Any
            }
            '4' {
                if ($s.autorun) { Enable-AutoRun } else { Disable-AutoRun }
                Pause-Any
            }
            '5' {
                if ($s.uac) { Reset-Uac } else { Set-UacMax }
                Pause-Any
            }
            'B' { return }
        }
    }
}

# メインメニュー
function Show-MainMenu {
    while ($true) {
        Write-Header
        $s = Get-AllStatus
        $score = ($s.Values | Where-Object { $_ }).Count
        $scoreColor = if ($score -ge 4) { 'Green' } elseif ($score -ge 2) { 'Yellow' } else { 'Red' }
        Write-Host ("  防衛スコア: {0}/5" -f $score) -ForegroundColor $scoreColor
        Write-Host ""
        Write-Host "  [1] 診断           - セキュリティ状態を確認" -ForegroundColor White
        Write-Host "  [2] 全防衛設定を適用 - ランサムウェア対策を一括有効化" -ForegroundColor Green
        Write-Host "  [3] 全設定を解除   - 設定を元に戻す" -ForegroundColor Magenta
        Write-Host "  [4] 個別設定       - 機能を個別にON/OFF" -ForegroundColor White
        Write-Sep
        Write-Host "  [Q] 終了" -ForegroundColor DarkGray
        Write-Host ""
        $c = Read-Host "  選択 (1/2/3/4/Q)"
        switch ($c.ToUpper()) {
            '1' { Show-Diagnosis }
            '2' { Invoke-ApplyAll }
            '3' { Invoke-UndoAll }
            '4' { Show-IndividualMenu }
            'Q' {
                Write-Host ""
                Write-Host "  終了します。" -ForegroundColor DarkGray
                exit
            }
        }
    }
}
#endregion

# --- エントリポイント ---
Show-MainMenu
