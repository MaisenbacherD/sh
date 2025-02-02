# Any subsequent(*) commands which fail will cause the shell script to exit immediately
set -e

ntabs=$1
nrows=$2
readsecs=$3
writesecs=$4
insertsecs=$5
dbAndCreds=$6
setup=$7
cleanup=$8
client=$9
tableoptions=${10}
sysbdir=${11}
ddir=${12}
dname=${13}
usepk=${14}
sync_size=${15}

# value for "postwrite" option for most tests
pwr=0

# The remaining args are the number of concurrent users per test run, for example "1 2 4"
shift 15


# prepare
preparesecs=$((readsecs / 4 ))

echo point-query.pre
bash run.sh $ntabs $nrows $preparesecs $dbAndCreds 0    0        point-query.pre 100    $client $tableoptions $sysbdir $ddir $dname $usepk $pwr $sync_size $@

for range in 10 100 10000 ; do
echo read-only.pre range $range
bash run.sh $ntabs $nrows $preparesecs $dbAndCreds 0    0        read-only.pre   $range $client $tableoptions $sysbdir $ddir $dname $usepk $pwr $sync_size $@
done


# main tests
echo update-index
bash run.sh $ntabs $nrows $writesecs $dbAndCreds 0      0        update-index    100    $client $tableoptions $sysbdir $ddir $dname $usepk $pwr $sync_size $@

echo update-nonindex
bash run.sh $ntabs $nrows $writesecs $dbAndCreds 0      0        update-nonindex 100    $client $tableoptions $sysbdir $ddir $dname $usepk $pwr $sync_size $@

echo update-one
bash run.sh $ntabs $nrows $writesecs $dbAndCreds 0      0        update-one      100    $client $tableoptions $sysbdir $ddir $dname $usepk $pwr $sync_size $@

echo update-zipf
bash run.sh $ntabs $nrows $writesecs $dbAndCreds 0      0        update-zipf      100    $client $tableoptions $sysbdir $ddir $dname $usepk $pwr $sync_size $@

echo write-only
bash run.sh $ntabs $nrows $writesecs $dbAndCreds 0      0        write-only      100 $client $tableoptions $sysbdir $ddir $dname $usepk $pwr $sync_size $@

echo read-write range 10
bash run.sh $ntabs $nrows $writesecs $dbAndCreds 0      0        read-write      10 $client $tableoptions $sysbdir $ddir $dname $usepk $pwr $sync_size $@
echo read-write range 100
bash run.sh $ntabs $nrows $writesecs $dbAndCreds 0      0        read-write      100 $client $tableoptions $sysbdir $ddir $dname $usepk $pwr $sync_size $@

for range in 10 100 10000 ; do
echo read-only range $range
bash run.sh $ntabs $nrows $readsecs  $dbAndCreds 0      0        read-only       $range $client $tableoptions $sysbdir $ddir $dname $usepk $pwr $sync_size $@
done

echo point-query
bash run.sh $ntabs $nrows $readsecs  $dbAndCreds 0      0        point-query     100    $client $tableoptions $sysbdir $ddir $dname $usepk $pwr $sync_size $@

echo delete
bash run.sh $ntabs $nrows $writesecs $dbAndCreds 0      0        delete               100  $client $tableoptions $sysbdir $ddir $dname $usepk $pwr $sync_size $@

echo insert
bash run.sh $ntabs $nrows $insertsecs $dbAndCreds 0     $cleanup insert               100  $client $tableoptions $sysbdir $ddir $dname $usepk $pwr $sync_size $@
