#!/usr/bin/env sh

APP=${@:-/bin/bash}

IMAGE="registry.gitlab.com/hdlteam/candidate-test"
DOCKER_BASHRC=/tmp/.docker_${USER}_bashrc

rm -rf ${DOCKER_BASHRC} 2>/dev/null
cp ${HOME}/.bashrc ${DOCKER_BASHRC} 2>/dev/null
echo "PS1=\"(docker) \$PS1\"" >> ${DOCKER_BASHRC}

docker run \
    -v ${HOME}:${HOME} \
    -v /etc/passwd:/etc/passwd:ro \
    -v /etc/shadow:/etc/shadow:ro \
    -v /etc/group:/etc/group:ro \
    -v /tmp:/tmp \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v ${DOCKER_BASHRC}:${HOME}/.bashrc \
    -v /var/run/dbus:/var/run/dbus \
    -v /usr/share/git/completion:/usr/share/git/completion \
    -h $(hostname) \
    -e DISPLAY=$DISPLAY \
    --privileged \
    -i -w $PWD -t -u $(id -u):$(id -g) --rm \
    --group-add=plugdev \
    --group-add=sudo \
    $IMAGE \
    $APP

