export test
const test <- object test
  const here <- locate self
  const so <- here$stdout
  initially
    here.delay[Time.create[1,0]]
    % self.start
    % self.uptest
    self.downtest
  end initially
  export op downtest
    const x<-testObject.create["x1"]
    const y<-testObject.create["y1"]
    const x_replicas<-framework.replicateMe[x,2]
    const y_replicas<-framework.replicateMe[y,1]
    framework.dump
    so.putstring["node down test"]
    here.delay[Time.create[10,0]]
    framework.dump
    
  end downtest

  export op uptest
    so.putstring["node up test"]
    here.delay[Time.create[10,0]]
    const x<-testObject.create["x1"]
    const y<-testObject.create["y1"]
    const x_replicas<-framework.replicateMe[x,4]
    const y_replicas<-framework.replicateMe[y,1]
    framework.dump
  end uptest
  export op start
    % name server
    so.putstring["name server tests\n\n"]
    const x<-testObject.create["x1"]
    const y<-testObject.create["y1"]
    const x_replicas<-framework.replicateMe[x,2]
    const y_replicas<-framework.replicateMe[y,1]
    framework.dump
    % update through a replica test
    so.putstring["update through replica test \n\n"]
    x_replicas[1].requestUpdate["x2"]
    framework.dump
    % get master node test
    so.putstring["get master node test \n\n"]
    so.putstring[framework.getObject["x2"]$name || "\n"]


    % time server
    so.putstring["time server test\n\n"]
    self.calctime[framework.getObject["y1"]]
    self.calctime[framework.getObject["x1"]]

  end start

  export op calctime[ob:testObjectType]
    const reqStartTime<-here$timeofday
    const t<- ob$time
    const reqEndTime<-here$timeofday
    const rtt <- reqEndTime-reqStartTime
    const est<-t+rtt/2
    here$stdout.putString["NAME:\t"||ob$name||"\n"]
    here$stdout.putString["RTT:\t"||rtt.asstring||"\n"]
    here$stdout.putString["ESTIMATE:\t"||est.asstring||"\n"]
    here$stdout.putString["DIFF:\t"||(est-reqEndTime).asString||"\n"]
    here$stdout.putString["--------\n"]
  end calctime
end test
