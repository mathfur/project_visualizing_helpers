d3.pvh = {};

d3.pvh.dataTable = function module() {
    var base = this;

    var start_time = null;
    var end_time   = null;

    var margin = {top: 35, right: 10, bottom: 10, left: 150},
        width = 960,
        height = 500;

    var eps = 10;

    var wrapper_class = "chart_group"

    function chartW(){
        return width - margin.left - margin.right;
    }

    function chartH(){
        return height - margin.top - margin.bottom;
    }

    this.render = function(svg, data, tag, klass, settings){
        var chart = svg.select("." + wrapper_class)
                       .selectAll(tag + "." + klass)
                       .data(data);
        chart.enter().append(tag).attr('class', klass).call(settings);
        chart.call(settings);
        chart.exit()
             .transition()
             .style({opacity: 0})
             .remove();
    }


    var main_render = function(){};
    var xScale = function(){};
    var yScale = function(){};

    var dispatch = d3.dispatch("customHover");
    function exports(_selection) {
        _selection.each(function(data_) {
            //== Chart ========================================

            var svg = d3.select(this)
                        .selectAll('svg')
                        .data([data_]);

            var container = svg.enter()
                               .append("svg")
                               .classed("data-table", true)
                               .append("g")
                               .classed("container-group", true);

            svg.transition()
               .attr({width: width, height: height})

            svg.select(".container-group")
               .attr({transform: "translate(" + margin.left + "," + margin.top + ")"});

            //== Axis ========================================

            var x = xScale(data_, chartW(), chartH());
            var y = yScale(data_, chartW(), chartH());

            var xAxis = d3.svg.axis()
                          .scale(x)
                          .orient('top')
                          .tickValues([]);

            var yAxis = d3.svg.axis()
                          .scale(y)
                          .orient("left")
                          .tickValues([]);

            container.append("g").classed("x-axis-group axis", true);
            container.append("g").classed("y-axis-group axis", true);

            svg.select(".x-axis-group.axis")
               .transition()
               .attr({transform: "translate(0,0)"})
               .call(xAxis);

            svg.select(".y-axis-group.axis")
               .transition()
               .attr({transform: "translate(0,0)"})
               .call(yAxis);

            //=================================================

            container.append("g").classed(wrapper_class, true);

            main_render.call(base, svg, container, data_, x, y, chartW(), chartH());
        }); // _selection.each END
    }

    // アクセサ
    exports.width = function(_x) {
        if (!arguments.length) return width;
        width = parseInt(_x);
        return this;
    };
    exports.height = function(_x) {
        if (!arguments.length) return height;
        height = parseInt(_x);
        return this;
    };
    exports.font_size = function(_s) {
        if (!arguments.length) return font_size;
        font_size = parseInt(_s);
        return this;
    };
    exports.ease = function(_x) {
        if (!arguments.length) return ease;
        ease = _x;
        return this;
    };
    exports.main_render = function(func) {
        if (!arguments.length) return main_render;
        main_render = func;
        return this;
    };
    exports.xScale = function(func) {
        if (!arguments.length) return xScale;
        xScale = func;
        return this;
    };
    exports.yScale = function(func) {
        if (!arguments.length) return yScale;
        yScale = func;
        return this;
    };

    d3.rebind(exports, dispatch, "on");
    return exports;
};
