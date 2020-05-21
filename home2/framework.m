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
  % object name -> [object]
  const index_oname_objects <- Directory.create
  % node name -> node
  const index_nname_node <- Directory.create
  const here <- locate self
  var a: Array.of[NodeListElement]

  % create 
  initially
    for i in here$activenodes
      a.addupper[i]
    end for
  end initially

  export op replicateMe[x:kms,n:Integer]
    % go through max nodes or until it reaches n
    var min:Integer
    if a.upperbound<n then %ikke slurv
      min<-a.upperbound+1
    else
      min<-n
    end if

    % add object to oname_object index
    index_oname_objects.insert[x$name,x]

    % objects to add to index_oname_objects
    const objects<-Array.of[kms].empty
    objects.addupper[x]

    var assigned:Boolean<-false
    var i:Integer
    for (i<-0 : i<min : i<-i+1)
      const m<-a[i]
      if m$thenode!==here then
        if assigned==false then
          const clone<-x.cloneMe
          objects.addupper[clone]
          self.addobject[clone,m,false]
        else
          % assign master at first node
          self.addobject[x,m,true]
          assigned<-false
        end if
      end if
    end for
    % add objects to index_oname_objects
    index_oname_objects.insert[x$name,objects]
  end replicateMe

  export op addobject[clone:kms,node:NodeListElement,master:Boolean]
    const nname<-node$thenode$name
    const oname<-clone$name

    % if master, then replace master obj
    if master==true then
      index_oname_mnn.insert[oname,nname]
      index_oname_m.insert[oname,clone]
    end if

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

  export op updateMe[x:kms,name:String,newtime:Time,newname:String]
    const objects<-view index_oname_objects.lookup[name] as Array.of[kms]
    % call update on all objects
    if objects!==nil then
      for o in objects
        o.update[newtime,newname]
      end for
    end if
    % update oname_nnames index
    const nnames<-view index_oname_nnames.lookup[name] as Array.of[String]
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
    end for
    % update master index
    const mnn <- view index_oname_mnn.lookup[name] as String
    index_oname_mnn.delete[name]
    index_oname_mnn.insert[newname,mnn]

    const mo <- view index_oname_m.lookup[name] as kms
    index_oname_m.delete[name]
    index_oname_m.insert[newname,mo]
  end updateMe

  export op updatenodes[droppednodelist:Array.of[NodeListElement],newnodelist:Array.of[NodeListElement]]
    % redistribute lost objects in nodes
    for n in droppednodelist
      const onames<-view index_nname_onames.lookup[n$thenode$name] as Array.of[String]
      % find available node to distribute for each object
      for oname in onames
        % check if master too
        const taken_nnames <- view index_oname_nnames.lookup[oname] as Array.of[String]
        var available_n:NodeListElement
        % diff two lists to check what nodes are not already occupied by the object
        for nn in newnodelist
          for tnn in taken_nnames
            if nn$thenode$name!=tnn then
              available_n<-nn
              exit
            end if
          end for
          % exit out of innermost loop
          if available_n!==nil then
            exit
          end if
        end for

        var clone:kms
        const master_nn<-view index_oname_mnn.lookup[oname] as String
        var mbool:Boolean<-false
        if master_nn==n$thenode$name then
          % should probably check for more shit
          % find new master object from new list of available nodes
          % indexes are not yet updated
          clone<-(view index_oname_objects.lookup[oname] as Array.of[kms])[1].cloneMe
          % update master index
          mbool<-true
        else
          % find master object
          clone <- view index_oname_m.lookup[oname] as kms
        end if
        % add object to indexes and fix it to node
        self.addobject[clone,available_n, mbool]

        % remove index_oname_nnames nname
        const active_nnames<-Array.of[String].empty
        for nn in (view index_oname_nnames.lookup[oname] as Array.of[String])
          if nn!=n$thenode$name then
            active_nnames.addupper[nn] 
          end if
        end for
        index_oname_nnames.insert[oname, active_nnames]
      end for
      % remove node related indexes
      index_nname_onames.delete[n$thenode$name]
      index_nname_node.delete[n$thenode$name]
    end for
  end updatenodes

  process
    % check every 10 sec if active nodes have changed
    % then redistribute lost objects in nodes
    const b<-here$activenodes
    if a.upperbound!==b.upperbound then % only checking length, since array equality is tedious in emerald
      var newnodelist:Array.of[NodeListElement]
      var droppednodelist:Array.of[NodeListElement]
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
    here.delay[Time.create[10,0]]
  end process
end framework
