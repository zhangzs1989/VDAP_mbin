function [ result ] = magnitude2moment( input, varargin )
%{
% magnitude2moment.m
% ------------------
% Converts from magnitude to moment. Add 'reverse' as a second input
% variable to convert moment to magnitude. Calculations are completed as
% per the definition provided by Stein and Wyession, Equation 31 (p. 273).
% Moment is in dyn-cm or ergs.
% 
% :Mo = 10^(1.5*Mw+16.1)
% :Mw = (log10(Mo)-16.1)/1.5
% 
% USAGE
% >>Mo = magnitude2moment(3.5)
% Mo =
%    2.2387e+21
% >>Mw = magnitude2moment(Mo,'reverse')
% Mw =
%     3.5000
%}

% @Jay Wellik, Michigan Technological University
% Updated: 2014 April 20
% Created: 2014 April 20

%% Magnitude to Moment

    % Mo = 10^(1.5*Mw+16.1); where "Mo->Moment" and "Mw->Moment Magnitude"
for n = 1:length(input)
    result(n) = 10^(1.5*input(n)+16.1);
end

%% Moment to Magnitude
% (cont'd if input includes 'reverse')

if nargin > 1;
    if strcmp(varargin{1},'reverse')
        
        for n = 1:length(input)
                % Mw = (log10(Mo)-16.1)/1.5; where "Mw->Moment Magnitude" and "Mo->Moment"
            result(n) = (log10(input(n))-16.1)/1.5;
            
                % Input should be seismic moment
                % display a warning if input looks like magnitude
            if input(n) < 1e5
                display('Warning, you may have inputted a magnitude value.')
            end
        end
    end
end

end

