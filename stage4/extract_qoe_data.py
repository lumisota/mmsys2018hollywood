import sys
#buffer profile proto oo algo ratio i 12829 0.981703

with open(sys.argv[1]) as f:
    for line in f:
        filename = sys.argv[1].split("-")
        line = line.split()
        
        if sys.argv[2] == "ssim":
            n = line[0].split(":")[1]
            all = line[4].split(":")[1]
            data = "%s %s" % (n, all)
        if sys.argv[2] == "psnr":
            n = line[0].split(":")[1]
            avg = line[5].split(":")[1]
            data = "%s %s" % (n, avg)
        
        print "%s %s %s %s %s %s %s %s" % (filename[4], filename[6], filename[1], filename[3], filename[5], filename[2], filename[7], data)
