'use strict';

let ffutils = require("freifunk.utils");

function process(config) {
	if (!config || type(config) != "object") return false;

	// add the "wirelessN" interfaces
	global.cursor.foreach("wireless", "wifi-device", function(s) {
		// add a new interface
		let ifname = "wireless" + substr(s[".name"], -1, 1);
		let section = {
			interface:       ifname,
			ignore:          0,
		};
		let result = ffutils.add_section("olsrd", {type: "Interface", name: ifname}, section);
		if (!result) return false;
	});

	// add the Hna4 for the dhcp network
	let dhcp_net = config?.node?.ips?.dhcp;
	let addr = split(dhcp_net, "/")[0];
	let netmask = ffutils.cidr_to_netmask(int(split(dhcp_net, "/")[1]));
	let section = {
		netaddr:        addr,
		netmask:        netmask,
	};
	return ffutils.add_section("olsrd", {type: "Hna4"}, section);
}

return {
	process,
};
