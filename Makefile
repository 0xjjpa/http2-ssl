ENTRYPOINT=./vagrant.sh

up:
	$(ENTRYPOINT) up --no-provision

reprovision:
	$(ENTRYPOINT) provision --provision-with replace,webpage

provision:
	$(ENTRYPOINT) provision --provision-with letsencrypt,replace,webpage

ssh:
	$(ENTRYPOINT) ssh

halt:
	$(ENTRYPOINT) halt

status:
	$(ENTRYPOINT) status

destroy:
	$(ENTRYPOINT) destroy
