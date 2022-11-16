pkgs: image:
let
  directory = "/opt/devkitpro";
in
pkgs.vmTools.runInLinuxVM (
  pkgs.runCommand "docker-preload-image" {
    memSize = 12 * 1024;
    buildInputs = [
      pkgs.curl
      pkgs.kmod
      pkgs.docker
      pkgs.e2fsprogs
      pkgs.utillinux
    ];
  }
  ''
    modprobe overlay

    # from https://github.com/tianon/cgroupfs-mount/blob/master/cgroupfs-mount
    mount -t tmpfs -o uid=0,gid=0,mode=0755 cgroup /sys/fs/cgroup
    cd /sys/fs/cgroup
    for sys in $(awk '!/^#/ { if ($4 == 1) print $1 }' /proc/cgroups); do
      mkdir -p $sys
      if ! mountpoint -q $sys; then
        if ! mount -n -t cgroup -o $sys cgroup $sys; then
          rmdir $sys || true
        fi
      fi
    done

    dockerd -H tcp://127.0.0.1:5555 -H unix:///var/run/docker.sock &

    until $(curl --output /dev/null --silent --connect-timeout 2 http://127.0.0.1:5555); do
      printf '.'
      sleep 1
    done

    echo load image
    docker load -i ${image}

    echo run image
    docker run ${image.destNameTag} tar -C '${toString directory}' -c . | tar -xv --no-same-owner -C $out || true

    echo end
    kill %1
  ''
)
