DB_PASSWORD=123456
container_name=leaf-prod

version=$(cat leaf_deploy/version)

echo 'docker build ...'
docker build leaf_deploy -t leaf:$version
if [ "$(docker ps -aq -f name=^mangosteen-prod-1$)" ]; then
  echo 'docker rm ...'
  docker rm -f $container_name
fi
echo 'docker run ...'
docker run -d -p 3000:3000 --network=network1 -e DB_PASSWORD=$DB_PASSWORD --name=$container_name leaf:$version
echo 'docker exec ...'
docker exec -it $container_name bin/rails db:create db:migrate
echo 'DONE!'
