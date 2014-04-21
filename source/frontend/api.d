/**
*   Copyright: © 2014 Anton Gushcha
*   License: Subject to the terms of the MIT license, as written in the included LICENSE file.
*   Authors: NCrashed <ncrashed@gmail.com>
*/
module frontend.api;

import data.question;
import data.testing;
import vibe.http.rest;
import vibe.core.log;
import backend.api;
import std.conv;
import std.datetime;
import dlogg.log;

interface IFrontend
{
    @path("next/")
    @property DisplayQuestion next(int sessionId = -1);
    
    @path("answer/")
    void postAnswer(int sessionId, string answer);
}

struct DisplayQuestion
{
    int sessionId;
    
    string text;
    bool hasVariants;
    string[] answers;

    string minValue;
    string maxValue;
    
    this(int id, Question q)
    {
        sessionId = id;
        
        text = q.text;
        hasVariants = q.hasVariants;
        answers = q.answers;
        minValue = q.minValue;
        maxValue = q.maxValue;
    }
}

class Frontend : IFrontend
{
    private
    {
        shared ILogger logger;
        
        IBackend backend;
        Testing[int] sessions;
        int sessionCounter;
        enum Duration seessionAlive = dur!"minutes"(1);
    }
    
    this(shared ILogger logger, IBackend backend)
    {
        this.logger = logger;
        this.backend = backend;
    }
    
    override:
    
    DisplayQuestion next(int sessionId)
    {
        if(sessionId == -1 || sessionId !in sessions || !sessions[sessionId].isValid)
        {
            logger.logInfo("New session is opening!");
            
            auto testing = new Testing(backend.startTrees, seessionAlive);
            sessions[sessionCounter] = testing;
            
            if(!testing.hasNextQuestion)
            {
                throw new Exception("Don't have any questions to ask?");
            }
            
            if(sessionId in sessions)
            {
                logger.logInfo(text("Removing timeouted session with id: ", sessionId));
                sessions.remove(sessionId);
            }
            
            logger.logInfo(text("Returning new question with session id: ", sessionCounter));
            return DisplayQuestion(sessionCounter++, testing.nextQuestion);
        }
        
        logger.logInfo(text("Valid session request with id: ", sessionId));
        
        auto testing = sessions[sessionId];
        if(testing.hasNextQuestion)
        {
            return DisplayQuestion(sessionId, testing.nextQuestion);
        } else
        {
            throw new Exception("not implemented!");
        }
    }
    
    void postAnswer(int sessionId, string answer)
    {
        if(sessionId == -1 || sessionId !in sessions || !sessions[sessionId].isValid)
        {
            logger.logInfo("Invalid session for posAnswer");
            return;
        }
        
        size_t index;
        try
        {
            index = answer.to!size_t;
        } 
        catch(Exception e)
        {
            return;
        }
        logInfo(text("User answered ", answer));
        
        auto testing = sessions[sessionId];
        testing.popFront(index);
    }
}