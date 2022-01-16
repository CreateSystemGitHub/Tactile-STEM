
window.onload = function() {
  speechSynthesis.onvoiceschanged = e => {
    tts_enable = appendVoices()
  }
}


//////////////////////////////////////////////////////
//    Mp3 player for main stream
//////////////////////////////////////////////////////

//var autoPlay = 0;
var tts_enable = false;
var v_scene = 0;
var v_names = new Array("","","","");
var v_rates  = new Array("0.8","0.8","0.8","0.8");
var v_pitchs = new Array("1.0","1.0","1.0","1.0");
var v_volums = new Array("0.7","0.7","0.7","0.7");
var v_mp3rate = 1.0;

//Hover_Enter effect sound
var effect_hover = false;


function audioVolumeSave(){
  var vol = document.getElementById("audio").volume;
  localStorage.setItem("audioVolume", vol.toString());
}

//再生開始
function audioPlay(){
  let elem = document.getElementById("playBtn");
  if (elem.value=="再生"){
    document.getElementById("audio").play();
  }
  else{
    document.getElementById("audio").pause();
  }
}

//再生開始した
function onPlay(){
  audioVolumeSave();
  document.getElementById("playBtn").value = "停止";
}
//再生停止した
function onPause(){
  audioVolumeSave();
  document.getElementById("playBtn").value = "再生";
}
//再生完了した
function onPlayEnded(folder, id, subpage){
  onPause();
}

import arrow0png from '../images/arrow_0.png';
import arrow0graypng from '../images/arrow_0_gray.png';
function onA4(button){
  var aa = document.getElementById('image-area');
  var bb = document.getElementById('imageFixBtn');
  var bb1 = document.getElementById('settingsBtnImg');
  var cc = document.getElementById('A4SettingBtn_IP');
  var dd = document.getElementById('A4SettingBtn_IM');
  var ee = document.getElementById('A4SettingBtn_TU');
  var ff = document.getElementById('A4SettingBtn_TD');
  var gg = document.getElementById('A4SettingBtn_LP');
  var hh = document.getElementById('A4SettingBtn_LM');
  var ii = document.getElementById('A4SettingBtn_HP');
  var jj = document.getElementById('A4SettingBtn_HM');
  var kk = document.getElementById('A4SettingBtn_WP');
  var ll = document.getElementById('A4SettingBtn_WM');
  if (bb.value=="絵固定"){
    //name is FIX ==> set to FIX mode, title=CENTER
    localStorage.setItem("A4_Display", 1);
    aa.className="show_image_Fix";   //set Fix form class
    bb.value="絵中央";
    bb1.src=arrow0png;
  }else{
    //name is CENTER ==> set to CENTER mode, title=FIX
    localStorage.setItem("A4_Display", 0);
    aa.className="show_image";         //set form fit class
    bb.value="絵固定";
    bb1.src=arrow0graypng;
  }
  cc.disabled=true;               //set Image+ button hidden
  dd.disabled=true;               //set Image- button hidden
  ee.disabled=true;               //set Top+ button hidden
  ff.disabled=true;               //set Top- button hidden
  gg.disabled=true;               //set Left+ button hidden
  hh.disabled=true;               //set Left- button hidden
  ii.disabled=true;               //set Height+ button hidden
  jj.disabled=true;               //set Height- button hidden
  kk.disabled=true;               //set Width+ button hidden
  ll.disabled=true;               //set Width- button hidden
  
  resizeImage();
  $('img[usemap]').rwdImageMaps();
}
function enableA4Setting(){
  console.log("enableA4Setting()");
  //Disabled?  Disableにすると枠が消えるのでボタンにはDisableをかけないので画像で判断する。
  var bb1 = document.getElementById('settingsBtnImg');
  if (bb1.src.endsWith("arrow_0_gray.png")) return;
  speakCancel();
  var cc = document.getElementById('A4SettingBtn_IP');
  var dd = document.getElementById('A4SettingBtn_IM');
  var ee = document.getElementById('A4SettingBtn_TU');
  var ff = document.getElementById('A4SettingBtn_TD');
  var gg = document.getElementById('A4SettingBtn_LP');
  var hh = document.getElementById('A4SettingBtn_LM');
  var ii = document.getElementById('A4SettingBtn_HP');
  var jj = document.getElementById('A4SettingBtn_HM');
  var kk = document.getElementById('A4SettingBtn_WP');
  var ll = document.getElementById('A4SettingBtn_WM');
  if (cc.disabled){
    cc.disabled=false;  //set Image+ button enable and visible
    dd.disabled=false;  //set Image- button enable and visible
    ee.disabled=false;  //set Top+ button enable and visible
    ff.disabled=false;  //set Top- button enable and visible
    gg.disabled=false;  //set Left+ button enable and visible
    hh.disabled=false;  //set Left- button enable and visible
    ii.disabled=false;  //set Heigt+ button enable and visible
    jj.disabled=false;  //set Height- button enable and visible
    kk.disabled=false;  //set width+ button enable and visible
    ll.disabled=false;  //set width- button enable and visible
  }else{
    cc.disabled=true;  //set Image+ button disable and invisible
    dd.disabled=true;  //set Image- button disable and invisible
    ee.disabled=true;  //set Top+ button disable and invisible
    ff.disabled=true;  //set Top- button disable and invisible
    gg.disabled=true;  //set Left+ button disable and invisible
    hh.disabled=true;  //set Left- button disable and invisible
    ii.disabled=true;  //set Height+ button disable and invisible
    jj.disabled=true;  //set Height- button disable and invisible
    kk.disabled=true;  //set Width+ button disable and invisible
    ll.disabled=true;  //set Width- button disable and invisible
  }
}
// Image size plus
function onA4Setting_plus(){
  var ppi = parseInt(localStorage.getItem("A4_DPI"), 10);
  if (isNaN(ppi)) ppi = 96;
  ppi = ppi + 1;
  if (ppi>400) ppi = 400;
  localStorage.setItem("A4_DPI", ppi);
  localStorage.setItem("A4_HEIGHT_OFFSET", 0);
  localStorage.setItem("A4_WIDTH_OFFSET", 0);
  resizeImage();
  $('img[usemap]').rwdImageMaps();
}
//  Image size minus
function onA4Setting_mins(){
  var ppi = parseInt(localStorage.getItem("A4_DPI"), 10);
  if (isNaN(ppi)) ppi = 96;
  ppi = ppi - 1;
  if (ppi < 10) ppi = 10;
  localStorage.setItem("A4_DPI", ppi);
  resizeImage();
  $('img[usemap]').rwdImageMaps();
}
//  Image height size plus
var addvalueH= 11.69/2;   //1dpiの半分
var addvalueW= 8.27/2;    //1dpiの半分
function onA4Setting_hplus(){
  var hoffset = parseInt(localStorage.getItem("A4_HEIGHT_OFFSET"), 10);
  if (isNaN(hoffset)) hoffset = 0;
  hoffset = hoffset + addvalueH;
  localStorage.setItem("A4_HEIGHT_OFFSET", hoffset);
  resizeImage();
  $('img[usemap]').rwdImageMaps();
}
//  Image width size minus
function onA4Setting_hmins(){
  var hoffset = parseInt(localStorage.getItem("A4_HEIGHT_OFFSET"), 10);
  if (isNaN(hoffset)) hoffset = 0;
  hoffset = hoffset - addvalueH;
  localStorage.setItem("A4_HEIGHT_OFFSET", hoffset);
  resizeImage();
  $('img[usemap]').rwdImageMaps();
}
//  Image width size plus
function onA4Setting_wplus(){
  var woffset = parseInt(localStorage.getItem("A4_WIDTH_OFFSET"), 10);
  if (isNaN(woffset)) woffset = 0;
  woffset = woffset + addvalueW;
  localStorage.setItem("A4_WIDTH_OFFSET", woffset);
  resizeImage();
  $('img[usemap]').rwdImageMaps();
}
//  Image width size minus
function onA4Setting_wmins(){
  var woffset = parseInt(localStorage.getItem("A4_WIDTH_OFFSET"), 10);
  if (isNaN(woffset)) woffset = 0;
  woffset = woffset - addvalueW;
  localStorage.setItem("A4_WIDTH_OFFSET", woffset);
  resizeImage();
  $('img[usemap]').rwdImageMaps();
}
//  Image top down
function onA4Setting_down(){
  var top = parseInt(localStorage.getItem("A4_TOP"), 10);
  if (isNaN(top)) top = 0;
  top = top + addvalueH;
  localStorage.setItem("A4_TOP", top);
  resizeImage();
  console.log('Top down=%d',top);
}
//  Image top up
function onA4Setting_up(){
  var top = parseInt(localStorage.getItem("A4_TOP"), 10);
  if (isNaN(top)) top = 0;
  top = top - addvalueH;
  if (top < -50 ) top = -50;
  localStorage.setItem("A4_TOP", top);
  resizeImage();
  console.log('Top up=%d',top);
}
//  Image left++
function onA4Setting_right(){
  var left = parseInt(localStorage.getItem("A4_LEFT"), 10);
  if (isNaN(left)) left = 0;
  left += addvalueW;
  localStorage.setItem("A4_LEFT", left);
  resizeImage();
  console.log('Left=%d',left);
}
//  Image left--
function onA4Setting_left(){
  var left = parseInt(localStorage.getItem("A4_LEFT"), 10);
  if (isNaN(left)) left = 0;
  left -= addvalueW;
  localStorage.setItem("A4_LEFT", left);
  resizeImage();
  console.log('Left=%d',left);
}



//
//  Windowのサイズ変更時に aspect ratio を変えないでimageサイズを変更する
//
function resizeImage(){
  var v_A4 = parseInt(localStorage.getItem("A4_Display"),10);
  if (isNaN(v_A4)) v_A4 = 0;
  if (v_A4==0) {
    //画面サイズにフィットする
    var h1 = window.innerHeight - 80  //minus btn-height 
    var w1 = window.innerWidth - 16;  //minus show-margin left,right
    var h3 = h1;
    var w3 = w1;
    if (h1 > w1) {
      h3 = w1*1.444;
      if (h3 < h1){
        w3 = w1;
      }
      else{
        h3 = h1;
        w3 = h1/1.444;
      }
    }
    else{ // h1 <= w1
      w3 = h1 / 1.444;
      if (w3 < w1){
        h3 = h1;
      }
      else{
        w3 = w1;
        h3 = w1 * 1.444;
      }
    }
    var aa = document.getElementById('image-area');
    aa.style.height = h3 + 0 +'px';
    aa.style.width = w3 + 0 +'px';
    //console.log("image w=%d,h=%d",w3,h3);
    return;
  } 
  //Image max siae = 720 x 1040
  //A4 固定画面 21cm X 29.7cm  8.27inch X 11.69inch   1inch=2.54cm
  //72 dpi (web) = 595 X 842 pixels   620x896
  //96 dpi = 794 X /1122
  //300 dpi (print) = 2480 X 3508 pixels
  //600 dpi (high quality print) = 4960 X 7016 pixels
  var h2 = 1040;
  var w2 = 720;
  var dpi = localStorage.getItem("A4_DPI");
  var top = localStorage.getItem("A4_TOP");
  var left = localStorage.getItem("A4_LEFT");
  var width_offset = localStorage.getItem("A4_WIDTH_OFFSET");
  var height_offset = localStorage.getItem("A4_HEIGHT_OFFSET");
  
  var ppi = parseInt(dpi, 10);
  var t2 = parseInt(top, 10);
  var l2 = parseInt(left, 10);
  var woff2 = parseInt(width_offset, 10);
  var hoff2 = parseInt(height_offset, 10);

  if (isNaN(ppi)) ppi = 152;
  if (ppi > 400) ppi = 152;
  if (ppi < 10)  ppi = 152;
  var scale = window.devicePixelRatio;
  var aa = document.getElementById('image-area');
//  h2 = ppi/scale*11.69 + 84 + hoff2;
//  w2 = ppi/scale*8.27 + 16 + woff2;
  h2 = ppi/scale*11.69 + hoff2;
  w2 = ppi/scale*8.27 + woff2;
  aa.style.height = h2 + 'px';
  aa.style.width = w2 + 'px';
  aa.style.top = t2 +'px';
  aa.style.left = l2 + 'px';
  //console.log("class=%s,ppi=%d,image w=%d,h=%d,t=%d,l=%d,hf=%d,wf=%d",aa.className,ppi,w2,h2,t2,l2,hoff2,woff2);
}


//////////////////////////////////////////////////////
//    2'nd Mp3 player for click or hover
//  自動再生機能ポリシーで許可を取っておくこと
//////////////////////////////////////////////////////
var mp3 = null;
function audioPlay2(src, start, stop){
  let tm;
  //console.log(src+",start="+start+",stop="+stop);
  var strtTime = Number(start);
  var stopTime = Number(stop);
  if (strtTime == NaN) strtTime=0;
  if (stopTime == NaN) stopTime=0;
  //以下は再生が途中で止まってしまう時がある。
  //  var mp3 = document.getElementById("audio2");
  if (mp3!=null && !mp3.paused){
    clearTimeout(tm);
    mp3.pause();
    mp3.currentTime=0;
    //console.log(src+",AAAAA:mp3.paused");
  }
  //以下だと再生が最後まで行われた。
  mp3 = new Audio();
  mp3.src = src;
  mp3.load();
  if (mp3.readyState == 4) {
    //console.log(src+",BBBB:mp3.readyState == 4");
    mp3.currentTime = start/1000;
    mp3.play();
    if (stopTime != 0){
      tm = setTimeout(function(){
        //console.log(src+",BBBB:mp3.timeout then pause");
        clearTimeout(tm);
        mp3.pause();
        mp3.currentTime = 0;
      }, stopTime-strtTime);
    }
  }
  else {
    mp3.addEventListener('canplaythrough', function (e) {
      //mp3.removeEventListener('canplaythrough', arguments.callee);
      mp3.currentTime = strtTime/1000.0;
      mp3.playbackRate = v_mp3rate;
      mp3.play();
      //console.log(src+",CCCC:mp3.play()");
      if (stopTime != 0){
        tm = setTimeout(function(){
          //console.log(src+",CCCC:mp3.timeout the pause");
          clearTimeout(tm);
          mp3.pause();
          mp3.currentTime = 0;
        }, stopTime-strtTime);
      }
    });
    mp3.addEventListener('ended',function (e) {
      //console.log(src+",CCCC:mp3.ended");
      mp3 = null;
    });
    mp3.addEventListener('waiting',function (e) {
      //console.log(src+",CCCC:mp3.waiting:"+mp3.readyState);
    });
    mp3.addEventListener('error',function (e) {
      //console.log(src+",CCCC:mp3.error:"+e.currentTarget.error.code);
      mp3 = null;
    });
  }
}

//////////////////////////////////////////////////////
//    3'rd Mp3 player for hover enter
//////////////////////////////////////////////////////
function effectPlay_enter(clipboard){
  if (clipboard.length ==0){
    document.getElementById("effect_sound_enter").play();
  }
  else{
    document.getElementById("effect_sound_enter2").play();
  }
  console.log("effectPlay_enter")
}


//////////////////////////////////////////////////////
//    Web Speech API WC3
//////////////////////////////////////////////////////
function speechEnabled(){
  if ('speechSynthesis' in window) {
    return true;
  } else {
    alert("このブラウザは音声合成に対応していません。😭");
  }
  return false;
}


function appendVoices(){
  if (!speechEnabled()) return false;
  load_tts_param();
  const voices = speechSynthesis.getVoices()
  if (voices.length == 0) return false;
  var dt = null;
  var dt1 = null;
  var uttr = new SpeechSynthesisUtterance();
  var voice = speechSynthesis.getVoices().find(function(voice){
    return voice.name === v_names[v_scene];
  });
  if (voice){
    if (voice.name == "Takashi")      dt = voice;
    else if (voice.name == "Keiko")   dt = voice;
    else if (voice.name == "Taro")    dt = voice;
    else if (voice.name == "Hanako")  dt = voice;
    else if (voice.name == "たかし")   dt = voice;
    else if (voice.name == "けいこ")   dt = voice;
    else if (voice.name == "太郎")     dt = voice;
    else if (voice.name == "花子")     dt = voice;
    else if (voice.name == "日本語 日本") dt = voice;
    uttr.voice = voice;
  };
  if (dt != null) {
    //ドキュメントトーカあり
    //ユーザー辞書登録
    //alert(dt.name)
    addUserDict(dt, "触読器", "しょくど^くき");
    addUserDict(dt, "保己一", "ほき^いち");
    addUserDict(dt, "突起物", "とっき^ぶつ");
    addUserDict(dt, "感覚野", "かんか^くや");
    addUserDict(dt, "運動野", "うんど^ーや");
    addUserDict(dt, "体部位", "たいぶ^い");
    addUserDict(dt, "観測台", "かんそくだい");
    addUserDict(dt, "黄道", "こーどー");
    addUserDict(dt, "正多角形", "せーたか^っけー");
    addUserDict(dt, "凸多角形", "とつたか^っけー");
    addUserDict(dt, "凹多角形", "おうたか^っけー");
    addUserDict(dt, "正四角形", "せーしか^っけー");
    addUserDict(dt, "正五角形", "せーごか^っけー");
    addUserDict(dt, "正六角形", "せーろっか^っけー");
    addUserDict(dt, "正七角形", "せーななか^っけー");
    addUserDict(dt, "正八角形", "せーはちか^っけー");
    addUserDict(dt, "凸頂点", "とつちょ^ーてん");
    addUserDict(dt, "凹頂点", "おうちょ^ーてん");
    addUserDict(dt, "右半身", "みぎは^んしん");
    addUserDict(dt, "左半身", "ひだりは^んしん");
    addUserDict(dt, "正積方位図", "せいせきほーい^ず");
    addUserDict(dt, "ＬＡＴＥＸ", "ラテフ");
    addUserDict(dt, "ラテフ", "ラテフ");
    addUserDict(dt, "開区間", "かいく^かん");
    addUserDict(dt, "閉区間", "へいく^かん");
    addUserDict(dt, "３乗根", "さんじょ^ーこん");
    addUserDict(dt, "結合則", "けつご^ーそく");
    
  }
  else{
    //alert("Dtalker not found")
  }
  return true;
}

function addUserDict(dt, kanj, yomi){
  var text = "＜登録：" + kanj + "：" + yomi + "＞";
  const uttr = new SpeechSynthesisUtterance(text)
  uttr.voice = dt;
  speechSynthesis.speak(uttr);
}


function speak(text){
  if (!tts_enable) {
    tts_enble = appendVoices();
  }
  //alert("Speak:"+text+"folder:"+folder+",id="+id);
  let elem = document.getElementById("playBtn");
  if (elem.value=="Speak"){
    //再生開始
    //elem.value = "Stop";
    if (speechSynthesis.paused){
      speechSynthesis.resume();
      return
    }
    //最初から再生
    speechSynthesis.cancel()
    const uttr = new SpeechSynthesisUtterance(text)
    if (v_names[v_scene]  != null) {
      uttr.voice = speechSynthesis.getVoices().filter(voice => voice.name === v_names[v_scene])[0];
    }
    if (v_rates[v_scene]  != null) uttr.rate   = v_rates[v_scene];
    if (v_pitchs[v_scene] != null) uttr.pitch  = v_pitchs[v_scene];
    if (v_volums[v_scene] != null) uttr.volume = v_volums[v_scene];
    speechSynthesis.speak(uttr);
    uttr.addEventListener("start", () => {elem.value = "Stop"});
    uttr.addEventListener("pause", () => {elem.value = "Speak"});
    uttr.addEventListener("resume", () => {elem.value = "Stop"});
    uttr.addEventListener("end",   ()  => {elem.value = "Speak";});
    return;
  }
  //停止ボタン
  //elem.value = "Start";
  if (speechSynthesis.paused){
    speechSynthesis.cancel();
    return;
  }
  if (speechSynthesis.speaking){
    speechSynthesis.pause();
    return;
  }

}

function speakCancel(){
  speechSynthesis.cancel()
}
function speakPause(){
  speechSynthesis.pause()
}
function speakResume(){
  speechSynthesis.resume()
}

function load_tts_param(){
  var aa = localStorage.getItem("voiceVoice");
  if (aa != null ) v_names = aa.split(",");
  var bb = localStorage.getItem("voiceRate");
  if (bb != null ) v_rates = bb.split(",");
  var cc = localStorage.getItem("voicePitch");
  if (cc != null ) v_pitchs = cc.split(",");
  var dd = localStorage.getItem("voiceVolum");
  if (dd != null ) v_volums = dd.split(",");
  var ee = localStorage.getItem("mp3Rate");
  if (ee != null ) v_mp3rate = ee;
/*
  console.log("load_tts_param():voice="+v_names[0]+","+v_names[1]+","+v_names[2]+","+v_names[3]);
  console.log("load_tts_param():rates="+v_rates[0]+","+v_rates[1]+","+v_rates[2]+","+v_rates[3]);
  console.log("load_tts_param():pitchs="+v_pitchs[0]+","+v_pitchs[1]+","+v_pitchs[2]+","+v_pitchs[3]);
  console.log("load_tts_param():volums="+v_volums[0]+","+v_volums[1]+","+v_volums[2]+","+v_volums[3]);
*/
}

///////////////////////////////////////////////////////////////////////////////
//  Enter image map
//  speak or play immediately on click or hover
// sound: target=mp3,start_time,stop_time   play mp3
// sound: target=mp3,TTS1 Jp default        Speak with TTS1, mp3s are ignored.
// sound: target=mp3,TTS2 Jp                Speak with TTS2, mp3s are ignored.
// sound: target=mp3,TTS3 English Male      Speak with TTS3, mp3s are ignored.
// sound: target=mp3,TTS4 English Female    Speak with TTS4, mp3s are ignored.
///////////////////////////////////////////////////////////////////////////////
function speakOne(path, text, sound, clipboard, click){
  console.log("speakOne:path=%s,sound=%s,clipboard=%s,click=%d",path,sound,clipboard,click);
  if (click==0){
    if (effect_hover) effectPlay_enter(clipboard);
    return;
  }
  //Clipboard file serch
  if (clipboard!=null && clipboard.length>0){
    var filename = path + clipboard
    if (filename.length > 0){
      readTextFileToClipboard(filename);
    }
  }
  v_scene = 0;
  if (sound!=null && sound.length>0){
    var sound1 = sound.split(',');
    if (sound1[1] == 'TTS'  || sound1[1] == 'TTS1' ||
        sound1[1] == 'TTS2' || sound1[1] == 'TTS3' || sound1[1] == 'TTS4'){
        //TTS Playing
    } else{
      //mp3 playing
      var filename = path + sound1[0] + ".mp3"
      if (sound1.length ==3){
        //alert("start="+sound1[1]+",stop="+sound1[2])
        audioPlay2(filename,sound1[1],sound1[2]);
        return;
      }
      if (sound1.length !=2){
        audioPlay2(filename, 0, 0);
        return;
      }
    }
    //TTS(1-4)
    if (!tts_enable) {
      tts_enble = appendVoices();
    }
    if (sound1[1] == "TTS")  v_scene = 0;
    if (sound1[1] == "TTS1") v_scene = 0;
    if (sound1[1] == "TTS2") v_scene = 1;
    if (sound1[1] == "TTS3") v_scene = 2;
    if (sound1[1] == "TTS4") v_scene = 3;
  //console.log("speakOne():tts_enable="+tts_enable+",sound="+sound1[1]+",v_scene="+v_scene);
  }
  speechSynthesis.cancel()
  const uttr = new SpeechSynthesisUtterance(text)
  if (v_names[v_scene]  != null) {
    uttr.voice = speechSynthesis.getVoices().filter(voice => voice.name === v_names[v_scene])[0];
  }
  if (v_rates[v_scene]  != null) uttr.rate   = v_rates[v_scene];
  if (v_pitchs[v_scene] != null) uttr.pitch  = v_pitchs[v_scene];
  if (v_volums[v_scene] != null) uttr.volume = v_volums[v_scene];
  speechSynthesis.speak(uttr);
  return false;
}


////////////////////////////////////////////////
// QR Code reader
////////////////////////////////////////////////
var stopFlag = false;
var video;
var timer;
function camera(folder){
  if (stopFlag){
    //alert("Playing");
    if (video) video.pause();
    if (timer) clearInterval(timer);
    stopFlag = false;
    location.reload();
    return;
  } else{
    stopFlag = true;
  }

  var target = document.getElementById('camera-target');
  target.classList.toggle('mokuji-camera');
  //var vw = target.width;
  //var vh = target.height;
  var vw = 300;
  var vh = 300;
  //alert("w="+vw+",h="+vh+","+target);
  const constraints = { audio: false, video: { facingMode: 'environment', width:vw, height:vh}};
  //const constraints = { audio: false, video: { facingMode: 'environment'}};
  //iPhone で動作しなかったが以下の追加で safari は動作したが、chrome は画面が黒のまま。 
  navigator.getUserMedia = navigator.getUserMedia || navigator.webkitGetUserMedia || window.navigator.mozGetUserMedia;
  //  window.URL = window.URL || window.webkitURL;
  navigator.mediaDevices.getUserMedia(constraints).then((stream) => {
    video = document.querySelector('video');
    video.srcObject = stream;
    video.play();

    const w = constraints.video.width, h = constraints.video.height;
    const canvas = document.createElement('canvas');
    canvas.width = w;
    canvas.height = h;
    const context = canvas.getContext('2d');

    timer = setInterval(() => {
      context.drawImage(video, 0, 0, w, h);
      const imageData = context.getImageData(0, 0, w, h);
      const code = jsQR(imageData.data, imageData.width, imageData.height);
      if (code) {
        const textContent = code.data;
        //alert("Found QR Code:"+textContent )
        //SYKZ_ID=HH,HH-2.wav
        if (textContent.indexOf("SYKZ_ID=")==0){
          const words = textContent.split(",");
          const folders = words[0].split("=");
          if (folders[1]==folder) {
            clearInterval(timer);
            const fnames = words[1].split("."); 
            video.pause();
            location.href = "../tactile/show?book=" + folder + "&pid=0&spid=0&fn=" + fnames[0];
            return;
          }
          else{
            alert("本が違います。");
            if (video) video.pause();
            if (timer) clearInterval(timer);
            stopFlag = false;
            location.reload();
            return;
          }
        }
      }
    }, 300);
  }).catch((e) => {
    console.log('load error', e);
  });
}

// copy to Clipboard
//  HTML上にテキストエリアを仮に作りそこにデータを移す。
//  execCommandがdeprecatedなので書き直しが必要
function copyTextToClipboard(textVal){
  var copyFrom = document.createElement("textarea");
  copyFrom.textContent = textVal;
  var bodyElm = document.getElementsByTagName("body")[0];
  bodyElm.appendChild(copyFrom);
  copyFrom.select();  // テキストエリアの値を選択
  var retVal = document.execCommand('copy');  // コピーコマンド発行
  bodyElm.removeChild(copyFrom);
  return retVal;
}

function loadTextFile(fName){
  var xmlhttp = new XMLHttpRequest();
  xmlhttp.onload = function() {
    if (xmlhttp.readyState == 4) {
      if (xmlhttp.status == 200) { 
        //console.log("file="+fName+",status = " + xmlhttp.status);
        if (xmlhttp.responseURL.endsWith('.ltx') || xmlhttp.responseURL.endsWith('.pyt')){
          copyTextToClipboard(xmlhttp.responseText);
        }
      }
    }
  }
  xmlhttp.open("GET", fName);
  xmlhttp.send();
}

function  readTextFileToClipboard(sfile){
  loadTextFile(sfile);
}


//
window.audioPlay = audioPlay;
window.onPlay = onPlay;
window.onPause = onPause;
window.onPlayEnded = onPlayEnded;

window.onA4 = onA4;
window.speakOne = speakOne;
window.enableA4Setting = enableA4Setting
window.onA4Setting_plus = onA4Setting_plus;
window.onA4Setting_mins = onA4Setting_mins;
window.onA4Setting_hplus = onA4Setting_hplus;
window.onA4Setting_hmins = onA4Setting_hmins;
window.onA4Setting_wplus = onA4Setting_wplus;
window.onA4Setting_wmins = onA4Setting_wmins;
window.onA4Setting_down = onA4Setting_down;
window.onA4Setting_up = onA4Setting_up;
window.onA4Setting_right = onA4Setting_right;
window.onA4Setting_left = onA4Setting_left;

window.resizeImage = resizeImage;
window.audioPlay2 = audioPlay2;
window.effectPlay_enter = effectPlay_enter;
window.speechEnabled = speechEnabled;
window.appendVoices = appendVoices;
window.speak = speak;
window.speakCancel = speakCancel;
window.load_tts_param = load_tts_param;
window.camera = camera;
