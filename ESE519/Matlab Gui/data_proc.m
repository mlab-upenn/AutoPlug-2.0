dwork=d1;
state=0;
count=0;
fuck=0;


for i=1:(length(dwork)-15)
k=d1(i);

if(d1(i)==170 && d1(i+1)==204)
    state=1;
end

if(d1(i)==204 && state==1)
    state=2; count=count+1;continue;
end

if(state>=2)
    state=state+1;
    
end

if(state==3)
    %lat accl
end

if(state==4)
   lv=typecast(uint8(k),'int8');
   lav=double(lv);
   lat_vel(count)=lav/50; 
    
end
   
if(state==5)
   ro=typecast(uint8(k),'int8');
   rol=double(ro);
   roll_angle(count)=rol/100; 
     
end

if(state==6)
   sta=typecast(uint8(k),'int8');
           staa=double(sta);
           steer_angl=double(staa/50);
           steer_angle(count)=double(steer_angl*180/3.142); 
    
end

if(state==7)
    bl=typecast(uint8(k),'int8');
            bll=double(bl);
            bfl(count)=bll; 
    
end
    
if(state==8)
    br=typecast(uint8(k),'int8');
           brr=double(br);
           bfr(count)=brr; 
    
end

if(state==9)
    t=typecast(uint8(k),'int8')
    if(t~=100)
        fuck=fuck+1;
        'fucked' 
    end
end

if(state==10)
  yw=typecast(uint8(k),'int8');
        yawrt=double(yw);
        yaw_r=double(yawrt*180/3.142);
        yaw_rt(count)=double(yaw_r)/20;   
    
end

if(state==11)
lar=typecast(uint8(k),'int8');  
        lataclr=double(lar);
        y11(count)=lataclr/50;    
    
end
    
if(state==12)
    y12_temp=typecast(uint8(k),'int8');
        y12_temp1=double(y12_temp);
        y12_temp2=double(y12_temp1*180/3.142); %was already in rads, FOOL!!
        y12(count)=double(y12_temp2)/1; 
        y12(count)=deg2rad(count);
% y12(count)=k;
%     y13(count)=k;
end

if(state==13)
    flg=typecast(uint8(k),'int8');
%            staar=double(starr);
%            steer_anglr=double(staar/50);
%            y13(count)=double(steer_anglr*180/3.142);  
     y13(count)=flg;

%  y12_temp=typecast(uint8(k),'int8');
%         y12_temp1=double(y12_temp);
%         y12_temp2=double(y12_temp1*180/3.142);
%         y12(count)=double(y12_temp2)/20; 
% 
% end
end

if(state==14)
   ror=typecast(uint8(k),'int8');
           rolr=double(ror);
          y14(count)=rolr/100; 
    
end
    
 if(state==15)
           state=0; 
 end
 
end


    
    
    
