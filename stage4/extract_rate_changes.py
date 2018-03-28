import sys
import math

with open(sys.argv[1]) as f:
    split_line = sys.argv[1].split("-"); 
    prot = split_line[1];
    net = split_line[6];
    prebuf = split_line[4];
    algo = split_line[5];
    rxbufratio = split_line[2];
    upswitch = 0; 
    downswitch = 0; 
    rate = -1; 
    sdrate = 0; 
    avrate = 0; 
    ratesum = 0; 
    ratecount = 0; 
    ratelist = [];
    lastswitch = 0;
    lastrate = -1;
    totalchunks = 0;
    
    if prebuf == "mp2s": 
        prebuf = 1000; 
    for fullline in f:
        if fullline.find("BUFFER")!=-1:
            line = fullline.split('BUFFER', 1)[-1]
            curr_rate = int(line.split()[6]);
            curr_time = int(line.split()[1])
            totalchunks = totalchunks + 1;
            if rate == -1: 
                rate = curr_rate;
                lastrate = curr_rate;
            elif rate > curr_rate:
                downswitch+=1;
                lastswitch = curr_time;
                lastrate = curr_rate;
            elif rate < curr_rate:
                upswitch+=1;
                lastswitch = curr_time;
                lastrate = curr_rate;
            rate = curr_rate;
            ratelist.append(curr_rate)
            ratesum+=rate; 
            ratecount+=1;   
    if ratecount == 0:
        avrate = 0;
        sdrate = 0;
    else:
        avrate = ratesum/ratecount;
        for i in ratelist:
            j =  ((i - avrate ) ** 2);
            sdrate += j;
        sdrate = (sdrate/ratecount) ** 0.5; 
    print prot, prebuf, net, algo, rxbufratio, upswitch, downswitch, avrate, sdrate, lastswitch, lastrate, totalchunks;

