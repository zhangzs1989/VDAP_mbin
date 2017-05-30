classdef SubspaceDetector
    %SUBSPACEDETECTOR Executes the NEIC Subspace JAR files and handles info
    %related to those programs
    % Specifically, SubspaceDetector holds the path to the JAR files. The
    % directory structure for these JAR files must be consistent with the
    % way the software is provided by the NEIC. I.e.,
    %
    %   |-> Subspace
    %       |-> preprocess
    %           |-> *Preprocess*.jar
    %       |-> subspace
    %           |-> *Subspace*.jar
    %
    
    properties
        
        software_folder; % location of 'Subspace' folder that holds NEIC Jar files
        
    end
    
    properties(Dependent)
        
        preprocjar; % filepath for the SubspacePreprocessor JAR file
        detectjar; % filepath for the SubspaceDetector JAR file
        
    end
    
    methods
        
        % constructor method
        function obj = SubspaceDetector(varargin)
            
            if nargin==0
                obj.software_folder = ' ';
            else
                
                inputs = parsePairedArgs(varargin);
                
                for n = 1:numel(inputs.name)
                    
                    switch lower(inputs.name{n})
                        
                        case 'software_folder'
                            
                            obj.software_folder = inputs.val{n};
                            
%                         case 'project_folder'
%                             
%                             obj.project_folder = inputs.val{n};
                            
                    end
                    
                end       
                            
            end
            
            test_java(obj)
            
        end
        
        % test Java connectivity
        function test_java(obj)
            
            warning('There is currently no known way to check whether or not the JAR files are working. Continue with the program.')
            
%             [status, cmdout] = system(['java -jar ' obj.preprocjar])
%             if status~=0
%                 error('Matlab''s Java version does not match the bash shell. Please change the Matlab environment variable to point to the system''s Java installation.')
%             end
            
        end
        
    end
    
    % GET METHODS FOR DEPENDENT VARIABLES
    methods
        
        % get filepath for 
        function val = get.preprocjar(obj)
            
            val = fullfile(obj.software_folder, 'preproc', 'SubspacePreprocessGitlab.jar');
            
        end
        
        % get file path for SubspaceDetectionGitlab.jar
        function val = get.detectjar(obj)
            
            val = fullfile(obj.software_folder, 'subspace', 'SubspaceDetectionGitlab.jar');
            
        end
        
    end
    
    methods(Static)
        
        % assumes that preprocessor put new cfg files in the ./ directory
        function move_new_cfg_files(cfg)
            
            warning('This code currently assumes that the new configuration files have been written to Matlab''s pwd and is moving them ot the project oflder.')
            
                movefile('./*.cfg', ...
                    fullfile(cfg.project_folder, cfg.name));

        end
        
    end
     
end

