const nopester <- object nopester
  const here <- (locate self)
  const all <- here.getActiveNodes
  const peers <- Array.of[PeerType].empty
  const pnum<-5
  % const s<-Server.create
  const files<-{
    "Sit accusamus et laudantium dolorem maxime quibusdam",
    "Ducimus explicabo nemo ut nobis et quis neque.",
    "Doloremque et voluptas cum ipsa quae",
    "Velit numquam sit ea dolorem.",
    "Aspernatur id eum exercitationem cumque",
    "aut voluptas assumenda.",
    "At facilis voluptatem sed possimus.",
    "Exercitationem dolorem vitae omnis ut odio",
    "Iure dignissimos voluptates possimus",
    "Sequi ipsum dolorem quae eos earum facilis",
    "Ipossimu dignissimos vsur eoluptates"
  }
  initially
    if all.upperbound >= 2 then
      self.test
    else
      stdout.putstring["Need at least 3 nodes" || all.upperbound.asstring || "\n"]
    end if
  end initially

  export op createPeer [name:String,f:ImmutableVector.of[String]]
    const p<-Peer.create[name,Server]
    for j:Integer<-0 while j<=f.upperbound by j<-j+1
      p.addFile[name || "file" || j.asstring,f[j]]
    end for
    peers.addupper[p]
  end createPeer

  export op test
    % gen peers
    begin
    fix Server at here
    for i:Integer<-0 while i<pnum by i<-i+1
      self.createPeer["peer" || i.asstring, files.getSlice[i*2,3]] 
    end for
    % distribute peers
    const distNodes<-Array.of[Node].empty
    for i in all
      if i$thenode!==here then
        distNodes.addupper[i$thenode]
      end if

    end for
    for p:Integer<-0 while p<pnum by p<-p+1
      const l<-p # (distNodes.upperbound+1)
      fix peers[p] at distNodes[l]
    end for 
    
    % tests
    self.log
    self.testDownload
    self.log
    self.testRemove
    self.log
    self.testUpdate
    self.log
    end  
  end test

  export op testRemove
    stdout.putstring["\nTest remove file\n"]
    peers[1].removeFile["peer1file1"]
  end testRemove

  export op testUpdate
    stdout.putstring["\nTest update file\n"]
    peers[2].updateFile["peer2file0","peer2file0-updated","asdasd test test update hehe"]

  end testUpdate

  export op testDownload
    stdout.putstring["\nTest download file\n"]
    const fileName<-"peer2file1"
    const peersWithFile<-view (peers[0].findFiles[fileName]) as Array.of[PeerType]
    for i in peersWithFile
      begin
        const fileContent<-i.getFile[fileName]
        if fileContent!==nil then
          peers[0].addFile[fileName || "-downloaded",fileContent]
        end if
        unavailable
          stdout.putstring["Peer unavailable\n"]
        end unavailable
      end
    end for
  end testDownload

  export op log
    stdout.putstring["Peers:\n"]
    for i in peers
      stdout.putstring[i.getname || "\t" || (locate i)$name || "\n"]
      const a<-i$files
      for j in a.list
        stdout.putstring["\t" || j || "\t" || (view a.lookup[j] as String) || "\n"]
      end for
    end for
    stdout.putstring["\nindex_hash_peers:\n"]
    const ihp<-Server$index_hash_peers
    for i in ihp.list
      stdout.putstring[i || ":\n"]
      for j in (view ihp.lookup[i] as Array.of[PeerType])
        begin
          stdout.putstring["\t" || j.getname || "\t" || (locate j)$name || "\n"]
          unavailable
            stdout.putstring["\tPeer unavailable\n"]
          end unavailable
        end 
      end for
    end for
    stdout.putstring["\nindex_hash_name:\n"]
    const ihn<-Server$index_hash_name
    for i in ihn.list
      stdout.putstring[i || ":\n"]
      for j in (view ihn.lookup[i] as Array.of[String])
        begin
          stdout.putstring["\t" || j || "\n"]
          unavailable
            stdout.putstring["\tPeer unavailable\n"]
          end unavailable
        end
      end for
    end for
  end log
end nopester

