const Kilroy <- object Kilroy
  process
    const home <- locate self
    var there :     Node
    var startTime,diff: Time
    var totalMachines:Real
    var all : NodeList
    var theElem :NodeListElement
    var stuff : Real

    home$stdout.PutString["Starting on " || home$name || "\n"]
    all <- home.getActiveNodes
    home$stdout.PutString[(all.upperbound + 1).asString || " nodes active.\n"]
    startTime <- home.getTimeOfDay
    for i in all
      there <- i$theNode
      refix Kilroy at there
      there$stdout.PutString["Kilroy was here\n"]
    end for
    refix Kilroy at home
    diff <- home.getTimeOfDay - startTime
    var timeAsInteger:Real<-diff.getseconds.asReal+diff.getmicroseconds.asreal/1000000.0
    totalMachines<-(all.upperBound.asreal+1.0)/timeAsInteger
    home$stdout.PutString["Back home.  Total time = " || diff.asString || "\n"]
    home$stdout.putString["Total machines visitable in 1 second: "||totalMachines.asString||"\n"]
  end process
end Kilroy
