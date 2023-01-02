clear; clf; close all; % 청소
video_file = VideoWriter("20191763_이지호_PROJECT.avi");
video_file.FrameRate = 5; open(video_file);
%% DATA LOAD
hFigure = figure(77); hFigure.Position = [10 500 1000 600]; % figure의 넘버링과 위치, 크기 설정.
hPanel1 = uipanel(hFigure,'Units','Normalized','Position',[0 2/3 1 1/3],'Title','Driver View'); % Driver View의 위치. 상단 전체.
hPanel2 = uipanel(hFigure,'Units','Normalized','Position',[0 0 1/3 2/3],'Title','Drone view');  % Drone View의 위치. 좌 하단.
hPanel3 = uipanel(hFigure,'Units','Normalized','Position',[1/3 0 1 2/3],'Title','JIsla FSD');   % JIsla FSD의 위치. 우 하단.
formula = stlread('formula.stl'); road = imread('road.jpeg'); FSD_road = imread('FSDroad.jpeg'); % formula 자동차 stl파일, 도로, 간략화 도로 load.
howmanycar = 20; ax=810; color = randi([0 1],howmanycar,3)/3; % 한 화면에 몇 대 굴릴 것인지?, plot 표시범위, 자동차들의 랜덤 색칠
for viewcopy=0:2 % plot이 3개니까 3번 반복.
    if viewcopy==0 % plot1. Normal road.
        hAxes1 = axes('Parent',hPanel1); surf([-ax ax; -ax ax],[ax -ax],[0 0; 0 0],'CData',road,'FaceColor','texturemap');
    elseif viewcopy==1 % plot2. Normal road.
        hAxes2 = axes('Parent',hPanel2); surf([-ax ax; -ax ax],[ax -ax],[0 0; 0 0],'CData',road,'FaceColor','texturemap');
    else  % plot3. FSD road.
        hAxes3 = axes('Parent',hPanel3); surf([-ax ax; -ax ax],[ax -ax],[0 0; 0 0],'CData',FSD_road,'FaceColor','texturemap');
    end
    hold on; grid on; axis equal; box on; axis([-ax ax -ax ax 0 150]); % graund와 같은 사이즈로 plot재단. 기본 설정 세팅.
    for i = 1:howmanycar % 각 plot에 대해 차량 대수만큼 반복.
        if viewcopy<=1 % Driver, Drone View 는 같은 랜덤 색의 자동차
            Car{i+howmanycar*viewcopy} = patch(formula,'FaceColor',color(i,:),'EdgeColor','none');
        else
            if i==1 % FSD View에선, EGO차량은 검정색, 나머지 차량들은 회색으로 색칠.
                Car{i+howmanycar*2} = patch(formula,'FaceColor','k','EdgeColor','none'); % plot3 EGO car color
            else
                Car{i+howmanycar*2} = patch(formula,'FaceColor',[0.5 0.5 0.5],'EdgeColor','none'); % plot3 SUB car color
            end
        end
        % 차량들의 선형변환을 위해 4 * length 행렬로 바꿔서 저장함. 이후 x,y,z값만 다시 patch data로 덮어씌움.
        dataset{i+howmanycar*viewcopy} = [Car{1}.Vertices, ones(1,length(Car{1}.Vertices))']'*0.8;
    end
    alpha(0.7); % 각 Plot의 투명도 설정
end
now = zeros(howmanycar,5); turn = zeros(1,howmanycar); % 차량의 이동과 각도를 저장할 변수들.
% 차량들 기본위치 offset. x, y 좌표와 초기 yaw각도가 들어있음. 중복위치 차량 대수가 많은 관계로 start, move가 길어저야함.
startpoint = [-155.95 -722.4 90; 623 156 360;-50 156 360;-722.4 156 360;517 -722.4 90;-722.4 -517 360;517 -50 90;-155.95 -50 90;-521.8 +722.4 270; +517 +622.4 90;];
start = [startpoint;startpoint;startpoint;startpoint;startpoint;startpoint;startpoint;startpoint;startpoint;];
move = [startpoint;startpoint;startpoint;startpoint;startpoint;startpoint;startpoint;startpoint;startpoint;];
% CAM preset
hAxes1.Projection="perspective"; % Driver View
hAxes1.CameraViewAngle=100; hAxes2.CameraViewAngle=60; hAxes3.CameraViewAngle=176; % plot들의 camera 앵글 각도. 180에 가까우면 맵 전체가 다 보임.
%% GO!
for k = 1:20 % 좌회전, 우회전, 통과, 직진 등 차량 1대당 n번 실행.
    r = randi([0 4],1,howmanycar); % random turn setting.
    for t = 1:30 % 한번 동작하는데 주어진 시간 30.
        for i = 1:howmanycar % 각 차량들마다 이동량을 계산함.
            if k==1
                r(1)=0;
                now(i,:) = go(t,r(i),move(i,3)/90,1); % 초기 yaw 각도가 360이면 4, 240이면 3, 180이면 2, 90이면 1 방향. 초기 진행방향 설정해주기.
            else
                now(i,:) = go(t,r(i),now(i,4),now(i,5));
            end
            % 현재 위치와 방향을 기반으로 함수를 통해 무작위의 변화량을 받아옴.
            % now(i,:)에서 값을 잘 빼내어, theta와 x, y변화량에 적용시킨다.
            turn(i) = move(i,3) + now(i,3);
            move(i,(1:2)) = [move(i,1)+now(i,1) move(i,2)+now(i,2)];
            R_z = [cosd(turn(i)) -sind(turn(i)) 0 move(i,1); sind(turn(i)) cosd(turn(i)) 0 move(i,2); 0 0 1 0; 0 0 0 1];
            temp =  R_z * dataset{i}; % 선형 변환된 행렬.
            % cam preset
            if i==1
                cam_now = temp((1:3),4895); cam_target = temp((1:3),423);
            end
            % 만약 바깥으로 튀어나가면? 초기화.
            if (abs(temp(1,4895))>ax ||abs(temp(2,4895))>ax) && t==30
                move(i,:)=start(i,:); now(i,4) = move(i,3)/90; now(i,5) = 1; turn(i)=move(i,3);
            end
            % 선형 변환 완료된 차량 데이터를, 새 patch data로 갱신시켜주기.
            % 모든 플롯에 대해 각 차량은 동일한 이동량을 보이니, 값 복사해주기.
            Car{i}.Vertices = temp((1:3),:)';
            Car{i+howmanycar*1}.Vertices = Car{i}.Vertices;
            Car{i+howmanycar*2}.Vertices = Car{i}.Vertices;
        end
        drawnow limitrate; refresh; pause(0.01);
        % plot CAM move offset
        hAxes1.CameraPosition=cam_now; hAxes1.CameraTarget = cam_target+[0 0 2.26]';
        hAxes2.CameraPosition=cam_now+[150 150 300]'; hAxes2.CameraTarget = cam_target;
        hAxes3.CameraPosition=cam_now+[0 0 200]'; hAxes3.CameraTarget = cam_target+[0 0 199]';
        %% recode
        frame = getframe(gcf);
        writeVideo(video_file,frame);
    end
    for i = 1:howmanycar
        move(i,3) = turn(i); % 마지막에 돌은 각도 넣어주는 것
    end
end
close(video_file);