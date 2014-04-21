/**
*   Copyright: © 2014 Anton Gushcha
*   License: Subject to the terms of the MIT license, as written in the included LICENSE file.
*   Authors: NCrashed <ncrashed@gmail.com>
*/
module data.testing;

import data.question;
import std.datetime;
import std.range;

class Testing
{
    QuestionTree[] trees;
    
    TickDuration lastTime;
    Duration aliveDuration;
    
    this(InputRange!QuestionTree startupTrees, Duration aliveDuration)
    {
        trees = startupTrees.array;
        this.aliveDuration = aliveDuration;
        updateSession();
    }

    bool hasNextQuestion()
    {
        if(trees.length == 0)
        {
            return false;
        }
        
        foreach(tree; trees)
        {
            if(!tree.isLeaf())
            {
                return true;
            }
        }
        return false;
    }
    
    Question nextQuestion()
    {
        foreach(tree; trees)
        {
            if(!tree.isLeaf())
            {
                return tree.value;
            }
        }
        throw new Exception("Invaild state, maybe hasNextQuestion isn't called before");
    }
    
    void popFront(size_t index)
    {
        if(trees.length == 0)
        {
            return;
        }
        
        trees[0].popFront(index);
    }
    
    /// Session isn't timeouted
    bool isValid()
    {
        return Clock.currSystemTick <= lastTime + cast(TickDuration)aliveDuration;
    }
    
    /// Session countdown cleared
    protected void updateSession()
    {
        lastTime = Clock.currSystemTick();
    }
}