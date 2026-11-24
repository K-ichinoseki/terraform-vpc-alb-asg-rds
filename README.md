# terraform-vpc-alb-asg-rds

Terraform で AWS 上に **VPC + ALB + Auto Scaling Group + RDS** の Web 3 層構成を構築する学習用リポジトリです。
完成形のコードを写すのではなく、要件（Todo リスト）から自分で書き、モジュールごとに `terraform plan` で確認しながら進めています。

> 🚧 **作業中**：現在 `network` と `alb` モジュールまで実装済みです。

## 構成図（完成予定）

```
                Internet
                    │
             ┌──────┴──────┐
             │     IGW     │
             └──────┬──────┘
┌─ VPC 10.0.0.0/16 ─┼──────────────────────────────────────┐
│                   │                                      │
│   ┌── Public 1a ──┴───────┐     ┌── Public 1c ─────────┐ │
│   │ 10.0.1.0/24           │     │ 10.0.2.0/24          │ │
│   │   ALB ────────────────┼─────┼── ALB                │ │
│   │   EC2 (ASG)           │     │   EC2 (ASG)          │ │
│   └───────────┬───────────┘     └──────────┬───────────┘ │
│               │       3306                 │             │
│   ┌── Private 1a ─────────┐     ┌── Private 1c ────────┐ │
│   │ 10.0.10.0/24          │     │ 10.0.20.0/24         │ │
│   │   RDS (MySQL 8.0)     │     │                      │ │
│   └───────────────────────┘     └──────────────────────┘ │
└──────────────────────────────────────────────────────────┘
```

## 進捗

| モジュール | 内容 | 状態 |
|---|---|---|
| `network` | VPC、IGW、パブリック／プライベートサブネット ×2、ルートテーブル | ✅ 完了 |
| `alb` | ALB、セキュリティグループ、ターゲットグループ（`/health.html`）、HTTP リスナー | ✅ 完了 |
| `compute` | Web 用 SG、SSM 用 IAM ロール、起動テンプレート（AL2023 + nginx）、ASG | ⬜ 未着手 |
| `rds` | RDS 用 SG、DB サブネットグループ、RDS for MySQL 8.0 | ⬜ 未着手 |

## ディレクトリ構成

```
.
├── envs/
│   └── dev/                    # 環境ごとのルートモジュール（ここで terraform を実行）
│       ├── backend.tf.example  # S3 backend 設定のテンプレート
│       ├── main.tf             # 各モジュールの呼び出しと、モジュール間の値の受け渡し
│       ├── variables.tf
│       ├── terraform.tfvars    # CIDR・サブネット定義などの環境固有値
│       └── versions.tf
└── modules/
    ├── network/
    └── alb/
```

各モジュールは `variables.tf`（入力）／ `main.tf`（リソース）／ `outputs.tf`（出力）の 3 ファイル構成です。
モジュール同士は直接参照せず、`envs/dev/main.tf` で `module.network.public_subnet_ids` のように output を別モジュールの入力へ渡しています。

## 設計で意識したこと

- **環境ごとのディレクトリ**：`envs/dev` に `cd` して実行する構成にし、`-var-file` の指定なしで `terraform.tfvars` が読み込まれるようにしています。
- **繰り返しは `for_each`**：同じ種類で値だけが違うリソース（サブネット、ルートテーブルの関連付け）は `for_each` で作成しています。キーが `public-1a` のように意味のある名前になるため、`count` と違い、要素を増減しても他のリソースに影響しません。
- **型付きの変数**：サブネット定義は `map(object({ name, cidr, az }))` で型を付け、tfvars の書き間違いを入口で検出します。
- **ID のリストは for 式で変換**：`for_each` で作ったリソース（map）を `[for s in aws_subnet.public : s.id]` で ID のリストにして output しています。
- **SG ルールは分割版**：`aws_vpc_security_group_ingress_rule` / `egress_rule` を使い、SG 本体とルールを別リソースにしています。

## 使い方

前提：Terraform `>= 1.10`、AWS 認証情報、state 保存用の S3 バケット

```bash
cd envs/dev
cp backend.tf.example backend.tf   # bucket を自分の S3 バケット名に書き換える
terraform init
terraform plan
terraform apply
```

後片付け：

```bash
terraform destroy
```

> ⚠️ ALB・EC2・RDS は起動している間、料金が発生します。確認が終わったら `destroy` してください。

## 使用技術

- Terraform `>= 1.10`（S3 ネイティブの state ロック `use_lockfile` を使用）
- AWS Provider `>= 6.6.0`
- リージョン：`ap-northeast-1`（東京）

## 参考

- [Terraform で VPC, EC2, RDS を構築してみた（Qiita）](https://qiita.com/y_inoue15/items/c2db7f6c9288fafcf6fa)
  — 構成の参考にしています。本リポジトリでは EC2 の代わりに ASG を使うなど、構成を一部変えています。
