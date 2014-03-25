import vibe.d;

struct Question
{
    string text = "Are you afraid of death, Mr. Freeman?";
    string[] answers = ["No, die octopus!", "Yes, i shall serve you!"];
}

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
    router.get("*", serveStaticFiles("public/"));
    
    auto settings = new HTTPServerSettings;
    settings.bindAddresses = ["127.0.0.1"];
    settings.port = 8000;
    
    listenHTTP(settings, router);
}
