let f = fs.open("/tmp/dhcp.leases");

if (!f)
	return false;

let count = 0;
while (nextline(f)) {
	count++;
}
f.close();

counter('node_dhcpleases_leases')(null, count);
