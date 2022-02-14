FROM alpine
RUN apk add --no-cache openssh-server openssh-client rsync \
 && echo -n "" > /etc/motd
COPY sshd_config /etc/ssh/sshd_config
CMD [ "/usr/sbin/sshd", "-D", "-e" ]