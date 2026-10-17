'use strict';

let ffutils = require("freifunk.utils");
let fs = require("fs");

const profile_dir = "/etc/freifunk/profiles/";
const community = ffutils.cursor.get("freifunk", "community", "name") || "berlin";

// deepMerge and deepMergeArray taken from
//       https://ucode-lang.org/ucode/tutorial-03-objects.html#merging
function deepMergeArray;

function deepMerge(target, ...sources) {
    for (let source in sources) {
        if (type(source) != "object")
            continue;

        for (let key in keys(source)) {
            if (type(source[key]) == "object" && type(target[key]) == "object")
                target[key] = deepMerge({ ...target[key] }, source[key]);
            else if (type(source[key]) == "array" && type(target[key]) == "array")
                target[key] = deepMergeArray(target[key], source[key]);
            else
                target[key] = source[key];
        }
    }

    return target;
}

function deepMergeArray(target, source) {
    for (let i = 0; i < length(source); i++) {
        if (type(source[i]) == "object" && type(target[i]) == "object")
            target[i] = deepMerge({ ...target[i] }, source[i]);
        else if (type(source[i]) == "array" && type(target[i]) == "array")
            target[i] = deepMergeArray(target[i], source[i]);
        else
            target[i] = source[i];
    }

    return target;
}

function get_defaults(config, section) {
	let freifunk = json(fs.readfile(profile_dir + "freifunk.json"));

	let profile = json(fs.readfile(profile_dir + community + ".json");

	let combined = deepMerge({}, 
			freifunk[config][section],
			profile[config]?.[section] ?? {});
	return combined
}

return {
	community,
	get_defaults,
};
