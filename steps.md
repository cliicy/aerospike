#  load and then run    
sudo ./loadrun.sh -a load -n css_sfx  -t 100 -r 540000000 -c device -w n -p 3000 -b sfd0n1

# only run
sudo ./loadrun.sh -a run -n css_sfx -t 100 -r 540000000 -c device -w n -p 3000 -b sfd0n1

# load and run no GC :recordcount=270million run for 3hours with following parts
# sfd0n1                          252:0     0   2.9T  0 disk
#├─sfd0n1p1                      252:1     0   292G  0 part
#├─sfd0n1p2                      252:2     0   292G  0 part
#├─sfd0n1p3                      252:3     0   292G  0 part
#├─sfd0n1p4                      252:4     0     1K  0 part
#├─sfd0n1p5                      252:5     0   292G  0 part
#├─sfd0n1p6                      252:6     0   292G  0 part
#├─sfd0n1p7                      252:7     0   292G  0 part
#└─sfd0n1p8                      252:8     0   292G  0 part
sudo ./loadrun.sh -a load -n css_sfx  -t 100 -r 270000000 -c device -w n -p 3000 -b sfd0n1

#load and run: GC occurrs : recoudcount=540million and run for 3hours with following parts
# sfd0n1                          252:0     0   2.9T  0 disk 
#├─sfd0n1p1                      252:1     0   292G  0 part 
#├─sfd0n1p2                      252:2     0   292G  0 part 
#├─sfd0n1p3                      252:3     0   292G  0 part 
#├─sfd0n1p4                      252:4     0     1K  0 part 
#├─sfd0n1p5                      252:5     0   292G  0 part 
#├─sfd0n1p6                      252:6     0   292G  0 part 
#├─sfd0n1p7                      252:7     0   292G  0 part 
#└─sfd0n1p8                      252:8     0   292G  0 part
sudo ./loadrun.sh -a run -n css_sfx -t 100 -r 540000000 -c device -w n -p 3000 -b sfd0n1
