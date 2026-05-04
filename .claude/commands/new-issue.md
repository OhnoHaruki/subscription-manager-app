# GitHub Issue 作成

このスキルは、Subscription Manager App プロジェクトの GitHub Issue を作成します。

## 手順

1. ユーザーから Issue の内容（タイトル・概要）を受け取る
2. 以下のテンプレートに沿って Issue の本文を構成する
3. `gh issue create` コマンドで Issue を作成する
4. 作成された Issue の番号を取得し、`feature/#<番号>` ブランチを作成して checkout する

## Issue テンプレート

```markdown
## 概要

<!-- 何を実装・修正・調査するかを簡潔に記述 -->

## 背景・目的

<!-- なぜこの Issue が必要か -->

## 実装方針（任意）

<!-- 実装アプローチのメモ（未定の場合は省略可） -->

## 完了条件

- [ ] 
```

## ラベル候補

- `feature` : 新機能の追加
- `bug` : バグ修正
- `enhancement` : 既存機能の改善
- `docs` : ドキュメント
- `chore` : 設定・環境整備

## 実行例

```bash
gh issue create \
  --title "タイトル" \
  --body "$(cat <<'EOF'
## 概要
...
EOF
)" \
  --label "feature"
```

ユーザーが Issue の内容を伝えたら、テンプレートを埋めて `gh issue create` を実行してください。
ラベルやマイルストーンが不明な場合は省略して構いません。

Issue 作成後は、返却された URL から issue 番号を取得し、以下のコマンドでブランチを作成して checkout してください。

```bash
git checkout -b feature/#<issue番号>
```
