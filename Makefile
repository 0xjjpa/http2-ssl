ENTRYPOINT=./vagrant.sh

up:
	$(ENTRYPOINT) up

provision:
	$(ENTRYPOINT) provision --provision-with replace,webpage

reprovision:
	$(ENTRYPOINT) provision --provision-with letsencrypt,replace,webpage

ssh:
	$(ENTRYPOINT) ssh

halt:
	$(ENTRYPOINT) halt

status:
	$(ENTRYPOINT) status
