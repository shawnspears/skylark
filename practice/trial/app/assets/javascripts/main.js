$(document).ready(function(){

  $('.directUpload').find("input:file").each(function(i, elem) {
    var fileInput = $(elem);
    console.log(fileInput);
  });


});