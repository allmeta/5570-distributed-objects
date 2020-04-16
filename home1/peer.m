export Peer

const Peer <- class PeerClass [name:String,s:ServerType]
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
    s.addFile[fileName,fileHash,self]
  end addFile

  export op removeFile[fileName:String]
    const fileContent <- view files.lookup[fileName] as String
    if fileContent !== nil then
      const fileHash <- fnv.hash[fileContent]
      files.delete[fileName]
      s.removeFile[fileName,fileHash,self]
    else
      (locate s)$stdout.putstring["File does not exist\n"]
    end if
  end removeFile

  export op updateFile[oldName:String,newName:String,newFileContent:String]
    const oldFileContent <- view files.lookup[oldName] as String
    if oldFileContent !== nil then
      const newFileHash <- fnv.hash[newFileContent]
      const oldFileHash <- fnv.hash[oldFileContent]
      files.delete[oldName]
      files.insert[newName,newFileContent]
      s.updateFile[oldName,newName,oldFileHash,newFileHash,self]
    else
      (locate s)$stdout.putstring["File does not exist\n"]
    end if
  end updateFile

  export op getFile[fileName:String]->[fileContent:String]
    fileContent <- view files.lookup[fileName] as String
  end getFile

  export op findFiles [query:String]->[peers:Array.of[PeerType]]
    peers <- s.getFileMatches[query]
  end findFiles
end PeerClass
