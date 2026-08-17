# STOIC SCHEDULER

「空いた時間に何をするか考える」のではなく、アプリ側が **今やるべき行動を1つ指示する** Flutter製MVPです。

## MVPでできること

- 読書・勉強・ゲーム・筋トレなどの行動を登録
- 現在の状況を「通勤 / 食後 / 自宅 / 外出」から指定
- 空き時間を指定
- 行動ごとの優先度、必要時間、利用可能な状況を考慮
- 今日の実施量と過去の実行成功率を考慮して「TODAY'S ORDER」を1件選定
- START → COMPLETE / SKIP を記録
- SKIP理由を記録
- 履歴から「時間帯 × 状況 × 行動」の成功率を学習し、次回推薦へ反映
- STOIC SCORE、達成率、連続達成日数を表示
- データは端末ローカル保存

## アーキテクチャ

```text
Flutter UI
  ├─ Home
  ├─ Activities
  ├─ History
  └─ Stats
        │
        ▼
RecommendationEngine
  ├─ Priority
  ├─ Remaining daily target
  ├─ Context match
  ├─ Available minutes
  └─ Learned success rate
        │
        ▼
LocalRepository
        │
        ▼
shared_preferences (JSON)
```

## 推薦スコア

概念上、以下を合成しています。

```text
score =
  priority * 20
  + targetRemainingRatio * 35
  + learnedSuccessRate * 25
  + contextFitBonus
  + timeFitBonus
  - completedTodayPenalty
```

学習データが少ない間は成功率を 0.5 とみなし、履歴が増えると
「朝の通勤中は勉強を完遂しやすい」
「帰宅直後の筋トレはSkipしやすい」
のような傾向を推薦へ反映します。

## 起動方法

### 1. Flutterをインストール

Flutter Stable をインストールしてください。

### 2. プロジェクト生成

このZIPには `android/` と `ios/` のネイティブ雛形を含めていません。
展開したディレクトリで次を実行すると生成できます。

```bash
flutter create . --platforms=android,ios
```

既存の `lib/` や `pubspec.yaml` を上書きするか確認された場合は、
この成果物側のファイルを残してください。

### 3. 依存関係取得

```bash
flutter pub get
```

### 4. 起動

```bash
flutter run
```

## テスト

```bash
flutter test
```

## 初期登録される行動

- 資格勉強
- 読書
- ゲーム
- 筋トレ

アプリ内の「行動」画面から追加・編集・削除できます。

## 次期開発案

### Phase 2
- Firebase Authentication
- Cloud Firestore同期
- 複数端末同期
- 友達ランキング
- Push通知
- バックグラウンド通知
- カレンダー連携

### Phase 3
- LLMによる自然言語コーチ
- 推薦理由生成
- 長期目標からの自動タスク分解
- 機械学習モデルによる推薦
- Apple Health / Google Health Connect連携

## 重要な設計方針

LLMに全判断を丸投げしません。
「何を推薦するか」は説明可能なRecommendationEngineで決定し、
将来LLMを使う場合も「伝え方・理由説明・タスク分解」を中心に担当させます。

これにより、API障害や費用増加があっても推薦機能そのものは継続できます。
