var tree = d3.layout.tree()
             .children(function(d) { return d.instance_variables; });

var render = function(svg, data, tag, klass, settings){
    var chart = svg.select(".chart-group")
                   .selectAll(tag + "." + klass)
                   .data(data);
    chart.enter().append(tag).attr('class', klass).call(settings);
    chart.call(settings);
    chart.exit()
         .transition()
         .style({opacity: 0})
         .remove();
}

var data_table = d3.frt.dataTable()
                   .width(900)
                   .height(300)
                   .main_render(function(svg, container, data, x, y, chartW, chartH){
                        var font_size = 11;

                        tree = tree.size([chartH, chartW]);
                        var nodes = tree.nodes(data);
                        var links = tree.links(nodes);

                        var diagonal = d3.svg.diagonal()
                                             .projection(function(d) { return [x(d.y), y(d.x)]; });
      
                        render(svg, links, 'path', 'link', function(){
                            this.attr("d", function(d){
                                   return diagonal(d);
                                });
                        });
      
                        render(svg, nodes, 'g', 'label_group', function(){
                            $("div#label-base div.label").remove();

                            this.each(function(d){
                                var node_height = font_size + 8;
                                var text = d3.select("div#label-base")
                                             .append("div")
                                             .attr("class", "label")
                                             .attr("data-name", d.name)
                                             .style("top", function(e){  return 35 + x(d.x) - node_height/2 + "px"; })
                                             .style("left", function(e){ return 150 + y(d.y)                 + "px"; })
                                             .style("height", node_height + "px")
                                             .style("font-size", font_size)
                                             .style("background-color", function(e){ return d3.hsl(0, 1, 0.5) })
                                             .html(function(t){
                                                 if(d.value){
                                                    return d.name + ": " + d.value;
                                                 }else if(d.klass){
                                                    return d.name + ": #" + d.klass;
                                                 }else{
                                                    return d.name + ": -";
                                                 }
                                             })
                            });
                        });
                   })
                   .xScale(function(data_, chartW, chartH){
                       return d3.scale.linear()
                                .domain([0, 1000])
                                .range([0, chartW]);
                   })
                   .yScale(function(data_, chartW, chartH){
                       return d3.scale.linear()
                                .domain([0, 1000])
                                .range([0, chartW]);
                   });

var update = function(){
    d3.json("/tree_data",  function(json) {
        d3.select('div#base')
          .datum(json)
          .call(data_table);
    });
}

d3.select('#update')
  .on('click', function(){
      update();
  })
