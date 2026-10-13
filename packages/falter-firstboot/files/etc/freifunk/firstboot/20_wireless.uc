'use strict';

const cfg = "wireless";

let ffutils = require("freifunk.utils");
ffutils.guard(cfg);

// determine how to name the setup ssid
let ssidlabel = ffutils.get_mac_label();
if (!ssidlabel) {
	// if we don't find a mac address, use the board name
	let ubus = require("ubus").connect();
	let boardinfo = ubus.call("system", "board");
	if (boardinfo) {
		ssidlabel = substr(board.info["board_name"], 0, 16);
	}
} else {
	// just the last 3 octets of the mac
	ssidlabel = substr(ssidlabel, 9);
}

ssidlabel = trim("freifunk-setup " + ssidlabel);

const wifi_device = {
	disabled:       0,
};

const wifi_iface = {
	ssid:           ssidlabel,
	disabled:       0,
};

global.cursor.foreach(cfg, "wifi-device", function(s) {
	ffutils.update_section(cfg, s[".name"], wifi_device);
});
global.cursor.foreach(cfg, "wifi-iface", function(s) {
	ffutils.update_section(cfg, s[".name"], wifi_iface);
});

ffutils.commit(cfg);
