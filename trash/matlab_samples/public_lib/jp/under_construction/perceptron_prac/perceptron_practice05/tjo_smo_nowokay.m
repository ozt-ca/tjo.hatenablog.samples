function alpha_smo=tjo_smo_nowokay(x_list,y_list,e_list,alpha,delta,Cmax,loop,clength,learn_stlength)

% global x_list y_list e_list alpha delta Cmax loop clength learn_stlength;

wvec=zeros(clength,1);
bias=0;
% alphaは最初なのでオール0の配列が読み込まれている

alldata=true; % 全てのデータを処理する場合
changed=false; % 変更があったことを示す
E_cache=zeros(clength,1);

while(alldata||changed)
    for lp=1:50000
        changed=false;
        z=0;
        lastchange=true;
        
        for j=1:clength
            % 基準点2を選ぶ
            alph2=alpha(j);
            if(~alldata && (alph2 <= 0 || alph2 >= Cmax)) % 0 < alpha < Cmaxの点だけ処理する
                continue;
            end;
            if(lastchange) % 初回やデータが変わった時にキャッシュをクリア
                E_cache=zeros(clength,1);
            end;
            lastchange=false;
            
            t2; % 保留
            fx2=calcE(j); % 後でcalcEを記述
            
            % KKT条件の判定
            r2 = fx2 * t2;
            if(~((alph2 < Cmax && r2 < -tol) || (alph2 > 0 && r2 > tol))) % KKT条件を満たすなら処理しない
                continue;
            end;
            
            % 基準点1を選ぶ
            % 選択法1
            i=0;
            offset_tmp=randperm(clength);
            offset=offset_tmp(1);
            
            max_val=-1;
            for ll=1:clength
                l = mod((ll + offset),clength); % 剰余の計算がmodなのでした
                % 0 < alpha < Cmax
                if(0>=alpha(l) || c<=alpha(l))
                    continue;
                end;
                dif=abs(calcE(l)-fx2);
                if(dif > max_val)
                    max_val=dif;
                    i=l;
                end;
            end;
            if(max_val>=0)
                if(step(i,j))
                    % 処理をしたら次へ
                    changed=true;
                    lastchange=true;
                    continue;
                end;
            end;
            % 選択法2
            offset_tmp=randperm(clength);
            offset=offset_tmp(1); % ランダムな位置から
            for l=1:clength
                % 0 < alpha < Cmax
                i=mod((l+offset),clength);
                if(0>=alpha(i) || Cmax<=alpha(i))
                    continue;
                end;
                if(step(i,j))
                    % 処理をしたら次へ
                    changed=true;
                    lastchange=true;
                    continue;
                end;
            end;
            % 選択法3
            offset_tmp=randperm(clength);
            offset=offset_tmp(1); % ランダムな位置から
            for l=1:clength
                i=mod((l+offset),clength);
                if(step(i,j))
                    % 処理をしたら次へ
                    changed=true;
                    lastchange=true;
                    continue;
                end;
            end;
        end;
        
    end;
end;

end