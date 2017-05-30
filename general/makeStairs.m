function [x_stair, y_stair] = makeStairs(varargin)
% MAKESTAIR Poor man's version of making a line plot look like a stair
% plot. This is super lame because Matlab does this automatically, but the
% automatic version doesn't freakin' work with the 'datetime' variable
% type, so I have to get around it on my own!
% NOTES: Can only handle 1 vector of x and y each
% NOTES: May not return vector in same dimension
% SEE ALSO: STAIR

%{
EXAMPLE:
[x_front y_front] = makeStair(x, y)
[x_middle y_middle] = makeStair(x, y, 'middle')
[x_back y_back] = makeStair(x, y, 'back')

subplot(311), plot(x_front, y_front)
hold on, plot(x,y,'*b'), xlim([0 11])

subplot(312), plot(x_middle, y_middle)
hold on, plot(x,y,'*b'), xlim([0 11])

subplot(313), plot(x_back, y_back)
hold on, plot(x,y,'*b'), xlim([0 11])
%}

% UPDATES:
% OCT 26 2015: Incorporates 'varargin', allows for 'front', 'middle',
% 'back' to be defined

%%

% stub data for testing
% x = 1:10;
% y = randn(1,10);


%% main

x.plot = varargin{1};
y.plot = varargin{2};


l = length(x.plot); % length of original vectors

% NOTE: this is a stupid temporary fix to get me past this issue for now
% until Jay and look at it.
if l<=1
    l=2;
    dx = 1;
else
    dx = x.plot(2) - x.plot(1); % gap between 2 two values
end


x.stair(1:l*2) = zeros;
y.stair(1:l*2) = zeros;

x.stair(1:2:l*2) = x.plot; % takes care of all odd indices
x.stair(2:2:l*2) = x.plot+dx; % takes care of all even indices
y.stair(1:2:l*2) = y.plot; % takes care of all odd indices
y.stair(2:2:l*2) = y.plot; % takes care of all even indices

%% Adjust for 'front', 'back', 'middle'

if nargin == 3
    
    switch varargin{3}
        
        case 'front'
            
            % do nothing
            
        case 'middle'
            
            x.stair = x.stair - dx/2;
            
        case 'back'
            
            x.stair = x.stair - dx;
            
        otherwise
            
            error('Variable was not understood.')
            
    end
    
end

%% Prep for output

x_stair = x.stair;
y_stair = y.stair;

%% Plotting routine for testing

% a(1) = subplot(211)
% plot(x,y)
% % xlim([x.stair(1) stair_x(end)])
% zoom xon
%
% a(2) = subplot(212)
% plot(stair_x, stair_y)
% % xlim([stair_x(1) stair_x(end)])
% zoom xon
% linkaxes(a,'x')

% end