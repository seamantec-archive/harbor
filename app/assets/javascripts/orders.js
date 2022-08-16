setPaymentMethodSectionVisible()


function updatePaymentDetails(data) {
    $(".product_items_value").text(data.new_net_value)
    $(".product_vat_value").text(data.new_vat_value)
    $(".product_total_value").text(data.new_total_value)
    $(".vat_percent").text(data.new_vat_percent)
}

function sendVatValidation() {
    $.ajax({
        dataType: "json",
        url: "/orders/validate_vat_id",
        data: {vat_id: $("#company_info_vat_id").val(), country: $("#billing_address_country").val()},
        success: function (data) {
            updatePaymentDetails(data)
        }
    })
}
$("#order_number_of_items").blur(function () {
    $.ajax({
        dataType: "json",
        url: "/orders/refresh_number_of_items",
        data: {number_of_items: $("#order_number_of_items").val()},
        success: function (data) {
            updatePaymentDetails(data);
        }
    });
});

$(".vat_id_validation_trigger").blur(function () {
    sendVatValidation()
});
$(".vat_id_validation_trigger").change(function () {
    sendVatValidation()
});


$('.right-tooltip').tooltip({
    html: true,
    placement: "right"
})
$('.left-tooltip').tooltip({
    html: true,
    placement: "left"
})

$('#what-is-paypal').tooltip({
    html: true,
    placement: 'right',
    trigger: 'click',
    container: 'body'
});


//---- payment ---
$('.payment-method-control').click(function (e) {
    setPaymentMethodSectionVisible()
});

function setPaymentMethodSectionVisible() {
    if ($("#payment_method_braintree").is(':checked')) {
        $(".credit_card_section").show();
        $(".paypal_section").hide();
    } else if ($("#payment_method_paypal").is(':checked')) {
        $(".credit_card_section").hide();
        $(".paypal_section").show();
    }
}


function validateCreditCard() {
    var field = $('#card_number')
    number = field.val()
    number = number.replace(/\D/g, "");
    var valid = false;
    if (number.length > 12 && number.length < 20) {
        valid = true;
    }

    // accept only digits, dashes or spaces
    if (/[^0-9-\s]+/.test(number)) valid = false;

    // The Luhn Algorithm. It's so pretty.
    var nCheck = 0, nDigit = 0, bEven = false;

    for (var n = number.length - 1; n >= 0; n--) {
        var cDigit = number.charAt(n),
            nDigit = parseInt(cDigit, 10);

        if (bEven) {
            if ((nDigit *= 2) > 9) nDigit -= 9;
        }

        nCheck += nDigit;
        bEven = !bEven;
    }

    valid = valid && (nCheck % 10) == 0;
    addRemoveErrorClassForField(field, valid)

    return valid

}

function addRemoveErrorClassForField(field, valid) {
    if (valid) {
        field.closest(".form-group").removeClass("has-error")
    } else {
        field.closest(".form-group").addClass("has-error")

    }
}

function validateExpirationDate() {
    var monthValid = $("#expiration_month").val() != " ";
    var yearValid = $("#expiration_year").val() != " "
    addRemoveErrorClassForField($("#expiration_month"), monthValid)
    addRemoveErrorClassForField($("#expiration_year"), yearValid)
    return monthValid && yearValid;
}


$("#card_number").keyup(function (e) {
    var val = $("#card_number").val().replace(/\D/g, "")
    val = val.replace(/(.{4})/g, "$1 ")
    if (val.charAt(val.length - 1) == " ") val.replaceAt(val.length - 1, "")
    $("#card_number").val(val)
})

$("#card_number").blur(function (e) {
    validateCreditCard();
})
$("#expiration_year, #expiration_month").change(function (e) {
    validateExpirationDate();
});

function validateCvv() {
    var valid = $("#cvv").val() != "";
    addRemoveErrorClassForField($("#cvv"), valid)
    return valid
}

$("#cvv").blur(function () {
    validateCvv()
})
function validateCardHolder() {
    var valid = $("#cardholder_name").val() != "";
    addRemoveErrorClassForField($("#cardholder_name"), valid)
    return valid
}
$("#cardholder_name").blur(function () {
    validateCardHolder()
})
function validatePostalCode() {
    var valid = $("#postal_code").val() != "";
    addRemoveErrorClassForField($("#postal_code"), valid)
    return valid
}
$("#postal_code").blur(function () {
    validatePostalCode()
})


function validateCountryCode() {
    var countryCode = $("#country_code").val() != " ";
    addRemoveErrorClassForField($("#country_code"), countryCode)
    return countryCode;
}

$("#country_code").change(function (e) {
    validateCountryCode();
});


//braintree.setup($("#braintree-token").val(), "custom", {
//    id: "checkout",
//    paypal: {
//        container: "paypal-button",
//        paymentMethodNonceInputField: "paypal-nonce",
//        onSuccess: function(e){
//            $("#pay-with-paypal-btn").show();
//        },
//        onCancelled: function(e){
//            $("#pay-with-paypal-btn").hide();
//        }
//    }
//});


function payWithCreditCard() {
    var token = $("#braintree-token").val()
    var client = new braintree.api.Client({clientToken: token });
    var form = $('#checkout');
    var cardValid = validateCreditCard()
    var expValid = validateExpirationDate()
    var cvvValid = validateCvv()
    var cardHolderValid = validateCardHolder()
    var cardPostalCode = validatePostalCode()
    var cardCountry = validateCountryCode()
    if (!cardValid || !expValid || !cvvValid || !cardHolderValid || !cardPostalCode || !cardCountry) {
        console.log("form is not valid");
        return false;
    }
    $("#pay_button, #card_number, #expiration_month, #expiration_year, #cardholder_name, #cvv,#postal_code, #country_code").prop('disabled', true);

    client.tokenizeCard(
        {
            number: $('#card_number').val().replace(/\D/g, ""),
            expirationMonth: $('#expiration_month').val(),
            expirationYear: $('#expiration_year').val(),
            cardholderName: $('#cardholder_name').val(),
            cvv: $('#cvv').val(),
            billingAddress: {
                postalCode: $('#country_code').val(),
                countryCodeAlpha2: $('#country_code').val()
            }
        },

        function (err, nonce) {
            console.log(err);
            console.log(nonce);
            submitFormWithNonce(nonce)

        })
}
function submitFormWithNonce(nonce) {
    console.log("SUBMIT FORM")
    var url = $("#checkout").attr("action");
    var auth_token = $("#checkout").find("[name='authenticity_token']").val()
    var form = $('<form action="' + url + '" method="post">' +
        '<input type="text" name="nonce" value="' + nonce + '" />' +
        '<input type="text" name="payment_method" value="' + $("input:radio[name ='payment_method']:checked").val() + '" />' +
        '<input type="text" name="order_id" value="' + $("#order_id").val() + '" />' +
        '<input name="authenticity_token" type="hidden" value="' + auth_token + '">' +
        '</form>');
    $('body').append(form);  // This line is not necessary
    $(form).submit();
}


$("#checkout").submit(function (e) {
    console.log("SUBMIT FORM ORIGIN")

    e.preventDefault();
    if ($("input:radio[name ='payment_method']:checked").val() == "braintree") {
        payWithCreditCard()
    } else {
        submitFormWithNonce($("#paypal-nonce").val());
    }
    $(form).ajaxSubmit(options);
    return true;
});




