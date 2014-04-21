/**
*   Copyright: © 2014 Anton Gushcha
*   License: Subject to the terms of the MIT license, as written in the included LICENSE file.
*   Authors: NCrashed <ncrashed@gmail.com>
*/
module app;

import vibe.d;
import frontend.api;
import backend.api;
import dlogg.strict;

void index(HTTPServerRequest req,
           HTTPServerResponse res)
{
    res.render!("index.dt", req);
}

version(unittest)
{
    
} else
{
    shared static this()
    {
        shared ILogger logger = new shared StrictLogger("logs/bookinger.log");
        auto router = new URLRouter;
        router.get("/", &index);
        
        auto backend = new Backend(logger, "http://127.0.0.1:8082");
        backend.headQuestions;
        registerRestInterface(router, new Frontend(backend), "/api");
        router.get("*", serveStaticFiles("public/"));
        
        auto settings = new HTTPServerSettings;
        settings.bindAddresses = ["127.0.0.1"];
        settings.port = 8000;
        
        listenHTTP(settings, router);
    }
}
