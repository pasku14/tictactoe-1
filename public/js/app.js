
// add js for game here

$(function() {
  var moves = ["circle","cross"]
  $(".cell").click(function(e) {
    $(e.target).addClass("circle");
    $.get(e.srcElement.id, function(data) {
      console.log(data);
      $("#"+data).addClass( "cross" );
      //alert( "Load was performed." );
    });
  });
});

