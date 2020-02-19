const maxProcesses:Integer <-4
const barrier <- monitor object barrier
  var count : Integer <- 0
  const c : Condition <- Condition.create

  export operation call
    count<-count+1
    if count < maxProcesses then
      stdout.putString["waiting for barrier\n"]
      wait c
    else
      stdout.putString["opening barrier\n"]
      count<-0
      var i:Integer<-0
      loop
        exit when i=maxProcesses
        signal c
        i<-i+1
      end loop
    end if
    stdout.putString["doing stuff\n"]
  end call
 end barrier 

const main <- object main
  const maxOperations : Integer <- 2
  initially
  for i:Integer<-0 while i<maxProcesses by i<-i+1
    const caller <- object caller
      process
        var i : Integer <- 0
        loop
          exit when i=maxOperations
          barrier.call
          i<-i+1
        end loop
      end process
    end caller
  end for
  end initially
end main
