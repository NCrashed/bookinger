/**
*   Copyright: © 2014 Anton Gushcha
*   License: Subject to the terms of the MIT license, as written in the included LICENSE file.
*   Authors: NCrashed <ncrashed@gmail.com>
*/
module frontend.api;

import data.question;
import vibe.http.rest;
import vibe.core.log;
import std.conv;

interface IFrontend
{
    @path("next/")
    @property Question next();
    
    @path("answer/")
    void postAnswer(string answer);
}

class Frontend : IFrontend
{
    override:
    
    Question next()
    {
        return Question();
    }
    
    void postAnswer(string answer)
    {
        logInfo(text("User answered ", answer));
    }
}