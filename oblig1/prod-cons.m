const market <- monitor object market
  var full:Condition<-Condition.create
  var empty:Condition<-Condition.create
  const bufferSize:Integer<-2
  var itemCount:Integer<-0
  var buffer:Array.of[Integer]<-Array.of[Integer].empty
  
  export operation add [item:Integer]
    if itemCount==bufferSize then
      wait full
    end if
    buffer.addUpper[item]
    stdout.putString["Produced: "||item.asstring||"\n"]
    itemCount<-itemCount+1
    if itemCount==1 then
      signal empty
    end if
  end add
  export operation remove->[res:Integer]
    if itemCount==0 then
      wait empty
    end if
    res<-buffer.removeLower
    stdout.putString["Consumed: "||res.asstring||"\n"]
    itemCount<-itemCount-1
    if itemCount==bufferSize-1 then
      signal full  
    end if
  end remove
end market

const main <- object main
  var sequence:Integer<-1
  var sequenceMax:Integer<-30
  const producer<-object producer
    process
      loop
        var item:Integer<-sequence
        market.add[item]
        if item#3==0 then
          stdout.putString["prodoocer waiting\n"]
          (locate self).delay[Time.create[0,100*1000]]
        end if
        sequence<-sequence+1
        if sequence>sequenceMax then
          exit
        end if
      end loop
    end process
  end producer
  const consumer<-object consumer
    process
      loop
        var item:Integer<-market.remove
        if item#5==0 then
          stdout.putString["consoomer waiting\n"]
          (locate self).delay[Time.create[0,100*1000]]
        end if
      end loop
    end process
  end consumer
end main
