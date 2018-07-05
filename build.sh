TAGS="7.2.7 latest"
DOCKER_REPO="sirboops/php"

BUILD_TAGS=""

# Gen build tags
for t in $TAGS;
do
    BUILD_TAGS="`echo $BUILD_TAGS` `echo -t $DOCKER_REPO:$t`"
done


# Build the image
docker build $BUILD_TAGS . --squash


# Upload the images
for t in $TAGS;
do
    docker push `echo $DOCKER_REPO:$t`
done
