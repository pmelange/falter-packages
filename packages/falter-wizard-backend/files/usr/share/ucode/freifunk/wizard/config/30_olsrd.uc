'use strict';

let ffutils = require("freifunk.utils");

function bandwidth(config) {
	if (!config || type(config) != "object") return false;

	// only configure if there is an ffuplink
	if (config?.node?.internet?.ffuplink == "nouplink") return true;

	// set bandwidth limits
	let download = config?.node?.internet?.download;
	let upload = config?.node?.internet?.upload;
	let section = {
		SmartGatewaySpeed:       upload + " " + download,
		SmartGatewayUplink:      "both",
	};
	return ffutils.update_section("olsrd", "@olsrd[0]", section);
}

function interface(config) {
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
	return true;
}

function hna4(config) {
	if (!config || type(config) != "object") return false;

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

function process(config) {
	if (!config || type(config) != "object") return false;

	let result = bandwidth(config);
	if (!result) return false;

	result = interface(config);
	if (!result) return false;

	return hna4(config);
}

return {
	process,
};
