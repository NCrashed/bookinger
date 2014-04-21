/**
*   Copyright: © 2014 Anton Gushcha
*   License: Subject to the terms of the MIT license, as written in the included LICENSE file.
*   Authors: NCrashed <ncrashed@gmail.com>
*/
module backend.api;

import data.question;
import std.range;
import core.time;
import backend.pgator;
import vibe.web.rest;
import dlogg.log;

interface IBackend
{
    InputRange!Question headQuestions();
}

class Backend : IBackend
{
    shared ILogger logger;
    private IDataBase db;
    
    this(shared ILogger logger, string url)
    {
        this.logger = logger;
        db = new RestInterfaceClient!IDataBase(url);
    }
    
    InputRange!Question headQuestions()
    {
        auto questions = Question.fromResponse(db.runRpc!"getAllQuestions"());
        auto trees = QuestionTree.construct(questions);
        
        foreach(tree; trees)
        {
            logger.logDebug(tree); 
        }
        
        assert(false);
    }
}