const myObject <- class myObject[time:Time,name:String]
  export op getname->[res:String]
    res<-name
  end getname
  export op gettime->[res:Time]
    res<-time
  end gettime
  export op cloneMe->[res:myObject]
    res<-myObject.create[time,name]
  end cloneMe
  export op update[t:Time,n:String]
    name<-n
    time<-t
  end update
  export op requestUpdate[newtime:Time,newname:String]
    framework.updateMe[self,name,newtime,newname]
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
  var a: NodeList<-here$activenodes

  export op replicateMe[x:myObject,n:Integer]
    var min:Integer
    if a.upperbound<n then %ikke slurv
      min<-a.upperbound+1
    else
      min<-n
    end if

    % add object to oname_object index
    index_oname_objects.insert[x$name,x]

    % objects to add to index_oname_objects
    const objects<-Array.of[myObject].empty
    objects.addupper[x]

    var assigned:Boolean<-false
    var i:Integer
    for (i<-0 : i<min : i<-i+1)
      const m<-a[i]$thenode
      if m!==here then
        if assigned==true then
          const clone<-x.cloneMe
          objects.addupper[clone]
          self.addobject[clone,m]
        else
          % assign master at first node
          index_oname_master.insert[x$name,m$name]
          fix x at m
        end if
      end if
    end for
    % add objects to index_oname_objects
    index_oname_objects.insert[x$name,objects]
  end replicateMe

  export op addobject[clone:myObject,node:NodeListElement]
    const nname<-node$name
    const oname<-clone$name

    % add nodename to oname_nnames index
    var nnames:Array.of[String]<-view index_oname_nnames.lookup[oname] as Array.of[String]
    if nnames==nil then
      nnames<-Array.of[String].empty
    end if
    nnames.addupper[nname]
    index_oname_nnames.insert[oname,nnames] 

    % add oname to nname_oname index
    var onames:Array.of[String]<-view index_nname_onames.lookup[nname] as Array.of[String]
    if onames!==nil then
      onames<-Array.of[String].empty
    end if
    onames.addupper[oname]
    index_nname_onames.insert[nname,onames] 
    % fix 
    fix clone at node
  end addobject

  export op updateMe[x:myObject,name:String,newname:String,newtime:String]
    const objects<-view index_oname_objects.lookup[name] as Array.of[myObject]
    % call update on all objects
    if objects!==nil then
      for o in objects
        o.update[newname,newtime]
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

  export op updatenodes[droppednodelist:NodeList,newnodelist:NodeList]
    % redistribute lost objects in nodes
    for n in droppednodelist
      const onames<-view index_nname_onames.lookup[n$name] as Array.of[String]
      % find available node to distribute for each object
      for oname in onames
        % check if master too
        const taken_nnames <- view index_oname_nnames.lookup[oname] as Array.of[String]
        var available_n:NodeListElement
        % diff two lists to check what nodes are not already occupied by the object
        for nn in newnodelist
          for tnn in taken_nnames
            if nn$name!=tnn then
              available_n<-nn
              exit
            end if
          end for
          if available_n!==nil then
            exit
          end if
        end for

        var clone:myObject
        const master_nn<-view index_oname_master.lookup[oname] as String
        if master_nn==n$name then
          % find available object
          % should probably check for more shit
          clone<-(view index_oname_objects.lookup[oname] as Array.of[myObject])[0].cloneMe
        else
          const master_node<-view index_nname_node.lookup[master_nn] as NodeListElement
          clone<-master_node.cloneMe
        end if
        % add object to indexes and fix it to node
        self.addobject[clone,available_n]
      end for
    end for
  end updatenodes

  process
    % check every 10 sec if active nodes have changed
    % then redistribute lost objects in nodes
    const b<-here$activenodes
    if a!==b then
      var newnodelist:NodeList
      var droppednodelist:NodeList
      for i in b
        var added:Boolean<-false
        for j in a
          if i==j then
            added<-true
            newnodelist.addupper[i]
            exit
          end if
        end for
        if added==true then
          droppednodelist.addupper[i]
        end if
      end for
      a<-newnodelist
      self.updatenodes[droppednodelist,newnodelist]
    end if
    % every 10 sec
    here$delay[Time.create[10,0]]
  end process
end framework
