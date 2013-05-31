function GC_plain_R2012b(it,Mlag1,Mlag2)
%%
% it: ブートストラップ回数。2000回もあれば十分だが、必要なp値によって変える必要あり。

%%
% GUIでファイルを読み込む。
% 便宜上"rawadata"という配列を読み込むことにさせてある。
% お好みで変更されたし。

[fname,pname]=uigetfile('*.mat','Input a name of the data file');
load(fname);

%%
% 取得したデータ配列を整形する。
% 原則としてノード（行方向）×時系列データ（列方向）の書式でないと
% このツールボックスは動かない。

[nodesNum,length]=size(rawdata);
dat=zeros(nodesNum,length);

% ノードごとに時系列データをz変換で正規化する。

for n=1:nodesNum
    dat(n,:)=zscore(rawdata(n,:));
end;

%%
% 探索ラグ最大値を設定する。
% 全時系列長の半分より長いラグを仮定したGCAは無意味なので、
% それ以下の値を指定しておく。
% 1はテスト値用、2はブートストラップ標本用。
% 必ずしも分ける必要はないが、後者は大抵最適ラグが小さくなる。

% 何らかの基準で自動で決めてしまっても良いが、
% 何に着目するかによっても変える必要があるので、
% 事前に手入力で決められた方が良いと思われる。
% なお、Mlag1 > Mlag2の方が無難。
% ランダム時系列の最適ラグは往々にしてかなり短くなる。

% Mlag1 = floor(length/2);
% Mlag2 = Mlag1;

%%

%%%%%%%%%%%%%%%%%%%%%%%%%
% テスト値の計算ルーチン %
%%%%%%%%%%%%%%%%%%%%%%%%%

% 1) まず最適ラグをcca_find_model_order関数で算出する。
% 2変数とも最適ラグの値であり、BICやAICの値そのものではない点に注意。

[bic,aic]=cca_find_model_order(dat,2,Mlag1);

% 2) 次に偏グレンジャー因果指数をcca_partialgc関数で算出する。
% 返値は構造体。

[ret]=cca_partialgc(dat,aic,1);

% 3) 構造体retを分解して変数に保存する。
% *.gcは因果性グラフマトリクス、*.fgは因果性指数強度(logF)、
% *.doifgは因果性指数強度のさらにノード間相互差(difference of influence)。
% 最近の研究ではこのDOIが最も信頼性が高いとされている。

gcv=ret.gc;fsv=ret.fg;div=ret.doifg;
gcv(isnan(gcv)==1)=0;
fsv(isnan(fsv)==1)=0;
div(isnan(div)==1)=0;
    
%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ブートストラップ標本の計算ルーチン %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ブートストラップ標本は後でテスト値と順位和検定で比較するので、
% 配列ではなくセルとして保存する。

    for i=1:it % it回ブートストラップ計算
        bdat=zeros(nodesNum,length); % ブートストラップ・ランダムデータのもと
        seqb=zeros(nodesNum,length); % ランダム化された時系列インデックスのもと。ラテン方格の方がベター。
        for r=1:nodesNum
            seqb(r,:)=randperm(length); % まず時系列インデックスをランダムソートする。ノードごとに作る。
        end;
        for r=1:nodesNum
            for j=1:length
                bdat(r,j)=dat(r,seqb(r,j)); % ノードごとにデータ時系列をバラバラにしてブートストラップ標本を作る。
            end;
        end;
    
% 後はテスト値の時と同じように計算するだけ。

        [bicb,aicb]=cca_find_model_order(bdat,1,Mlag2);
        [bret]=cca_partialgc(bdat,aicb,1);
        x1=bret.gc;x2=bret.fg;x3=bret.doifg;
        x1(isnan(x1)==1)=0;
        x2(isnan(x2)==1)=0;
        x3(isnan(x3)==1)=0;
        gcbv{i}=x1;fsbv{i}=x2;dibv{i}=x3;
        fprintf(1,'\n　　　　　　　　　　　　　　　　　　　　　　bootstrap %d AIC %f\n\n',i,aicb);
    end;

%%    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ブートストラップ統計値の算出 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 興味があるのはfs(=*.fg)とdoi(=*.doifg)だけなので、
% この2つのゼロ配列を作っておく。

    tmpfs=zeros(nodesNum,nodesNum);
    tmpdoi=zeros(nodesNum,nodesNum);

% ここからはGCマトリクス配列の各要素ごとに統計値を計算する。
    
    for i=1:nodesNum
        for j=1:nodesNum
            btfs=[];btdoi=[]; % ブートストラップ標本加算の準備
            for k=1:it % ここで膨大なブートストラップ標本を連結させる
                btfs=[btfs;fsbv{k}(i,j)];
                btdoi=[btdoi;dibv{k}(i,j)];
            end;
            % 連結されたブートストラップ標本とテスト値との統計的差異を
            % 順位和検定で評価する。
            % statsにz値が入るので、これをp値の代わりとする。
            [p,h,stats1]=ranksum(fsv(i,j),btfs);
            [p,h,stats2]=ranksum(div(i,j),btdoi);
            % z値をstatsテーブルから抜いてきて保存する。
            tmpfs(i,j)=stats1.zval;
            tmpdoi(i,j)=stats2.zval;
        end;
    end;
    zfs=tmpfs;
    zdoi=tmpdoi;

%%
% 得られたz値を配列として保存し、ファイルに出力して終了。
save gcdata_computed.mat gcv fsv div zfs zdoi bic aic;
end