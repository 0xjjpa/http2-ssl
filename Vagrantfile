# -*- mode: ruby -*-
# vi: set ft=ruby :

$AWS_ACCESS_KEY = ENV['AWS_ACCESS_KEY']
$AWS_SECRET_KEY = ENV['AWS_SECRET_KEY']
$AWS_KEYPAIR_NAME = ENV['AWS_KEYPAIR_NAME']
$AWS_KEYPAIR_PATH = ENV['AWS_KEYPAIR_PATH']

$rsync_folder_disabled = false

Vagrant.configure(2) do |config|
  config.vm.box_url = "https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box"
  config.vm.box = "dummy" 

  config.vm.provider :aws do |aws, override|
    aws.access_key_id = $AWS_ACCESS_KEY
    aws.secret_access_key = $AWS_SECRET_KEY
    aws.keypair_name = $AWS_KEYPAIR_NAME

    aws.ami = "ami-6d2d470d"
    aws.region = "us-west-1"
    aws.instance_type = "t2.nano"

    override.ssh.username = "rancher"
    override.ssh.private_key_path = $AWS_KEYPAIR_PATH
  end

  config.vm.synced_folder ".", "/opt/rancher", type: "rsync",
      rsync__exclude: ".git/", rsync__args: ["--verbose", "--archive", "--delete", "--copy-links"],
      disabled: $rsync_folder_disabled
end
