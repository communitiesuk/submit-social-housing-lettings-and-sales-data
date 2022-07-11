## Question

Questions are under the page level of the form definition. A example question might look something like this:

```JSON
"postcode_known": {
  "check_answer_label": "Do you know the property postcode?",
  "header": "Do you know the property’s postcode?",
  "hint_text": "",
  "type": "radio",
  "answer_options": {
    "1": {
      "value": "Yes"
    },
    "0": {
      "value": "No"
    }
  },
  "conditional_for": {
    "postcode_full": [1]
  },
  "hidden_in_check_answers": true
}
```

In the above example the the question has the id `postcode_known`. 

The `check_answer_label` contains the text that will be displayed in the label of the table on the check answers page.

The header is text that is displayed for the question. 

Hint text is optional, but if provided it sits under the header and is normally given to provide the data inputters with guidance when answering the question, for example it might inform them about terms used in the question.

The type is question type, which is used to determine the view rendered for the question. In the above example the question is a radio type so the `app/views/form/_radio_question.html.erb` partial will be rendered on the page when this question is displayed to the user.

The `conditional_for` contains the value needed to be selected by the data inputter in order to display another question that appears on the same page. In the example above the `postcode_full` question depends on the answer to `postcode_known` being selected as `1` or `Yes`, this would then display the `postcode_full` underneath the `Yes` option on the page, allowing the provide the provide the postcode if they have indicated they know it. If the user has JavaScript enabled then this realtime conditional display is handled by the `app/frontend/controllers/conditional_question_controller.js` file.

the `hidden_in_check_answers` is used to hide a value from displaying on the check answers page. You only need to provide this if you want to set it to true in order to hide the value for some reason e.g. it's one of two questions appearing on a page and the other question is displayed on the check answers page. It's also worth noting that you can declare this as a with a `depends_on` which can be useful for conditionally displaying values on the check answers page. For example: 

```JSON
"hidden_in_check_answers": {
  "depends_on": [
    {
      "age6_known": 0
    },
    {
      "age6_known": 1
    }
  ]
}
```

Would mean the question the above is attached to would be hidden in the check answers page if the value of age6_known is either `0` or `1`.

The answer the data inputter provides to some questions allows us to infer the values of other questions we might have asked in the form, allowing us to save the data inputters some time. An example of how this might look is as follows:

```JSON
"postcode_full": {
  "check_answer_label": "Postcode",
  "header": "What is the property’s postcode?",
  "hint_text": "",
  "type": "text",
  "width": 5,
  "inferred_answers": {
    "la": {
      "is_la_inferred": true
    }
  },
  "inferred_check_answers_value": {
    "condition": {
      "postcode_known": 0
    },
    "value": "Not known"
  }
}
```

In the above example the width is an optional attribute and can be provided for text type questions to determine the width of the text box on the page when when the question is displayed to a user (this allows you to match the width of the text box on the page to that of the design for a question).

The above example links to the first example as both of these questions would be on the same page. The `inferred_check_answers_value` is what should be displayed on the check answers page for this question if we infer it. If the value of `postcode_known` was given as `0` (which is a no), as seen in the condition part of `inferred_check_answers_value`  then we can infer that the data inputter does not know the postcode and so we would display the value of `Not known` on the check answers page for the postcode. 

In the above example the `inferred_answers` refers to a question where we can infer the answer based on the answer of this question. In this case the `la` question can be inferred from the postcode value given by the data inputter as we are able to lookup the local authority based on the postcode given. We then set a property on the case log `is_la_inferred` to true to indicate that this is an answer we've inferred.