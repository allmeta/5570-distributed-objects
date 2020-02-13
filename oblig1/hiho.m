const hiho <- monitor object hiho
  var flip : Boolean <- true % true => print hi next
  const c : Condition <- Condition.create

  export operation Hi
    if ! flip then
      wait c
    end if
    stdout.putString["Hi \n"]
    flip <- false
    signal c
  end hi

  export operation Ho
    if flip then
      wait c
    end if
    stdout.PutString["Ho\n"]
    flip <- true
    signal c
  end ho

  initially
    stdout.putString["Starting Hi Ho program \n"]
  end initially
end hiho


const main <- object main
  const limit : Integer  <- 5
  const hier <- object hier
    process
      var i : Integer <- 0
      loop
        exit when i = limit
        hiho.Hi
          i <- i + 1
      end loop
    end process
  end hier

  const hoer <- object hoer
    process
      var i : Integer <- 0
      loop
        exit when i = limit
        hiho.Ho
        i <- i + 1
      end loop
    end process
  end hoer

end main
