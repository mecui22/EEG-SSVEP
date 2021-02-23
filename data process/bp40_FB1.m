function  y=bp40_FB1(x,fs,nFB)
fs=fs/2;

%h1
fls1(1)=[6]; 
fls2(1)=[4];
fhs1(1)=[90]; 
fhs2(1)=[100];

%h2
fls1(2)=[14]; 
fls2(2)=[10];
fhs1(2)=[90]; 
fhs2(2)=[100];

%h3
fls1(3)=[22]; 
fls2(3)=[16];
fhs1(3)=[90]; 
fhs2(3)=[100];

%h4
fls1(4)=[30]; 
fls2(4)=[24];
fhs1(4)=[90]; 
fhs2(4)=[100];

%h5
fls1(5)=[38]; 
fls2(5)=[32];
fhs1(5)=[90]; 
fhs2(5)=[100];

%h6
fls1(6)=[46]; 
fls2(6)=[40];
fhs1(6)=[90]; 
fhs2(6)=[100];

%h7
fls1(7)=[54]; 
fls2(7)=[48];
fhs1(7)=[90]; 
fhs2(7)=[100];

%h8
fls1(8)=[62]; 
fls2(8)=[56];
fhs1(8)=[90]; 
fhs2(8)=[100];

%h9
fls1(9)=[70]; 
fls2(9)=[64];
fhs1(9)=[90]; 
fhs2(9)=[100];

%h10 80-90
fls1(10)=[78]; 
fls2(10)=[72];
fhs1(10)=[90]; 
fhs2(10)=[100];


Wp=[fls1(nFB)/fs fhs1(nFB)/fs];%3 7
Ws=[fls2(nFB)/fs fhs2(nFB)/fs];%1 1


Wn=0;
%[N,Wn]=cheb1ord(Wp,Ws,5,30);
[N,Wn]=cheb1ord(Wp,Ws,3,40);
[B,A] = cheby1(N,0.5,Wn);
y = filtfilt(B,A,x);

 