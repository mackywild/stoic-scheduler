# GitHub ActionsでAPKを自動生成する手順

この版は、PCにFlutterやAndroid Studioを入れなくても、
GitHub Actions上でAndroid APKを生成できます。

## 初回だけやること

### 1. GitHubで新しいリポジトリを作成

例:

`stoic-scheduler`

PrivateでもPublicでも構いません。

### 2. このフォルダの中身をすべてアップロード

GitHubのWeb画面から、

`Add file` → `Upload files`

を選び、このプロジェクト内のファイルをアップロードします。

重要:
`.github/workflows/android-apk.yml`
も必ずアップロードしてください。

### 3. mainブランチへCommit

Commitすると自動でGitHub Actionsが開始します。

### 4. Actionsを開く

GitHubリポジトリ上部:

`Actions`
→ `Build Android APK`
→ 最新の実行

緑色のチェックになれば成功です。

### 5. APKをダウンロード

実行結果画面の下部にある:

`Artifacts`
→ `stoic-scheduler-android`

をタップするとZIPがダウンロードされます。

ZIP内:

`stoic-scheduler.apk`

がAndroid用インストールファイルです。

### 6. Androidへインストール

AndroidスマホでAPKを開きます。

初回はブラウザまたはファイルアプリに対して
「不明なアプリのインストールを許可」
を求められる場合があります。

自分で作成したAPKであることを確認した上で許可してください。

その後:

`インストール`

で完了です。

---

## 2回目以降

ソースコードをGitHubへ更新するだけです。

```text
ソース変更
   ↓
GitHubへアップロード / push
   ↓
GitHub Actions
   ↓
自動テスト
   ↓
APK生成
   ↓
ArtifactsからスマホへDL
```

## 手動ビルド

Actions
→ Build Android APK
→ Run workflow

から手動でもAPK生成できます。

## 現在のビルド形式

MVP検証用なので debug APK を生成します。

`flutter build apk --debug`

友人への正式配布フェーズでは、
署名付きrelease APKまたはGoogle Play向けAABへ変更します。
