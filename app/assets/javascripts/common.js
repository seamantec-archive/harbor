setFormErrors();


$('.content').css('min-height', $(document).height() - $('#footer').outerHeight(true) - $('.navbar-fixed-top').outerHeight(true));


$('[data-toggle=offcanvas]').click(function () {
    $('.row-offcanvas').toggleClass('active');
});


$(".video-link").magnificPopup({type: "iframe"})

$("#accept-cookie").click(function () {
    $.ajax({
        type: "POST",
        dataType: "json",
        url: "/accept_cookie",
        success: function (data) {
            $(".cookie-notification").hide();
        }
    })
})

function setFormErrors() {
    $($(".form-group:has(.label-form-error)")).addClass("has-error");
}


$("#video_link").on("click", function () {
    ga('send', 'event', 'intro_video_n', 'start', this.href);
    var start_time = new Date();
    $(".mfp-close").on('click', function () {
        ga('send', 'event', 'intro_video_n', 'close', (new Date() - start_time) / 1000);
    });
    $(".mfp-s-ready").on('click', function () {
        ga('send', 'event', 'intro_video_n', 'close', (new Date() - start_time) / 1000);
    });
});

$("#ios_button").on('click', function () {
    ga('send', 'event', 'ios_store', 'click');
});

$("#android_button").on('click', function () {
    ga('send', 'event', 'ios_store', 'click');
});

$("#polar_video_link").on("click", function () {
    ga('send', 'event', 'polar_video_click', 'start', this.href);
    var start_time = new Date();
    $(".mfp-close").on('click', function () {
        ga('send', 'event', 'polar_video_click', 'close', (new Date() - start_time) / 1000);
    });
    $(".mfp-s-ready").on('click', function () {
        ga('send', 'event', 'polar_video_click', 'close', (new Date() - start_time) / 1000);
    });
})
function setMenuTypeDependOnScroll() {
    var navbar = $('#navbar');
    var top = $("#top")
    if (top.length == 0) {
        return;
    }
    if ($(window).scrollTop() >= top.offset().top + top.height()) {
        if (navbar.hasClass("navbar-static-top")) {
            navbar.removeClass("navbar-static-top");
            navbar.removeClass("navbar-custom-static");
        }
        if (!navbar.hasClass("navbar-fixed-top")) {
            navbar.addClass("navbar-fixed-top");
        }
    } else {
        if (navbar.hasClass("navbar-fixed-top")) {
            navbar.removeClass("navbar-fixed-top")
        }
        if (!navbar.hasClass("navbar-static-top")) {
            navbar.addClass("navbar-static-top");
        }
        if (!navbar.hasClass("navbar-custom-static")) {
            navbar.addClass("navbar-custom-static");
        }
    }
}
var hasOnceScrolledDown = false
$(window).scroll(function () {
    setMenuTypeDependOnScroll()
    if ($("#first-feature").length > 0 && $(window).scrollTop() + $(window).height() >= $("#first-feature").offset().top) {
        if (!hasOnceScrolledDown) {
            ga('send', 'event', 'scroll_down', 'left_demo_btn');
            hasOnceScrolledDown = true;
        }
    }
});


function setCarouselHeight() {
    var height = $(window).height();
    if (height < 500) {
        height = 500;
    } else if (height > 800) {
        height = 800;
    }
    $(".full-page-feature").css("height", height);
}
setCarouselHeight();

$('.carousel').carousel({
    "pause": "false",
    "interval": 13500
})
$(window).bind("resize", function () {
    setCarouselHeight();
});

$(".learn-more").click(function () {
    $('html,body').animate({
        scrollTop: $("#first-feature").offset().top - 40
    });
})

function setPasswordVisible() {
    if ($(".password-fields").length > 0) {
        if ($("#sign_up")[0].checked) {
            $(".password-fields").show()
        } else {
            $(".password-fields").hide()
        }
    }
}
setPasswordVisible()
$("#sign_up").click(function () {
    $(".password-fields").toggle(this.checked);
});

$(".datepicker").datepicker({
    "dateFormat": "yy-mm-dd"
});