#! /bin/bash
# fomo.sh
# Fetch Ontology Metadata Overview

set -e

ARCHIVE=https://archive.monarchinitiative.org

# to call other scripts in the same source directory
SCRIPTS=$(dirname $(realpath "${BASH_SOURCE[0]}"))

# Step 0)
#   make sure we have a data dir to work in (is .gitignored)

if [ ! -d './data/' ] ; then
    echo "Making data dir"
    mkdir data
fi
cd ./data/ || exit

# Step 1)
#   fetch [_beta_|latest|release|YYYYMM]   rdf metadata,
#   Builds a file in which determine the datestamp of the dipper dataset targeted
#   (overkill for this use case but the result might become its own thing)

TARGET=${1:-beta}

OUT=$(mktemp -p . -d)
(
    cd "$OUT" || exit
    wget --quiet --recursive --no-parent --timestamping --no-host-directories --cut-dirs=2 \
        --accept "*_dataset.ttl,*_count.ttl" "$ARCHIVE/$TARGET"/rdf/
)

"$SCRIPTS"/turtle_merge.awk "$OUT"/*.ttl > "$OUT"/dipper_rdf_dataset.ttl
RELEASE=$(fgrep "dcterms:created " "$OUT"/dipper_rdf_dataset.ttl|tr -d '.;-'|sort -u| cut -f2 -d'"'|cut -c1-6)
echo "Using Release DateStamp of $RELEASE"

# Step 2)
#   a. Use the release datestamp to create a space for the distilled rdf from $ARCHIVE
#   b. pull the Graphviz dot-lang files of distilled dipper RDF over

mkdir -p "./$RELEASE/graphviz"
mv "./$OUT/" "./$RELEASE/dipper_rdf_dataset"
(
    cd "./$RELEASE/graphviz" || exit
    wget --quiet --recursive --no-parent --timestamping --no-host-directories --cut-dirs=3 \
        --accept "*.gv" "$ARCHIVE/$RELEASE"/visual_reduction/release/
)

# step 3)
#   filter and reformat to a table suitable for scripts/tina.awk   (s_o_p.tab)
#   Again with a bit more context, which ingest and how many

grep ' -> ' "$RELEASE"/graphviz/*.gv |
    cut -f2- -d ':'|
    egrep -v 'owl|LITERAL|http'|
    cut -f1 -d'('|
    sed 's| -> |\t|g;s| \[label=<|\t|g'|
    cut -f1 -d '!' |
    sort -u > "$RELEASE"/s_o_p.tab


grep ' -> ' "$RELEASE"/graphviz/*.gv |
    cut -c22- |
    sed 's|\.gv:|\t|g;s| -> |\t|g;s| \[label=<|\t|g;s| (\([0-9]*\))>];|\t\1|g' |
    sort -u > "$RELEASE"/g_s_o_p_c.tab

