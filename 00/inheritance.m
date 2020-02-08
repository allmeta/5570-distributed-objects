const Person <- object PersonCreator
  const PersonType <- typeobject PersonType
    operation getname -> [res:String]
  end PersonType
  export function create [name:String]->[res:PersonType]
    res<-
      object Person
        export operation getname->[res:String]
        res <-name
  end getname
end Person
end create
end PersonCreator

const Teacher <- object TeacherCreator
  const TeacherType <- typeobject TeacherType
    operation getname -> [res:String]
    operation getposition->[res:String]
  end TeacherType
  export operation create[name:String,position:String]->[res:TeacherType]
    res<-
      object Teacher
        export operation getname->[res:String]
          res<-name
        end getname
        export operation getposition->[res:String]
          res<-position
        end getposition
      end Teacher
  end create
end TeacherCreator


const main <- object main
  initially

    const oleks <- Person.create["Oleks"]
    stdout.putstring[oleks.getname || "\n"]

    const eric <- Teacher.create["Eric", "Professor"]
    stdout.putstring[eric.getname || "\n"]
    stdout.putstring[eric.getposition || "\n"]

  end initially
end main
