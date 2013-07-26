window.URL = window.URL || window.webkitURL;
navigator.getUserMedia  = navigator.getUserMedia || navigator.webkitGetUserMedia || navigator.mozGetUserMedia || navigator.msGetUserMedia;

var video = document.querySelector('video');
var canvas = document.querySelector('canvas');
var logo = document.querySelector('#logo');
var take_pic = document.querySelector('#take_pic');
var countdown = document.querySelector('#countdown');
var poloroid = document.querySelector('#poloroid');
var ctx = canvas.getContext('2d');
var localMediaStream = null;

function snapshot() {
  if (localMediaStream) {
    ctx.drawImage(video, -79, 20);
    ctx.drawImage(logo, 30, 30);
    ctx.drawImage(poloroid, 0, 0);

    var text = document.querySelector('#title').innerText;
    var width = ctx.canvas.width;
    ctx.fillStyle = "black";
    ctx.font = '18pt Garamond, Baskerville, "Baskerville Old Face", "Hoefler Text", "Times New Roman", serif';
    ctx.textAlign = "center";
    ctx.fillText(text, width/2, 550);
    // "image/webp" works in Chrome 18. In other browsers, this will fall back to image/png.
    document.querySelector('#final').src = canvas.toDataURL('image/webp');
    document.querySelector('#final').style.setProperty('display', 'block');
    document.querySelector('#wrapper').style.setProperty('display', 'none');
    take_pic.innerText = 'Take another Picture';
    take_pic.style.setProperty('display', 'block');
  }
}

function takePic() {
  countdown.style.setProperty('display', 'block');
  document.querySelector('#wrapper').style.setProperty('display', 'block');
  document.querySelector('#final').style.setProperty('display', 'none');
  take_pic.style.setProperty('display', 'none');
  count = 3;
  countdown.innerText = count;
  var intervalId = setInterval(function() {
    count--;
    countdown.innerText = count;
    if(count === 0) {
      countdown.style.setProperty('display', 'none');
      snapshot();
      clearInterval(intervalId);
    }
  }, 1000);
}

take_pic.addEventListener('click', takePic);

if (navigator.getUserMedia) {
  take_pic.style.setProperty('display', 'block');

// Not showing vendor prefixes or code that works cross-browser.
navigator.getUserMedia({video: true}, function(stream) {
  video.src = window.URL.createObjectURL(stream);
  localMediaStream = stream;
}, function(){ alert('failed')});} else {
  alert('not supported'); // fallback.
}
