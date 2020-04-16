export fnv

% https://en.wikipedia.org/wiki/Fowler%E2%80%93Noll%E2%80%93Vo_hash_function#FNV-1a_hash
const fnv : hashType <- object fnv
  export op hash [c : String]->[hs:String]
    var h:Integer<-0x811c9dc5
    for i in c
      const o<-i.ord
      h<-(h+o) - (h & o) - (h & o)
      h<-h*0x01000193
    end for
    hs<-h.abs.asString
  end hash
end fnv
