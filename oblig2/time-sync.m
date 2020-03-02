const master <- object master
  process
    const home<-locate self
    var nodes: NodeList<-home.getActiveNodes
    loop
      sync
      home.delay[Time.create[60,0]]
    end loop
  end process
  export function sync 
    stdout.putString[(nodes.upperbound + 1).asString || " nodes active.\n"]
    for e in nodes
      var now: Time<-home.getTimeOfDay
      var time: Time<-e.getTimeOfDay
      var rtt: Time<-time-now
      var est:Time<-cristian[time,rtt]
      stdout.putString[e.name||"\n"]
      stdout.putString[est.asstring||"\n"]
      stdout.putString["--------\n"]
    end for
  end sync
  export function cristian [time:Time,rtt:Time]->[res:Time]
    res<-time+rtt/2
  end cristian
end master
