clear all;instrreset;
s = serial('COM6','baudrate',115200);
set(s,'InputBufferSize',100);
fopen(s);

state=0;
count=0;
d1=[];
for j=1:200
kk = fread(s,100);
d1=[d1 ; kk];

end
fclose(s);
