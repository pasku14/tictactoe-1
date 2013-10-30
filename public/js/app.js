
$(function() {
  $(".cell").click(function(e) {
    $.get(e.srcElement.id, function(data) {
      console.log(data);
      if (data != 'illegal') {
        $(e.target).addClass("circle");
        $("#"+data).addClass( "cross" );
      }
      else {
        alert("Illegal move!")
      }
      //alert( "Load was performed." );
    });
  });
});

