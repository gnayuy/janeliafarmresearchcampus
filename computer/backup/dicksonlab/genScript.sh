#

 
##qsub -A dicksonb -b y -cwd -V -pe batch 4 
##qsub -A dicksonb -b y -cwd -V -pe batch 32 -l haswell=true /nobackup/scicompsoft/yuTest/dicksonlab/calciumimaging/align.sh

FILE=$1
PATH=$2

OUT=$3


echo 'echo "Running on "`hostname`
echo "Finding a port for Xvfb, starting at 5281..."
PORT=5281 COUNTER=0 RETRIES=10
function cleanXvfb {
    kill $MYPID
    rm -f /tmp/.X${PORT}-lock
    rm -f /tmp/.X11-unix/X${PORT}
    echo "Cleaned up Xvfb"
}
trap cleanXvfb EXIT
while [ "$COUNTER" -lt "$RETRIES" ]; do
    while (test -f "/tmp/.X${PORT}-lock") || (test -f "/tmp/.X11-unix/X${PORT}") || (netstat -atwn | grep "^.*:${PORT}.*:\*\s*LISTEN\s*$")
        do PORT=$(( ${PORT} + 1 ))
    done
    echo "Found the first free port: $PORT"
    /usr/bin/Xvfb :${PORT} -screen 0 1x1x24 -fp /usr/share/X11/fonts/misc > Xvfb.${PORT}.log 2>&1 &
    echo "Started Xvfb on port $PORT"
    MYPID=$!
    export DISPLAY="localhost:${PORT}.0"
    sleep 3
    if kill -0 $MYPID >/dev/null 2>&1; then
        echo "Xvfb is running as $MYPID"
        break
    else
        echo "Xvfb died immediately, trying again..."
        cleanXvfb
        PORT=$(( ${PORT} + 1 ))
    fi
    COUNTER="$(( $COUNTER + 1 ))"
done

export LD_LIBRARY_PATH=/groups/jacs/jacsDev/server/jacs-staging/executables/Qt-4.7.4-redhat/lib:/groups/jacs/jacsDev/server/jacs-staging/executables/vaa3d-redhat/lib:$LD_LIBRARY_PATH

export LD_LIBRARY_PATH=/groups/jacs/jacsDev/server/jacs-staging/executables/Qt-4.7.4-redhat/lib:/groups/jacs/jacsDev/server/jacs-staging/executables/vaa3d-redhat/lib:$LD_LIBRARY_PATH' >> $OUT

echo "cd $PATH" >> $OUT

echo "sh /nobackup/scicompsoft/yuTest/debug/Debug1/run_configured_aligner.sh /nobackup/scicompsoft/yuTest/dicksonlab/projects/alignmentpipeline/brainaligner/brainalignPolarity20xBrainVNCRescale_dpx.sh 8 -o $PATH -c /nobackup/scicompsoft/yuTest/dicksonlab/projects/alignmentpipeline/brainaligner/systemvars.apconf -t /nobackup/scicompsoft/yuTest/dicksonlab/projects/alignmentpipeline/template -k /groups/jacs/jacsDev/servers/jacs-staging/executables/scripts/single_neuron/Toolkits -m \'\"DPX PBS Mounting\"\' -i $FILE,2,2,0.46x0.46x0.52,768x768x180 -g \"m\" " >> $OUT


