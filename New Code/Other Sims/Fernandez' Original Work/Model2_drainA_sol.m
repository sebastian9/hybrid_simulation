% Margaret Mary Fernandez's Master's Thesis
% Non Ideal (Peng-Robinson), High Pressure Equilibrium Model
% draining Tank Calculation - ODE45 Solution File

function dx = Model2_drainA_sol(t,x)

T = x(1);
P = x(2);
n2l = x(3);
n2v = x(4);

% Given constants
nHe = 0;                % He in tank [kmol]
Vol = 0.0354;           % total volume of tank [m^3]
y2 = n2v/(n2v+nHe);     % mol fraction of N2O
m_T = 6.4882;           % tank mass [kg]
R = 8314.3;             % universal gas constant [J/(kmol*K)];
C_D = 0.425;            % discharge coefficient: Test 1
% C_D = 0.365;            % Test 2 and 3
% C_D = 0.9;              % Test 4
A_inj = 0.0001219352;   % injector hole area [m^2]
MW2 = 44.013;           % molecular weight of N2O [kg/kmol]

C1 = 0.2079e5;          % heat capacity of He at constant pressure [J/(kmol*K0] coefficients
C2 = 0;                 % valid for Temp range [100 K - 1500 K]
C3 = 0;
C4 = 0;
C5 = 0;

D1 = 0.2934e5;          % heat capacity of N2O gas at constant pressure [J/(kmol*K)] coefficients
D2 = 0.3236e5;          % valid for Temp range [100 K - 1500 K]
D3 = 1.1238e3;
D4 = 0.2177e5;
D5 = 479.4;

E1 = 6.7556e4;          % heat capacity of N2O liquid at constant pressure [J/(kmol*K)] coefficints
E2 = 5.4373e1;          % valid for Temp range [182.3 K - 200 K]
E3 = 0;
E4 = 0;
E5 = 0;

J1 = 2.3215e7;          % heat of vapourization of N2O [J/kmol] coefficients
J2 = 0.384;             % valid for Temp range [182.3 K - 309.57 K]
J3 = 0;
J4 = 0;

% polynomial fit of combustion chamber pressure [Pa]
Pe = -2924.42*t^6 + 46778.07*t^5 - 285170.63*t^4 + 813545.02*t^3 - ...
    1050701.53*t^2 + 400465.85*t + 1175466.2;                          % Test 1
% Pe = 95.92*t^6 - 2346.64*t^5 + 21128.78*t^4 - 87282.73*t^3 + ...
%    186675.17*t^2 - 335818.91*t + 3029190.03;                         % Test 2
% Pe = 58.06*t^6 - 1201.90*t^5 + 8432.11*t^4 - 22175.67*t^3 + ...
%    21774.66*t^2 - 99922.82*t + 2491369.68;                           % Test 3
% Pe = -4963.73*t + 910676.22;                                         % Test 4 


% Critical constants and acentric factors from Perry's Handbook
% Tc1 = 5.2;        % He critical temperature [K]
% Tc2 = 309.57;     % N2O critical temperature [K]
% Pc1 = 0.23e6;     % He critical pressure [Pa]
% Pc2 = 7.28e6;     % N2O critical pressure [Pa]
% w1 = -0.388;      % He acentric factor
% w2 = 0.143;       % N2O acentric factor
% Critical Constants and acentricd factors from Sandler's code
Tc1 = 5.19;
Tc2 = 309.6;
Pc1 = 0.227e6;
Pc2 = 7.24e6;
w1 = -0.365;
w2 = 0.165;

% Peng-Robinson parameters
kappa1 = 0.37464 + 1.54226*w1 - 0.26992*w1^2;   % Sandler p.250
kappa2 = 0.37464 + 1.54226*w2 - 0.26992*w2^2;   
alpo1 = (1 + kappa1*(1-sqrt(T/Tc1)))^2;
alpo2 = (1 + kappa2*(1-sqrt(T/Tc2)))^2;

a1 = 0.45724*R^2*Tc1^2*alpo1/Pc1;               % Sandler p.250
a2 = 0.45724*R^2*Tc2^2*alpo2/Pc2;
b1 = 0.0778*R*Tc1/Pc1;
b2 = 0.0778*R*Tc2/Pc2;
daldT = -0.45724*R^2*Tc1^2*kappa1*sqrt(alpo1/(T*Tc1))/Pc1;
da2dT = -0.45724*R^2*Tc2^2*kappa2*sqrt(alpo2/(T*Tc2))/Pc2;
d2aldT2 = (-0.45724*R^2*Tc1^2/Pc1)*kappa1*0.5*(alpo1/(T*Tc1))^-0.5* ...
    ((-kappa1*sqrt(alpo1*T*Tc1)-alpo1*Tc1)/(T*Tc1)^2);
d2a2dT2 = (-0.45724*R^2*Tc2^2/Pc2)*kappa2*0.5*(alpo2/(T*Tc2))^-0.5* ...
    ((-kappa2*sqrt(alpo2*T*Tc2)-alpo2*Tc2)/(T*Tc2)^2);

A2 = P*a2/(R*T)^2;                        % Sandler p.251
B2 = P*b2/(R*T);

c2 = -(1-B2);
c1 = (A2 - 3*B2^2 - 2*B2);
c0 = -(A2*B2 - B2^2 - B2^3);

ql = c1/3 - c2^2/9;
rl = (c1*c2 - 3*c0)/6 - c2^3/27;
qrl = ql^3 + rl^2;

% Liquid - Pure
% Z_2l^3 + c2*Z_2l^2 + c1*Z_2l + c0 = 0

if qrl > 0                % Case 1: 1 real root
    rpqrl = rl + qrl^0.5;
    rmqrl = rl - qrl^0.5;
    if rpqrl>=0
        s1 = rpqrl^(1/3);
    else
        s1 = -(abs(rpqrl)^(1/3));
    end
    if rmqrl >= 0
        s2 = rmqrl^(1/3);
    else
        s2 = -(abs(rmqrl)^(1/3));
    end
    Z2l = s1 + s2 - c2/3;
elseif qrl ==0              % Case 2:  3 real roots, at least 2 equal
    if rl >= 0
        s1 = rl^(1/3);
        s2 = rl^(1/3);
    else
        s1 = -(abs(rl))^(1/3);
        s2 = -(abs(rl))^(1/3);
    end
    Z2l_1 = s1 + s2 - c2/3;
    Z2l_2 = -0.5*(s1 + s2) - c2/3;
    Z2l = min([Z2l_1 Z2l_2]);
else
    alpha = (abs(qrl))^0.5;
    if rl > 0
        th1 = atan(alpha/rl);
    else
        th1 = pi - atan(alpha/abs(rl));
    end
    th2 = atan2(alpha,rl);
    if abs(th1 - th2) < 1e-14
        th = th1;
    else
        disp('Liquid Thetas do not match');
        pause;
    end
    rho = (rl^2 + alpha^2)^0.5;
    Z2l_1 = 2*rho^(1/3)*cos(th/3) - c2/3;
    Z2l_2 = -rho^(1/3)*cos(th/3) - c2/3 - sqrt(3)*rho^(1/3)*sin(th/3);
    Z2l_3 = -rho^(1/3)*cos(th/3) - c2/3 + sqrt(3)*rho^(1/3)*sin(th/3);
    Z2l = min([Z2l_1 Z2l_2 Z2l_3]);
end

% Gas - Mixture
% Z_m^3 + d2*Z_m^2 + d1*Z_m + d0 = 0
        
k12 = 0;                                    % binary interaction parameter (He/N2O mix)
a21 = sqrt(a1*a2)*(1-k12);                  % Sandler p.423
am = (1-y2)^2*a1 + 2*y2*(1-y2)*a21 + y2^2*a2;
bm = (1-y2)*b1 + y2*b2;

da21dT = (1-k12)/2*((a1*a2)^-0.5*(daldT*a2+a1*da2dT));
d2a21dT2 = (1-k12)/2*(-0.5*(a1*a2)^(-3/2)*(daldT*a2+a1*da2dT)^2+(a1*a2)^-0.5* ...
    (d2aldT2*a2+2*daldT*da2dT+a1*d2a2dT2));
damdT = (1-y2)^2*daldT + 2*y2*(1-y2)*da21dT + y2^2*da2dT;
d2amdT2 = (1-y2)^2*d2aldT2 + 2*y2*(1-y2)*d2a21dT2 + y2^2*d2a2dT2;
d2amdTdy2 = -2*(1-y2)*daldT + 2*(1-2*y2)*da21dT + 2*y2*da2dT;
damdy2 = -2*(1-y2)*a1 + 2*a21*(1-2*y2) + 2*y2*a2;    % @T
dbmdy2 = -b1 + b2;

Am = P*am/(R*T)^2;                      % Sandler p.425
Bm = P*bm/(R*T);
A2l = P*a21/(R*T)^2;
        
d2 = -(1-Bm);
d1 = (Am - 3*Bm^2 - 2*Bm);
d0 = -(Am*Bm - Bm^2 - Bm^3);
       
qm = d1/3 - d2^2/9;
rm = (d1*d2 - 3*d0)/6 - d2^3/27;
qrm = qm^3 + rm^2;

if qrm > 0                                  % Case 1: 1 real root
    rpqrm = rm + qrm^0.5;
    rmqrm = rm - qrm^0.5;
    if rpqrm>=0
        s1m = rpqrm^(1/3);
    else
        s1m = -(abs(rpqrm)^(1/3));
    end
    if rmqrm>=0
        s2m = rmqrm^(1/3);
    else
        s2m = -(abs(rmqrm)^(1/3));
    end
    Zm = s1m + s2m - d2/3;
elseif qrm == 0                             % Case 2: 3 real roots, at least 2 equal
    if rm >= 0
        s1m = rm^(1/3);
        s2m = rm^(1/3);
    else
        s1m = -(abs(rm))^(1/3);
        s2m = -(abs(rm))^(1/3);
    end
    Zm_1 = s1m + s2m - d2/3;
    Zm_2 = -0.5*(s1m + s2m) - d2/3;
    Zm = max([Zm_1 Zm_2]);
else                                        % Case 3: 3 real, distinct roots
    alpham = (abs(qrm))^0.5;
    if rm > 0
        th1m = atan(alpham/rm);
    else
        th1m = pi - atan(alpham/abs(rm));
    end
    th2m = atan2(alpham,rm);            % double check angle with Matlab atan2 code
    if abs(th1m - th2m) < 1e-14
        thm = th1m;
    else
        disp('Mixture Thetas do not match');
        pause;
    end
    rhom = (rm^2 + alpham^2)^0.5;
    Zm_1 = 2*rhom^(1/3)*cos(thm/3) - d2/3;
    Zm_2 = -rhom^(1/3)*cos(thm/3) - d2/3 - sqrt(3)*rhom^(1/3)*sin(thm/3);
    Zm_3 = -rhom^(1/3)*cos(thm/3) - d2/3 + sqrt(3)*rhom^(1/3)*sin(thm/3);
    Zm = max([Zm_1 Zm_2 Zm_3]);
end

H2lex = R*T*(Z2l-1) + (T*da2dT-a2)/(2*sqrt(2)*b2)*log((Z2l+(1+sqrt(2))*B2)/(Z2l+(1-sqrt(2))*B2));
Hgex = R*T*(Zm-1) + (T*damdT-am)/(2*sqrt(2)*bm)*log((Zm+(1+sqrt(2))*Bm)/(Zm+(1-sqrt(2))*Bm));
phi2l = exp((Z2l-1) - log(Z2l - B2) - (A2/(2*sqrt(2)*B2))*log((Z2l+(1+sqrt(2))*B2)/(Z2l+(1-sqrt(2))*B2)));
phi2v = exp((B2/Bm)*(Zm-1) - log(Zm - Bm) - (Am/(2*sqrt(2)*Bm))*((2*((1-y2)*A2l+y2*A2)/Am) - B2/Bm)*...
        log((Zm+(1+sqrt(2))*Bm)/(Zm+(1-sqrt(2))*Bm)));
        
%%Analytical Derivatives %%
dA2dT = (P/R^2)*(da2dT/T^2-2*a2/T^3);   % @P
dA2dP = a2/(R*T)^2;                     % @T
dB2dT = -P*b2/(R*T^2);                  % @P
dB2dP = b2/(R*T);                       % @T
dA2ldT = (P/R^2)*(da21dT/T^2-2*a21/T^3);
dA2ldP = a21/(R*T)^2;
dAmdT = (P/R^2)*(damdT/T^2-2*am/T^3);   % @P,y2
dAmdP = am/(R*T)^2;                     % @T,y2
dAmdy2 = P/(R*T)^2*damdy2;              % @T,P
dBmdT = -P*bm/(R*T^2);                  % @P,y2
dBmdP = bm/(R*T);                       % @T,y2
dBmdy2 = P/(R*T)*dbmdy2;                % @T,P

% helpful substitutions
Z2lpB2 = Z2l + (1+sqrt(2))*B2;
Z2lmB2 = Z2l + (1-sqrt(2))*B2;
ZmpBm = Zm + (1+sqrt(2))*Bm;
ZmmBm = Zm + (1-sqrt(2))*Bm;
dABT = (dA2dT*B2 - A2*dB2dT)/B2^2;
dABP = (dA2dP*B2 - A2*dB2dP)/B2^2;
dB2mT = (dB2dT*Bm - B2*dBmdT)/Bm^2;
dB2mP = (dB2dP*Bm - B2*dBmdP)/Bm^2;
dABmT = (dAmdT*Bm - Am*dBmdT)/Bm^2;
dABmP = (dAmdP*Bm - Am*dBmdP)/Bm^2;
dABmy2 = (dAmdy2*Bm - Am*dBmdy2)/Bm^2;
AB21m = 2*((1-y2)*A2l+y2*A2)/Am - B2/Bm;
dAB21mT = (2/Am^2)*(((1-y2)*dA2ldT+y2*dA2dT)*Am-((1-y2)*A2l+y2*A2)*dAmdT) - dB2mT;
dAB21mP = (2/Am^2)*(((1-y2)*dA2ldP+y2*dA2dP)*Am-((1-y2)*A2l+y2*A2)*dAmdP) - dB2mP;
dAB21my2 = (2/Am^2)*((-A2l+A2)*Am-((1-y2)*A2l+y2*A2)*dAmdy2) + B2*dBmdy2/Bm^2;
exp2l = exp(Z2l-1-log(Z2l-B2)-(A2/(2*sqrt(2)*B2))*log(Z2lpB2/Z2lmB2));
exp2v = exp((B2/Bm)*(Zm-1)-log(Zm-Bm)-(Am/(2*sqrt(2)*Bm))*AB21m*log(ZmpBm/ZmmBm));

% analytical derivatives [T,P,Z(T,P,y2(n2v)),y2(n2v)]
AdZ2ldT = ((-Z2l^2+6*B2*Z2l+2*Z2l+A2-2*B2-3*B2^2)*dB2dT + ...
    (-Z2l+B2)*dA2dT)/(3*Z2l^2-(1-B2)*2*Z2l+A2-3*B2^2-2*B2);
AdZ2ldP = ((-Z2l^2+6*B2*Z2l+2*Z2l+A2-2*B2-3*B2^2)*dB2dP + ...
    (-Z2l+B2)*dA2dP)/(3*Z2l^2-(1-B2)*2*Z2l+A2-3*B2^2-2*B2);
AdZmdT = ((-Zm^2+6*Bm*Zm+2*Zm+Am-2*Bm-3*Bm^2)*dBmdT + ...
    (-Zm+Bm)*dAmdT)/(3*Zm^2-(1-Bm)*2*Zm+Am-3*Bm^2-2*Bm);
AdZmdP = ((-Zm^2+6*Bm*Zm+2*Zm+Am-2*Bm-3*Bm^2)*dBmdP + ...
    (-Zm+Bm)*dAmdP)/(3*Zm^2-(1-Bm)*2*Zm+Am-3*Bm^2-2*Bm);
AdZmdy2 = ((-Zm^2+6*Bm*Zm+2*Zm+Am-2*Bm-3*Bm^2)*dBmdy2 + ...
    (-Zm+Bm)*dAmdy2)/(3*Zm^2-(1-Bm)*2*Zm+Am-3*Bm^2-2*Bm);
AdH21dT = R*(Z2l-1) + (1/(2*sqrt(2)*b2))*(T*d2a2dT2)*log(Z2lpB2/Z2lmB2) + ...
    ((T*da2dT-a2)/b2)*(Z2l/(Z2lpB2*Z2lmB2))*dB2dT;
AdH21dP = (T*da2dT-a2)/b2*(Z2l/(Z2lpB2*Z2lmB2))*dB2dP;
AdH21dZ2l = R*T + (T*da2dT-a2)/b2*(-B2/(Z2lpB2*Z2lmB2));
AdHgdT = R*(Zm-1) + (1/(2*sqrt(2)*bm))*(T*d2amdT2)*log(ZmpBm/ZmmBm) + ...
    ((T*damdT-am)/bm)*(Zm/(ZmpBm*ZmmBm))*dBmdT;
AdHgdP = (T*damdT-am)/bm*(Zm/(ZmpBm*ZmmBm))*dBmdP;
AdHgdy2 = (((T*d2amdTdy2-damdy2)*2*sqrt(2)*bm-(T*damdT-am)*2*sqrt(2)*dbmdy2)/(8*bm^2))*log(ZmpBm/ZmmBm) + ...
    ((T*damdT-am)/(2*sqrt(2)*bm))*(ZmmBm/ZmpBm)*(2*sqrt(2)*Zm/ZmmBm^2)*dBmdy2;
AdHgdZm = R*T + (T*damdT-am)/(2*sqrt(2)*bm)*(ZmmBm/ZmpBm)*(-2*sqrt(2)*Bm/ZmmBm^2);
Adphi21dT = exp2l*(dB2dT/(Z2l-B2)-dABT/(2*sqrt(2))*log(Z2lpB2/Z2lmB2)-...
    (A2/B2)*(Z2l/(Z2lpB2*Z2lmB2))*dB2dT);
Adphi21dP = exp2l*(dB2dP/(Z2l-B2)-dABP/(2*sqrt(2))*log(Z2lpB2/Z2lmB2)-...
    (A2/B2)*(Z2l/(Z2lpB2*Z2lmB2))*dB2dP);
Adphi21dZ2l = exp2l*(1-1/(Z2l-B2)+A2/(Z2lpB2*Z2lmB2));
Adphi2vdT = exp2v*((Zm-1)*dB2mT+dBmdT/(Zm-Bm)-(1/(2*sqrt(2)))*(dABmT*AB21m+(Am/Bm)*dAB21mT)*...
    log(ZmpBm/ZmmBm)-(Am/Bm)*(AB21m/ZmpBm)*(Zm*dBmdT/ZmmBm));
Adphi2vdP = exp2v*((Zm-1)*dB2mP+dBmdP/(Zm-Bm)-(1/(2*sqrt(2)))*(dABmP*AB21m+(Am/Bm)*dAB21mP)*...
    log(ZmpBm/ZmmBm)-(Am/Bm)*(AB21m/ZmpBm)*(Zm*dBmdP/ZmmBm));
Adphi2vdy2 = exp2v*((Zm-1)*-B2/Bm^2*dBmdy2+dBmdy2/(Zm-Bm)-(1/(2*sqrt(2)))*...
    (dABmy2*AB21m+(Am/Bm)*dAB21my2)*log(ZmpBm/ZmmBm)-(Am/Bm)*(AB21m/ZmpBm)*(Zm*dBmdy2/ZmmBm));
Adphi2vdZm = exp2v*(B2/Bm-1/(Zm-Bm)+Am*AB21m/(ZmpBm*ZmmBm));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ng = n2v + nHe;
Tr = T/Tc2;
Cp_1g = C1 + C2*T + C3*T^2 + C4*T^3 + C5*T^4;    % specific heat of he at constant volume [J/kmol*K)]
Cp_2v = D1 + D2*((D3/T)/sinh(D3/T))^2 + D4*((D5/T)/cosh(D5/T))^2;
    % specific heat of N2O gas at constant volume [J/kmol*K)];
Cp_T = (4.8 + 0.00322*T)*155.239;                  % specific heat of tank, Aluminum 6061-T6 [J/(kg*K)]
Cp_2l = E1 + E2*T + E3*T^2 + E4*T^3 + E5*T^4;
    % specific heat of N2O liquid at constant volume, approx. same as at
    % constant pressure [J/(kmol*K)]
deltaH_2v = J1*(1-Tr)^(J2 + J3*Tr + J4*Tr^2);       % heat of vapourization of N2) [J/kmol];

D = nHe*Cp_1g + n2v*Cp_2v + ng*AdHgdZm*AdZmdT + ng*AdHgdT - ng*R*(Zm + T*AdZmdT);
N = m_T*Cp_T + n2l*(Cp_2l + AdH21dZ2l*AdZ2ldT + AdH21dT - R*(Z2l+T*AdZ2ldT));
E = ng*(AdHgdZm*AdZmdP + AdHgdP - R*T*AdZmdP);
Q = n2l*(AdH21dZ2l*AdZ2ldP + AdH21dP - R*T*AdZ2ldP);
M = Hgex - Zm*R*T + (1-y2)*(AdHgdZm*AdZmdy2 + AdHgdy2 - R*T*AdZmdy2);
K = (C_D*A_inj*sqrt(2/MW2))*sqrt(P*(P-Pe)/(Z2l*R*T));
beta = ng*AdZmdT + n2l*AdZ2ldT + (Zm*ng+Z2l*n2l)/T;
gamma = ng*AdZmdP + n2l*AdZ2ldP - Vol/(R*T);
delta = Zm + (1-y2)*AdZmdy2;
theta = ng*(Adphi21dZ2l*AdZ2ldT + Adphi21dT) - n2v*(Adphi2vdZm*AdZmdT + Adphi2vdT);
lamda = ng*(Adphi21dZ2l*AdZ2ldP + Adphi21dP) - n2v*(Adphi2vdZm*AdZmdP + Adphi2vdP);
psi = phi2l - phi2v - y2*(1-y2)*(Adphi2vdZm*AdZmdy2 + Adphi2vdy2);

X = D+N;
W = E+Q;
Y = -Z2l*R*T;
Z = deltaH_2v + M - H2lex;

% Solve using Cramer's Rule
Col1 = [X 0 beta theta]';
Col2 = [W 0 gamma lamda]';
Col3 = [Y 1 Z2l 0]';
Col4 = [Z 1 delta psi]';
Col5 = [0 -K 0 0]';

AA = [Col1 Col2 Col3 Col4];
BB = [Col5 Col2 Col3 Col4];
CC = [Col1 Col5 Col3 Col4];
DD = [Col1 Col2 Col5 Col4];
EE = [Col1 Col2 Col3 Col5];

dTdt = det(BB)/det(AA);
dPdt = det(CC)/det(AA);
dn2ldt = det(DD)/det(AA);
dn2vdt = det(EE)/det(AA);

dx(1,1) = dTdt;
dx(2,1) = dPdt;
dx(3,1) = dn2ldt;
dx(4,1) = dn2vdt;