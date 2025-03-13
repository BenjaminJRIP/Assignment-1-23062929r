%% for multi-correaltor output
data=trackResults(4).I_multi{201};
if data(6)<0
    data=-data
end
plot(-0.5:0.1:0.5,data,'r-');hold on;
scatter(-0.5:0.1:0.5,data,'bo');
xlabel('code delay');
ylabel('ACF');
title('ACF of Multi-correlator');

plotAcquisition_3D(acqResults);

%% WLS for velocity

v=[];
for i=1:size(navSolutions.vX,2)
   v=[v;navSolutions.vX(i),navSolutions.vY(i),navSolutions.vZ(i)] ;
end
plot(1:39,v(:,1),1:39,v(:,2));
legend('x (ECEF)','y (ECEF)')


%% for Kalman Filter
v=[];
for i=1:size(navSolutions.vX,2)
   v=[v;navSolutions.VX_kf(i),navSolutions.VY_kf(i),navSolutions.VZ_kf(i)] ;
end
plot(1:39,v(:,1),1:39,v(:,2));
legend('x (ECEF)','y (ECEF)')