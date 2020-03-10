const master <- object master
  const home<-locate self
  var nodes: NodeList<-home.getActiveNodes
  process
    loop
      begin
        stdout.putString[(nodes.upperbound + 1).asString || " nodes active.\n"]
        for e in nodes
          const reqStartTime<- home$timeofday
          const time<- e$thenode$timeofday
          const reqEndTime<-home$timeofday
          const rtt <- reqEndTime-reqStartTime
          const est<-time+rtt/2
          stdout.putString["name:\t"||e$thenode$name||"\n"]
          stdout.putString["est:\t"||est.asstring||"\n"]
          stdout.putString["Rtt:\t"||rtt.asstring||"\n"]
          stdout.putString["Diff:\t"||(reqStartTime-est).asString||"\n"]
          stdout.putString["--------\n"]
        end for
        home.delay[Time.create[60,0]]
        unavailable
          stdout.putString["Unavailable...\n"]
        end unavailable
      end
    end loop
  end process
end master
