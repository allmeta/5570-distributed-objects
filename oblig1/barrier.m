const barrier <- monitor object barrier
  var count : Integer <- 0
  var max:Integer <-4
  const c : Condition <- Condition.create

  export operation call
    count<-count+1
    if count < max then
      stdout.putString["waiting for barrier\n"]
      wait c
    else
      stdout.putString["opening barrier\n"]
      count<-0
      var i:Integer<-0
      loop
        exit when i=max
        signal c
        i<-i+1
      end loop
    end if
    stdout.putString["doing my shit\n"]
  end call
 end barrier 

const main <- object main
  const limit : Integer <- 2
  const caller1 <- object caller1
    process
      var i : Integer <- 0
      loop
        exit when i=limit
        barrier.call
        i<-i+1
      end loop
    end process
  end caller1
  const caller2 <- object caller2
    process
      var i : Integer <- 0
      loop
        exit when i=limit
        barrier.call
        i<-i+1
      end loop
    end process
  end caller2
  const caller3 <- object caller3
    process
      var i : Integer <- 0
      loop
        exit when i=limit
        barrier.call
        i<-i+1
      end loop
    end process
  end caller3
end main
