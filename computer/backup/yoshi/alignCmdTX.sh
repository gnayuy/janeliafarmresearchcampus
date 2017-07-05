echo "Finding a port for Xvfb, starting at 5298..."
PORT=5298 COUNTER=0 RETRIES=5
while [ "$COUNTER" -lt "$RETRIES" ]; do
while (test -f "/tmp/.X${PORT}-lock") || (netstat -atwn | grep "^.*:${PORT}.*:\*\s*LISTEN\s*$")
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
    PORT=$(( ${PORT} + 1 ))
    kill $MYPID >/dev/null 2>&1
    rm -f /tmp/.X$MYPID-lock
fi
COUNTER="$(( $COUNTER + 1 ))"
done

WD=/groups/scicomp/jacsData/yuTest/YoshiMB/sources/standardbrainDPX/workdir/
count=1;
for subtx in /groups/scicomp/jacsData/yuTest/YoshiMB/sources/standardbrainDPX/TX/*.lsm;
do

WORKDIR=${WD}"tmp"$((count++))

if [ ! -d $WORKDIR ]; then 
mkdir $WORKDIR
fi

sh /groups/scicomp/jacsData/yuTest/Debug/run_configured_aligner.sh /groups/scicomp/jacsData/yuTest/YoshiMB/sources/standardbrainDPX/flyalign20x_INT.sh -w $WORKDIR -c /groups/scicomp/jacsData/servers/rokicki-ws/executables/install/scripts/brainaligner/systemvars.apconf -t /groups/scicomp/jacsData/servers/rokicki-ws/executables/install/scripts/single_neuron/BrainAligner/AlignTemplates/configured_templates -k /groups/scicomp/jacsData/yuTest/toolkits -m '"DPX PBS Mounting"' -i "$SUBTX,1,1,0.46x0.46x0.46,"


done;


kill $MYPID
rm -f /tmp/.X$MYPID-lock
echo "Cleaned up Xvfb"

