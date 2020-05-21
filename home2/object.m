export testObject

const testObject <- class testObjectClass [time:Time,name:String]
  export op getName->[res:String]
    res<-name
  end getName
  export op getTime->[res:Time]
    res<-time
  end getTime
  export op cloneMe->[res:kms]
    res<-testObject.create[time,name]
  end cloneMe
  export op update[newTime:Time,newName:String]
    name<-newName
    time<-newTime
  end update
  export op requestUpdate[newTime:Time,newName:String]
    framework.updateMe[self,name,newTime,newName]
  end requestUpdate
end testObjectClass
