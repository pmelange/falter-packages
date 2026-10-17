'use strict';

const service = "/etc/init.d/dnsmasq";

// dnsmasq needs to be restarted after config changes
function process(config) {
	system(service + " restart");
	sleep(2000); // sleep so that dnsmasq has time to start
	return true;
}

return {
	process,
};
