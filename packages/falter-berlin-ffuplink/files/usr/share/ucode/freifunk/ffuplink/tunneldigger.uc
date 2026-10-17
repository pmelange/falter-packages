'use strict';

//import * as rtnl from 'rtnl';

let ffutils = require("freifunk.utils");
let community = require("freifunk.community");

//let ubus = require('ubus').connect();

const name = "notunnel";
const description = {
	en: {
		"DESCRIPTION": "Share internet through the Freifunk VPN tunnel",
	},
	de: {
		"DESCRIPTION": "tunneldigger Kartoffelbrei",
	},
};

function configure() {
	// set up the ffuplink interface
	let ffuplink_interface = {
		proto:          "dhcp",
		disabled:       0,
        };
	ffutils.update_section("network", "ffuplink", ffuplink_interface);

	// set up tunneldigger
	let tunneldigger_config = community.get_defaults("tunneldigger", "ffuplink");
	let mac = global.cursor.get("network", "ffuplink_dev", "macaddr")
	if (!mac) mac = ffutils.generate_mac("fe");

	td.options.uuid = ffutils.generate_hex_string(10, mac);
	ffutils.add_section("tunneldigger", {type: "broker", name: "ffuplink",}, tunneldigg_config);

	ffutils.commit("network");
	ffutils.commit("tunneldigger");
}

function unconfigure() {
	let ffuplink_interface = {
		proto:          "none",
		disabled:       1,
        };
	ffutils.update_section("network", "ffuplink", ffuplink_interface);

	ffutils.delete_section("tunneldigger", "ffuplink");

	ffutils.commit("network");
	ffutils.commit("tunneldigger");
}

function status() {
	let iface = ffutils.cursor.get("network", "ffuplink", "disabled");
	let td_status = ffutils.cursor.get("tunneldigger", "ffuplink", "enabled");
	if (iface == 0 && td_status == 1) return true;
	return false;
}

return {
	name: name,
	description: description,
	configure: configure,
	unconfigure: unconfigure,
	status: status,
};
