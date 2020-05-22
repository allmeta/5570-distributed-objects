export testObjectType
const testObjectType <- typeobject testObjectType 
  op getname->[res:String]
  op gettime->[res:Time]
  op cloneMe->[res:testObjectType]
  op update[n:String]
  op requestUpdate[newName:String]
end testObjectType

