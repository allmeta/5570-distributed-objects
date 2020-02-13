const producer <- object producer
  var sequence:Array.of[Integer]<-Array.of[Integer].create[0]
  initially
    for i:Integer<-1 while i<31 by i<i+1
      sequence.addUpper[i]
    end for
  end initially
  export operation produce [array:Array.of[Integer]] -> [res:Integer]
    res<-sequence.removeLower
    array.addUpper[res]
    stdout.putString["added item"||res||"\n"]
  end produce
end producer

const consumer <- object consumer
  export operation consume [array:Array.of[Integer]]
    var x<-array.removeLower
    stdout.putString["removed item: "||x||"\n"]
  end consume
end consumer 

const main <- object main
  var market:Array.of[Integer]<-Array.of[Integer].create[0]
  const p1 <- object p1
    process
      loop
        
      exit loop
    end process
  end p1
end main
