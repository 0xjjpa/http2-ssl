ENTRYPOINT=./vagrant.sh

up:
	$(ENTRYPOINT) up

provision:
	$(ENTRYPOINT) provision

ssh:
	$(ENTRYPOINT) ssh

halt:
	$(ENTRYPOINT) halt
