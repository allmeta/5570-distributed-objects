
export ServerType
export PeerType
export hashType
const hashType <- typeobject hashAlg
  op hash [String] -> [String]
end hashAlg
const ServerType <- typeobject ServerType
  op getIndex_hash_name->[ihn:Directory]
  op getIndex_hash_peers->[ihp:Directory]
  op addFile [fileName:String,fileHash:String,peer:PeerType]   
  op removeFile [fileName:String,fileHash:String,peer:PeerType]
  op updateFile [oldName:String,newName:String,oldFileHash:String,newFileHash:String,peer:PeerType]
  op getFileMatches[query:String]->[peers:Array.of[PeerType]]
end ServerType
const PeerType <- typeobject PeerType
  op getName -> [n:String]
  op getFiles -> [f:Directory]
  op addFile [fileName:String,fileContent:String]
  op removeFile [fileName:String]
  op updateFile [oldName:String,newName:String,newFileContent:String]
  op getFile [fileName:String]->[fileContent:String]
  op findFiles [query:String]->[peers:Array.of[PeerType]]
end PeerType

