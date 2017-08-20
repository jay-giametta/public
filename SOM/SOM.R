#read input file
data=read.csv('Clowns.csv',header=T)

#som parameters
iterations=10
rows=8
cols=8
sigma=seq(0.65,0.1,length=iterations*nrow(data))
alpha=seq(0.6,0.05,length=iterations*nrow(data))

#random seed for reuse
set.seed(0)

#som data structure
som=list(rows=rows, 															#rows in som
         cols=cols, 															#cols in som
         weights=matrix(c(runif(rows*cols,range(data$x1)[1],range(data$x1)[2]), #weight vector
                          runif(rows*cols,range(data$x2)[1],range(data$x2)[2])),
                        nrow=rows*cols, 
                        ncol=2),
         nodes=matrix(0,nrow=rows*cols,ncol=nrow(data)),  						#observation assignments
         distances=matrix(0,nrow=rows*cols,ncol=rows*cols), 					#lattice distances
         counts=rep(0,cols*rows), 												#observation counts per element
         neighborhoods=c(), 													#current neighborhood function
         error=c(), 															#quantification error per epoch
         t=1) 																	#current observation count

#calculate distance matrix
for(i in 1:(rows*cols)){
  i.coord=cbind(ceiling(i/rows),i%%rows)
  i.coord[i.coord==0]=rows
  
  for(j in i:(rows*cols)){
    j.coord=cbind(ceiling(j/rows),j%%rows)
    j.coord[j.coord==0]=rows
    value=sqrt((i.coord[1]-j.coord[1])^2+(i.coord[2]-j.coord[2])^2)
    som$distances[i,j]=value
    som$distances[j,i]=value
  }
}

#updates the neighborhood matrix
som.updateNeighborHood=function(t){
  som$neighborhoods<<-exp(-som$distances/(2*sigma[t]^2))
}

#updates the weight vectors
som.updateWeight=function(observation,winner,t){
  som$weights<<-som$weights+alpha[t]*som$neighborhoods[,winner]*cbind(data[observation,1]-som$weights[,1],data[observation,2]-som$weights[,2])
}

#calls the previous update functions
som.update=function(observation,winner,t){
  som.updateNeighborHood(t)
  som.updateWeight(observation,winner,t)
}

#calculates the distance from an observation to all elements
som.calculateDistances=function(x){
  sqrt((data[x,1]-som$weights[,1])^2+(data[x,2]-som$weights[,2])^2)
}

#calculates the quantification error for the last epoch of observations
som.calculateError=function(){
  error=0
  
  for(i in 1:nrow(som$nodes)){
    assigned=data[which(som$nodes[i,]==1),]
    error=error+sum(sqrt(rowSums(cbind((assigned[,1]-som$weights[i,1])^2,(assigned[,2]-som$weights[i,2])^2))))
  }
  error
}

#main function
som.assign=function(){ 
  #clear node assignments
  som$nodes<<-matrix(0,nrow=rows*cols,ncol=nrow(data))
  #shuffle input data
  data.shuffled=sample(1:nrow(data))
  #online update
  for(observation in data.shuffled){  
    distances=som.calculateDistances(observation)
    winner=which.min(distances)
    som.update(observation,winner,som$t)
    som$nodes[winner,observation]<<-1
    som$t<<-som$t+1
  }
  #calculate node counts and quantification error
  som$counts<<-rowSums(som$nodes)
  som$error<<-c(som$error,som.calculateError())
}

#main loop
for(i in 1:iterations){
  set.seed(i)
  som.assign()
}

#plot lattice in feature space
windows()
plot(som$weights[,1],
     som$weights[,2],
     xlim=c(range(data$x1)[1],range(data$x1)[2]),
     ylim=c(range(data$x2)[1],range(data$x2)[2]),
     xlab='x1',
     ylab='x2',
     main='SOM Lattice',
     cex=0)

#add mesh to plot
for(i in 1:(som$rows*som$cols)){
  if(i%%som$rows!=0){
    segments(som$weights[i,1],
             som$weights[i,2],
             som$weights[i+1,1],
             som$weights[i+1,2])
  } 
  if(i<=som$rows*(som$cols-1)){
    segments(som$weights[i,1],
             som$weights[i,2],
             som$weights[i+som$rows,1],
             som$weights[i+som$rows,2])
  }
}

#fence plot
ramp=colorRamp(c('black','red'))

#element counts
intensities=t(matrix(som$counts,nrow=som$rows,ncol=som$cols))
intensities=255*((intensities-min(intensities))/(max(intensities)-min(intensities)))

windows()
image(1:som$cols,
      1:som$rows,
      intensities,
      col=rgb(ramp(seq(0,1,length=255)),max=255),
      xlab='Cols',
      ylab='Rows',
      main='Fence Plot')

#element distances
v=matrix(0,nrow=som$rows,ncol=som$cols)
for(i in 1:(length(v)-1)){
  if(i%%som$rows!=0){
    v[i]=sqrt((som$weights[i,1]-som$weights[i+1,1])^2+(som$weights[i,2]-som$weights[i+1,2])^2)
  }
}

h=matrix(0,nrow=som$rows,ncol=som$cols)
for(i in 1:(length(h)-som$rows)){
  h[i]=sqrt((som$weights[i,1]-som$weights[i+som$rows,1])^2+(som$weights[i,2]-som$weights[i+som$rows,2])^2)
}

uMatrix=list(v=v[-som$rows,],h=h[,-som$cols])
uMatrix.unlist=unlist(uMatrix)

uMatrix$v=255*((uMatrix$v-min(uMatrix.unlist))/(max(uMatrix.unlist)-min(uMatrix.unlist)))
uMatrix$h=255*((uMatrix$h-min(uMatrix.unlist))/(max(uMatrix.unlist)-min(uMatrix.unlist)))


for(i in 1:(som$rows-1)){
  y=(2*i+1)/2
  for(j in 1:som$cols){
    x1=j-.5
    x2=j+.5
    
    segments(x1,
             y,
             x2,
             y,
             col=gray(uMatrix$v[i,j]/255),
             lwd=5)
  }
}

for(i in 1:(som$rows)){
  y1=i-.5
  y2=i+.5
  for(j in 1:(som$cols-1)){
    x=(2*j+1)/2
    
    segments(x,
             y1,
             x,
             y2,
             col=gray(uMatrix$h[i,j]/255),
             lwd=5)
  }
}

#convergence plot
windows()
plot.ts(som$error,
        xlab='Cycles',
        ylab='Quantization Error',
        main='Error Per Number of Cycles')

cbind(som$error)