## Transdipporator

Translator is talking about describing a knowledge graphs contents
by posting metadata as json

```
Schema [
    Subject [
        Object [
            Predicate [
            ]
        ]
    ]
]
```

With the GraphViz dot files I have some of this,
including counts, just in a different format.

It makes little (visual) sense to create a Monarch graph combining all of the sub
graphs as people already seem to struggle with them individually.
But I always wanted to see it anyway and this is as good an excuse as any.


for each dot file pull out the edge declarations

    the owl declarations LITERALS and one off http-iri are not so helpful
    the counts are interesting to me but not immediately relevant to translator

```
# isolate the subject,object and predicates of interest

RELEASE=202001
ARCHIVE=https://archive.monarchinitiative.org


mkdir data/dot_$RELEASE
cd  data/dot_$RELEASE
wget -r -np "$ARCHIVE/$RELEASE/visual_reduction/release/"
unlink release
ln -s archive.monarchinitiative.org/$RELEASE/visual_reduction/release release
cd -

grep ' -> ' data/dot_$RELEASE/release/*.gv |
    cut -f2- -d ':'|
    egrep -v 'owl|LITERAL|http'|
    cut -f1 -d'('|
    sed 's| -> |\t|g;s| \[label=<|\t|g'|
    cut -f1 -d '!' |
    sort -u > data/s_o_p.tab

# howmany distinct edge species
wc -l < data/s_o_p.tab
1082

# howmany namespace transitions
cut -f1,2 data/s_o_p.tab | sort -u | wc -l
626

# I would look at that
cut -f1,2 data/s_o_p.tab | sort -u |potodot.awk > namespace_transition.gv
```


Still pretty dense, but shows the roots and leaf nodes

dot -T svg namespace_transition.gv > namespace_transition.svg


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
./scripts/tina.awk  data/s_o_p.tab > "dipper_predicate_lists_$RELEASE.yaml"
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
by listing the possible node types one hop from your current node
via which type of edges.
------------------------------------------------

# Second iteration

To facilitate a more automate-able approach write a script which by default pulls
metadata files from archive.mi/beta in the form of dipper's  *_dataset.ttl and *_count.ttl
files and merges them into a `dipper_rdf_dataset.ttl` file with the `scripts/turtle_merge.awk`
script I moves out of dipper/scripts because it is has never been used there.

At present I do not have further plans for the `dipper_rdf_dataset.ttl` but things like
that end up useful eventually.

We then query this consolidated metadata file for the datestamp of the release and
create a directory under `./data/` to store the `release` set of GraphViz files for the
dipper run.

The collection of graphviz files are reduced to two tables, the original one  `s_o_p.tab`
mentioned above and a second that does not throw away the ingest name and instance count
named `g_s_o_p_c.tab`  which I hope to use to make some generalizations.

To use :

```
 ./scripts/fomo.sh

```

Will default to fetching what it finds in: https://archive.monarchinitiative.org/beta/

arguments for other directories in archive.monarchinitiative.org may be given


```
 ./scripts/fomo.sh  latest

```

or

```
 ./scripts/fomo.sh  201911

```

Results will be found in a  `./data/` directory under the appropriate datastamp.



-----------------------------------------------


