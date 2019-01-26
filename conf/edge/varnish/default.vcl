vcl 4.0;

// load vmods
import std;
import directors;

# // Backend definitions
# backend origin {
#     .host = "uk-origin-envoy";
#     .port = "80";
# }

// Generated dynamically using dns-to_backend.sh services uk-services
// as can't rely on varnish to do dns lookups
// https://info.varnish-software.com/blog/varnish-backends-in-the-cloud
include "origin.vcl";


sub vcl_recv {

    // Health check
    if (req.method == "GET" && req.url == "/varnish-status") {
       return(synth(200, "OK"));
    }

    call choose_backend;

    // Don't want any cookies
    unset req.http.Cookie;

    // The default vcl_hash takes care of host and url, so we don't need to add it
}

sub choose_backend {
    # TODO; This would be a good place for magical routing trickery
    set req.backend_hint = origin.backend();
}

sub vcl_backend_response {
    set beresp.http.X-Backend = beresp.backend.name;
}

sub vcl_hash {
    if(req.http.X-Original-Host) {
        hash_data(req.http.X-Original-Host);
    }
}

sub vcl_deliver {

    // override backend cache status with varnish status
    if (obj.hits > 0) {
        set resp.http.X-WRM-Edge-Status = "HIT";
    } else {
        set resp.http.X-WRM-Edge-Status = "MISS";
    }

    // tidy up headers
    unset resp.http.X-Varnish;
    unset resp.http.via;
    unset resp.http.Server;

    // Container identifier
    set resp.http.X-WRM-Edge = server.hostname;
}
