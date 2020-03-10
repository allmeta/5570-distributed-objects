const timeSync<-class timeSync
  export op getTime->[res:Time]
    res<-(locate self)$timeofday
  end getTime
  export op getName->[res:String]
    res<-(locate self)$name
  end getName
end timeSync

const master <- object master
  const home<-locate self
  var nodes: NodeList<-home.getActiveNodes
  const timeSyncObjects<-Array.of[timeSync].empty[]
  process
    for e in nodes
      const t<-timeSync.create[]
      timeSyncObjects.addupper[t]
      move t to e$thenode
    end for
    loop
      begin
        stdout.putString[(nodes.upperbound + 1).asString || " nodes active.\n"]
        for e in timeSyncObjects
          const reqStartTime<- home$timeofday
          const time<- e$time
          const reqEndTime<-home$timeofday
          const rtt <- reqEndTime-reqStartTime
          const est<-time+rtt/2
          stdout.putString["name:\t"||e$name||"\n"]
          stdout.putString["est:\t"||est.asstring||"\n"]
          stdout.putString["Rtt:\t"||rtt.asstring||"\n"]
          stdout.putString["Diff:\t"||(est-reqEndTime).asString||"\n"]
          stdout.putString["--------\n"]
        end for
        home.delay[Time.create[10,0]]
        unavailable
          stdout.putString["Unavailable...\n"]
        end unavailable
      end
    end loop
  end process
end master
