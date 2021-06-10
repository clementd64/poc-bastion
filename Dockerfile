FROM alpine as base
RUN apk add --no-cache openssh-server openssh-client \
 && echo -n "" > /etc/motd
COPY sshd_config /etc/ssh/sshd_config
CMD [ "/usr/sbin/sshd", "-D", "-e" ]

FROM base as bastion
RUN addgroup -g 40000 group1 \
 && addgroup -g 40001 group2 \
 && mkdir -p /keys \
 # user 1
 && addgroup user1 \
 && adduser -g user1 -G group1 -D -s /usr/bin/bastion user1 \
 && passwd -u user1 \
 && mkdir -p /home/user1/.ssh && chown -R user1:user1 /home/user1 \
 # user 2
 && addgroup user2 \
 && adduser -g user2 -G group2 -D -s /usr/bin/bastion user2 \
 && passwd -u user2 \
 && mkdir -p /home/user2/.ssh && chown -R user2:user2 /home/user2

COPY --chown=root:group1 keys/group1_key /keys/group1_key
COPY --chown=root:group2 keys/group2_key /keys/group2_key
COPY --chown=user1:user1 authorized_keys /home/user1/.ssh/authorized_keys
COPY --chown=user2:user2 authorized_keys /home/user2/.ssh/authorized_keys
COPY keys/bastion_key /etc/ssh/ssh_host_ed25519_key
CMD [ "/usr/sbin/sshd", "-D", "-e" ]

FROM base as host
RUN addgroup -g 1000 app \
 && adduser -u 1000 -G app -D app \
 && passwd -u app
CMD [ "/usr/sbin/sshd", "-D", "-e" ]