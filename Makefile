init: authorized_keys host_keys
	docker-compose up -d --build

host_keys: keys/bastion_key keys/host1_key keys/host2_key keys/host3_key keys/group1_key keys/group2_key
	chmod g+r keys/group1_key
	chmod g+r keys/group2_key

keys/%_key:
	mkdir -p keys
	ssh-keygen -t ed25519 -f $@ -N ""

authorized_keys: ~/.ssh/id_rsa.pub
	cat $< > $@
	chmod 600 $@
