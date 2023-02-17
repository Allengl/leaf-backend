# 注意修改 oh-my-env 目录名为你的目录名
dir=oh-my-env
time=$(date +'%Y%m%d-%H%M%S')
dist=tmp/leaf-$time.tar.gz
current_dir=$(dirname $0)
deploy_dir=/workspaces/$dir/leaf_deploy
gemfile=$current_dir/../Gemfile
gemfile_lock=$current_dir/../Gemfile.lock
vendor_dir=$current_dir/../vendor
vendor_1=rspec_api_documentation
api_dir=$current_dir/../doc/api
frontend_dir=$cache_dir/frontend

function title {
  echo 
  echo "###############################################################################"
  echo "## $1"
  echo "###############################################################################" 
  echo 
}

yes | rm tmp/leaf-*.tar.gz; 
yes | rm $deploy_dir/leaf-*.tar.gz; 


title '运行测试用例'
rspec || exit 1
title '重新生成文档'
bin/rails docs:generate || exit 2
title '打包源代码'
tar --exclude="tmp/cache/*" --exclude="tmp/deploy_cache/*" --exclude="vendor/*" -cz -f $dist *
title "打包本地依赖 ${vendor_1}"
bundle cache --quiet
tar -cz -f "$vendor_dir/cache.tar.gz" -C ./vendor cache
tar -cz -f "$vendor_dir/$vendor_1.tar.gz" -C ./vendor $vendor_1
title '打包前端代码'
mkdir -p $frontend_dir
rm -rf $frontend_dir/repo
git clone git@github.com:Allengl/leaf-fe.git $frontend_dir/repo
cd $frontend_dir/repo && pnpm install && pnpm run build; cd -
tar -cz -f "$frontend_dir/dist.tar.gz" -C "$frontend_dir/repo/dist" .
title '创建远程目录'
mkdir -p $deploy_dir/vendor
title '上传源代码和依赖'
cp $dist $deploy_dir/
yes | rm $dist
cp $gemfile $deploy_dir/
cp $gemfile_lock $deploy_dir/
cp $vendor_dir/cache.tar.gz $deploy_dir/vendor/
yes | rm $vendor_dir/cache.tar.gz
cp $vendor_dir/$vendor_1.tar.gz $deploy_dir/vendor/
yes | rm $vendor_dir/$vendor_1.tar.gz
title '上传前端代码'
scp "$frontend_dir/dist.tar.gz" $deploy_dir/
yes | rm -rf $frontend_dir
title '上传 Dockerfile'
cp $current_dir/../config/host.Dockerfile $deploy_dir/Dockerfile
scp $current_dir/../config/nginx.default.conf $deploy_dir/
title '上传 setup 脚本'
cp $current_dir/setup_host.sh $deploy_dir/
title '上传版本号'
echo $time > $deploy_dir/version
echo 'DONE!'
