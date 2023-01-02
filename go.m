function sol = go(t,direction,now,goal)
% sol = [   x  ,  y  ,theta  , now(x,y)  ,   goal여부   ]
Lt_x =(t-26.935)^2/30; Lt_y = (t^2/50+0.125);
Lt_theta = (t^2/10);
Rt_x = (t^2/101); Rt_y = ((t-26.75)^2/60);
Rt_theta = -(t^2/10);
cross = 9.8; gotogoal = 12.625;
if direction>2 && goal==1
    sol = [0 0 0 now 1];
    return
end
%% case 1 ->
if now==1
    if goal==0
        sol = [gotogoal 0 0 1 0];
        if t==30
            sol(5)=1;
        end
    elseif direction==0 % x++ y++ 2
        sol = [Lt_x Lt_y Lt_theta 1 1];
        if t==30
            sol(4)=2; sol(5)=0;
        end
    elseif direction==1 % x++ 000 1
        sol = [cross 0 0 1 1];
        if t==30
            sol(5)=0;
        end
    elseif direction==2 % x++ y-- 4
        sol = [+Rt_y -Rt_x Rt_theta 1 1];
        if t==30
            sol(4)=4; sol(5)=0;
        end
    end
    %% case 2 ^^
elseif now==2
    if goal==0
        sol = [0 gotogoal 0 2 0];
        if t==30
            sol(5)=1;
        end
    elseif direction==0 % x-- y++ 3
        sol = [-Lt_y Lt_x Lt_theta 2 1];
        if t==30
            sol(4)=3; sol(5)=0;
        end
    elseif direction==1 % 000 y++ 2
        sol = [0 cross 0 2 1];
        if t==30
            sol(5)=0;
        end
    elseif direction==2 % x++ y++ 1
        sol = [Rt_x Rt_y Rt_theta 2 1];
        if t==30
            sol(4)=1; sol(5)=0;
        end
    end
    %% case 3 <-
elseif now==3
    if goal==0
        sol = [-gotogoal 0 0 3 0];
        if t==30
            sol(5)=1;
        end
    elseif direction==0 % x-- y-- 4
        sol = [-Lt_x -Lt_y Lt_theta 3 1];
        if t==30
            sol(4)=4; sol(5)=0;
        end
    elseif direction==1 % x-- 000 3
        sol = [-cross 0 0 3 1];
        if t==30
            sol(5)=0;
        end
    elseif direction==2 % x-- y++  2
        sol = [-Rt_y Rt_x Rt_theta 3 1];
        if t==30
            sol(4)=2; sol(5)=0;
        end
    end
    %% case 4 \/
elseif now==4
    if goal==0
        sol = [0 -gotogoal 0 4 0];
        if t==30
            sol(5)=1;
        end
    elseif direction==0 % x++ y-- 1
        sol = [Lt_y -Lt_x Lt_theta 4 1];
        if t==30
            sol(4)=1; sol(5)=0;
        end
    elseif direction==1 % 000 y-- 4
        sol = [0 -cross 0 4 1];
        if t==30
            sol(5)=0;
        end
    elseif direction==2 % x-- y-- 3
        sol = [-Rt_x -Rt_y Rt_theta 4 1];
        if t==30
            sol(4)=3; sol(5)=0;
        end
    end
end
end