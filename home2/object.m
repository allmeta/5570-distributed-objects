export testObject

const testObject <- class testObjectClass [name:String]
  export op getName->[res:String]
    res<-name
  end getName
  export op getTime->[res:Time]
    res<-(locate self)$timeofday
  end getTime
  export op cloneMe->[res:kms]
    res<-testObject.create[name]
  end cloneMe
  export op update[newName:String]
    name<-newName
  end update
  export op requestUpdate[newName:String]
    framework.updateMe[self,name,newName]
  end requestUpdate
end testObjectClass
