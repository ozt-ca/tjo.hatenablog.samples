function varargout = svmdemo(varargin)
% SVMDEMO M-file for svmdemo.fig
%      SVMDEMO, by itself, creates a new SVMDEMO or raises the existing
%      singleton*.
%
%      H = SVMDEMO returns the handle to a new SVMDEMO or the handle to
%      the existing singleton*.
%
%      SVMDEMO('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SVMDEMO.M with the given input arguments.
%
%      SVMDEMO('Property','Value',...) creates a new SVMDEMO or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before svmdemo_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to svmdemo_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help svmdemo

% Last Modified by GUIDE v2.5 30-May-2003 19:48:05

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @svmdemo_OpeningFcn, ...
                   'gui_OutputFcn',  @svmdemo_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin & isstr(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before svmdemo is made visible.
function svmdemo_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to svmdemo (see VARARGIN)

% Choose default command line output for svmdemo
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes svmdemo wait for user response (see UIRESUME)
% uiwait(handles.figure1);
set(findobj('Tag', 'IncButton'), 'Enable', 'off');
set(findobj('Tag', 'StartButton'), 'Enable', 'off');
set(findobj('Tag', 'StopButton'), 'Enable', 'off');
set(findobj('Tag', 'LSVMradio'), 'Value', 1);
set(findobj('Tag', 'NLSVMradio'), 'Value', 0);
set(findobj('Tag', 'sig2Text'), 'Enable', 'off');
set(findobj('Tag', 'sig2Edit'), 'Enable', 'off');
global SVMopt; SVMopt = 1;


% --- Outputs from this function are returned to the command line.
function varargout = svmdemo_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in ResetButton.
function ResetButton_Callback(hObject, eventdata, handles)
% hObject    handle to ResetButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
resetSVM;

% リセット
function ret = resetSVM
global num1; num1 = 10; %入力データ群1の数
global num2; num2 = 10; %入力データ群1の数
global axsize; axsize = 6; % グラフの幅
global X; % 入力データ
global Y; % 教師データ
global W; % 重み係数
global gW; % 重み係数（ガウシアンカーネル）
global B; % バイアス係数
global gB; % バイアス係数（ガウシアンカーネル）
global Lambda; % ラグランジュ乗数ベクトル
global XforPlotAll; % プロット用ベクトル列
global YforPlotAll; % プロット用ベクトル列
global XforPlot1; % プロット用ベクトル列
global YforPlot1; % プロット用ベクトル列
global XforPlot2; % プロット用ベクトル列
global YforPlot2; % プロット用ベクトル列
global step; % 学習ステップ数
global sig2; % ガウシアンカーネルの分散
global G; % ガウシアンカーネルと教師信号の積行列
global stopFlg;
X1 = randn(2, num1) + 2*ones(2, num1);
X2 = randn(2, num2) - 2*ones(2, num2);
X = [X1, X2];
XforPlotAll = X(1, :);
YforPlotAll = X(2, :);
XforPlot1 = X1(1, :);
YforPlot1 = X1(2, :);
XforPlot2 = X2(1, :);
YforPlot2 = X2(2, :);
Y1 = ones(1, num1);
Y2 = -1*ones(1, num2);
Y = [Y1, Y2];
Lambda = ones(1, num1 + num2);
W = calcW(X, Lambda, Y);
gW = calcWgaussian(X, Lambda, Y);
B = calcB(Y, W, X);
sig2 = str2num(get(findobj('Tag', 'sig2Edit'), 'String'));
gB = calcBgaussian(Y, gW, X);
step = 0;
stopFlg = 1;
plotDots;
set(findobj('Tag', 'IncButton'), 'Enable', 'on');
set(findobj('Tag', 'StartButton'), 'Enable', 'on');
G = calcG(X, Y, sig2);
dispStep(step);

% W の算出
function W = calcW(X, Lambda, Y)
W = X*(Lambda.*Y)';

% B の算出
function B = calcB(Y, W, X)
global Lambda;
rindex = find(Lambda > 0);
B = Y(1, rindex(1, 1)) - W'*X(:, rindex(1, 1));

% gW の算出（ガウシアンカーネル）
function gW = calcWgaussian(X, Lambda, Y)
%for i = 1: size(X, 2)
%    for j = 1: size(X, 2)
%        gX(j, i) = gaussianKernel(X(:, i), X(:, j));
%    end
%end
%gW = gX*(Lambda.*Y)';
gW = (Lambda.*Y)';

% gB の算出（ガウシアンカーネル）
function gB = calcBgaussian(Y, gW, X)
global Lambda;
rindex = find(Lambda > 0);
for j = 1: size(X, 2)
    gx(j, 1) = gaussianKernel(X(:, rindex(1, 1)), X(:, j));
end
gB = Y(1, rindex(1, 1)) - gW'*gx;
X(:, rindex(1, 1))

% 点のプロット
function ret = plotDots
global num1; global num2;
global axsize;
global XforPlotAll; global YforPlotAll;
global XforPlot1; global YforPlot1;
global XforPlot2; global YforPlot2;
global Lambda;
global SVMopt;
% サポートベクター
svindex = find(Lambda > 0);
SVX = XforPlotAll(svindex);
SVY = YforPlotAll(svindex);
% プロット
plot(XforPlot1, YforPlot1, '.b', XforPlot2, YforPlot2, 'xr', SVX, SVY, 'ok');
hold on;
% 識別境界
if SVMopt == 1 % 線形SVM
    bX = boundary(0);
    plot(bX(1, :), bX(2, :), 'k');
    bX = boundary(1);
    plot(bX(1, :), bX(2, :), 'b');
    bX = boundary(-1);
    plot(bX(1, :), bX(2, :), 'r');
else % 非線形SVM
    for i = -axsize: axsize
        for j = -axsize: axsize
            retValue(j + axsize + 1, i + axsize + 1) = NLSVM([i j]');
        end
    end
    [C h] = contour([-axsize: axsize], [-axsize: axsize], retValue, [-10:10; -10:10]');
    clabel(C, h);
end
% 軸固定
axis([-axsize axsize -axsize axsize]); axis square;
hold off;
% 学習パラメータの表示
global Lambda; Lambda

% ステップ数の表示
function ret = dispStep(step)
set(findobj('Tag', 'StepDispText'), 'String', step);

% 識別境界座標計算
function X = boundary(ret)
global axsize;
bX = [-axsize axsize 0 0];
bY = [0 0 -axsize axsize];
bY(1) = calcBoundY(bX(1), ret);
bY(2) = calcBoundY(bX(2), ret);
bX(3) = calcBoundX(bY(3), ret);
bX(4) = calcBoundX(bY(4), ret);
index = find(bX > axsize);
bX(index) = []; bY(index) = [];
index = find(bX < -axsize);
bX(index) = []; bY(index) = [];
index = find(bY > axsize);
bX(index) = []; bY(index) = [];
index = find(bY < -axsize);
bX(index) = []; bY(index) = [];
X = [bX; bY];


function x = calcBoundX(y, ret)
global W; global B;
x = (ret - W(2, 1)*y - B)/W(1, 1);

function y = calcBoundY(x, ret)
global W; global B;
y = (ret - W(1, 1)*x - B)/W(2, 1);

% --- Executes on button press in IncButton.
function IncButton_Callback(hObject, eventdata, handles)
% hObject    handle to IncButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
incStep;
plotDots;

% 学習ステップのインクリメント
function ret = incStep
global Lambda;
global X;
global Y;
global W; global B;
global gW; global gB;
global SVMopt;

if SVMopt == 1 % 線形SVM
    Lambda = normalize(Lambda, Y); % 正規化
    Lambda = incLambda(Lambda, Y, X);
    W = calcW(X, Lambda, Y);
    B = calcB(Y, W, X);
elseif SVMopt == 2 % 非線形SVM
    Lambda = normalize(Lambda, Y); % 正規化
    Lambda = incLambdaGaussian(Lambda, Y, X);
    gW = calcWgaussian(X, Lambda, Y);
    gB = calcBgaussian(Y, gW, X);
else % オプションエラー
    % 何もしない
end


% ラグランジュ乗数の更新(最急降下法による)
function newLambda = incLambda(Lambda, Y, X)
Ytmp = ones(size(X, 1), 1)*Y;
YXtmp = (Ytmp.*X)';
XLambdaYtmp = X*(Lambda.*Y)';
dLambda = ones(size(Lambda)) - (YXtmp*XLambdaYtmp)';
newLambda = Lambda + 0.01*dLambda;
zeroindex = find(newLambda < 0);
newLambda(zeroindex) = 0;
global step;
step = step + 1;
dispStep(step);

% ガウシアンカーネルSVMのラグランジュ乗数の更新(最急降下法による)
function newLambda = incLambdaGaussian(Lambda, Y, X)
global G;
%dLambda = ones(size(Lambda)) - Y.*(G*Lambda')';
dLambda = ones(size(Lambda)) - (G*(Lambda.*Y)')';
newLambda = Lambda + 0.1*dLambda;
zeroindex = find(newLambda < 0);
newLambda(zeroindex) = 0;
global step;
step = step + 1;
dispStep(step);

% ラグランジュ乗数の正規化
function newLambda = normalize(Lambda, Y)
LambdaTmp = Lambda.*Y;
onesMatrix = ones(size(LambdaTmp));
posiindex = find(LambdaTmp > 0);
negaindex = find(LambdaTmp < 0);
posiLambda = LambdaTmp;
posiLambda(negaindex) = 0;
posisum = onesMatrix*posiLambda';
negaLambda = LambdaTmp;
negaLambda(posiindex) = 0;
negasum = onesMatrix*negaLambda';
ave = (posisum - negasum)/2;
newLambda = Lambda;
neganum = size(negaindex, 2);
posinum = size(posiindex, 2);
if neganum == 0
    index = find(Y < 0);
    newLambda(index) = ave/size(index, 2);
else
    newLambda(negaindex) = -(newLambda(negaindex)*ave)/negasum;
end
if posinum == 0
    index = find(Y > 0);
    newLambda(index) = ave/size(index, 2);
else
    newLambda(posiindex) = (newLambda(posiindex)*ave)/posisum;
end

% --- Executes on button press in StartButton.
function StartButton_Callback(hObject, eventdata, handles)
% hObject    handle to StartButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global stopFlg;
stopFlg = 0;
set(findobj('Tag', 'ResetButton'), 'enable', 'off');
set(findobj('Tag', 'IncButton'), 'enable', 'off');
set(findobj('Tag', 'StartButton'), 'enable', 'off');
set(findobj('Tag', 'StopButton'), 'enable', 'on');
while 1
    if stopFlg == 1
        break;
    end
    incStep;
    plotDots;
    drawnow;
end
set(findobj('Tag', 'ResetButton'), 'enable', 'on');
set(findobj('Tag', 'IncButton'), 'enable', 'on');
set(findobj('Tag', 'StartButton'), 'enable', 'on');
set(findobj('Tag', 'StopButton'), 'enable', 'off');

% --- Executes on button press in StopButton.
function StopButton_Callback(hObject, eventdata, handles)
% hObject    handle to StopButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global stopFlg;
stopFlg = 1;
plotDots;


% --- Executes on button press in LSVMradio.
function LSVMradio_Callback(hObject, eventdata, handles)
% hObject    handle to LSVMradio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of LSVMradio
global SVMopt;
SVMopt = 1;
set(findobj('Tag', 'sig2Text'), 'Enable', 'off');
set(findobj('Tag', 'sig2Edit'), 'Enable', 'off');
set(findobj('Tag', 'NLSVMradio'), 'Value', 0);

% --- Executes on button press in NLSVMradio.
function NLSVMradio_Callback(hObject, eventdata, handles)
% hObject    handle to NLSVMradio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of NLSVMradio
global SVMopt;
global G;
global X; global Y; global sig2;
SVMopt = 2;
set(findobj('Tag', 'sig2Text'), 'Enable', 'on');
set(findobj('Tag', 'sig2Edit'), 'Enable', 'on');
set(findobj('Tag', 'LSVMradio'), 'Value', 0);
G = calcG(X, Y, sig2);

% ガウシアンカーネルと教師信号の積行列
function G = calcG(X, Y, sig2)
for i = 1: size(X, 2)
    for j = 1: size(X, 2)
        G(i, j) = Y(1, i);
        K(i, j) = gaussianKernel(X(:, i), X(:, j));
    end
end
G = G.*K;

% ガウシアンカーネル
function ret = gaussianKernel(x1, x2)
global sig2;
abs2 = norm(x1 - x2);
abs2 = abs2*abs2;
ret = exp(-abs2/sig2);

% 非線形SVMの入出力
function ret = NLSVM(x)
global gW; global gB;
global X;
for i = 1: size(X, 2)
    fai(i, 1) = gaussianKernel(x, X(:, i));
end
ret = gW'*fai + gB;


% --- Executes during object creation, after setting all properties.
function sig2Edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sig2Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function sig2Edit_Callback(hObject, eventdata, handles)
% hObject    handle to sig2Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sig2Edit as text
%        str2double(get(hObject,'String')) returns contents of sig2Edit as a double
global sig2;
sig2 = str2num(get(findobj('Tag', 'sig2Edit'), 'String'));


