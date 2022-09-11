from debian:bookworm
run apt -y update
run apt -y install linux-headers-arm64 xdp-tools clang libbpf-dev iproute2 iptables make
