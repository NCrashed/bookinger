import vibe.d;

void handleRequest(HTTPServerRequest req,
                   HTTPServerResponse res)
{
    res.writeBody("Hello, World!", "text/plain");
}

shared static this()
{
    auto settings = new HTTPServerSettings;
    settings.bindAddresses = ["127.0.0.1"];
    settings.port = 8000;
    
    listenHTTP(settings, &handleRequest);
}
