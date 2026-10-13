'use strict';

const cfg = "network";

let ffutils = require("freifunk.utils");
ffutils.guard(cfg);

// set up lan
const lan_defaults = {
	ipaddr:         [ "192.168.42.1/24" ],
};
ffutils.update_section(cfg, "lan", lan_defaults);

const wan_defaults = {
	device:         "br-wan",
	proto:          "dhcp",
	peerdns:        0,
};

const wan6_defaults = {
	device:         "br-wan",
	proto:          "dhcp6",
	peerdns:        0,
};

const wandev_defaults = {
	name:           "br-wan",
	type:           "bridge",
};

// we need to convert wan to a bridge
let dev = global.cursor.get(cfg, "wan", "device");

// handle devices which have no wan (single port devices)
if (!dev) {
	ffutils.add_section(cfg, {type: "interface", name: "wan"}, wan_defaults);
	ffutils.add_section(cfg, {type: "interface", name: "wan6"}, wan6_defaults);
	ffutils.add_section(cfg, {type: "device"}, wandev_defaults);
}
// convert wan to a bridge
else if (!match(dev, /^br-(.*)/)) {
	ffutils.update_section(cfg, "wan", wan_defaults);
	ffutils.update_section(cfg, "wan6", wan6_defaults);
	let wandev = wandev_defaults;
	wandev.ports = [ dev ];
	ffutils.add_section(cfg, {type: "device"}, wandev);
}
ffutils.commit(cfg);
