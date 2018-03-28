import sys

with open(sys.argv[1], "r+") as f:
    for line in f:
        profile = line.split("-")[6]
        other = ":".join(line.split(":")[1:])[:-1]
        print "Net:%s:%s" % (profile, other)