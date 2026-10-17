'use strict';

let ffutils = require("freifunk.utils");

// handle setting up the prometheus-push config
function process(config) {
	if (!config || type(config) != "object") return false;

	let addr = ffutils.first_ip(config?.node?.ips?.dhcp);
	let section = {
		interface:       split(addr, "/")[0], // from cidr from addr
	};

	let result = ffutils.update_section("prometheus-push", "ping", section);
	if (!result) return false;

	// enable statistics if so configured
	if (config?.node?.statistics) {
		result = global.cursor.set("prometheus-push", "statistics", "enabled", 1);
	}

	return result;
}

return {
	process,
};

