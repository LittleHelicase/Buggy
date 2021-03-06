/** Taken from http://note19.com/2007/05/27/javascript-guid-generator/
  * Thank you!
  * Adapted for requirejs
  */


define(function(){
  return guid = (function() {
    function s4() {
      return Math.floor((1 + Math.random()) * 0x10000)
                 .toString(16)
                 .substring(1);
    }
    return function() {
      return s4() + s4() + '-' + s4() + '-' + s4() + '-' +
             s4() + '-' + s4() + s4() + s4();
    };
  })();
});