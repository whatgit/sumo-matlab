%{
MATLAB script for running with sumo-gui.

Copyright (C) 2019 Maytheewat Aramrattana <maytheewat.aramrattana@vti.se>

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
%}

%Define a role, either 'server' or 'client'
%If you are connecting to SUMO, choose 'client'
%If you are waiting for a connection, e.g. from Veins, choose 'server'
role = 'client';   

isSubscribed = false;
time = 0;

%Initilize traci connection
sumo_PORT = 8813;
sumo_IP = '0.0.0.0';
t = traci(sumo_PORT, sumo_IP, role);

%connect
fopen(t.connection);
fwrite(t.connection,t.step_packet)

while 1
   if t.connection.BytesAvailable ~= 0
       t.received_packet = fread(t.connection, t.connection.BytesAvailable);
       command = t.extract_command();
       if command == t.constants.cmd_step_simulation && length(t.received_packet) > 15
           t.current_index = 16;
           subscribed = typecast(uint8(fliplr(t.received_packet(12:15)')),'uint32');
           for i=1:subscribed
               [c1posX, c1posY, c1posLane, c1road_id, c1speed] = t.extract_sumo_subscription(t.current_index);
           end
       end
       if isSubscribed == false && time == 10
			%this example assume you want to subscribe to three cars in the simulation
			%the cars are named 'carOne', 'carTwo', and 'carThree'
            t.subscribeToVehicleVariable('carOne')
            t.subscribeToVehicleVariable('carTwo')
            t.subscribeToVehicleVariable('carThree')
            isSubscribed = true;
       end
       fwrite(t.connection,t.step_packet)
       t.current_index = 0;
       time = time + 1;
   end
end
