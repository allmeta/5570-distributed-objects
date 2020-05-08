const myObject <- class myObject[info:String,name:String]
  export op getname->[res:String]
    res<-name
  end getname
  export op getinfo->[res:String]
    res<-info
  end getinfo
  export op cloneMe->[res:myObject]
    res<-myObject.create[info,name]
  end cloneMe
  export op update[i:String,n:String]
    name<-n
    info<-i
  end update
  export op requestUpdate[newinfo:String,newname:String]
    framework.updateMe[self,name,newinfo,newname]
  end requestUpdate
end myObject

const framework <- object framework
  % object name -> [node name]
  const index_oname_nnames <- Directory.create
  % object name -> master node 
  const index_oname_master<- Directory.create
  % node name -> [object name]
  const index_nname_onames <- Directory.create
  % object name -> [object]
  const index_oname_objects <- Directory.create
  % node name -> node
  const index_nname_node <- Directory.create
  const here <- locate self

  export op replicateMe[x:myObject,n:Integer]
    const a<-here$activenodes
    var min:Integer
    if a.upperbound<n then %ikke slurv
      min<-a.upperbound+1
    else
      min<-n
    end if

    % assign master at this node
    index_oname_master.insert[x$name,x]

    % add object to oname_object index
    index_oname_objects.insert[x$name,x]

    % objects to add to index_oname_objects
    const objects<-Array.of[myObject].empty
    objects.addupper[x]

    var i:Integer
    for (i<-0 : i<min : i<-i+1)
      const m<-a[i]$thenode
      if m!==here then
        const clone<-x.cloneMe
        objects.addupper[clone]
        % add nodename to oname_nnames index
        var nnames:Array.of[String]<-view index_oname_nnames.lookup[x$name] as Array.of[String]
        if nnames==nil then
          nnames<-Array.of[String].empty
        end if
        nnames.addupper[m$name]
        index_name_nodes.insert[x$name,nnames] 

        % add oname to nname_oname index
        var onames:Array.of[String]<-view index_nname_onames.lookup[m$name] as Array.of[String]
        if onames!==nil then
          onames<-Array.of[String].empty
        end if
        onames.addupper[x$name]
        index_nname_onames.insert[m$name,onames] 
        % fix 
        fix clone at m
      end if
    end for
    % add objects to index_oname_objects
    index_oname_objects.insert[x$name,objects]
  end replicateMe

  export op updateMe[x:myObject,name:String,newname:String,newinfo:String]
    const objects<-view index_oname_objects.lookup[name] as Array.of[myObject]
    % call update on all objects
    if objects!==nil then
      for o in objects
        o.update[newname,newinfo]
      end for
    end if
    % update oname_nnames index
    const nnames<-view index_oname_nnames.lookup[name] as Array.of[String]
    index_oname_nnames.remove[name]
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
    end for
    % update master index
    const master <- index_oname_master.lookup[name]
    index_oname_master.remove[name]
    index_oname_master.insert[newname,master]
  end updateMe
end framework
