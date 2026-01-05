---
description: アプリを別のMacで動かすための配布用ビルド手順
---

別のMacにアプリを配布するには、以下の手順で「.app」ファイルを作成して送ります。

### 1. 配布用のビルドを作成する (Xcode GUI)
1. Xcodeの画面上部で、ビルドターゲット（マイマック等）の左隣にあるデバイス選択から **"Any Mac (Apple Silicon, Intel)"** を選択します。
2. メニューの **Product > Archive** をクリックします。
3. ビルドが完了すると "Organizer" ウィンドウが開きます。
4. **"Distribute App"** ボタンを押し、**"Copy App"**（または "Custom" -> "Copy App"）を選択して進めます。
5. 作成されたフォルダ内にある `WakaType.app` を右クリックして **「"WakaType.app" を圧縮」** し、`.zip` ファイルを作ります。

### 2. 別のMacに送る
1. 作成した `WakaType.zip` を AirDrop、メール、Slack、USBメモリ等で別のMacに送ります。

### 3. 受け取ったMacで開く（Gatekeeperの回避）
Appleの承認（公証）を受けていない自作アプリの場合、ダブルクリックしただけでは「開発元が未確認のため開けません」という警告が出ます。

1. `WakaType.zip` を展開します。
2. `WakaType.app` を **右クリック（または Control + クリック）して「開く」** を選択します。
3. 確認ダイアログが出るので、そこで **「開く」** を押すと実行できます。
   - ※一度この手順で行えば、次からはダブルクリックで開けるようになります。

### (参考) コマンドラインでビルドする場合
ターミナルで実行して `.app` を取り出すことも可能です。

```zsh
# Release構成でビルド
xcodebuild -project WakaType.xcodeproj -scheme WakaType -configuration Release -derivedDataPath ./build_output

# ビルドされた .app の場所を確認（通常は以下のパスに生成されます）
# ./build_output/Build/Products/Release/WakaType.app
```
