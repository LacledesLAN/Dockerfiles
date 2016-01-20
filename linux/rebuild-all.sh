echo "Destroying all LL docker containers"
docker rm -f $(docker ps -a -q)   #todo: add filter for ll/*

echo "Destroying all LL docker images"
docker rmi $(docker images -q)   #todo: add filter for ll/*

docker build -t ll/gamesvr ./gamesvr 

echo "done"
