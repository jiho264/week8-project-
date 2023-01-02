clear; clf; close all; %% DATA LOAD
hFigure = figure(77); hFigure.Position = [10 500 1000 600]; 
hPanel1 = uipanel(hFigure,'Units','Normalized','Position',[0 2/3 1 1/3],'Title','Driver View'); 
hPanel2 = uipanel(hFigure,'Units','Normalized','Position',[0 0 1/3 2/3],'Title','Drone view'); 
hPanel3 = uipanel(hFigure,'Units','Normalized','Position',[1/3 0 1 2/3],'Title','JIsla FSD');   
formula = stlread('formula.stl'); road = imread('road.jpeg'); FSD_road = imread('FSDroad.jpeg'); 
howmanycar = 15; ax=810; color = randi([0 1],howmanycar,3)/3;
for viewcopy=0:2
    if viewcopy==0 
        hAxes1 = axes('Parent',hPanel1); surf([-ax ax; -ax ax],[ax -ax],[0 0; 0 0],'CData',road,'FaceColor','texturemap');
    elseif viewcopy==1 
        hAxes2 = axes('Parent',hPanel2); surf([-ax ax; -ax ax],[ax -ax],[0 0; 0 0],'CData',road,'FaceColor','texturemap');
    else  
        hAxes3 = axes('Parent',hPanel3); surf([-ax ax; -ax ax],[ax -ax],[0 0; 0 0],'CData',FSD_road,'FaceColor','texturemap');
    end
    hold on; grid on; axis equal; box on; axis([-ax ax -ax ax 0 150]);
    for i = 1:howmanycar 
        if viewcopy<=1
        Car{i+howmanycar*viewcopy} = patch(formula,'FaceColor',color(i,:),'EdgeColor','none');
        else
            if i==1
                Car{i+howmanycar*2} = patch(formula,'FaceColor','k','EdgeColor','none'); 
            else
            Car{i+howmanycar*2} = patch(formula,'FaceColor',[0.5 0.5 0.5],'EdgeColor','none'); 
            end
        end
        dataset{i+howmanycar*viewcopy} = [Car{1}.Vertices, ones(1,length(Car{1}.Vertices))']'*0.8;
    end
    alpha(0.7);
end
now = zeros(howmanycar,5); turn = zeros(1,howmanycar); 
startpoint = [-155.95 -722.4 90; 623 156 360;-50 156 360;-722.4 156 360;517 -722.4 90;-722.4 -517 360;517 -50 90;-155.95 -50 90;-521.8 +722.4 270; +517 +622.4 90;];
start = [startpoint;startpoint;startpoint;startpoint;startpoint;startpoint;startpoint;startpoint;startpoint;];
move = [startpoint;startpoint;startpoint;startpoint;startpoint;startpoint;startpoint;startpoint;startpoint;];
hAxes1.Projection="perspective"; hAxes1.CameraViewAngle=100; hAxes2.CameraViewAngle=60; hAxes3.CameraViewAngle=176; 
for k = 1:20 %% GO!
    r = randi([0 4],1,howmanycar); 
    for t = 1:30 
        for i = 1:howmanycar 
            if k==1
                now(i,:) = go(t,r(i),move(i,3)/90,1); r(1)=0;
            else
                now(i,:) = go(t,r(i),now(i,4),now(i,5));
            end
            turn(i) = move(i,3) + now(i,3);
            move(i,(1:2)) = [move(i,1)+now(i,1) move(i,2)+now(i,2)];
            R_z = [cosd(turn(i)) -sind(turn(i)) 0 move(i,1); sind(turn(i)) cosd(turn(i)) 0 move(i,2); 0 0 1 0; 0 0 0 1];
            temp =  R_z * dataset{i};
            if i==1
                cam_now = temp((1:3),4895); cam_target = temp((1:3),423);
            end
            if (abs(temp(1,4895))>ax ||abs(temp(2,4895))>ax) && t==30
                move(i,:)=start(i,:); now(i,4) = move(i,3)/90; now(i,5) = 1; turn(i)=move(i,3);
            end
            Car{i}.Vertices = temp((1:3),:)';
            Car{i+howmanycar*1}.Vertices = Car{i}.Vertices;
            Car{i+howmanycar*2}.Vertices = Car{i}.Vertices;
        end
        drawnow limitrate; refresh; pause(0.01);
        hAxes1.CameraPosition=cam_now; hAxes1.CameraTarget = cam_target+[0 0 2.26]';
        hAxes2.CameraPosition=cam_now+[150 150 300]'; hAxes2.CameraTarget = cam_target;
        hAxes3.CameraPosition=cam_now+[0 0 200]'; hAxes3.CameraTarget = cam_target+[0 0 199]';
    end
    for i = 1:howmanycar
        move(i,3) = turn(i); 
    end
end