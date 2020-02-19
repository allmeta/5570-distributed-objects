const Kilroy <- object Kilroy
  process
    const home <- locate self
    var there :     Node
    var startTime,diff: Time
    var totalMachines:Integer
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
    totalMachines<-1000000/diff.getmicroseconds*(all.upperBound+1)
    home$stdout.PutString["Back home.  Total time = " || diff.asString || "\n"]
    home$stdout.putString["Total machines visitable in 1 second: "||totalMachines.asString||"\n"]
  end process
end Kilroy
