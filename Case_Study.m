%% ENGS 85.07: Practical EV Engineering
% *Electric Go-Kart Design Case Study*
% 
% Matt Gardner & Peter Mahoney
% 
% 5/30/18

%% Motor Choice (Assessing Demands)
% For our motor selection, we first calculated the gear ratio needed using
% this equation: $ratio = v_m * r_w * \frac{\frac{60*2\pi}{63360}}{25mph}$
% 
% We selected the *larger motor* to fulfill our requirements with a *gear
% ratio of 1:7.14*.

clear all;

max_motor_speed = 3000; %RPM

wheel_radius = 10; % 5" wheel radius and tires estimated to be 5" sidewall

max_ground_speed = 25; %mph

gear_ratio = max_motor_speed * wheel_radius * 2*pi * 60 * (1/(5280*12)) / max_ground_speed %#ok<NOPTS>
%% 
% Next, we calculated k & R for our chosen motor using given motor
% parameter graphs.
% 
% Torque constant: $k_m = \frac{\tau}{i}$; Winding resistance: $R_m = \frac{V-k \Delta \omega}{\Delta i}$

torque_max = 4.05; % N-m
torque_min = 0;
current_max = 33.6; % A
current_min = 1.6;
RPM_max = 3700; %RPM
RPM_min = 2880;
k_motor = (4.05 - 0) / (33.6-1.6) %#ok

v_motor = 48; % V
R_motor = (v_motor - k_motor * (RPM_min-RPM_max) * (2*pi/60)) / (current_max-current_min)  %#ok

%% Road Load Requirements
% Road load can be calculated by summing rolling resistance, drag, and
% driveline losses accounting for defined speed requirements at certain
% grades. Power requirements can be summarized using the following
% equation: $F = F_{rolling} + R_{drive} v + F_{drag}$

mass_curb = 59 + 5.25 + 1.13 + 30*0.750+5 + 10; % kg; rolling chassis + motor + motor controller + batteries + driveline
mass_driver = 100; % kg
C_rr = 0.02;
F_roll = (mass_curb+mass_driver) * 9.81 * C_rr; % N

C_d = 0.5;
A_front = 0.5; % m^2
F_drag = 1/2 * 1.225 * C_d * A_front * (max_ground_speed * 0.44704)^2; % N 0.44704 factor converts mph to m/s

F_driveline = 0.709 * max_ground_speed*0.44704; % N

F_road = F_roll + F_drag + F_driveline %#ok

Cap_battery = F_road * max_ground_speed * 0.44704 * 3600 * 0.000277778; % Wh

%Factor of safety for battery:
Cap_battery*3 %#ok

%% Battery Sizing Requirement
% ~2.2 kWh energy requirement; 
% 48V = 3.2V/cell * 15 cells/string; 
% charge requirement: ~45 Ah; Use 2 strings of 15 cells each to gain 40Ah (30 cells
% total)
% 
% Does battery fulfill course requirements (6 2-second accelerations for 20
% laps with constant 25mph speed otherwise, 1 min/lap)

power_max = torque_max * 2*pi/60 * RPM_min;

power_constant_speed = F_road * 10 * 0.0254 / gear_ratio * (2*pi/60) * RPM_max;

% Accelerations & Constant Speed
energy_reqd = (power_max * 2 * 6 + power_constant_speed * 60) * 20 * 0.0002777777778 %#ok

%Accelerations
power_reqd = power_max * 2 * 6 * 20 * 0.0002777777778;

%Maximum Speed on 5 percent grade

grade_load = sin(atan(0.05))*9.81*(mass_curb + mass_driver);
b = 0.709;
a =1/2 * 1.225 * C_d * A_front;b
c = F_roll + grade_load;
Speed_max = power_max/(c+a*speed_max+b*speed_max^2);


