user=leaf
root=leaf_deploy 
version=$(cat $root/version)
container_name=leaf-prod
db_container_name=db-for-leaf
DB_HOST=$db_container_name
DB_PASSWORD=123456
nginx_container_name=leaf-nginx

function set_env {
  name=$1
  hint=$2
  [[ ! -z "${!name}" ]] && return
  while [ -z "${!name}" ]; do
    [[ ! -z "$hint" ]] && echo "> 请输入 $name: $hint" || echo "> 请输入 $name:" 
    read $name
  done
  sed -i "1s/^/export $name=${!name}\n/" ~/.bashrc
  echo "${name} 已保存至 ~/.bashrc"
}
function title {
  echo 
  echo "###############################################################################"
  echo "## $1"
  echo "###############################################################################" 
  echo 
}
title '设置远程机器的环境变量'
set_env DB_HOST
set_env DB_PASSWORD
set_env RAILS_MASTER_KEY '请将 config/credentials/production.key 的内容复制到这里'

title '创建数据库'
if [ "$(docker ps -aq -f name=^${DB_HOST}$)" ]; then
  echo '已存在数据库'
else
  docker run -d --name $DB_HOST \
            --network=network1 \
            -e POSTGRES_USER=leaf \
            -e POSTGRES_DB=leaf_production \
            -e POSTGRES_PASSWORD=$DB_PASSWORD \
            -e PGDATA=/var/lib/postgresql/data/pgdata \
            -v leaf-data:/var/lib/postgresql/data \
            postgres:14
  echo '创建成功'
fi
title 'docker build'
docker build $root -t leaf:$version
if [ "$(docker ps -aq -f name=^leaf-prod$)" ]; then
  title 'docker rm'
  docker rm -f $container_name
fi
title 'docker run'
docker run -d -p 3000:3000 \
           --network=network1 \
           --name=$container_name \
           -e DB_HOST=$DB_HOST \
           -e DB_PASSWORD=$DB_PASSWORD \
           -e RAILS_MASTER_KEY=$RAILS_MASTER_KEY \
           leaf:$version
if [[ ! -z "$need_migrate" ]]; then
  title '更新数据库'
  docker exec $container_name bin/rails db:create db:migrate
fi

if [ "$(docker ps -aq -f name=^${nginx_container_name}$)" ]; then
  title 'doc: docker rm'
  docker rm -f $nginx_container_name
fi
title 'doc: docker run'
cd leaf_deploy
rm -rf ./dist
mkdir ./dist
tar xf dist.tar.gz --directory=./dist
cd -
docker run -d -p 8080:80 \
           --network=network1 \
           --name=$nginx_container_name \
           -v /leaf_deploy/nginx.default.conf:/etc/nginx/conf.d/default.conf \
           -v /leaf_deploy/dist:/usr/share/nginx/html \
           -v /leaf_deploy/api:/usr/share/nginx/html/apidoc \
           nginx:latest

title '全部执行完毕'
