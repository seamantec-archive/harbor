function drawLast30DayUsers(datas) {
    var labels = [];
    var dataPoints = [];
    for (var i = 0; i < datas.length; i++) {
        labels.push(datas[i]["date"]);
        dataPoints.push(datas[i]["value"]);
    }

    var chartData = {
        labels: labels,
        datasets: [
            {
                label: "Last 30 days",
                fillColor: "rgba(220,220,220,0.2)",
                strokeColor: "rgba(220,220,220,1)",
                pointColor: "rgba(220,220,220,1)",
                pointStrokeColor: "#fff",
                pointHighlightFill: "#fff",
                pointHighlightStroke: "rgba(220,220,220,1)",
                data: dataPoints
            }
        ]
    }
    var options = {
        legendTemplate: "<ul class=\"vertical-legend\"><% for (var i=0; i<datasets.length; i++){%><li><span style=\"background-color:<%=datasets[i].pointColor%>\"></span><%if(datasets[i].label){%><%=datasets[i].label%><%}%></li><%}%></ul>"
    }
    $("#lastUsersChart").attr("width", $("#lastUsersChart").parent().width())
    var ctx = $("#lastUsersChart").get(0).getContext("2d");
    var myNewChart = new Chart(ctx).Line(chartData, options);
    var legend = myNewChart.generateLegend();
    $("#lastUsersChartLegend").append(legend);

}


function drawAllUsers(datas) {

    var chartData = [
        {
            value: datas["all"],
            color: "#F7464A",
            highlight: "#FF5A5E",
            label: "All"
        }
    ]
    var options = {
        legendTemplate: "<ul class=\"vertical-legend\"><% for (var i=0; i<segments.length; i++){%><li><span style=\"background-color:<%=segments[i].fillColor%>\"></span><%if(segments[i].label){%><%=segments[i].label%><%}%></li><%}%></ul>"
    }
    $("#allUsersChart").attr("width", $("#allUsersChart").parent().width())
    var ctx = $("#allUsersChart").get(0).getContext("2d");
    var myDoughnutChart = new Chart(ctx).Doughnut(chartData, options);
    var legend = myDoughnutChart.generateLegend();
    $(".users_counter").text(datas["all"])
    $("#allUsersChartLegend").append(legend);
}

function drawAllLicenses(datas) {
    var chartData = [
        {
            value: datas["demo"],
            color: "#28DDD1",
            highlight: "#1FA59C",
            label: "Demo"
        },
        {
            value: datas["commercial"],
            color: "#4628DD",
            highlight: "#3821B0",
            label: "Commercial"
        }
    ]
    var options = {
        legendTemplate: "<ul class=\"vertical-legend\"><% for (var i=0; i<segments.length; i++){%><li><span style=\"background-color:<%=segments[i].fillColor%>\"></span><%if(segments[i].label){%><%=segments[i].label%><%}%></li><%}%></ul>"
    }
    $("#licensesChart").attr("width", $("licensesChart").parent().width())
    var ctx = $("#licensesChart").get(0).getContext("2d");
    var myDoughnutChart = new Chart(ctx).Doughnut(chartData, options);
    var legend = myDoughnutChart.generateLegend();
    $(".licenses_counter").text(datas["all"])
    $("#allLicensesChartLegend").append(legend);
}

function drawLast30DayLicenses(datas) {
    var labels = [];
    var demodataPoints = [];
    var commercialdataPoints = [];
    for (var i = 0; i < datas.length; i++) {
        labels.push(datas[i]["date"]);
        demodataPoints.push(datas[i]["demoSum"]);
        commercialdataPoints.push(datas[i]["commercialSum"]);
    }

    var chartData = {
        labels: labels,
        datasets: [
            {
                label: "Demo",
                fillColor: "rgba(31,165,156,0.2)",
                strokeColor: "rgba(33,165,156,1)",
                pointColor: "rgba(33,165,156,1)",
                pointStrokeColor: "#fff",
                pointHighlightFill: "#fff",
                pointHighlightStroke: "rgba(220,220,220,1)",
                data: demodataPoints
            },
            {
                label: "Commercial",
                fillColor: "rgba(70,40,221,0.2)",
                strokeColor: "rgba(70,40,221,1)",
                pointColor: "rgba(70,40,221,1)",
                pointStrokeColor: "#fff",
                pointHighlightFill: "#fff",
                pointHighlightStroke: "rgba(220,220,220,1)",
                data: commercialdataPoints
            }
        ]
    }
    var options = {
        legendTemplate: "<ul class=\"vertical-legend\"><% for (var i=0; i<datasets.length; i++){%><li><span style=\"background-color:<%=datasets[i].pointColor%>\"></span><%if(datasets[i].label){%><%=datasets[i].label%><%}%></li><%}%></ul>"
    }
    $("#lastLicensesChart").attr("width", $("#lastLicensesChart").parent().width())
    var ctx = $("#lastLicensesChart").get(0).getContext("2d");
    var myNewChart = new Chart(ctx).Line(chartData, options);
    var legend = myNewChart.generateLegend();
    $("#lastLicensesChartLegend").append(legend);

}


function drawAllOrders(datas) {
    var chartData = [
        {
            value: datas["success"],
            color: "#5CB85C",
            highlight: "#57D157",
            label: "Success"
        },
        {
            value: datas["failed"],
            color: "#D9534F",
            highlight: "#F35C57",
            label: "Failed"
        },
        {
            value: datas["new"],
            color: "#428BCA",
            highlight: "#4CA3EE",
            label: "new"
        }
    ]

    var options = {
        legendTemplate: "<ul class=\"vertical-legend\"><% for (var i=0; i<segments.length; i++){%><li><span style=\"background-color:<%=segments[i].fillColor%>\"></span><%if(segments[i].label){%><%=segments[i].label%><%}%></li><%}%></ul>"
    }

    $("#ordersChart").attr("width", $("ordersChart").parent().width())
    var ctx = $("#ordersChart").get(0).getContext("2d");
    var myDoughnutChart = new Chart(ctx).Doughnut(chartData, options);
    $(".orders_counter").text(datas["all"])
    var legend = myDoughnutChart.generateLegend();
    $("#allOrdersChartLegend").append(legend);
}


function drawLast30DayOrders(datas) {
    var labels = [];
    var succesDataPoints = [];
    var newDataPoints = [];
    var failedDataPoints = [];
    for (var i = 0; i < datas.length; i++) {
        labels.push(datas[i]["date"]);
        succesDataPoints.push(datas[i]["successSum"]);
        newDataPoints.push(datas[i]["newSum"]);
        failedDataPoints.push(datas[i]["failedSum"]);
    }

    var chartData = {
        labels: labels,
        datasets: [
            {
                label: "Success",
                fillColor: "rgba(66,139,202,0.2)",
                strokeColor: "rgba(66,139,202,1)",
                pointColor: "rgba(66,139,202,1)",
                pointStrokeColor: "#fff",
                pointHighlightFill: "#fff",
                pointHighlightStroke: "rgba(220,220,220,1)",
                data: succesDataPoints
            },
            {
                label: "New",
                fillColor: "rgba(92,184,92,0.2)",
                strokeColor: "rgba(92,184,92,1)",
                pointColor: "rgba(92,184,92,1)",
                pointStrokeColor: "#fff",
                pointHighlightFill: "#fff",
                pointHighlightStroke: "rgba(220,220,220,1)",
                data: newDataPoints
            },
            {
                label: "Failed",
                fillColor: "rgba(217,83,79,0.2)",
                strokeColor: "rgba(217,83,79,1)",
                pointColor: "rgba(217,83,79,1)",
                pointStrokeColor: "#fff",
                pointHighlightFill: "#fff",
                pointHighlightStroke: "rgba(220,220,220,1)",
                data: failedDataPoints
            }
        ]
    }

    var options = {
        legendTemplate: "<ul class=\"vertical-legend\"><% for (var i=0; i<datasets.length; i++){%><li><span style=\"background-color:<%=datasets[i].pointColor%>\"></span><%if(datasets[i].label){%><%=datasets[i].label%><%}%></li><%}%></ul>"
    }

    $("#lastOrdersChart").attr("width", $("#lastOrdersChart").parent().width())
    var ctx = $("#lastOrdersChart").get(0).getContext("2d");
    var myNewChart = new Chart(ctx).Line(chartData, options);
    //then you just need to generate the legend
    var legend = myNewChart.generateLegend();

    //and append it to your page somewhere
    $('#lastOrderChartLegend').append(legend);

}


function drawLast30DayPayments(datas) {
    var labels = [];
    var eurDataPoints = [];
    var usdDataPoints = [];
    for (var i = 0; i < datas.length; i++) {
        labels.push(datas[i]["date"]);
        //eurDataPoints.push(datas[i]["EUR"] == null ? 0 : datas[i]["EUR"]);
        usdDataPoints.push(datas[i]["USD"] == null ? 0 : datas[i]["USD"]);
    }

    var chartData = {
        labels: labels,
        datasets: [
            {
                label: "USD",
                fillColor: "rgba(66,139,202,0.2)",
                strokeColor: "rgba(66,139,202,1)",
                pointColor: "rgba(66,139,202,1)",
                pointStrokeColor: "#fff",
                pointHighlightFill: "#fff",
                pointHighlightStroke: "rgba(220,220,220,1)",
                data: usdDataPoints
            }//,
            //{
            //    label: "EUR",
            //    fillColor: "rgba(92,184,92,0.2)",
            //    strokeColor: "rgba(92,184,92,1)",
            //    pointColor: "rgba(92,184,92,1)",
            //    pointStrokeColor: "#fff",
            //    pointHighlightFill: "#fff",
            //    pointHighlightStroke: "rgba(220,220,220,1)",
            //    data: eurDataPoints
            //}
        ]
    }
    var options = {
        legendTemplate: "<ul class=\"vertical-legend\"><% for (var i=0; i<datasets.length; i++){%><li><span style=\"background-color:<%=datasets[i].pointColor%>\"></span><%if(datasets[i].label){%><%=datasets[i].label%><%}%></li><%}%></ul>"
    }

    $("#lastPaymentsChart").attr("width", $("#lastPaymentsChart").parent().width())
    var ctx = $("#lastPaymentsChart").get(0).getContext("2d");
    var myNewChart = new Chart(ctx).Line(chartData, options);
    //then you just need to generate the legend
    var legend = myNewChart.generateLegend();

    //and append it to your page somewhere
    $('#lastPaymentsChartLegend').append(legend);
}

function fillAllPayments(data) {
    var text = ""
    for (var i = 0; i < data.length; i++) {
        $("#all_payments").append($("<h1></h1>").html(data[i]["currency"] + " " + data[i]["amount"]))
    }
}
if (window.location.pathname.match("/dashboard")) {
    $.get("/dashboards/get_user_reports", function (data) {
        drawLast30DayUsers(data["last_30_day"])
        drawAllUsers(data["all_user"])
    });

    $.get("/dashboards/get_licenses_reports", function (data) {
        drawAllLicenses(data["all_licenses"]);
        drawLast30DayLicenses(data["last_30_day"]);
    });
    $.get("/dashboards/get_orders_reports", function (data) {
        drawAllOrders(data["all_orders"]);
        drawLast30DayOrders(data["last_30_day"]);
    });

    $.get("/dashboards/get_payments_reports", function (data) {
        fillAllPayments(data["all_payments"])
        drawLast30DayPayments(data["last_30_day"])
    });
}