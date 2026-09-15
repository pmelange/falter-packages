const olsrinfo = json(poneline("printf '/all' | nc 127.0.0.1 9090 2>/dev/null"));

let linkCount = 0;
let lqSum = 0.0;
let nlqSum = 0.0;

for (let link in olsrinfo.links) {
    linkCount++;
    lqSum += link.linkQuality;
    nlqSum += link.neighborLinkQuality;
    namebase = link.localIP + "-" + link.remoteIP
    gauge("olsrd_link_signal_quality")({name: namebase + "-lq",}, link.linkQuality);
    gauge("olsrd_link_signal_quality")({name: namebase + "-rx",}, link.neighborLinkQuality);
}

gauge("olsrd_link_signal_quality")({name: "average-lq",}, lqSum / linkCount);
gauge("olsrd_link_signal_quality")({name: "average-rx",}, nlqSum / linkCount);

let routeCount = 0;
let etxSum = 0.0;
let metricSum = 0.0;

for (let route in olsrinfo.routes) {
    routeCount++;
    etxSum += route.etx;
    metricSum += route.metric;
}

gauge("olsrd_route_etx")(null, etxSum / routeCount);
gauge("olsrd_route_metric")(null, metricSum / routeCount);
gauge("olsrd_routes")(null, routeCount);

let topologyCount = 0;
let signalQualitySum = 0.0;

for (let topology in olsrinfo.topology) {
    topologyCount++;
    signalQualitySum += topology.linkQuality;
}

gauge("olsrd_topology_signalquality")(null, signalQualitySum / topologyCount);
gauge("olsrd_topology_links")(null, topologyCount);
