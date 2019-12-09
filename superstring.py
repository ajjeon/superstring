import igraph as ig
import numpy as np
import pandas as pd

# g = Graph()

# g.add_vertices(3)
# g.add_edges([(1,0),(1,2)])
# g.vs["name"]=["Alice","Bob","Claire"]
# print(g)


# plot(g)



## read in superstring.input
kmers = np.genfromtxt('superstring.input',dtype='str')

## TODO  consider various orientations


def getdist( fromkmer, tokmer ):
    "get distance between two kmers for the adjacency matrix"
    match3 = ''.join(list(fromkmer)[3:])==''.join(list(tokmer)[:3])
    match4 = ''.join(list(fromkmer)[2:])==''.join(list(tokmer)[:4])
    match5 = ''.join(list(fromkmer)[1:])==''.join(list(tokmer)[:5])

    if match5:
        mydist = 5
    elif match4:
        mydist = 4
    elif match3:
        mydist = 3
    else:
        mydist = 0

#    print(mydist)
    return mydist


w, h = len(kmers), len(kmers);
admatrix = [[0 for x in range(w)] for y in range(h)]

for fromidx in range(1, len(kmers)):
    for toidx in range(1, len(kmers)):
        admatrix[fromidx][toidx] = getdist(kmers[fromidx], kmers[toidx])

df = pd.DataFrame(admatrix,
                  columns=kmers,
                  index=kmers)

g = ig.Graph.Adjacency(df.values.tolist())


# Add edge weights and node labels.
g.es['weight'] = df.values[df.values.nonzero()]
g.vs['label'] = kmers  # or a.index/a.columns

plot(g)



# for i in range(0, len(kmers)):
#  for j in range(0, len(kmers)):
#    indirect[i,j] <- length(get.all.shortest.paths(g,
#                                                   i,
#                                                   j,
#                                                   "out"))

