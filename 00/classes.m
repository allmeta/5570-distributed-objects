const Person <- object PersonCreator
  const PersonType <- typeobject PersonType
    operation getname -> [res:String]
  end PersonType
  export function create [name:String]->[res:PersonType]
    res<-
      object Person
        export operation getname->[res:String]
          res<-name
        end getname
      end Person
  end create
end PersonCreator

%const Person <- class PersonClass [ name : String ]
%  export operation getname -> [ res : String ]
%    res <- name
%  end getname
%end PersonClass

const main <- object main
  initially 
    const oleks <- Person.create["Oleks"]
    stdout.putstring[oleks.getname || "\n"]
    const eric <- Person.create["Eric"]
    stdout.putstring[eric.getname || "\n"]
  end initially
end main
