const remoteObject<-object remoteObject
  export op callByMove[arg : Array.of[Integer]]
    const arraySize<-arg.upperbound+1
  end callByMove
  export op callByVisit[arg : Array.of[Integer],org : Node]
    const arraySize<-arg.upperbound+1
    move arg to org
  end callByVisit
end remoteObject


const main <- object main
  const home<-locate self
  const arraySizes <- {50,100,500,1000,10000}  
  const nodes<-home$activenodes
  const remote<-nodes[1]$thenode

  var startReqTime : Time
  var endReqTime : Time

  export op toSeconds[t:Time]->[res:Real]
    res<-t$seconds.asreal+t$microseconds.asreal/1000000.0 
  end toSeconds

  process
    fix remoteObject at remote
    for size in arraySizes
      attached const arg<-Array.of[Integer].create[size]
      stdout.putstring["Size:\t\t\t"||size.asstring||"\n"]
      startReqTime<-home$timeofday
      remoteObject.callByMove[arg]
      endReqTime<-home$timeofday
      const moveTime<-self.toSeconds[endReqTime-startReqTime]
      stdout.putstring["callByMove time:\t"||moveTime.asstring||"\n"]


      move arg to remote
      startReqTime<-home$timeofday
      remoteObject.callByVisit[arg,home]
      endReqTime<-home$timeofday
      const visitTime<-self.toSeconds[endReqTime-startReqTime]

      stdout.putstring["callByVisit time:\t"||visitTime.asstring||"\n"]

      stdout.putstring["Break even: \t\t"||(visitTime/moveTime-1.0).asstring||"\n"]
      stdout.putstring["-----\n"]
    end for
  end process
end main

