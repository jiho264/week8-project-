%% Preset.
clear;clf;
figure(2);
formula = stlread('formula.stl'); % formula
road = imread('road.jpeg');  % 바닥
FSD_road = imread('road.jpeg');  % FSD 바닥
ax=810; howmanycar = 60; color = randi([0 1],howmanycar,3)/3;
surf([-ax ax; -ax ax],[ax -ax],[0 0; 0 0],'CData',FSD_road,'FaceColor','texturemap');
xlabel('x');ylabel('y');
hold on; grid on; axis equal; box on; axis([-ax ax -ax ax 0 150]);
for i = 1:howmanycar
    Car{i} = patch(formula,'FaceColor',color(i,:),'EdgeColor','none');
    dataset{i} = [Car{1}.Vertices, ones(1,length(Car{1}.Vertices))']'*0.8;
end
alpha(0.7);
% 각 설정 값 * 차량대수있는 빈 행렬~~
now = zeros(howmanycar,5); turn = zeros(1,howmanycar);
% 차량들 기본위치 offset. 꺾고싶으면 yaw 하나하나 수정하셈 ^^
offset = [-155.95 -722.4 90; 623 156 360;-50 156 360;-722.4 156 360;517 -722.4 90;-722.4 -517 360;517 -50 90;-155.95 -50 90;-521.8 +722.4 270;    +517 +622.4 90;];
start = [offset;offset;offset;offset;offset;offset;offset;offset;offset;];
move = [offset;offset;offset;offset;offset;offset;offset;offset;offset;];
%% race
view(0,90)
for k = 1:15
    r = randi([0 4],1,howmanycar); % random turn setting
    for t = 1:30
        for i = 1:howmanycar
            if k==1
                r(1)=0;
                now(i,:) = go(t,r(i),move(i,3)/90,1); % 360이면 4, 240이면 3, 180이면 2, 90이면 1 방향. 초기 진행방향 설정해주기.
            else
                now(i,:) = go(t,r(i),now(i,4),now(i,5));
            end
            turn(i) = move(i,3) + now(i,3);
            move(i,(1:2)) = [move(i,1)+now(i,1) move(i,2)+now(i,2)];
            R_z = [cosd(turn(i)) -sind(turn(i)) 0 move(i,1); sind(turn(i)) cosd(turn(i)) 0 move(i,2); 0 0 1 0; 0 0 0 1];
            temp =  R_z * dataset{i};
            if i==1 % 카메라 시점 세팅
                cam_now=  temp((1:3),4895);
                cam_target=  temp((1:3),1);
            end
            if (abs(temp(1,4895))>ax ||abs(temp(2,4895))>ax) && t==30 % 만약 바깥으로 튀어나가면?
                move(i,:)=start(i,:); % 원래 출발 위치로 초기화!
                now(i,4) = move(i,3)/90; now(i,5) = 1; turn(i)=move(i,3);
            end
            Car{i}.Vertices = temp((1:3),:)';
        end
        drawnow limitrate; refresh;
        pause(0.1); d=1;
        line([cam_now(1,d) cam_target(1,d)],[cam_now(2,d) cam_target(2,d)],[cam_now(3,d) cam_target(3,d)],'Color','r','LineWidth',8);
    end
    for i = 1:howmanycar
        move(i,3) = turn(i); % 마지막에 돌은 각도 넣어주는 것
    end
end