var client;
var answerVariants;
var lastQuestion;

window.onload = function()
{
    client = new $.RestClient('/api/');
    client.add('next');
    client.add('answer', {stringifyData:true});
    
    $('#sendAnswer').click(function(event) {
        event.preventDefault();
        
        var res = sendQuestion();
        if(res)
        {
            requestQuestion();
        }
    });
    
    requestQuestion();
}

function requestQuestion()
{
    client.next.read().done(function(data) {
        lastQuestion = data;
        displayQuestion(data);        
    });
}

function sendQuestion()
{
    if(answerVariants)
    {
        client.answer.create({answer: $('input[name=variant]:checked', '#answerForm').val()});
        return true;
    }
    else
    {
        var ansval = parseInt($('#answer-input').val());
        if(ansval >= parseInt(lastQuestion.minValue) && ansval <= parseInt(lastQuestion.maxValue))
        {
            $('#answer-validator').text('');
            $('#answer-validator').removeClass('errormsg');
            client.answer.create({answer: ansval.toString()});
            return true;
        }
        else
        {
            $('#answer-validator').addClass('errormsg');
            $('#answer-validator').text('Неправильные данные!');
            return false;
        }
    }
}

function displayQuestion(question)
{
    clearQuestion();
    $('#question-text').text(question.text);
    
    answerVariants = question.hasVariants;
    if(answerVariants)
    {
        question.answers.forEach(function(entry, i) {
            if(i == 0)
            {
                $('#answerForm').prepend('<input class="radio" type="radio", name="variant", value="' + i + '" checked>'
                                       + '<label class="radio bold">' + entry + '</label><br class="radio">');
            } else
            {
                $('#answerForm').prepend('<input class="radio" type="radio", name="variant", value="' + i + '">'
                                       + '<label class="radio bold">' + entry + '</label><br class="radio">');
            }
        });
    }
    else
    {
        $('#answerForm').prepend('<input id="answer-input" class="radio" type="text" size="50">'
                               + '<p class="radio" id="answer-validator"></p>'
                               );
    }
}

function clearQuestion()
{
    $('.radio').remove();
}