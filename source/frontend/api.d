/**
*   Copyright: © 2014 Anton Gushcha
*   License: Subject to the terms of the MIT license, as written in the included LICENSE file.
*   Authors: NCrashed <ncrashed@gmail.com>
*/
module frontend.api;

import data.question;
import vibe.http.rest;

interface IFrontend
{
    @path("next/")
    @property Question next();
}

class Frontend : IFrontend
{
    override:
    
    Question next()
    {
        return Question();
    }
}