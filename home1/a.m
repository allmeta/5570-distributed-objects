const main <- object main
  process
    const a<-Array.of[Integer].empty
    a.addupper[2]
    const b<-a.catenate[Array.of[Integer].empty]
    a.addupper[3]
    const i<-b.removeupper
    assert b.empty == false
    stdout.putstring[a[1].asstring || "\n"]
    failure
      stdout.putstring[b.empty.asstring || "\n"]
    end failure
  end process

end main
