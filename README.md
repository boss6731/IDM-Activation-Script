# IDM 啟動文稿

用於啟動和重置 [Internet Download Manager]（https://www.internetdownloadmanager.com/） 試用版的開源工具

## 特點

- 使用註冊表項鎖定方法進行IDM凍結試用和啟動
- 即使在安裝 IDM 更新後，啟動和試用仍然存在
- IDM 試用重置
- 完全開源
- 基於透明批處理文稿

## IAS 最新版本

最後發佈 - v1.2 （12-Feb-2024）\
[GitHub上]（https://github.com/WindowsAddict/IDM-Activation-Script） - [BitBucket]（https://bitbucket.org/WindowsAddict/idm-activation-script/）

## 下載 / 如何使用？

- 首次全新安裝 [Internet Download Manager]（https://www.internetdownloadmanager.com/）。確保刪除/卸載以前的裂縫/補丁（如果有）。
- 之後，請按照以下步驟啟動它。

## 注意事項
- 📌 啟用選項當前在腳本中不起作用，請使用「凍結試用」選項鎖定 30 天的試用期。

### 方法 1 - PowerShell

（推薦）

- 右鍵按下 Windows 開始功能表，然後選擇 PowerShell 或終端（非 CMD）。
- 複製粘貼以下代碼並按回車鍵\
    'irm https://massgrave.dev/ias |iex'
- 您將看到啟動選項，按照螢幕上的說明進行操作。
-就這樣。

### 方法 2 - 繁體

- 從 [GitHub]（https://github.com/WindowsAddict/IDM-Activation-Script/archive/refs/heads/main.zip） 或 [Bitbucket]（https://bitbucket.org/WindowsAddict/idm-activation-script/get/main.zip） 下載檔
- 右鍵按鍵按鍵的 zip 檔並解壓縮
- 在解壓的資料夾中，運行名為“IAS.cmd”的檔
- 您將看到啟動選項，並按照螢幕上的說明進行操作。
-就這樣。

## 資訊

#### 凍結試用
- IDM 提供 30 天的試用期，您可以在腳本中使用此選項將此試用期鎖定為終身，這樣您就不必再次重置試用期，並且您的試用期不會過期。
- 此方法在應用此選項時需要 Internet。
- IDM 更新可以直接安裝，無需再次凍結。

#### 啟動

（\*當前不工作）

- 此文稿應用註冊表鎖定方法來啟動 Internet 下載管理員 （IDM）。
- 此方法在啟動時需要 Internet。
- IDM 更新可以直接安裝，而無需再次啟動。
- 啟動後，如果在某些情況下，IDM 開始顯示啟動嘮叨螢幕，則只需再次運行激活選項，而無需使用重置選項。

#### 重置 IDM 啟動/試用

- Internet 下載管理器提供 30 天的試用期，您可以隨時使用此腳本重置此啟動/試用期。
- 如果 IDM 報告偽造序列號和其他類似錯誤，此選項也可用於恢復狀態。

#### 操作系統要求

- 該專案支援 Windows 7/8/8.1/10/11 及其 Server 等效版本。
- Windows 8 及更高版本支援運行 IAS 的 PowerShell 方法。

#### 高級資訊

- 要在無人值守模式下啟動，請運行帶有“/act”參數的腳本。
- 要在無人參與模式下凍結試用，請運行帶有“/frz”參數的腳本。
- 要在無人值守模式下重置，請運行帶有“/res”參數的腳本。

## 它是如何工作的？
- IDM 將與試用和啟動相關的數據存儲在各種註冊表項中。其中一些密鑰被鎖定以保護它們不被篡改，數據存儲在一種模式中，以跟蹤虛假的連續問題和剩餘的試用天數。要啟動它，此處的腳本只需通過在IDM中觸發一些下載來生成這些註冊表項，識別這些註冊表項，並鎖定它們，以便IDM無法編輯和查看它們。這樣一來，IDM 就無法顯示它是用假序列號啟動的警告。

## 故障排除

- 瀏覽器集成修復：[Chrome]（https://www.internetdownloadmanager.com/register/new_faq/bi9.html） - [Firefox]（https://www.internetdownloadmanager.com/register/new_faq/bi4.html）
- 在 [Github]（https://github.com/WindowsAddict/IDM-Activation-Script） 上提出問題並附上屏幕截圖。

## 更新紀錄

#### v1.2
- 添加了帶有隨機名稱、電子郵件和註冊詳細資訊的金鑰的重新啟動選項，並警告它不適用於某些使用者，推薦的選項是使用凍結試用版。

#### v1.1

- IDM 更新 6.42b3 已開始顯示帶有 IAS 啟動的虛假串行彈出視窗，因此我們刪除了啟動選項，並將其替換為凍結試用選項，以鎖定 30 天的試用期。
- 現在，該腳本將使用Powershell在 CMD 視窗中禁用快速編輯，而不是編輯註冊表，這要歸功於 @abbodi1406的代碼和@awuctl的想法。
- 由於@abbodi1406，用於重新啟動腳本的代碼現在合併到快速編輯禁用代碼中，conhost.exe以避免終端應用程式。

#### v1.0

- 添加了代碼，以重新啟動腳本，並conhost.exe腳本是否從終端應用程式運行。
- 修復了獲取當前用戶帳戶 SID 時出現的問題。

#### v0.9
- 修復了腳本無法在非管理員用戶帳戶中啟動和重置IDM的問題。
- 修復了文稿錯誤地顯示IDM已激活的問題。
- 修復了可能出現虛假串行彈出窗口的問題。該腳本還將顯示在不使用重置選項的情況下再次運行激活選項的資訊。
- 修復了以下問題：由於某些區域的 GitHub 阻止，用於啟動 IAS 的 Powershell 代碼可能無法正常工作。它將使用新的 [BitBucket]（https://bitbucket.org/WindowsAddict/idm-activation-script/） 存儲庫作為回退連結。
- IDM 註冊表掃描和鎖定代碼現在在 Powershell 中編寫。
- 文稿更新檢查器代碼添加到腳本中。
- 腳本現在將暫時禁用快速編輯模式，因為使用者經常在腳本視窗內按兩下並暫停腳本。
- 該腳本將在對 CLSISD 註冊表項執行操作之前備份它們。
- 添加了許多錯誤檢查，以更好地識別問題。

#### v0.8
- 將項目移動到 [Github]（https://github.com/WindowsAddict/IDM-Activation-Script） 和 [massgrave.dev]（https://massgrave.dev/idm-activation-script.html）
- 小錯誤修復
- 添加資訊以通知使用者，當腳本刪除大量空註冊表項時，將刪除空註冊表項

## 截圖

![]（https://massgrave.dev/images/IAS.png?raw=true）

![]（https://massgrave.dev/images/IAS_Freeze_Trial.png?raw=true）

## 致謝

|                                            |                                                                                                                                                                                                                                       |
|-------------------|-----------------------------------------------------|
|杜昆卡布爾 |這個IDM試驗重置和激活邏輯的原始研究人員，為這些方法製作了一個Autoit工具，[IDM-AIO_2020_Final]（https://nsaneforums.com/topic/371047-discussion-internet-download-manager-fixes/page/8/#comment-1632062） |
|AveYo 又名 BAU |[reg_own精益求精的片段]（https://pastebin.com/XTPt0JSC） |
|[阿博迪1406]（https://github.com/abbodi1406） |編碼説明 |
|Windows癮君子 |IAS 作者 |

感謝 IAS 使用者的關注、反饋和説明。

------------------------------------------------------------------------

用愛❤️製造
