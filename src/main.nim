import std/strformat
import std/enumerate
import std/strutils
from std/htmlgen import b
import std/with
import std/json
import std/dom

include ./questions

# i like "exportjs" better
{. pragma: exportjs, exportc .}




let questions = parseJson questions_list

let 
  normativeQuestions = [1, 6, 11, 18, 23, 26, 33, 37, 43, 47, 48, 53, 58, 62, 68, 72, 77]

  socialQuestions = [1, 3, 5, 6, 8, 11, 12, 14, 17, 18, 20, 21, 22, 23, 25, 26, 28, 31, 37, 38, 39, 43, 44, 45, 47, 48, 53, 54, 55, 60, 61, 64, 68, 69, 72, 76, 77, 79, 80]
  languageQuestions = [2, 7, 15, 27, 35, 58, 66]
  sensoryQuestions = [4, 10, 16, 19, 29, 33, 34, 36, 42, 46, 49, 51, 57, 59, 62, 65, 67, 71, 73, 74]
  circumscribedInterestsQuestions = [9, 13, 24, 30, 32, 40, 41, 50, 52, 56, 63, 70, 75, 78]

let mainDiv = document.getElementById "main"

proc generateHtml =
  let responses = [
    "Never true",
    "True only when I was younger than 16",
    "True only now",
    "True now and when I was young",
  ]

  for qidx, question in enumerate questions:
    let questionElem = document.createElement "h4"

    with questionElem:
      innerText = cstring (if qidx + 1 in normativeQuestions: fmt"{qidx + 1}*. {question.str}"
                          else: fmt"{qidx + 1}. {question.str}")
      id = cstring fmt"question{qidx}"

    mainDiv.appendChild questionElem

    for idx, response in enumerate responses:
      var responseElem = document.createElement "input"

      with responseElem:
        setAttribute "type", "radio"
        id = cstring fmt"question{qidx}-{idx}"
        class = cstring "response"
        name = cstring fmt"question{qidx}"

      let labelElem = document.createElement "label"

      with labelElem:
        setAttribute "for", responseElem.id
        innerHTML = cstring response

      mainDiv.appendChild responseElem
      mainDiv.appendChild labelElem
      mainDiv.appendChild document.createElement "br"

proc score {. exportjs .} = 
  proc reverse(score: 0..3): int =
    case score:
    of 0: return 3
    of 1: return 2
    of 2: return 1
    of 3: return 0

  let responseElems = document.getElementsByClassName "response"

  var 
    responses: seq[int]

    totalScore: int
    social: int
    language: int
    sensory: int
    circumscribedInterests: int

  for responseElem in responseElems:
    if responseElem.checked:
      let id = $responseElem.id
      responses.add parseInt $id[^1]

  if responses.len < 80:
    window.alert "You have not answered all questions. Please go back and do so."
    return

  for question, response in enumerate responses:
    if question + 1 in normativeQuestions: 
      responses[question] = reverse response

    if question + 1 in socialQuestions: social.inc responses[question]
    elif question + 1 in languageQuestions: language.inc responses[question]
    elif question + 1 in sensoryQuestions: sensory.inc responses[question]
    elif question + 1 in circumscribedInterestsQuestions: circumscribedInterests.inc responses[question]

  totalScore = social + language + sensory + circumscribedInterests

  let 
    scoresRow = document.getElementById "scores-row"
    scores = document.getElementById "scores"

  scores.style.display = "block"
  scores.scrollIntoView

  for idx, i in enumerate [totalScore, language, social, sensory, circumscribedInterests]:
    var elem = document.getElementById cstring $(idx + 1)
    elem.innerHTML = cstring b $i

    scoresRow.appendChild elem

  echo "Total: ", totalScore
  echo "Social: ", social
  echo "Language: ", language
  echo "Sensory: ", sensory
  echo "Circumscribed Interests: ", circumscribedInterests

generateHtml()
