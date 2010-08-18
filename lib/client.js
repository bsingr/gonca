(function(){

  Gonca = window.Gonca = {
    remaining: []
  };

  jQuery('body')
    .append('<div class="gonca"> </div>')
    .append('<div class="jspec"><div id="jspec"></div></div>');

  Gonca.runSuites = function(){
    var content = jQuery('.gonca').find('.content').html();
    eval('with (JSpec){'+ JSpec.preprocess(content) +'}');
	  JSpec
	   .run({ fixturePath: 'fixtures' })
	   .report();
  };

  Gonca.asyncXSS = function(url, callback) {
	  var head = document.getElementsByTagName("head")[0];
    var newScript = document.createElement('script');
    newScript.type = 'text/javascript';
    var blocker = true;
    newScript.onload = function(){
	    jQuery(newScript).remove();
	    callback();
	  };
    newScript.src = "http://localhost:9887/file/"+url;
    head.appendChild(newScript);
    return Gonca;
  };

  Gonca.syncXSS = function(url, callback) {
    if (url) {
      Gonca.remaining.push([url, callback]);
    }
    if(Gonca.remaining.length) {
      var current = Gonca.remaining.shift();
      Gonca.asyncXSS(current[0], function(){
        if (current[1]) {
          current[1]();
        }
        Gonca.chain();
      });
    }
    return Gonca;
  };

  Gonca
    .syncXSS('jspec.js')
    .syncXSS('jspec.xhr.js')
    .syncXSS('jspec.timers.js')
    .syncXSS('jspec.jquery.js');

})();
