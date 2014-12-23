

g<-read.graph(file='analysiskm.graphml',format='graphml')
plot(g, vertex.size=4, vertex.label=NA,edge.arrow.size=0.7,edge.color="black",vertex.color="red", frame=TRUE)
title(main = "1024 Clusters by KMeans")
