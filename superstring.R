setwd("~/projects/matias")

library(igraph)

## read in data
kmers <- read.table("superstring.input",stringsAsFactors=FALSE)$V1

############################################# functions

#### calculate distance between two kmers
getdist <- function(km1, km2) {
    ## from km1 to km2
    if (substr(km1,4,nchar(km1)) == substr(km2,1,3)) {
        mydist <- 3 ## adjust this to play around with overlap length
    } else if (substr(km1,3,nchar(km1)) == substr(km2,1,4)) {
        mydist  <- 4
    } else if (substr(km1,2,nchar(km1)) == substr(km2,1,5)) {
        mydist <- 5
    } else {
        mydist <- 0
    }
    return(mydist)
    }


getlongest <- function(g, startv, gmode) {
    allp <- all_simple_paths(g,
                             startv,
                             mode=gmode)
    if (length(allp)==0) {
        return(NA) } else {
                       return(allp[[which.max(unlist(lapply(allp, length)))]])
                   }
}

superstring <- function(km1, km2) {
    ## from km1 to km2
    if (substr(km1,nchar(km1)-2,nchar(km1)) == substr(km2,1,3)) {
        mystring <- paste0(km1,substr(km2,4,nchar(km2))) # adjust this to adjust overlap length
    } else if (substr(km1,nchar(km1)-3,nchar(km1)) == substr(km2,1,4)) {
        mystring <- paste0(km1,substr(km2,5,nchar(km2)))
    } else if (substr(km1,nchar(km1)-4,nchar(km1)) == substr(km2,1,5)) {
        mystring <- paste0(km1,substr(km2,6,nchar(km2)))
    }
    return(mystring)
}


get_superstring <- function(sinput) {
    sst <- sinput[1]

    i <- 2
    while (i <= length(sinput)) {
        sst <- superstring(sst, sinput[i])
        i = i+1
    }
    return(sst)
}


##########################################
#### get adj matrix
adjm <- matrix(NA, nrow=length(kmers), ncol=length(kmers))

for (ridx in 1:length(kmers)) {
    for (cidx in 1:length(kmers)) {
        adjm[ridx,cidx] <- getdist(kmers[ridx],kmers[cidx])
    }}

rownames(adjm) <- kmers
colnames(adjm) <- kmers


### convert to graph

g <- graph_from_adjacency_matrix(adjm,
                                 mode="directed",
                                 weighted=TRUE,
                                 diag=FALSE)



gin <- sapply(kmers, function(x) getlongest(g, x, "in"))
gout <- sapply(kmers, function(x) getlongest(g, x, "out"))

ginlongest <- as_ids(getlongest(g, names(which.max(lapply(gin, length))), "in"))
goutlongest <- as_ids(getlongest(g, names(which.max(lapply(gout, length))), "out"))

sinput <- rev(ginlongest)

get_superstring(rev(ginlongest))
get_superstring(goutlongest)

### change graph aesthetics

set.seed(1)
for (n in goutlongest) {
    V(g)[n]$color <- "yellow" 
}

V(g)[goutlongest[1]]$color <- "red"
V(g)$label.cex = 0.6
E(g)$color <- "grey"

for (i in 1:(length(goutlongest)-1)) {
    E(g)[get.edge.ids(g, c(goutlongest[i], goutlongest[i+1]))]$color <- "black"
    }


set.seed(1)
plot(g,
     rescale = FALSE,
     ylim=c(-1,9),
     xlim=c(-2,9),
     asp = 0,
     vertex.size=50,
     vertex.shape="rectangle")
