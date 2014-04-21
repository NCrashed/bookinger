/**
*   Copyright: © 2014 Anton Gushcha
*   License: Subject to the terms of the MIT license, as written in the included LICENSE file.
*   Authors: NCrashed <ncrashed@gmail.com>
*/
module data.question;

import vibe.data.json;
import backend.pgator;
import std.range;
import std.container;
import std.array;

struct Question
{
    string text;
    
    int id;
    bool hasVariants;
    string[] answers;
    string[] parameters;
    string[] values;
    int[] nexts;
    string minValue;
    string maxValue;
    
    this(string text, string[] variants)
    {
        this.text = text;
        this.hasVariants = true;
        this.answers = variants;
    }
    
    this(string text, string minval, string maxval)
    {
        this.text = text;
        this.hasVariants = false;
        this.minValue = minval;
        this.maxValue = maxval;
    }
    
    Json toJson() const
    {
        auto json = Json.emptyObject;
        json.text = text;
        
        json.hasVariants = hasVariants;
        if(hasVariants)
        {
            json.answers = answers.serializeToJson;
        }
        else
        {
            json.minValue = minValue;
            json.maxValue = maxValue;
        }
        
        return json;
    } 
    
    static Question fromJson(Json json)
    {
        if(json.hasVariants)
        {
            return Question(json.text.to!string, json.answers.deserializeJson!(string[]));
        } else
        {
            return Question(json.text.to!string, json.minValue.to!string, json.maxValue.to!string);
        }
    }
    
    static InputRange!Question fromResponse(RpcRespond res)
    {
        auto rows = res.assertOk!(
              Column!(uint, "id")
            , Column!(string, "type")
            , Column!(string[], "variants")
            , Column!(string[], "parameters")
            , Column!(string[], "values")
            , Column!(string[], "nexts")
            , Column!(string, "minval")
            , Column!(string, "maxval")
            , Column!(string, "content"));
        
        DList!Question ret;
        foreach(i; 0..rows.length)
        {
            auto q = Question("", []);
            q.id = rows.id[i];
            q.text = rows.content[i];
            q.hasVariants = rows.type[i] == "Choose";
            q.answers = rows.variants[i];
            q.parameters = rows.parameters[i];
            q.values = rows.values[i];
            
            auto builder = appender!(int[]);
            foreach(id; rows.nexts[i])
            {
                try
                {
                    builder.put(id.to!int);
                } 
                catch(Exception e)
                {
                    builder.put(-1);
                }
            }
            q.nexts = builder.data;
            
            q.minValue = rows.minval[i];
            q.maxValue = rows.maxval[i];
            ret.insert = q;
        }
        return ret[].inputRangeObject;
    }
}

class QuestionTree
{
    Node root;
    
    static class Node
    {
        DList!Node childs;
        Question value;
        
        this(Question question)
        {
            value = question; 
        }
        
        void insert(Node q)
        {
            childs.insert = q;
        }
        
        override string toString()
        {
            auto builder = appender!string;
            
            builder.put(value.id.to!string);
            builder.put(" ");
            builder.put(childs[].array.to!string);
            return builder.data;
        }
    }
    
    this(Node root)
    {
        this.root = root;
    }
    
    override string toString()
    {
        return "Tree: "~root.toString;
    }
    
    static InputRange!QuestionTree construct(InputRange!Question questionsRange)
    {
        auto questions = indexed(questionsRange);
        auto heads = findHeads(questions);
        
        DList!QuestionTree trees;
        foreach(head; heads)
        {
            Node iterate(Question q)
            {
                auto tree = new Node(q);
                
                foreach(next; q.nexts)
                {
                    if(next >= 0)
                    {
                        tree.insert(iterate(questions[next]));
                    } else
                    {
                        tree.insert(null);
                    }
                }
                return tree;
            }
            
            trees.insert = new QuestionTree(iterate(head));
        }
        return trees[].inputRangeObject;
    }
    
    private static Question[int] indexed(InputRange!Question questions)
    {
        Question[int] array;
        foreach(question; questions)
        {
            array[question.id] = question;
        }
        return array;
    }
    
    private static InputRange!Question findHeads(Question[int] questions)
    {
        bool[int] marks;
        foreach(question; questions)
        {
            foreach(next; question.nexts)
            {
                if(next >= 0)
                {
                    marks[next] = true;
                }
            }
        }
        
        DList!Question list;
        foreach(question; questions)
        {
            if(question.id !in marks)
            {
                list.insert = question;
            }
        }
        
        return list[].inputRangeObject;
    }
}