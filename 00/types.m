const SimpleCollection <- typeobject SimpleCollection
  operation add [ name : Integer ] -> [ res : Boolean ]
  function contains [ name : String ] -> [ res : Boolean ]
  operation remove [ name : String ] -> [ res : Boolean ]
end SimpleCollection

const set : SimpleCollection <- object set
  export operation add [name : Integer ] -> [ res : Boolean ]
    if name == 3 then
      res <- true
    else
      res <- false
    end if
  end add 
  export function contains [ name : String ] -> [ res : Boolean ]
    res<-name==""
  end contains
  export operation remove [ name : String ] -> [ res : Boolean ]
    res<-name==""
  end remove
end set

const main <- object main
  initially
    stdout.putstring[set.add[3].asString || "\n"]
  end initially
end main
