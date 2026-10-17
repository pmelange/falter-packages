'use strict';

const service = "/etc/init.d/dnsmasq";

// dnsmasq needs to be restarted after config changes
function process(config) {
	system(service + " restart");
	return true;
}

return {
	process,
};
