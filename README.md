# Proof of concept SSH bastion

Main feature
- KISS: keep it simple, stupid
- Openssh as ssh client/server
- Filesystem based ACL

## Usage
```sh
make
ssh -t localhost -p 2222 -l user1 -- host1 # authorized
ssh -t localhost -p 2222 -l user1 -- host2 # unauthorized
```
