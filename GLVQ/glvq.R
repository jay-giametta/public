library(deldir)
library(ggplot2)

glvq=function(x,y,K,alpha_j,alpha_k,decay,update,iterations){
  
  #format input data
  x=as.matrix(x)
  y=as.factor(y)
  
  #seed for reuse
  set.seed(0)
  
  #calculate number of classes
  C=length(table(y))
  
  #randomly initialize the prototype vector
  w=apply(x,2,function(x)runif(K*C,range(x)[1]+(range(x)[2]-range(x)[1])/4,range(x)[2]-(range(x)[2]-range(x)[1])/4))

  #w=apply(x,2,function(x)runif(K*C,range(x)[1],range(x)[2]))
  w.y=as.factor(names(table(y))[sample(replicate(K,sample(C,C)))])

  #initialize time count
  t=1
  
  #initialize classification error vector
  error=c()
  
  #best
  best=0
  best.w=c()
  
  #loop until convergence
  while(T){
    #shuffled input indices
    M=sample(nrow(x))
    
    misClass=0
    
    #run through an entire training set (epoch)
    for(m in M){
      #compute distance
      d=rowSums(t(t(w)-x[m,])^2)
      
      #find in class minimum
      d.j=min(d[which(w.y==y[m])])
      j=which(d==d.j&w.y==y[m])
      d.j=sqrt(d.j)
      
      #find out of class minimum
      d.k=min(d[which(w.y!=y[m])])
      k=which(d==d.k&w.y!=y[m])
      d.k=sqrt(d.k)
      
      #if incorrect
      if(d.j>d.k){
        
        #update the number of misclassifications
        misClass=misClass+1
      }
      #update weights
      w[j,]=w[j,]+(alpha_j*d.k/((d.j+d.k)^2)*(x[m,]-w[j,]))
      w[k,]=w[k,]-(alpha_k*d.j/((d.j+d.k)^2)*(x[m,]-w[k,]))

    }
    if(1-(misClass/nrow(x)) > best){
      best.w=w
    }  
    
    #update the error vector
    error=c(error,1-(misClass/nrow(x)))
    
    #terminate after preset iterations
    if(t==iterations){
      return(list(w=best.w,w.y=w.y,error=error))
    }
    
    if(t%%update==0){
      #update alpha
      alpha_j=alpha_j*decay
      alpha_k=alpha_k*decay
    }
    
    #update time
    t=t+1
  }
}

#compute models for 1,3,5 prototype glvqs
lvq.1=glvq(iris[,1:4],iris[,5],1,0.001,0.0005,0.8,20,500)
lvq.3=glvq(iris[,1:4],iris[,5],3,0.002,0.001,0.8,20,500)
lvq.5=glvq(iris[,1:4],iris[,5],5,0.004,0.002,0.825,20,500)

#plot results
windows()
matplot(cbind(lvq.1$error,lvq.3$error,lvq.5$error),
        type='l',
        ylab='Classification Rate',
        xlab='Training Epochs',
        col=c('black','red','blue'),
        lty=c(1,1,1),
        lwd=c(2,2,2),
        main='Iris Dataset GLVQ Convergence')

legend(350,0.5,c('K=1','K=3','K=5'),col=c('black','red','blue'),lty=c(1,1,1),lwd=c(2,2,2))

#read wsom data
wsom=read.table('WSOM2016.txt',header=F)
wsom[,1:2]=(wsom[,1:2]-min(wsom[,1:2]))/(max(wsom[,1:2])-min(wsom[,1:2]))

#calculate 2d lvq
#lvq.2d=glvq(wsom[,1:2],wsom[,3],1,0.1,0.1,0.95,1,50) #93.11
#lvq.2d=glvq(wsom[,1:2],wsom[,3],3,0.1,0.025,0.95,1,50)
lvq.2d=glvq(wsom[,1:2],wsom[,3],5,0.1,0.025,0.95,1,50)

#calculate voronoi tesselation
voronoi=deldir(lvq.2d$w[,1],lvq.2d$w[,2])

#plot 2d
windows()
ggplot()+geom_point(aes(x=wsom[,1],y=wsom[,2],col=factor(wsom[,3])))+
  geom_point(aes(x=lvq.2d$w[,1],y=lvq.2d$w[,2],col=factor(lvq.2d$w.y)),size=3)+
  geom_segment(data=voronoi$dirsgs,aes(x=x1,y=y1,xend=x2,yend=y2),linetype=2,size=1.5)+
  theme_bw()+
  labs(col='Category')+
  xlab('X1')+
  ylab('X2')



