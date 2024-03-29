{

boot = {
  # Set up static IPv4 address in the initrd.
  kernelParams = [ "ip=<ipv4_address>::<ipv4_gateway>:<ipv4_netmask>::<interface>:none" ];

  initrd = {
    # Switch this to your ethernet's kernel module.
    # You can check what module you're currently using by running: lspci -v
    kernelModules = [ "e1000" ];

    network = {
      # This will use udhcp to get an ip address.
      # Make sure you have added the kernel module for your network driver to `boot.initrd.availableKernelModules`,
      # so your initrd can load it!
      # Static ip addresses might be configured using the ip argument in kernel command line:
      # https://www.kernel.org/doc/Documentation/filesystems/nfs/nfsroot.txt
      enable = true;
      ssh = {
        enable = true;
        # To prevent ssh clients from freaking out because a different host key is used,
        # a different port for ssh is useful (assuming the same host has also a regular sshd running)
        port = 2222;
        # hostKeys paths must be unquoted strings, otherwise you'll run into issues with boot.initrd.secrets
        # the keys are copied to initrd from the path specified; multiple keys can be set
        # you can generate any number of host keys using
        # `ssh-keygen -t ed25519 -N "" -f /path/to/ssh_host_ed25519_key`
        hostKeys = [ /persist/etc/ed5key ];
        # public ssh key used for login
        authorizedKeys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKgtiyDGe+vYeazvXepFiKgOqL1KbDdHAmffPe9Lu+uZ radbellatrix@gmail.com"];
      };
      # this will automatically load the zfs password prompt on login
      # and kill the other prompt so boot can continue
      postCommands = ''
        cat <<EOF > /root/.profile
        if pgrep -x "zfs" > /dev/null
        then
          zfs load-key -a
          killall zfs
        else
          echo "zfs not running -- maybe the pool is taking some time to load for some unforseen reason."
        fi
        EOF
      '';
    };
  };
};

}