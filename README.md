## Transdipporator

Translator is talking about describing a knoweledge graphs contents
by posting metadata as json

Schema [
    Subject [
        Object [
            Predicate [
            ]
        ]
    ]
]


With the GraphViz dot files I have some of this,
including counts, just in a different format.

It makes little (visual) sense to create a Monarch graph combining all of the sub
graphs as people already seem to struggle with them individually.
But I always wanted to see it anyway and this is aa good an excuse as any.


for each dot file pull out the edge declarations

    the owl declarations LITERALS and one off http-iri are not helpful
    the counts are interesting to me but not immediatly relevent to translator


# isolate the subject,object and predicates of intrest
grep ' -> ' data/dot_201901/*.gv|
    cut -f2- -d ':'|
    egrep -v 'owl|LITERAL|http'|
    cut -f1 -d'('|
    sed 's| -> |\t|g;s| \[label\=\"|\t|g'|
    sort -u > data/s_o_p.tab

# howmany distinct edge species
wc -l < data/s_o_p.tab
1065

# howmamy namespace transitions
cut -f1,2 data/s_o_p.tab | sort -u | wc -l
584

# I would look at thatthe
cut -f1,2 data/s_o_p.tab | sort -u |potodot.awk > namespace_transition.gv

 still pretty dense, but shows the roots and nodes


########################################################

Perhaps more helpful will be what I hear refered to as:
     the "predicate list"

The script `tina.awk` takes a list of triples and
(by default) keys the third column with
a space indented joining of the first two (columns).

a list of triples

```
head data/s_o_p.tab
APB	NCBITaxon	rdf:type
APO	UPHENO	rdfs:subClassOf
AQTLPub	IAO	rdf:type
AQTLTrait	CMO	oboInOwl:hasDbXref
AQTLTrait	LPT	oboInOwl:hasDbXref
BASE	BNODE	GENO:0000382
BASE	dbSNP	GENO:0000382
BASE	EFO	RO:0003304
BASE	GO	RO:0003304
BASE	HP	RO:0003304


```

Is transformed to a yaml structure

```
./tina.awk  data/s_o_p.tab
---
- 'schema':
  - 'APB':
    - 'NCBITaxon':
      - 'rdf:type'
  - 'APO':
    - 'UPHENO':
      - 'rdfs:subClassOf'
  - 'AQTLPub':
    - 'IAO':
      - 'rdf:type'

  - 'Coriell':
    - 'BNODE':
      - 'RO:0001000'
    - 'CL':
      - 'RO:0001000'
    - 'CLO':
      - 'RO:0001000'
      - 'rdf:type'
    - 'OMIM':
      - 'RO:0003301'
  - 'CoriellCollection':
    - 'Coriell':
      - 'RO:0002351'
    - 'ERO':
      - 'rdf:type'
  - 'CoriellFamily':
    - 'PCO':
      - 'rdf:type'
  - 'DECIPHER':
    - 'HP':
      - 'RO:0000091'
      - 'RO:0002200'
    - 'SIO':
      - 'rdf:type'
  - 'DOI':
    - 'IAO':
      - 'rdf:type'
```


Which lends itself to assisting with graph traversal queries
by enumerating the node types one hop from your current node
and by which type of edges.



