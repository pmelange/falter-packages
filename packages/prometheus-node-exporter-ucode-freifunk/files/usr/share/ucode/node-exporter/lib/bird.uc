import { popen } from 'fs';
let resolv = require('resolv');

function exec(cmd) {
	let fh = fs.popen(cmd, 'r');
	if (fh) { let r = trim(fh.read('all')); fh.close(); return r; }
	return '';
}

function build_neigh_tables() {
	let ipv6 = exec('ip -j -6 neigh show 2>/dev/null');
	if (!ipv6) return;
	let entries6 = json(ipv6);
	if (!entries6) return;

	let cleaned = filter(entries6, (val) => index(val.dst, "fe80") == 0);

	let ipv4 = exec('ip -j -4 neigh show 2>/dev/null');
	if (!ipv4) return;
	let entries4 = json(ipv4);
	if (!entries4) return;

	for (let i = 0; i < length(entries4); i++) {
		for (let j = 0; j < length(cleaned); j++) {
			if ( cleaned[j].lladdr == entries4[i].lladdr ) {
				cleaned[j].ip4 = entries4[i].dst;
			}
		}
	}
	return cleaned;
}

function resolve_hostname(ip) {
	let result = resolv.query(ip, { type: ['PTR'] });
	for (let domain in result) {
		let ptr = result[domain]?.PTR?.[0];
		if (!ptr) continue;
		let m = match(ptr, /([^.]+)\.ff$/);
		if (m) return m[1];
	}
	return ip;
}

let tables = build_neigh_tables();

// birdc show babel neighbors

let babelneigh_rtt = gauge("babel_neighbor_rtt");
let babelneigh_metric = gauge("babel_neighbor_metric");
let babelneigh_iface = gauge("babel_neighbor_interface");

let fd = popen("birdc show babel neighbors");
while (true) {
	if (!fd) break;

	let line = fd.read('line');
	if (!line) break;

	let data = wsplit(line);
	if (index(data[0], "fe80") == 0) {
		let lookup = filter(tables, function(row) {
			return row.dst == data[0];
		});
		let hostname = data[0];
		if (lookup) {
			hostname = resolve_hostname(lookup[0].ip4);
		}
		babelneigh_rtt({host: hostname,}, data[7]);
		babelneigh_metric({host: hostname,}, data[2]);
		babelneigh_iface({host: hostname, iface: data[1],}, 1);
	}
}
fd.close();

// birdc show babel routes

let babel_ipv4_gateway_interface = gauge("babel_ipv4_gateway_interface");
let babel_ipv4_gateway_metric = gauge("babel_ipv4_gateway_metric");
let babel_ipv4_gateway_selection = gauge("babel_ipv4_gateway_selection"); 
let babel_ipv6_gateway_interface = gauge("babel_ipv6_gateway_interface");
let babel_ipv6_gateway_metric = gauge("babel_ipv6_gateway_metric");
let babel_ipv6_gateway_selection = gauge("babel_ipv6_gateway_selection"); 
                                                                       
fd = popen("birdc show babel routes");
while(true) {
	if (!fd) break;
 
        let line = fd.read('line');
        if (!line) break;

        if (index(line, "0.0.0.0/0") == 0) {
		let data = wsplit(line);
		let hostname = resolve_hostname(data[1]);
		babel_ipv4_gateway_interface( {host: hostname, iface: data[2],}, 1);
		babel_ipv4_gateway_metric( {host: hostname,}, data[3]);
		let selected = -1;
		if (data[4] == "*") {
			selected = 1;
		}
		if (data[4] == "+") {
			selected = 0;
		}
		babel_ipv4_gateway_selection( {host: hostname,}, selected);
	}
        else if (index(line, "::/0") == 0) {
		let data = wsplit(line);
		let lookup = filter(tables, function(row) {
			return row.dst == data[3];
		});
		let hostname = data[3];
		if (lookup) {
			hostname = resolve_hostname(lookup[0].ip4);
		}
		babel_ipv6_gateway_interface( { host: hostname, iface: data[4],}, 1);
		babel_ipv6_gateway_metric( { host: hostname,}, data[5]);
		let selected = -1;
		if (data[6] == "*") {
			selected = 1;
		}
		if (data[6] == "+") {
			selected = 0;
		}
		babel_ipv6_gateway_selection( {host: hostname,}, selected)
	}
}
fd.close();




// birdc show route count

let bird_routes_table_routes = gauge("bird_routes_table_routes");
let bird_routes_table_of_routes = gauge("bird_routes_table_of_routes");
let bird_routes_table_networks = gauge("bird_routes_table_networks");

fd = popen("birdc show route count");
while (true) {
	if (!fd) break;

	let line = fd.read('line');
	if (!line) break;

	if (index(line, "BIRD") == 0) continue;
	if (index(line, "Total") == 0) continue;

	let data = wsplit(line);
	bird_routes_table_routes( {table: data[9], }, data[0]);
	bird_routes_table_of_routes( {table: data[9], }, data[2]);
	bird_routes_table_networks( {table: data[9], }, data[5]);
 
}
fd.close();
