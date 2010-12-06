$(document).ready(function(){
    $(".tabs").tabs()
})

var startTime = 0
var start = 0
var end = 0
var diff = 0
var timerID = 0
var sec = 0
var min = 0
var hr = 0

var chronoStarted = false;
  function chrono(){
    end = new Date()
      diff = end - start
      diff = new Date(diff)
      //var msec = diff.getMilliseconds()
      sec = diff.getSeconds()
      min = diff.getMinutes()
      hr = diff.getHours()-1
      hr = "00";
    if (min < 10){
      min = "0" + min
    }
    if (sec < 10){
      sec = "0" + sec
    }

    /*if(msec < 10){
      msec = "00" +msec
      }
      else if(msec < 100){
      msec = "0" +msec
      }*/

    //alert('oi');
    //alert(document.getElementById("chronotime"));
    document.getElementById("clock").innerHTML = hr + ":" + min + ":" + sec; //+ ":" + msec
    timerID = setTimeout("chrono()", 10)
  }
function chronoStart(){
  //document.chronoForm.startstop.value = "stop!"
  //document.chronoForm.startstop.onclick = chronoStop
  //document.chronoForm.reset.onclick = chronoReset
  if (!chronoStarted) {
    start = new Date();
    chrono();
    chronoStarted = true;
  }
}
function chronoContinue(){
  document.chronoForm.startstop.value = "stop!"
    document.chronoForm.startstop.onclick = chronoStop
    document.chronoForm.reset.onclick = chronoReset
    start = new Date()-diff
    start = new Date(start)
    chrono()
}
function chronoReset(){
  document.getElementById("chronotime").innerHTML = "00:00:000"
    start = new Date()
}
function chronoStopReset(){
  document.getElementById("chronotime").innerHTML = "00:00:000"
    document.chronoForm.startstop.onclick = chronoStart
}
function chronoStop(){
  document.chronoForm.startstop.value = "start!"
    document.chronoForm.startstop.onclick = chronoContinue
    document.chronoForm.reset.onclick = chronoStopReset
    clearTimeout(timerID)
}

function submitChrono(){
  //var theTime = document.getElementById("clock").innerHTML;
  // submit time in secondes

  var theTime = sec + min * 60 + hr * 3600;
  //alert(theTime);
  document.getElementById("chrono").value = theTime;
}


function selectId(id){
  jQuery('.number').removeClass('indexSel')
    jQuery('#qIndex'+id).addClass('indexSel')
    //document.getElementById('qIndex'+id).className += ' indexSel';
}

function showLoading(){
  $('#question_box fieldset').html("<div id=\"q_loading\">" +
                          "<em>Carregando questão...</em>" +
                          "<img src=\"/images/loadingAnimation.gif\" alt=\"Loadinganimation\">" +
                          "</div>")
}

function addQuestionParams(question_id){
  var alternative_id = $("#question_box input[type=radio]:checked").val()
  alternative_id = alternative_id == undefined ? "" : alternative_id

  return "question="+ question_id + ";answer=" + alternative_id
}

function clearAnswers(){
  $("#all_respostas input[type=radio]").removeAttr("checked")
}
