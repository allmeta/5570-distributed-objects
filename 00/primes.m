const Gen <- typeobject Gen
  operation next -> [ res : Integer ]
end Gen

const PrimGen <- object PrimGenCreator
  export function create [max:Integer]->[res:Gen]
    res<-
      object PrimGen
        var index:Integer<-0
        var initprimes:Array.of[Boolean]<-Array.of[Boolean].create[max]
        var primes:Array.of[Integer]<-Array.of[Integer].create[0]
        initially
          for i:Integer <-0 while i<initprimes.upperbound by i<-i+1
            initprimes.setElement[i,true]
          end for
          for i:Integer <- 2 while i<10 by i<- i+1
            if initprimes.getElement[i]==true then
              for j:Integer<-i*i while j<max by j<-j+i
                  initprimes.setElement[j,false]
              end for
            end if
          end for
          for i:Integer <- 2 while i<initprimes.upperbound by i<- i+1
            if initprimes.getElement[i]==true then
              primes.addUpper[i]
            end if
          end for
        end initially
        export operation next->[res:Integer]
          index<-index+1
          res<-primes.getElement[index-1]
        end next
      end PrimGen
    end create
  end PrimGenCreator

const main <- object main
  initially
    const primes <- PrimGen.create[100]
    stdout.putstring[primes.next.asstring||"\n"]
    stdout.putstring[primes.next.asstring||"\n"]
    stdout.putstring[primes.next.asstring||"\n"]
    stdout.putstring[primes.next.asstring||"\n"]
    stdout.putstring[primes.next.asstring||"\n"]
    stdout.putstring[primes.next.asstring||"\n"]
    stdout.putstring[primes.next.asstring||"\n"]
    stdout.putstring[primes.next.asstring||"\n"]
    stdout.putstring[primes.next.asstring||"\n"]
    stdout.putstring[primes.next.asstring||"\n"]
    stdout.putstring[primes.next.asstring||"\n"]
    stdout.putstring[primes.next.asstring||"\n"]
    stdout.putstring[primes.next.asstring||"\n"]
    stdout.putstring[primes.next.asstring||"\n"]
    stdout.putstring[primes.next.asstring||"\n"]
    stdout.putstring[primes.next.asstring||"\n"]
    stdout.putstring[primes.next.asstring||"\n"]
    stdout.putstring[primes.next.asstring||"\n"]
    stdout.putstring[primes.next.asstring||"\n"]
    stdout.putstring[primes.next.asstring||"\n"]
    stdout.putstring[primes.next.asstring||"\n"]
    stdout.putstring[primes.next.asstring||"\n"]
    stdout.putstring[primes.next.asstring||"\n"]
    stdout.putstring[primes.next.asstring||"\n"]
    stdout.putstring[primes.next.asstring||"\n"]
    stdout.putstring[primes.next.asstring||"\n"]
    stdout.putstring[primes.next.asstring||"\n"]
    stdout.putstring[primes.next.asstring||"\n"]
    stdout.putstring[primes.next.asstring||"\n"]
    stdout.putstring[primes.next.asstring||"\n"]
    stdout.putstring[primes.next.asstring||"\n"]
    stdout.putstring[primes.next.asstring||"\n"]
    stdout.putstring[primes.next.asstring||"\n"]
    stdout.putstring[primes.next.asstring||"\n"]
    stdout.putstring[primes.next.asstring||"\n"]
  end initially
end main

