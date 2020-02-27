const TimeCollector <- object TimeCollector
  process
    const home <- locate self
    var there :     Node
    var all : NodeList
    var localtimes:Array.of[Time]<-Array.of[Time].create[0]
    var nodeInfo:Array.of[String]<-Array.of[String].create[0]

    home$stdout.PutString["Starting on " || home$name || "\n"]
    all <- home.getActiveNodes
    home$stdout.PutString[(all.upperbound + 1).asString || " nodes active.\n"]
    for i in all
      there <- i$theNode
      refix TimeCollector at there
      there$stdout.PutString["TimeCollector was here\n"]
      localtimes.addUpper[there.getTimeOfDay]
      nodeInfo.addUpper[there.getname]
    end for
    refix TimeCollector at home
    
    for i:Integer<-0 while i<=localtimes.upperbound by i<-i+1
      stdout.putString[nodeInfo[i] || "\n"]
      stdout.putString[localtimes[i].asString||"\n"]
      stdout.putString["---------\n"]
    end for
  end process
end TimeCollector
