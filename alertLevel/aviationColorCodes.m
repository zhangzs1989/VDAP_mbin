%% AVO Aviation Color Codes

warning('This code is out of date. It will go away soon. Please use ''alertLevelSchema'' and ''createSchema'' instead.')

avicode.green = [0 0.7 0.3];
avicode.yellow = [1 1 0.4];
avicode.orange = [1 0.5 0];
avicode.red = [1 0.25 0.25];
avicode.unassigned = avicode.green;


%% Test view

figure;
rectangle('Position',[0 0 10 10],'FaceColor',avicode.green); hold on;
rectangle('Position',[10 0 10 10],'FaceColor',avicode.yellow); hold on;
rectangle('Position',[20 0 10 10],'FaceColor',avicode.orange); hold on;
rectangle('Position',[30 0 10 10],'FaceColor',avicode.red); hold on;
rectangle('Position',[40 0 10 10],'FaceColor',[1 1 1]); hold on;
