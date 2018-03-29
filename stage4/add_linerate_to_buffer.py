import sys
import math

with open(sys.argv[1]) as f:
    split_line = sys.argv[1].split("-"); 
    prot = split_line[1];
    net = split_line[6];
    netfile = "stage3/profiles/" + net;
    with open(netfile) as nf:
        netconditions = nf.readlines()
    netiter = iter(netconditions);
    curr_net = next(netiter);
    prebuf = split_line[4];
    algo = split_line[5];
    rxbufratio = split_line[2];
    basetime = 0;
    
    if prebuf == "mp2s": 
        prebuf = 1000; 
    for fullline in f:
        if fullline.find("BUFFER")!=-1:
            line = fullline.split('BUFFER', 1)[-1]
            curr_rate = int(line.split()[6]);
            curr_time = int(line.split()[1])/1000;
            if (basetime + curr_time <= 30):
                print prot, prebuf, algo, rxbufratio, curr_time, curr_rate, curr_net;
            else:
                try:
                    curr_net = next(netiter);
                except StopIteration:
                    netiter = iter(netconditions);
                    curr_net = next(netiter);
                    basetime = basetime + 30;
                print prot, prebuf, algo, rxbufratio, curr_time, curr_rate, curr_net;



