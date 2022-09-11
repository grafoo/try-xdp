.PHONY: build-image
build-image:
	docker build -t xdp .

.PHONY: run-container
run-container:
	# `--cap-add=SYS_ADMIN` would work for mount but `--cap-add=BPF` doesn't seem supported
	# https://docs.docker.com/engine/reference/run/#runtime-privilege-and-linux-capabilities
	docker run --cap-add=ALL --rm -ti -v $(shell pwd):/root/xdp -w /root/xdp xdp bash

try_xdp.o: try_xdp.c
	clang -v -I/usr/include/aarch64-linux-gnu -O2 -g -Wall -target bpf -c try_xdp.c -o try_xdp.o

.PHONY: load
load:
	ip link set eth0 xdpgeneric obj try_xdp.o sec try_xdp
	# sysfs on /sys/fs/bpf type sysfs (rw,nosuid,nodev,noexec,relatime)
	# none on /sys/fs/bpf type bpf (rw,relatime,mode=700)
	# the above mounts are needed for loading. `ip` will do this automagically
	# if e.g. `xdp-loader load -m skb -s try_xdp eth0 try_xdp.o` is used 
	# mounting could be done via `mount --make-private -t bpf /sys/fs/bpf`

.PHONY: unload
unload:
	ip link set eth0 xdpgeneric off
	# `xdp-loader unload -a eth0` would also be an option

.PHONY: status
status:
	xdp-loader status

.PHONY: clean
clean:
	rm try_xdp.o

.PHONY: format
format:
	clang-format -i --sort-includes=false try_xdp.c
