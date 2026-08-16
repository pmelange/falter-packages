import { cursor } from "uci";

const uci = cursor();
let v = uci.get("system", "@system[0]", "version");
let t = uci.get("ffberlin-uplink", "preset", "current");
let c = uci.get("freifunk", "community", "name");
gauge("node_freifunk_info")({
        version:	v,
        type:           t,
        community:	c,
}, 1);
