# TestFlight 上架配置指南

## 前置条件

- Apple Developer Program 会员资格 ($99/年)
- App Store Connect 中有该 App 的记录（可首次上传时自动创建）
- `probe_web_ios` 仓库代码已推送到 GitHub

---

## 一、Apple Developer 后台操作

### 1.1 创建 App ID

1. 打开 [Apple Developer](https://developer.apple.com) → Certificates, Identifiers & Profiles
2. Identifiers → 点击 "+" → App IDs
3. Type: **App**
4. Description: `Probe Tool`
5. Bundle ID: `com.xiaofei.probetool` (Explicit)
6. 勾选需要的 Capabilities（默认无需勾选）
7. 保存

### 1.2 创建分发证书 (Distribution Certificate)

1. Certificates → 点击 "+" → Software
2. 选择 **Apple Distribution** (App Store and TestFlight)
3. 按提示生成 CSR 文件：

```bash
openssl genrsa -out distribution.key 2048
openssl req -new -key distribution.key -out distribution.csr -subj "/emailAddress=your@email.com/CN=Probe Tool Distribution"
```

4. 上传 CSR，下载生成的 `.cer` 文件
5. 转换为 `.p12` 格式：

```bash
openssl x509 -in distribution.cer -inform DER -out distribution.pem
openssl pkcs12 -export -out distribution.p12 -inkey distribution.key -in distribution.pem
```

6. 记下设置的密码（后面用作 `APPLE_DISTRIBUTION_CERTIFICATE_PASSWORD`）

### 1.3 创建描述文件 (Provisioning Profile)

1. Profiles → 点击 "+" → Distribution
2. 选择 **App Store Connect** → Continue
3. 选择上面创建的 App ID (`com.xiaofei.probetool`)
4. 选择上面创建的分发证书
5. 命名：`ProbeTool AppStore`
6. 下载 .mobileprovision 文件，**记住这个文件名**

### 1.4 创建 App Store Connect API 密钥

1. 打开 [App Store Connect](https://appstoreconnect.apple.com)
2. 用户和访问 → 集成 → 密钥 → 点击 "+"
3. 名称：`CI Upload`
4. 访问权限：**App Manager**
5. 下载 `.p8` 文件，**记下 Key ID** 和 **Issuer ID**

---

## 二、GitHub Secrets 配置

在 `probe_web_ios` 仓库 → Settings → Secrets and variables → Actions → New repository secret：

| Secret 名称 | 值 | 来源 |
|------------|-----|------|
| `PRIVATE_REPO_ACCESS_TOKEN` | GitHub PAT（已有） | probe_web 仓库访问 |
| `APPLE_DISTRIBUTION_CERTIFICATE_BASE64` | `base64 -i distribution.p12` | 1.2 的 .p12 文件 |
| `APPLE_DISTRIBUTION_CERTIFICATE_PASSWORD` | .p12 文件的密码 | 1.2 导出时设置的 |
| `APPLE_PROVISIONING_PROFILE_BASE64` | `base64 -i ProbeTool_AppStore.mobileprovision` | 1.3 下载的文件 |
| `PROVISIONING_PROFILE_NAME` | `ProbeTool AppStore` | 1.3 创建时的名称 |
| `APPSTORE_CONNECT_API_KEY_BASE64` | `base64 -i AuthKey_XXXXXX.p8` | 1.4 下载的 .p8 |
| `APPSTORE_CONNECT_API_KEY_ID` | Key ID (如 `ABC123XYZ`) | 1.4 |
| `APPSTORE_CONNECT_API_KEY_ISSUER_ID` | UUID (如 `xxxxxxxx-xxxx-...`) | 1.4 |

---

## 三、首次构建 & 上架

### 3.1 运行 GitHub Actions

1. GitHub → probe_web_ios → Actions → Build iOS App → Run workflow
2. 等待 15-20 分钟（编译 Go + Swift + 上传）
3. 查看日志中的 "TestFlight public link" 步骤获取链接格式

### 3.2 配置 TestFlight

上传成功后：

1. 打开 [App Store Connect](https://appstoreconnect.apple.com)
2. My Apps → Probe Tool → TestFlight
3. 等待状态变为 "Ready to Test"（通常 30 分钟）

#### 内部测试（快速，无需审核）

- TestFlight → Internal Testing → 添加测试员
- 输入测试员的 Apple ID 邮箱
- 他们会在 iPhone 上收到 TestFlight 邀请

#### 外部测试（需要 Beta 审核）

- TestFlight → External Testing → 创建外部测试组
- 首次需要提交 Beta App Review（通常 1-2 天审核）
- 审核通过后可启用 Public Link
- Public Link 格式：`https://testflight.apple.com/join/<自动生成的随机码>`

### 3.3 后续更新

每次推送新代码后运行 GitHub Actions，新版本会自动出现在 TestFlight 中，已安装的测试员会自动收到更新通知。

---

## 四、常见问题

| 问题 | 解决 |
|------|------|
| 证书过期 | Apple Distribution 证书有效期 1 年，需重新生成并更新 Secret |
| 描述文件过期 | 证书过期会连带使描述文件失效 |
| Provisioning profile 不匹配 | 检查 PROVISIONING_PROFILE_NAME 是否与 1.3 创建的一致 |
| API 密钥无权限 | 在 App Store Connect → 用户和访问中检查 API 密钥权限是否为 App Manager |
| IPA 上传大小超限 | Go framework + Swift 通常不会超，如有问题检查是否包含了不必要的资源 |
