export framework
const framework <- object framework
  % object name -> [node name]
  const index_oname_nnames <- Directory.create
  % object name -> master node name
  const index_oname_mnn<- Directory.create
  % object name -> master object
  const index_oname_m<- Directory.create
  % node name -> [object name]
  const index_nname_onames <- Directory.create
  % node name -> node
  const index_nname_node <- Directory.create
  % (node name + object name) -> object
  const index_nnon_object <- Directory.create

  const here <- locate self

  % create 
  process
    here$stdout.putstring["===INIT===\n"]
    for i in here$activenodes
      index_nname_node.insert[i$thenode$name,i$thenode]
    end for
    here.setNodeEventHandler[self]
  end process

  export op replicateMe[x:testObjectType,n:Integer] -> [res:Array.of[testObjectType]]
    const nnames<-index_nname_node.list
    % go through max nodes or until it reaches n
    var min:Integer
    if nnames.upperbound<n then %ikke slurv
      min<-nnames.upperbound+1
    else
      min<-n
    end if
    min<-min+1 % add master

    % objects to return
    const objects<-Array.of[testObjectType].empty

    var master:Boolean<-true
    var i:Integer
    for (i<-0 : i<=min : i<-i+1)

      const m<-view index_nname_node.lookup[nnames[i]] as Node
      if m!==here then
        if master==false then
          const clone<-x.cloneMe
          objects.addupper[clone]
          self.addobject[clone,nnames[i],false]
        else
          % assign master at first node
          self.addobject[x,nnames[i],true]
          master<-false
        end if
      end if
    end for
    res<-objects
  end replicateMe

  export op addobject[clone:testObjectType,nname:String,master:Boolean]
    const nd<-view index_nname_node.lookup[nname] as Node
    const oname<-clone$name

    % if master, then replace master obj
    if master==true then
      index_oname_mnn.insert[oname,nname]
      index_oname_m.insert[oname,clone]
    end if

    % add to nnon index
    index_nnon_object.insert[nname || oname,clone]

    % add nodename to oname_nnames index
    var nnames:Array.of[String]<-view index_oname_nnames.lookup[oname] as Array.of[String]
    if nnames==nil then
      nnames<-Array.of[String].empty
    end if
    nnames.addupper[nname]
    index_oname_nnames.insert[oname,nnames] 

    % add oname to nname_oname index
    var onames:Array.of[String]<-view index_nname_onames.lookup[nname] as Array.of[String]
    if onames==nil then
      onames<-Array.of[String].empty
    end if
    onames.addupper[oname]
    index_nname_onames.insert[nname,onames] 
    % fix 
    fix clone at nd
  end addobject

  export op updateMe[x:testObjectType,name:String,newname:String]
    const nnames<-view index_oname_nnames.lookup[name] as Array.of[String]
    % call update on all objects
    for n in nnames
      const o<-(view index_nnon_object.lookup[n || name] as testObjectType)
      o.update[newname]
    end for
    % update oname_nnames index
    index_oname_nnames.delete[name]
    index_oname_nnames.insert[newname,nnames]
    % update nname_onames index
    for n in nnames
      const onames<-view index_nname_onames.lookup[n] as Array.of[String]
      const newOnames<-Array.of[String].empty
      newOnames.addupper[newname]
      for oname in onames
        if oname!=name then
          newOnames.addupper[oname]
        end if
      end for
      index_nname_onames.insert[n,newOnames]
      % update nnon index
      const o<-view index_nnon_object.lookup[n || name] as testObjectType
      index_nnon_object.delete[n || name]
      index_nnon_object.insert[n || newname,o]
    end for
    % update master index
    const mnn <- view index_oname_mnn.lookup[name] as String
    index_oname_mnn.delete[name]
    index_oname_mnn.insert[newname,mnn]

    const mo <- view index_oname_m.lookup[name] as testObjectType
    index_oname_m.delete[name]
    index_oname_m.insert[newname,mo]
  end updateMe

  export op getObject[name:String]->[res:testObjectType]
    res<-view index_oname_m.lookup[name] as testObjectType
  end getObject

  export op nodeUp[n:Node,t:Time]
    here$stdout.putstring["===NODE UP===\n"]
    const nname <- n$name
    index_nname_node.insert[nname,n]
  end nodeUp
    
  export op nodeDown[nd:Node,t:Time]
    here$stdout.putstring["===NODE DOWN===\n"]
    var nname:String
    % find node that went down
    for n in index_nname_node.list
      var found:Boolean<-false
      for an in here$activenodes
        if n==an$thenode$name then
          found<-true
          exit
        end if
      end for
      if found==false then
        % found dead node
        nname<-n
        exit
      end if
    end for
    % update indexes
    % nname_node
    index_nname_node.delete[nname]
    const onames <- view index_nname_onames.lookup[nname] as Array.of[String]
    if onames==nil then
      return
    end if
    for o in onames
      % nnon
      index_nnon_object.delete[nname || o]
      % oname_nnames
      const nn <- view index_oname_nnames.lookup[o] as Array.of[String]
      const newnn<-Array.of[String].empty
      for n in nn
        if n!=nname then
          newnn.addupper[n]
        end if
      end for
      index_oname_nnames.insert[o,newnn]
      % check master
      var clone:testObjectType
      if (view index_oname_mnn.lookup[o] as String)==nname then
        % choose new master 
        const nnames <- view index_oname_nnames.lookup[o] as Array.of[String]
        for n in nnames
          const ob <- view index_nnon_object.lookup[n || o] as testObjectType
          if ob!==nil then
            clone<-ob
            % update master index
            index_oname_mnn.insert[o,n]
            index_oname_m.insert[o,ob]
            exit
          end if
        end for
      else
        % replicate node if enough available
        clone<-view index_oname_m.lookup[o] as testObjectType
      end if
      % find available node to replicate on
      const takenn<-view index_oname_nnames.lookup[o] as Array.of[String]
      var availableN:String
      for n in index_nname_node.list
        for tn in takenn
          if n!=tn then
            availableN<-n
            self.addobject[clone.cloneMe,availableN, false]
            exit
          end if
        end for
        if availableN!==nil then
          exit
        end if
      end for
      here$stdout.putstring["===No available nodes for replication===\n"]
    end for
  end nodeDown

  export op dump
    here$stdout.putstring["==DUMP==\n"]
    for i in index_oname_nnames.list
      here$stdout.putstring["object " || i.asstring || "\n"]
      for j in (view index_oname_nnames.lookup[i] as Array.of[String])
        here$stdout.putstring["\t->node " || j.asstring || "\n"]
      end for
    end for
    for i in index_nname_onames.list
      here$stdout.putstring["node " || i.asstring || "\n"]
      for j in (view index_nname_onames.lookup[i] as Array.of[String])
        here$stdout.putstring["\t->object " || j.asstring || "\n"]
      end for
    end for
    here$stdout.putstring["==DUMP FINISH==\n"]
  end dump
end framework
