#! /usr/bin/gawk -f
# tina.awk
# Tab Indented Node Associations

# usage:
# ./tina.awk  data/s_o_p.tab > dipper_predicate_lists_201901.yaml

BEGIN {
    # allow overiding SPO order on the command line
    # since predicate last is not typical for RDF
    SUBJECT = 1;
    OBJECT = 2;
    PREDICATE = 3;
    print "---"
    print "- 'schema':"
}

# collapse subjects ...
NF == 3 {
    # subject collects objects
    if($SUBJECT in s)
        s[$SUBJECT] = s[$SUBJECT] SUBSEP $OBJECT
    else
        s[$SUBJECT] = $OBJECT

    # associations collect predicates
    if($SUBJECT SUBSEP $OBJECT in a)
        a[$SUBJECT,$OBJECT]=a[$SUBJECT,$OBJECT] SUBSEP $PREDICATE
    else
        a[$SUBJECT,$OBJECT]=$PREDICATE
}

NF != 3 {
    print "bad input from " FILENAME " line: " FNR  > "/dev/stderr"
}

# for each subject list objects
# for each subject-object association, list predicates
# keep things ordered
END {
    n = asorti(s, t)
    for(i=1; i<=n; i++){
        subject = t[i]
        print "  - '" subject "':"
        delete(o);delete(objs);delete(ob)
        split(s[subject], o, SUBSEP)
        for(dd in o){objs[o[dd]]++} # dedup
        m = asorti(objs, ob)
        for(j=1; j<=m; j++){
            object = ob[j]
            print "    - '" object "':"
            delete(p);delete(preds);delete(prd)
            split(a[subject SUBSEP object], p, SUBSEP)
            for(dd in p){preds[p[dd]]++} # dedup
            x = asorti(preds, prd)
            for(k=1; k<=x; k++){
                predicate = prd[k]
                print "      - '" predicate "'"
            }
        }
    }
    print "..."
}
