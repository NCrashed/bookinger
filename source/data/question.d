/**
*   Copyright: © 2014 Anton Gushcha
*   License: Subject to the terms of the MIT license, as written in the included LICENSE file.
*   Authors: NCrashed <ncrashed@gmail.com>
*/
module data.question;

import vibe.data.json;

struct Question
{
    string text;
    
    bool hasVariants;
    string[] answers;
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
}