function SourceOfTits() {
  var settings = {
    user_token: '',
    endpoint: 'http://tits.spiridonov.pro/tits'
  };

  this.process = function(link) {
    var xhr = new XMLHttpRequest();
    xhr.onreadystatechange = function(data) {};
    xhr.open('POST', settings.endpoint, true);
    xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
    xhr.send('link=' + link);
    console.log(link);
  }
}

function getClickHandler() {
  return function(info, tab) {
    tits.process(info.srcUrl);
  };
};

chrome.contextMenus.create({
  "title" : "Source of tits (Dev)",
  "type" : "normal",
  "contexts" : ["image"],
  "onclick" : getClickHandler()
});

var tits = new SourceOfTits();