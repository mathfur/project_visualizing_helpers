var getParamCache = {};
function getParam(key){
  if(cache_val = getParamCache[key]){
    return cache_val;
  }else{
    var pairs = (location.href.split("?")[1] || "").split("&").map(function(pair){ return pair.split("=") });
    var result = (_.find(pairs, function(pair){ return pair[0] == key }) || [])[1];
    getParamCache[key] = result;
    return result
  }
}

function windowWidth(){
    return window.innerWidth || documentElement.clientWidth || getElementsByTagName('body')[0].clientWidth;
}

cache = {}
var getFromCsv = function(url, key, func){
  var call_func = function(cache){
    func(key ? _.pluck(cache, key) : cache)
  }

  if(cache[url]){
    call_func(cache[url])
  }else{
    d3.csv(url, function(ds){
      cache[url] = ds
      call_func(cache[url])
    })
  }
}
