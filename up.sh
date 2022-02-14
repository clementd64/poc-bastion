#!/bin/sh

set -xe

genkey() {
    mkdir -p keys
    if [ ! -f "keys/$1_key" ]; then
        ssh-keygen -t ed25519 -f "keys/$1_key" -N ""
    fi
}

start_bastion() {
    genkey bastion
    docker rm -f bastion || true
    docker run --rm -d -p 2222:22 -v "$PWD"/bastion:/usr/bin/bastion -v "$PWD"/keys/bastion_key:/etc/ssh/ssh_host_ed25519_key:ro --name bastion bastion
}

add_host() {
    genkey "$1"
    docker rm -f "$1" || true
    docker run --rm -d -v "$PWD"/keys/"$1"_key:/etc/ssh/ssh_host_ed25519_key:ro --name "$1" --hostname "$1" bastion

    genkey "$1_user"

    docker exec -i bastion sh <<EOF
set -xe
adduser -D -s /usr/bin/bastion "$1"
passwd -u "$1"
mkdir -p /home/"$1"/.ssh
echo "$(cat keys/"$1"_user_key)" > /home/"$1"/.ssh/id_ed25519
chmod 600 /home/"$1"/.ssh/id_ed25519
echo "REMOTE_USER=app
HOST=$(docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$1")" > /home/"$1"/config
chown -R "$1":"$1" /home/"$1"
EOF

    docker exec -i "$1" sh <<EOF
set -xe
adduser -D app
passwd -u app
mkdir -p /home/app/.ssh
echo "$(cat keys/$1_user_key.pub)" > /home/app/.ssh/authorized_keys
chown -R app:app /home/app
EOF
}

add_user() {
    genkey "$2"
    docker exec -i bastion sh <<EOF
echo "$(cat keys/"$2"_key.pub)" >> /home/"$1"/.ssh/authorized_keys
EOF
}

docker build -t bastion .

start_bastion
add_host host1
add_host host2
add_host host3

add_user host1 user1
add_user host2 user2
add_user host3 user1
add_user host3 user2
