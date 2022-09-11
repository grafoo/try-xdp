#include <linux/if_ether.h> // for: struct ethhdr
#include <linux/bpf.h> // for: struct xdp_md
#include <bpf/bpf_helpers.h> // for: #define SEC
// context information object about the packet
// grep -A 9 'struct xdp_md {' /usr/include/linux/bpf.h
// struct xdp_md {
// 	__u32 data;
// 	__u32 data_end;
// 	__u32 data_meta;
// 	/* Below access go through struct xdp_rxq_info */
// 	__u32 ingress_ifindex; /* rxq->dev->ifindex */
// 	__u32 rx_queue_index;  /* rxq->queue_index  */
//
// 	__u32 egress_ifindex;  /* txq->dev->ifindex */
// };

// return codes to be communicated to the kernel after this
// program has finished processing the packet
// grep -A 6 'enum xdp_action {' /usr/include/linux/bpf.h
// enum xdp_action {
// 	XDP_ABORTED = 0,
// 	XDP_DROP,
// 	XDP_PASS,
// 	XDP_TX,
// 	XDP_REDIRECT,
// };
SEC("try_xdp")
int try_xdp_net(struct xdp_md *ctx)
{
	void *data = (void *)(long)ctx->data;
	void *data_end = (void *)(long)ctx->data_end;
	// make the verifier happy and do bounds checking here,
	// so the static analysis during load time will
	// consider memory access after this to be safe
	if (data + sizeof(struct ethhdr) > data_end)
		return XDP_DROP;
	// let the kernel networking stack pick up this packet
	// for further processing
	return XDP_PASS;
}
