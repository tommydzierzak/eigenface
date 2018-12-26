function varargout = eigenface(varargin)
% EIGENFACE MATLAB code for eigenface.fig
%      EIGENFACE, by itself, creates a new EIGENFACE or raises the existing
%      singleton*.
%
%      H = EIGENFACE returns the handle to a new EIGENFACE or the handle to
%      the existing singleton*.
%
%      EIGENFACE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EIGENFACE.M with the given input arguments.
%
%      EIGENFACE('Property','Value',...) creates a new EIGENFACE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before eigenface_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to eigenface_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help eigenface

% Last Modified by GUIDE v2.5 15-Apr-2018 20:35:20

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @eigenface_OpeningFcn, ...
    'gui_OutputFcn',  @eigenface_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT
end

% --- Executes just before eigenface is made visible.
function eigenface_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to eigenface (see VARARGIN)

% Choose default command line output for eigenface
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes eigenface wait for user response (see UIRESUME)
% uiwait(handles.figure1);

end

% --- Outputs from this function are returned to the command line.
function varargout = eigenface_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
end

% --- Executes on button press in learn.
function learn_Callback(hObject, eventdata, handles)
% hObject    handle to learn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.match, 'String', 'Learning...','ForegroundColor','black');
set(handles.learn, 'String', 'Learning...Taking Photos','BackgroundColor',[.5 .5 .5],'Enable','inactive');
drawnow

cam=webcam;
pause(1)
for q=1:90
    img = snapshot(cam);
    imwrite(img,sprintf('%i.jpg',q))
end

r=90;             %number of images in training set
%place in current matlab folder labeled '1','2',...
filetype='.jpg';  %must be same resolution and filetype
scale=0.5;        %0-1 to vary resolution of images, small is faster


%settings
showtset=1;     %show training set images
showmeanimg=1;  %show the mean image
showeigface=0;  %show the eigenfaces
showdistance=1; %show euclidean distance between the test image and training set
showconstruc=1; %show reconstruction of test image from training set


%import images and convert to 1d vectors

set(handles.learn, 'String', 'Learning...Converting to 1d Vectors','BackgroundColor',[.5 .5 .5]);
drawnow


figure(2)
for k=1:r
    x=strcat(int2str(k),'.jpg');
    t=imread(x);
    try
        t=rgb2gray(t);
    catch
    end
    t=imresize(t,scale);
    [x, y]=size(t);
    rowcol=ceil(sqrt(r));
    if showtset==1;
        subplot('Position',[mod(k-1,rowcol)/rowcol 1-(ceil(k/rowcol)/rowcol) 1/rowcol 1/rowcol])
        imshow(t)
    end
    tset(:,k)=reshape(t',x*y,1);
end

if showtset==1;
    p=get(gcf,'Position');
    k=[y x]/(y+x);
    set(gcf,'Position',[p(1) p(2) (p(3)+p(4)).*k]);
    %suptitle('Training faces')
    movegui(figure(2),'onscreen')
end

%create the mean face
meanface=mean(tset,2);
if showmeanimg==1;
    meanimg=reshape(uint8(meanface),y,x);
    figure(3)
    imshow(meanimg');
    title('Mean image')
    movegui(figure(3),'onscreen')
end

%convert training set from uint8 to double

for k=1:r
    A(:,k)=double(tset(:,k));
end

set(handles.learn, 'String', 'Learning...Computing Eigenvectors','BackgroundColor',[.5 .5 .5]);
drawnow
%compute eigenvectors of the covariance matrix
L=A'*A;
[eigvect, eigval]=eig(L);
eigval=diag(eigval);

%get rid of 0 eigenvalues
count=1;
for k=1:size(L,2)
    if eigval(k)<1
    else
        eigvectnew(:,count)=eigvect(:,k);
        count=count+1;
    end
end
eigvect=eigvectnew;

set(handles.learn, 'String', 'Learning...Normalizing','BackgroundColor',[.5 .5 .5]);
drawnow
%normalize eigenvectors
for k=1:length(eigvect)
    eigvect(:,k)=eigvect(:,k)./norm(eigvect(:,k));
end

set(handles.learn, 'String', 'Learning...Finding Eignevectors','BackgroundColor',[.5 .5 .5]);
drawnow
%find eigenvectors of covariance matrix (eigenfaces)
for k=1:size(eigvect,2)
    eigface(:,k)=A*eigvect(:,k)./norm(A);
    eigface(:,k)=eigface(:,k)./norm(eigface(:,k));
end

set(handles.learn, 'String', 'Learning...Resizing Vectors','BackgroundColor',[.5 .5 .5]);
drawnow
%resize 1d vectors to original picture size and display eigenfaces
if showeigface==1;
    figure(4)
    colormap(gray);
    for k=1:size(eigvect,2)
        eigfacedisp{k}=reshape(eigface(:,k)',y,x);
        eigfacedisp{k}=eigfacedisp{k}';
        if showeigface==1;
            subplot('Position',[mod(k-1,rowcol)/rowcol 1-(ceil(k/rowcol)/rowcol) 1/rowcol 1/rowcol])
            imagesc(eigfacedisp{k}) %imagesc because the images aren't normed?
            axis off
            daspect([1 1 1])
        end
    end
    p=get(gcf,'Position');
    k=[y x]/(y+x);
    set(gcf,'Position',[p(1) p(2) (p(3)+p(4)).*k]);
    %suptitle('Eigenfaces')
    movegui(figure(4),'onscreen')
end

save('learned','x','y','A','eigface','meanface','showdistance','r','showconstruc','scale')

set(handles.learn, 'String', 'Learn New Face','BackgroundColor',[.94 .94 .94],'Enable','on');
set(handles.check, 'String', 'Check Face','BackgroundColor',[.94 .94 .94],'Enable','on');
set(handles.match, 'String', 'Face Learned','ForegroundColor','black');
drawnow
fprintf('done\n\n')
end

% --- Executes on button press in check.
function check_Callback(hObject, eventdata, handles)
% hObject    handle to check (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

load('learned')

set(handles.match, 'String', 'Checking...','ForegroundColor','black');
set(handles.check, 'String', 'Checking...Taking Test Photo','BackgroundColor',[.5 .5 .5],'Enable','inactive');
drawnow


%load and manipulate test face
cam=webcam;
pause(1)
img = snapshot(cam);
imwrite(img,'testpic.jpg')

set(handles.check, 'String', 'Learning...Loading Photos');
drawnow

t=imread('testpic.jpg');
try 
    t=rgb2gray(t);
catch
end
t=imresize(t,[x y]);
testpicvect=reshape(t',x*y,1);
testpicvect=double(testpicvect);

set(handles.check, 'String', 'Learning...Projecting Test Face');
drawnow

%projection of test face and training set
for k=1:size(A,2)
    for i=1:size(eigface,2)
        datasetproj(i,k)=dot(eigface(:,i),A(:,k));
    end
    testproj(:,k)=dot(eigface(:,k)',(testpicvect-meanface)');
end

set(handles.check, 'String', 'Learning...Calculating Distance');
drawnow

%distance between test face and training set
for k=1:size(eigface,2)
    distance(k)=norm(testproj(:)-datasetproj(:,k));
end

set(handles.check, 'String', 'Learning...Finding Most Similar Picture');
drawnow

%find min distance (Most similar face)
[minimum, index] = min(distance);
match=strcat(num2str(index),'.jpg');

if showdistance==1;
    figure()
    plot(1:length(distance),distance,'*',index,minimum,'o')
    title('Closeness of each picture')
    xlabel('Image number')
    axis([1 r 0 max(distance)+1])
    ylabel('Euclidean distance')
end

set(handles.check, 'String', 'Learning...Reconstructing Test Photo');
drawnow

%reconstruct test image from training set
if showconstruc==1;
    eigface=eigface./norm(eigface);
    for k = 1:size(eigface,2)
        p(k) = dot(testpicvect,eigface(:,k));
    end
    reconstructed=meanface+eigface*p(:);
    reconstructed=reshape(reconstructed',y,x);
end

set(handles.check, 'String', 'Learning...Displaying');
drawnow

%display original image, most similar image, and reconstructed image
if showconstruc==1
    k=3;
else k=2;
end
figure()
subplot(1,k,1)
imshow('testpic.jpg')
title('Test Picture')
subplot(1,k,2)
matchpic=imread(match);
try 
    t=rgb2gray(t);
catch
end
t=imresize(t,scale);
imshow(matchpic)
title(match)
if showconstruc==1;
    subplot(1,3,3)
    colormap(gray)
    imagesc(reconstructed')
    axis off
    daspect([1 1 1])
    title('Reconstructed picture')
end
%suptitle('Most Similar Image')

set(handles.match, 'String', minimum);

 if minimum<8e+04
     set(handles.match, 'String', 'MATCH','ForegroundColor','green');
 else
     set(handles.match, 'String', 'NO MATCH','ForegroundColor','red');
 end

set(handles.check, 'String', 'Check Face','BackgroundColor',[.94 .94 .94],'Enable','on');
 
disp(minimum)
end
