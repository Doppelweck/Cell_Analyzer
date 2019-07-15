%-------------------------------------------------------------------------- 
% Imagealignment with ECC algorithm according to:
%
% "G.D.Evangelidis, E.Z.Psarakis, Parametric Image Alignment
% using Enhanced Correlation Coefficient.
% IEEE Trans. on PAMI, vol.30, no.10, 2008"
%--------------------------------------------------------------------------

% Set Name of .tiff sequence to save the aligned (warped) images
vidName ='Video_aligned12.tif';

% Set alignment parameters

alignIteration = 20; % number of iterationsS
init_warp_value = 5;  %initialization of shift for correlation 
NoL = 1;  % number of pyramid-levels %it's not working --> set to 1
transform = 'translation'; % Method of transformation --> only translation is working


%% Load image sequence

[FileName,PathName] = uigetfile('*.tif','Select the .tif file', 'MultiSelect', 'On');
imageCell = cell(1,numel(FileName)); % allocate memory for imageCell
imageCellaligned = cell(1,numel(FileName)); % allocate memory for aligned images
vec_final_warp = zeros(2,numel(FileName)); 

for i = 1: numel (FileName)
    imageCell{i} = imread( [PathName,FileName{i}] , 'tif', 'Index', 1);
    ctrl_read = i 
end

%%
%Assignment of first image as template
template_image=double(imageCell{1});
imageCellaligned{1} = double(imageCell{1});

[A,B,C]=size(template_image);
% if C==3     % RGB zu grayscale bild
%     template_image=rgb2gray(template_image);
% end


%% Alignment
init_warp = [init_warp_value;init_warp_value];
NoI = 2*alignIteration;
for i=2:1:numel(FileName)
   
    image_to_align=double(imageCell{i});
    [A,B,C]=size(image_to_align);
    
    % Convert image in grayscale and to type double
    if C==3     
        image_to_align=rgb2gray(image_to_align);
    end

    do_align = 1;
    while do_align > 0  
    % Follwing function calculates the aligned image
        [results,  vec_final_warp(1:2,i), warped_image]=...
            ecc(image_to_align, template_image,NoL, NoI, transform, init_warp);
        % is there a high image shift two subsequent images the 
        % number of correlation steps will be increased and image new
        % aligned
        if max(abs(vec_final_warp(:,i)-vec_final_warp(:,i-1))) > 2.5....
                && do_align < 2 
            do_align = do_align+1
            NoI = 2*alignIteration;
        else
            do_align = 0;
            NoI = alignIteration;
        end
    end
    init_warp = vec_final_warp(1:2,i);  % new start values for next alignment
    imageCellaligned{i} = warped_image; % aligned image in cell

    ctrl_loop = i   % Control output
end

 %% Write Video .tiff
for i=1:1:numel(FileName)
    imwrite(uint16(imageCellaligned{i}),vidName,'WriteMode','append')
    ctrl_video=i    % Control output
end 



%%
% vec_final_warp_pos=vec_final_warp;
% vec_final_warp_pos(1,1)=(max(vec_final_warp(1,:)));
% vec_final_warp_pos(2,1)=(max(vec_final_warp(2,:)));
% vec_final_warp_pos=floor(vec_final_warp_pos);
% 
% vec_final_warp_neg=vec_final_warp;
% vec_final_warp_neg(1,1)=(min(vec_final_warp(1,:)));
% vec_final_warp_neg(2,1)=(min(vec_final_warp(2,:)));
% vec_final_warp_neg=floor(vec_final_warp_neg);
% 
% vec_final_warp_pos(vec_final_warp<0)=0;
% vec_final_warp_neg(vec_final_warp>0)=0;
% 
% max_warp_array(1,1:numel(FileName)) = floor(max(vec_final_warp_pos(1,:)));
% max_warp_array(2,1:numel(FileName)) = floor(max(vec_final_warp_pos(2,:)));
% delta_warp_pos=max_warp_array-vec_final_warp_pos; 
% 
% min_warp_array(1,1:numel(FileName)) = floor(min(vec_final_warp_neg(1,:)));
% min_warp_array(2,1:numel(FileName)) = floor(min(vec_final_warp_neg(2,:)));
% delta_warp_neg=min_warp_array-vec_final_warp_neg; 
% 
%    Image=imageCell{i};
%     imageCellaligned{i}=Image(vec_final_warp_pos(1,i)-delta_warp_neg(1,i)+1:...
%         end+vec_final_warp_neg(1,i)-delta_warp_pos(1,i),...
%         vec_final_warp_pos(2,i)-delta_warp_neg(2,i)+1:end+vec_final_warp_neg(2,i)-delta_warp_pos(2,i));

%     imageCellaligned{i}=...
%         Image(1+vec_final_warp_pos(1,i)-delta_warp_neg(1,i):...
%         end+vec_final_warp_neg(1,i)-delta_warp_pos(1,i),...
%         1+vec_final_warp_pos(2,i)-delta_warp_neg(2,i):...
%         end+vec_final_warp_neg(2,i)-delta_warp_pos(2,i));






 