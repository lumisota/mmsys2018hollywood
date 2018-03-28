from mininet.topo import Topo
from mininet.node import CPULimitedHost
from mininet.link import TCLink
from mininet.net import Mininet
from mininet.log import setLogLevel, info
from mininet.util import dumpNodeConnections
from mininet.cli import CLI
import sys
import csv
import os.path
from subprocess import call
from time import time, sleep

#SA: argument is target file name e.g. figures/dash-500-np2a-tcph-oo-playout.pdf

 
class LinearTopo(Topo):
    def build(self):
        switch1 = self.addSwitch('switch1')
        appClient = self.addHost('Client')
        appServer = self.addHost('Server')
        self.addLink(appClient, switch1)
        self.addLink(appServer, switch1)

def hollywood():
    setLogLevel( 'info' )
    linear = LinearTopo()
    network = Mininet(topo=linear, host=CPULimitedHost, link=TCLink, autoPinCpus=True)
    network.start()
    dumpNodeConnections(network.hosts)
    network.pingAll()
    hollywood = ''
    oo = ''
    algo = '' 

    appClient = network.get('Client')
    appServer = network.get('Server')


    # disable offloading - when enabled, permits segments larger than 1500 bytes
    appClient.cmd('ethtool -K ' + str(appClient.intf()) + ' gso off')
    appServer.cmd('ethtool -K ' + str(appServer.intf()) + ' gso off')


    runName = sys.argv[1];
    print runName;

    if sys.argv[1].split('-')[1] == 'tcph':
        hollywood=' --hollywood ';
    if sys.argv[1].split('-')[3] == 'oo':
        oo=' --oo ';
    bufferlen = sys.argv[1].split('-')[4]; 

    # Careful, the code for panda and abma is not updated in the client. Results will be incorrect.  
    if sys.argv[1].split('-')[5] == 'bola':
        algo=' --algo bola ';
    elif sys.argv[1].split('-')[5] == 'panda':
        algo=' --algo panda ';
    elif sys.argv[1].split('-')[5] == 'abma':
        algo=' --algo abma ';
    rxratio = sys.argv[1].split('-')[2];

    npname = '/vagrant/profiles/'+ sys.argv[1].split('-')[6]
    np = open(npname, 'r')

    try:
        reader = list(csv.DictReader(np, fieldnames=['bw','delay','loss'], delimiter=' '))
        appServer.cmd('tcpdump -S port 5678 > /vagrant/data/' + runName + '.aserver-tcpdump &')
        appServer.cmd('./httptl --port 5678 ' + hollywood +' > /vagrant/data/' + runName + '.aserver-out &')
        sleep(0.5)

        #Apply initial network conditions. 
        row = reader[0] 
        print row; 
        appServer.cmdPrint('tc qdisc add dev Server-eth0 root handle 1:0 tbf rate ' + row['bw'] +'kbit buffer 5000 latency 100ms');
        appServer.cmdPrint('tc qdisc add dev Server-eth0 parent 1:0 handle 10: netem loss ' + row['loss'] + '% delay ' + row['delay'] +'ms');        

        #initialize client code
        appClient.cmdPrint('./httpc  --mpd ' + appServer.IP() +'/BBB_8bitrates_hd/bunny_1080_simple_ts.mpd ' + oo + hollywood + algo  +' --minrxratio ' + rxratio + ' --port 5678 --bufferlen ' + bufferlen + ' --out /vagrant/data/received.ts > /vagrant/data/' + runName + '.aclient-out & echo $! > receiver-pid')
#        appClient.cmd('tcpdump -S port 5678 > /vagrant/data/' + runName + '.aclient-tcpdump &')

        #terminate test after 15 minutes
        exitTime = time() + 900;

        #Wait 30 seconds before starting loop 
        sleep(30)
        nextindex = 1; 
        while appClient.cmd('ps -p `cat receiver-pid` -o pid=') and exitTime > time():
            row = reader[nextindex] 
            print row; 
            appServer.cmdPrint('tc qdisc del dev Server-eth0 root');
            appServer.cmdPrint('tc qdisc add dev Server-eth0 root handle 1:0 tbf rate ' + row['bw'] +'kbit buffer 5000 latency 100ms');
            appServer.cmdPrint('tc qdisc add dev Server-eth0 parent 1:0 handle 10: netem loss ' + row['loss'] + '% delay ' + row['delay'] +'ms');
            nextindex+=1 
            if nextindex == len(reader):
                nextindex = 0;
            #sleep for 30 seconds before changing the network path 
            sleep(30)

        if appClient.cmd('ps -p `cat receiver-pid` -o pid='):
            print "Client is running. Timeout\n";
            appClient.cmd('kill `cat receiver-pid`');
            sleep(2);
            appClient.cmd('kill -9 `cat receiver-pid`');
        else:
            print "Client has stopped\n"
             
    except Exception as e:
        print "Exception!"
        print e
    finally:
        np.close()

if __name__ == '__main__':
    hollywood()
