'use strict';

const cfg = "dhcp";

let ffutils = require("freifunk.utils");
ffutils.guard(cfg);

const dnsmasq_defaults = {
	quietdhcp:      1,
	domain:         "ff",
	notinterface:   "wan",
	server:         [ "9.9.9.10", "194.150.168.168" ], // overwritten later by the wizard
};

const freifunk_domain_name = {
	name:           "frei.funk",
	ip:             "192.168.42.1",
};

// we need the first address in the ULA.  Drop off the /48 and replace with a 1
const ula = replace(global.cursor.get("network", "globals", "ula_prefix"), "/48", "1");
const freifunk_v6_domain_name = {
	name:           "frei.funk",
	ip:             ula,
};

const lan_dhcp = {
	ra_default:     1,
	dhcp_option:    [ 3 ],
};

ffutils.update_section(cfg, "@dnsmasq[0]", dnsmasq_defaults);
ffutils.add_section(cfg, {type: "domain", name: "frei_funk"}, freifunk_domain_name);
ffutils.add_section(cfg, {type: "domain", name: "frei_funk_ipv6"}, freifunk_v6_domain_name);
ffutils.update_section(cfg, "lan", lan_dhcp);

ffutils.commit(cfg);
