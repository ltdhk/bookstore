AWS S3配置步骤
1. 创建S3存储桶（Bucket）
登录AWS管理控制台
访问 https://console.aws.amazon.com/
登录你的AWS账户
进入S3服务
在搜索框中输入 "S3" 或在服务列表中找到 "S3"
点击进入S3控制台
创建新存储桶
点击 "Create bucket"（创建存储桶）
设置以下参数：
Bucket name: bookstore-images（或其他唯一名称，全球唯一）
AWS Region: 选择 ap-southeast-1（新加坡）或其他离你近的区域
Object Ownership: 选择 "ACLs enabled"
Block Public Access settings: 取消勾选 "Block all public access"（允许公开访问）
会弹出警告，勾选确认框
其他设置保持默认
点击 "Create bucket" 创建
2. 配置存储桶权限
设置存储桶策略（Bucket Policy）
点击刚创建的存储桶
进入 "Permissions"（权限）标签页
滚动到 "Bucket policy"，点击 "Edit"
添加以下策略（替换 bookstore-images 为你的桶名）：
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::bookstore-images/*"
        }
    ]
}
配置CORS（跨域资源共享）
在 "Permissions" 标签页中找到 "Cross-origin resource sharing (CORS)"
点击 "Edit"
添加以下CORS配置：
[
    {
        "AllowedHeaders": ["*"],
        "AllowedMethods": ["GET", "PUT", "POST", "DELETE"],
        "AllowedOrigins": ["*"],
        "ExposeHeaders": ["ETag"]
    }
]
3. 创建IAM用户和访问密钥
进入IAM服务
在AWS控制台搜索 "IAM"
点击进入IAM控制台
创建新用户
点击左侧菜单 "Users"（用户）
点击 "Create user"（创建用户）
用户名输入：bookstore-s3-uploader
点击 "Next"
设置权限
选择 "Attach policies directly"（直接附加策略）
搜索并勾选 AmazonS3FullAccess（完整S3访问权限）
或者创建自定义策略，只授予特定桶的权限（更安全）
点击 "Next"，然后 "Create user"
创建访问密钥
点击刚创建的用户
进入 "Security credentials"（安全凭证）标签页
滚动到 "Access keys"，点击 "Create access key"
选择用途：选择 "Application running outside AWS"
点击 "Next"，可选添加描述
点击 "Create access key"
重要：记录下 Access key 和 Secret access key
Access key 示例：AKIAIOSFODNN7EXAMPLE
Secret access key 示例：wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
这是唯一一次可以查看 Secret access key 的机会，请妥善保存
4. 更新application.yml配置
在 application.yml 中更新AWS配置：
aws:
  s3:
    access-key: AKIAIOSFODNN7EXAMPLE  # 替换为你的Access Key
    secret-key: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY  # 替换为你的Secret Key
    region: ap-southeast-1  # 替换为你选择的区域
    bucket-name: bookstore-images  # 替换为你的桶名称
5. 安全建议（可选但推荐）
为了更安全，建议创建自定义IAM策略，仅授予特定桶的访问权限：
创建自定义策略
在IAM控制台，点击左侧 "Policies"（策略）
点击 "Create policy"
选择 JSON 编辑器，输入：
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:DeleteObject",
                "s3:PutObjectAcl"
            ],
            "Resource": "arn:aws:s3:::bookstore-images/*"
        },
        {
            "Effect": "Allow",
            "Action": "s3:ListBucket",
            "Resource": "arn:aws:s3:::bookstore-images"
        }
    ]
}
将策略附加到用户
策略名称：BookstoreS3UploadPolicy
创建后，在用户权限中移除 AmazonS3FullAccess
附加刚创建的 BookstoreS3UploadPolicy
6. 测试配置
重启后端服务
更新配置后，需要重启Spring Boot应用
测试上传
在Admin后台尝试上传一张书籍封面图片
如果成功，会返回类似这样的URL：
https://bookstore-images.s3.ap-southeast-1.amazonaws.com/covers/uuid.jpg
验证公开访问
将返回的URL粘贴到浏览器中
应该能直接看到上传的图片
常见问题
Q: 上传失败，提示权限错误
检查IAM用户是否有正确的S3权限
检查Access Key和Secret Key是否正确
检查桶策略是否允许公开读取
Q: 图片无法访问
检查桶的 "Block Public Access" 设置是否关闭
检查桶策略是否正确配置
检查对象的ACL是否设置为 public-read
Q: CORS错误
确保在S3桶的权限设置中正确配置了CORS策略
Q: 费用问题
S3存储费用：按存储量计费（前5GB免费/月，12个月免费套餐）
请求费用：PUT请求按次数计费（每月前2000次免费）
数据传输费用：向互联网传输数据按流量计费
配置完成后，你的图片上传功能就可以正常使用了！




访问密钥
YOUR_AWS_ACCESS_KEY（请替换为你自己的密钥）
秘密访问密钥
YOUR_AWS_SECRET_KEY（请替换为你自己的密钥）