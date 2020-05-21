export kms
const kms <- typeobject kms 
  op getname->[res:String]
  op gettime->[res:Time]
  op cloneMe->[res:kms]
  op update[n:String]
  op requestUpdate[newName:String]
end kms

