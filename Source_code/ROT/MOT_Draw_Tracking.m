function [all_mot] = MOT_Draw_Tracking(Trk_sets, out_path, video_path, option)
%% Copyright (C) 2014 Seung-Hwan Bae
%% All rights reserved.

% Draw Tracking Results
if ~isfield(option,'new_thr'); 
    option.isdraw = 1;
    option.iswrite = 1;
    option.new_thr = 5; 
end
new_thr = option.new_thr;
all_mot = [];

reader = VideoReader(video_path);


for q=1:length(Trk_sets) % for each frames
    
    rgbimg = readFrame(reader);
    
    wind_lx=[];  wind_ly =[]; windw = []; windh = [];
    Labels =[]; trk_idx = [];  trk_sts =[]; conf = [];
    
    
    if q<=new_thr
        trk_idx = Trk_sets(new_thr+1).high;
        for i=1:length(trk_idx)
            states = Trk_sets(new_thr+1).states{trk_idx(i)};
            lab = Trk_sets(new_thr+1).label;
            trk_sts = zeros(1,length(trk_idx));
            if sum(states(:,q)) ~=0
                wind_lx = [wind_lx, states(1,q)];
                wind_ly = [wind_ly, states(2,q)];
                windw = [windw,states(3,q)];
                windh = [windh,states(4,q)];
                Labels = [Labels,lab(trk_idx(i))];
                conf(i)  = 0.33 + rand *0.33;
            end
        end
    else
        high = Trk_sets(q).high;
        low = Trk_sets(q).low;
        trk_idx = [high,low];
        
        for i=1:length(trk_idx)
            states = Trk_sets(q).states{trk_idx(i)};
            wind_lx = [wind_lx, states(1,end)];
            wind_ly = [wind_ly, states(2,end)];
            windw = [windw,states(3,end)];
            windh = [windh,states(4,end)];
            conf(i) = Trk_sets(q).conf(trk_idx(i));
        end
        if ~isempty(wind_cx)
            all_lab = Trk_sets(q).label;
            Labels = [all_lab(high), all_lab(low)];
        end
    end
    
    [wind_cx wind_cy] = CenterToLeft(wind_lx,wind_ly,windh,windw);
    
    
    %% Draw results
    if option.isdraw
        fg1 = gcf;
        mot_draw_confidence_boxes(rgbimg, wind_lx, wind_ly,windw,windh,Labels, conf);
        
        if ~exist(out_path);mkdir(out_path);end;
        
        out_filename = strcat(out_path,sprintf('Tracking_Results_%04d.jpg',q));
        
        if option.iswrite
            testImg= frame2im(getframe(fg1));
            imwrite(testImg, out_filename);
        end
    end
    disp([sprintf('Frame_%04d',q)]);
    
    %% Output
    if ~isempty(wind_cx)
        all_mot.cpos{q} = [wind_cx;wind_cy]; % center position
        all_mot.lpos{q} = [wind_lx;wind_ly]; % left-top position
        all_mot.size{q} = [windw;windh];     % size
        all_mot.lab{q} = Labels;             % labels
        all_mot.conf{q} = conf;
    end
    
end
end