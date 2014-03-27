/**
*   Copyright: © 2014 Anton Gushcha
*   License: Subject to the terms of the MIT license, as written in the included LICENSE file.
*   Authors: NCrashed <ncrashed@gmail.com>
*/
module app;

import vibe.d;
import data.question;
import frontend.api;

void index(HTTPServerRequest req,
           HTTPServerResponse res)
{
    auto question = Question();
    res.render!("index.dt", req, question);
}

shared static this()
{
    auto router = new URLRouter;
    router.get("/", &index);
    registerRestInterface(router, new Frontend(), "/api");
    router.get("*", serveStaticFiles("public/"));
    
    auto settings = new HTTPServerSettings;
    settings.bindAddresses = ["127.0.0.1"];
    settings.port = 8000;
    
    listenHTTP(settings, router);
}
