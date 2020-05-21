export kms
const kms <- typeobject kms 
  op getname->[res:String]
  op gettime->[res:Time]
  op cloneMe->[res:kms]
  op update[t:Time,n:String]
  op requestUpdate[newTime:Time,newName:String]
end kms

