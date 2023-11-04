Printer = {}

$(document).ready(function(){
    window.addEventListener('message', function(event){
        var action = event.data.action;

        switch(action) {
            case "open":
                Printer.Open(event.data);
                break;
            case "start":
                Printer.Start(event.data);
                break;
            case "close":
                Printer.Close(event.data);
                break;
        }
    });
});

$(document).ready(function() {
    $('.printer-accept').click(function() {
        Printer.Save();
        Printer.Close();
    });
    $('.printer-decline').click(function() {
        Printer.Close();
    });
});

$(document).on('keydown', function() {
    switch(event.keyCode) {
        case 27: // ESC
            Printer.Close();
            break;
        case 9: // ESC
            Printer.Close();
            break;
    }
});

Printer.Open = function(data) {
    if (data.url) {
        $(".document-container").fadeIn(150);
        $(".document-image").attr('src', data.url);
    } else {
        console.log('No document is linked to it!!!!!')
    }
}

Printer.Start = function(data) {
    $(".printer-container").fadeIn(150);
}

Printer.Save = function(data) {
    $.post('https://wp-placeables/SaveDocument', JSON.stringify({
        url: $('.printer-input').val()
    }));
}

Printer.Close = function(data) {
    $(".printer-container").fadeOut(150);
    $(".document-container").fadeOut(150);
    $.post('https://wp-placeables/CloseDocument');
}