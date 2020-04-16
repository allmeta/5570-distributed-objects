export Server

const Server : ServerType<- object Server
  attached var index_hash_peers : Directory <- Directory.create
  attached var index_hash_name : Directory <- Directory.create

  export op getIndex_hash_peers -> [ihp:Directory]
    ihp<-index_hash_peers
  end getIndex_hash_peers
  export op getIndex_hash_name -> [ihn:Directory]
    ihn<-index_hash_name
  end getIndex_hash_name

  export op addFile[fileName:String,fileHash:String,peer:PeerType]
    const peers <- view index_hash_peers.lookup[fileHash] as Array.of[PeerType]
    const names <- view index_hash_name.lookup[fileHash] as Array.of[String]
    if peers == nil then
      const p<-Array.of[PeerType].empty
      p.addupper[peer]
      index_hash_peers.insert[fileHash,p]
    else
      peers.addupper[peer]
      index_hash_peers.insert[fileHash,peers]
    end if

    
    if names == nil then
      const n<-Array.of[String].empty
      n.addupper[fileName]
      index_hash_name.insert[fileHash,n]
    else
      names.addupper[fileName]
      index_hash_name.insert[fileHash,names]
    end if
  end addFile

  export op removeFile [fileName:String,fileHash:String,peer:PeerType]
    const names <- view index_hash_name.lookup[fileHash] as Array.of[String]
    const updatedNames <- Array.of[String].empty
    const peers <- view index_hash_peers.lookup[fileHash] as Array.of[PeerType]
    const updatedPeers <- Array.of[PeerType].empty

    if names !== nil then
      for i in names
        if i!=fileName then
          updatedNames.addupper[i]
        end if
      end for
      % delete index if empty
      if updatedNames.empty==true then
        index_hash_name.delete[fileHash]
      else
        index_hash_name.insert[fileHash,updatedNames]
      end if
    end if
    if peers !== nil then
      for i in peers
        if i!==peer then
          updatedPeers.addupper[i]
        end if
      end for
      if updatedPeers.empty==true then
        index_hash_peers.delete[fileHash]
      else
        index_hash_peers.insert[fileHash,updatedPeers]
      end if
    end if
  end removeFile

  export op updateFile [oldName:String,newName:String,oldFileHash:String,newFileHash:String,peer:PeerType]
    self.removeFile[oldName,oldFileHash,peer]
    self.addFile[newName,newFileHash,peer]
  end updateFile

  export op getFileMatches[query:String]->[peers:Array.of[PeerType]]
    for h in index_hash_name.list
      for n in (view index_hash_name.lookup[h] as Array.of[String])
        if n.str[query] !== nil then
          peers<-view index_hash_peers.lookup[h] as Array.of[PeerType]
        end if
      end for
    end for
  end getFileMatches
end Server
