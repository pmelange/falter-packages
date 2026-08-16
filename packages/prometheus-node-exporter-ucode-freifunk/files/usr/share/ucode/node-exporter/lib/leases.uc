const x = ubus.call("file", "read", {path: "/tmp/dhcp.leases",});

if (!x) {
	counter("node_dhcpleases_leases")(null, 0);
}
else {
	let count = 0;
	let lines = split(x.data, "\n");
	for (let line in lines) {
		count++;
	}
	counter("node_dhcpleases_leases")(null, count-1);
}
