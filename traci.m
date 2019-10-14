%{
TraCI class for sending/receiving TraCI messages from/to SUMO.

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

classdef traci

    properties
        connection
        received_packet
        step_packet = [ fliplr(typecast(uint32(10),'uint8'))';
                        fliplr(typecast(uint8(6),'uint8'))';
                        hex2dec('02')  %0x02 is the command for simulation step in SUMO
                        fliplr(typecast(int32(0),'uint8'))';
                        ]
        constants = traci_constants()
        current_index
    end
    
    methods
        function obj = traci(port, ipAddr, role)
          obj.connection = tcpip(ipAddr, port, 'NetworkRole', role);
          obj.current_index = 1;
        end
        
        function command = extract_command(obj)
            command = obj.received_packet(6);
        end
              
        function subscribeToVehicleVariable(obj, name)
            nameVect = int8(name);
            subscribe_packet = [ obj.constants.cmd_subscribe_vehicle; %0xD4 is the command for subscribing to vehicle
                              fliplr(typecast(uint32(0),'uint8'))';                 %begin time
                              fliplr(typecast(uint32(hex2dec('7FFFFFF')),'uint8'))';    %end time
                              fliplr(typecast(uint32(length(nameVect)),'uint8'))';  %object id (length)
                              nameVect';                                            %object id           
                              fliplr(typecast(uint8(4),'uint8'))';                  %variable number
                              obj.constants.var_lane_position;    %position 
                              obj.constants.var_2d_position;
                              obj.constants.var_road_id;    %road_id
                              obj.constants.var_speed;    %speed
                            ];
             subscribe_packet = [fliplr(typecast(uint8(length(subscribe_packet)+1),'uint8'))'; subscribe_packet];
             subscribe_packet = [fliplr(typecast(uint32(length(subscribe_packet)+4),'uint8'))'; subscribe_packet];
             fwrite(obj.connection, subscribe_packet);
        end
		
        function [position_x, position_y, position_lane, road_id, speed] = extract_sumo_subscription(obj, index)
            size = typecast(uint8(fliplr(obj.received_packet(index+1:index+4)')),'uint32');    %get the size of this command
            index = index + 6;      %then skip over the size and command part
            vNameLength = typecast(uint8(fliplr(obj.received_packet(index:index+3)')),'uint32'); %objectID's length
            %if object name is important, extract it here then
            index = index + 4 + vNameLength;        %then skip over the name
            %if the number of subscribed variable is of interests, extract it here
            index = index + 1;  %skip over the variable count
            while index ~= size+16
                variable_type = obj.received_packet(index);
                index = index + 3;
                if variable_type == obj.constants.var_2d_position
                    position_x = typecast(uint8(fliplr(obj.received_packet(index:index+7)')),'double');
                    position_y = typecast(uint8(fliplr(obj.received_packet(index+8:index+15)')),'double');
                    index = index + 16;
                end
                if variable_type == obj.constants.var_lane_position
                    position_lane = typecast(uint8(fliplr(obj.received_packet(index:index+7)')),'double');
                    index = index + 8;
                end
                if variable_type == obj.constants.var_road_id
                    roadNameLength = typecast(uint8(fliplr(obj.received_packet(index:index+3)')),'uint32');
                    road_id = char(obj.received_packet(index+4:index+4+roadNameLength-1)');
                    index = index + 4 + roadNameLength;        %then skip over the name
                end
                if variable_type == obj.constants.var_speed
                    speed = typecast(uint8(fliplr(obj.received_packet(index:index+7)')),'double');
                    index = index + 8;
                end
            end
        end
    end
end