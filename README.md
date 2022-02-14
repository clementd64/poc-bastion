# Proof of concept SSH bastion

Main feature
- KISS: keep it simple, stupid
- Openssh as ssh client/server

## Usage
```sh
sh up.sh

ssh -i keys/user1_key localhost -p 2222 -l host1 # authorized
ssh -i keys/user1_key localhost -p 2222 -l host2 # unauthorized
ssh -i keys/user1_key localhost -p 2222 -l host3 # authorized
ssh -i keys/user2_key localhost -p 2222 -l host1 # unauthorized
ssh -i keys/user2_key localhost -p 2222 -l host2 # authorized
ssh -i keys/user2_key localhost -p 2222 -l host3 # authorized
```

Not working: port forwarding, x11 forwarding, sftp.

## How it works

Each remote host has a corresponding user in the bastion.
OpenSSH validate the user with the `autorized_keys` file.
A simple script is used as shell that create a connection to the remote host.
When a autorized user (see `autorized_keys`) make a connection, a simple shell script make a new ssh connection to the remote host.

In case of user escapation, the private keys for other host are protected by the file system permision.