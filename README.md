# README

## 开发配置

### 数据库创建
```
docker run -d      --name db-for-leaf      -e POSTGRES_USER=leaf      -e POSTGRES_PASSWORD=123456      -e POSTGRES_DB=leaf_dev      -e PGDATA=/var/lib/postgresql/data/pgdata      -v leaf-data:/var/lib/postgresql/data      --network=network1      postgres:14

```

### 创建密钥

```
rm config/credentials.yml.enc
EDITOR="code --wait" rails credentials:edit
```

在打开的文件中写下如下内容（其中 xxx 是密码或者随机字符串）：

```
secret_key_base: xxx
email_password: xxx
hmac_secret: xxx
```

然后提交代码。

### 启动应用

```
bin/rails s
或者
bundle exec rails s
```
