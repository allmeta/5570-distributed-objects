const nopester <- object nopester
  const here <- (locate self)
  const all <- here.getActiveNodes
  const peers <- Array.of[PeerType].empty
  const pnum<-5
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

  export op test
    % gen peers
    fix Server at here
    for i:Integer<-0 while i<pnum by i<-i+1
      const n<-"peer" || i.asString
      const p<-Peer.create[n,Server]
      const f<-files.getSlice[i*2,3]
      for j:Integer<-0 while j<f.upperbound by j<-j+1
        p.addFile[n || "file" || j.asstring,f[j]]
      end for
      peers.addupper[p]
    end for
    % distribute peers
    const distNodes<-Array.of[NodeListElement].empty
    for i in all
      if i!==here then
        distNodes.addupper[i]
      end if
    end for
    for p:Integer<-0 while p<pnum by p<-p+1
      const l<-p # (distNodes.upperbound+1)
      fix peers[p] at distNodes[l]
    end for 
    
    % tests
    self.dump
    self.testDownload
    self.dump
    self.testRemove
    self.dump
    self.testUpdate
    self.dump
      
  end test

  export op testRemove
    stdout.putstring["Test remove file\n"]
    peers[1].removeFile["peer1file1"]
  end testRemove

  export op testUpdate
    stdout.putstring["Test update file\n"]
    peers[2].updateFileName["peer2file0","peer2file0 - updated"]

  end testUpdate

  export op testDownload
    stdout.putstring["Test download file\n"]
    const file<-"peer0file1"
    const peersWithFile<-view peers[0].findFiles[file] as Array.of[PeerType]
    for i in peersWithFile
      begin
        const fileContent<-i.getFile[file]
        if fileContent!=nil then
          peers[0].addFile[file || " - downloaded",fileContent]
        end if
        unavailable
          stdout.putstring["Peer unavailable\n"]
        end unavailable
      end
    end for
  end testDownload

  export op dump
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
      
    
  end dump
  
end nopester


const Server : ServerType <- object Server
  var index_hash_peers : Directory <- Directory.create
  var index_hash_name : Directory <- Directory.create

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
      index_hash_peers.insert[fileHash,{peer}]
    else
      index_hash_peers.insert[fileHash,peers.catenate[(view {peer} as Array.of[PeerType])]]
    end if
    
    if names == nil then
      index_hash_name.insert[fileHash,{fileName}]
    else
      index_hash_name.insert[fileHash,names.catenate[(view {fileName} as Array.of[String])]]
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
      index_hash_name.insert[fileHash,updatedNames]
    end if
    if peers !== nil then
      for i in peers
        if i!==peer then
          updatedPeers.addupper[i]
        end if
      end for
      index_hash_peers.insert[fileHash,updatedPeers]
    end if
  end removeFile

  export op updateFileName [oldName:String,newName:String,fileHash:String,peer:PeerType]
    const names <- view index_hash_name.lookup[fileHash] as Array.of[String]
    const updatedNames <- Array.of[String].empty

    if names !== nil then
      for i in names
        if i == oldName then
          updatedNames.addupper[newName]
        else
          updatedNames.addupper[i]
        end if
      end for
      index_hash_name.insert[fileHash,updatedNames]
    end if
  end updateFileName

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

const Peer <- class PeerClass [name:String, server : ServerType]
  attached var files : Directory <- Directory.create

  export op getName -> [n:String]
    n<-name
  end getName

  export op getFiles -> [f:Directory]
    f<-files
  end getFiles

  export op addFile[fileName:String,fileContent:String]
    const fileHash<-fnv.hash[fileContent]
    files.insert[fileName,fileContent]
    server.addFile[fileName,fileHash,self]
  end addFile

  export op removeFile[fileName:String]
    const fileContent <- view files.lookup[fileName] as String
    if fileContent !== nil then
      const fileHash <- fnv.hash[fileContent]
      files.delete[fileName]
      server.removeFile[fileName,fileHash,self]
    else
      (locate server)$stdout.putstring["File does not exist\n"]
    end if
  end removeFile

  export op updateFileName[oldName:String,newName:String]
    const fileContent <- view files.lookup[oldName] as String
    const fileHash <- fnv.hash[oldName]
    files.delete[oldName]
    files.insert[newName,fileContent]
    server.updateFileName[oldName,newName,fileHash,self]
  end updateFileName

  export op getFile[fileName:String]->[fileContent:String]
    fileContent <- view files.lookup[fileName] as String
  end getFile

  export op findFiles [query:String]->[peers:Array.of[PeerType]]
    peers <- server.getFileMatches[query]
  end findFiles
end PeerClass

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

const hashType <- typeobject hashAlg
  op hash [String] -> [String]
end hashAlg

const PeerType <- typeobject PeerType
  op getName -> [n:String]
  op getFiles -> [f:Directory]
  op addFile [fileName:String,fileContent:String]
  op removeFile [fileName:String]
  op updateFileName [oldName:String,newName:String]
  op getFile [fileName:String]->[fileContent:String]
  op findFiles [query:String]->[peers:Array.of[PeerType]]
end PeerType

const ServerType <- typeobject ServerType
  op getIndex_hash_name->[ihn:Directory]
  op getIndex_hash_peers->[ihp:Directory]
  op addFile [fileName:String,fileHash:String,peer:PeerType]   
  op removeFile [fileName:String,fileHash:String,peer:PeerType]
  op updateFileName [oldName:String,newName:String,fileHash:String,peer:PeerType]
  op getFileMatches[query:String]->[peers:Array.of[PeerType]]
end ServerType

