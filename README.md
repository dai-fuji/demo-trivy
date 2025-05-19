# Terraform セキュリティスキャンのデモ

このリポジトリは、GitHubActions と Trivy を使用して Terraform コードの脆弱性スキャンを行うデモプロジェクトです。

## プロジェクト構成

- `main.tf` - AWS リソースを定義する Terraform ファイル（意図的に脆弱性を含む）
- `.github/workflows/terraform-scan.yml` - GitHubActions のワークフローファイル

## 含まれる脆弱性

このデモプロジェクトには、以下のような意図的な脆弱性が含まれています：

1. セキュリティグループで全ポートを開放（0.0.0.0/0）
2. EC2 インスタンスにパブリック IP を割り当て
3. 弱いパスワードを使用したルートユーザーの設定
4. S3 バケットの公開アクセス設定
5. 過度に寛容な IAM ポリシー（管理者権限）

## Trivy による脆弱性スキャン

このプロジェクトでは、GitHubActions を使用して Terraform ファイルの脆弱性スキャンを自動化しています。

### スキャンの実行方法

1. コードを GitHub リポジトリにプッシュする
2. GitHubActions が自動的に Trivy を使用してスキャンを実行
3. 重大な脆弱性が検出された場合、ワークフローは失敗します

### ローカルでのスキャン実行

Trivy をローカルにインストールして実行することもできます：

```bash
# Trivyのインストール
brew install aquasecurity/trivy/trivy

# Terraformファイルのスキャン
trivy config --severity HIGH,CRITICAL .
```

## セキュリティのベストプラクティス

実際の環境では、以下のベストプラクティスを適用することをお勧めします：

1. 最小権限の原則に従う
2. パブリックアクセスを制限する
3. 強力な認証情報を使用する
4. 暗号化を適切に設定する
5. セキュリティグループのルールを制限する

## 注意事項

このコードは教育目的のみで提供されています。実際の環境にデプロイしないでください。

![image](https://github.com/user-attachments/assets/463c33fb-2b33-4af4-bccf-d72d6d337c67)

