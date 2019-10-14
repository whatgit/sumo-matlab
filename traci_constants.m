%{
Define some of the constants used by the TraCI interface.

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

classdef traci_constants
    properties
        %% Commands
        cmd_step_simulation = hex2dec('02')
        
        cmd_subscribe_vehicle = hex2dec('D4')
        cmd_subscribe_vehicle_resp = hex2dec('E4')
        
        %% Variables
        
        var_speed = hex2dec('40')
        var_2d_position = hex2dec('42')
        var_lane_position = hex2dec('56')
        var_road_id = hex2dec('50')
        
        %% Data types
        data_2DPos = hex2dec('01')
        data_double = hex2dec('0B')
        data_string = hex2dec('0C')
        
    end
    methods
        function obj = traci_constants
        end
    end
end