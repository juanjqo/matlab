% Implements a classic control law based on the Jacobian pseudoinverse and an Euclidean error.
%
% Usage: controller = DQ_TaskSpacePseudoInverseController(robot), where robot is a
% DQ_Kinematics object.
%
% DQ_TaskSpacePseudoInverseController Methods:
%   compute_control_signal - Based on the task reference, compute the control signal.
%   verify_stability - Verify if the closed-loop system has reached a stable region.
%
% For more methods and properties, see also DQ_KinematicController.

% (C) Copyright 2011-2019 DQ Robotics Developers
%
% This file is part of DQ Robotics.
%
%     DQ Robotics is free software: you can redistribute it and/or modify
%     it under the terms of the GNU Lesser General Public License as
%     published by the Free Software Foundation, either version 3 of the
%     License, or (at your option) any later version.
%
%     DQ Robotics is distributed in the hope that it will be useful, but
%     WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%     Lesser General Public License for more details.
%
%     You should have received a copy of the GNU Lesser General Public
%     License along with DQ Robotics.  If not, see
%     <http://www.gnu.org/licenses/>.
%
% DQ Robotics website: dqrobotics.github.io
%
% Contributors to this file:
%     Bruno Vihena Adorno - adorno@ufmg.br

classdef DQ_TaskSpacePseudoInverseController < DQ_KinematicController
    methods
        function controller = DQ_TaskSpacePseudoInverseController(robot)
            controller = controller@DQ_KinematicController(robot);    
        end
        
        function u = compute_control_signal(controller, q, task_reference, primitive)
            % Based on the task reference, compute the control signal
            if controller.is_set()
                % Plane control and line control
                if nargin == 4
                  %  disp('4')
                    % get the task variable according to the control objective
                    task_variable = controller.get_task_variable(q, primitive);
                    % get the Jacobian according to the control objective
                    J = controller.get_jacobian(q, primitive);
                elseif nargin == 3
                 %    disp('3')
                     % get the task variable according to the control objective
                    task_variable = controller.get_task_variable(q);
                    % get the Jacobian according to the control objective
                    J = controller.get_jacobian(q);
                end
                % calculate the Euclidean error
                task_error = task_reference - task_variable;
                % compute the control signal
                u = pinv(J)*controller.gain*task_error;
                
                controller.verify_stability(task_error);
                
                % Store the values of the last error signal and last
                % control signal
                controller.last_control_signal = u;
                controller.last_error_signal = task_error;
            end
        end
        
        function verify_stability(controller, task_error)
        % Verify if the closed-loop system has reached a stable region.
        %
        % If the task error changes below a threshold, then we consider
        % that the system has reached a stable region.
        % TODO: Choose different criteria

            if norm(controller.last_error_signal - task_error) < ...
                controller.stability_threshold
                controller.is_stable = true;
            end
        end      
    end
end