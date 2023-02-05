# README

## 开发配置

### 数据库创建
```
docker run -d      --name db-for-leaf      -e POSTGRES_USER=leaf      -e POSTGRES_PASSWORD=123456      -e POSTGRES_DB=leaf_dev      -e PGDATA=/var/lib/postgresql/data/pgdata      -v leaf-data:/var/lib/postgresql/data      --network=network1      postgres:14

```
