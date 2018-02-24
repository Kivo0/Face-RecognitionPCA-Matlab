clear all;
clc;
dname = uigetdir('C:\MATH');
files = dir(cat(2,dname,'\*.txt'));
E = [1.0000;1.0000;1.0000;1.0000;1.0000];
% Fp is a matrix with predetermined positions
Fp = [13.0000 20.0000 1.0000;
    50.0000 20.0000 1.0000;
    34.0000 34.0000 1.0000;
    16.0000 50.0000 1.0000;
    48.0000 50.0000 1.0000];
%prepare variables to store coordinates of features(f),
%transformation(Anew) and updated coordinates after applying Anew (new_F)
f = cell(length(files),1);
Anew = cell(length(files),1);
new_F = cell(length(files),1);
iterations = 0;

for i=1:length(files) %open all files with coordinates
    f{i,1} = dlmread(cat(2,dname,'\',files(i).name));
    f{i,1} = cat(2,f{i,1},E);
end
%For the 1st iteration we put a first image into a matrix with averaged
%features F
Fnew = f{1,1}
F = zeros(5,3)
%Find best transformation and compare current F with a previous F. If the
%difference is big, repeat again.
while (abs(F(:,1:2)-Fnew(:,1:2)) > 0.0001)
    F = Fnew
    A=F\Fp
    Fnew = F*A
    accum = zeros(5,3);
    for i=1:length(files)
        Anew{i,1} = f{i,1}\Fnew;
        new_F{i,1} = f{i,1}*Anew{i,1};
        accum = accum + new_F{i,1};
    end;
    Fnew = accum/length(files);
    iterations = iterations+1;
end
%Once we have found best transformation, we have a matrix Fnew. We take it
%for each picture, find transformation A and then 
for n=1:size(files)
    F = f{n}; 
    A = F\Fnew;
    Ainv=A^(-1);
    point = cell(4096,1);%in order to store coordinates of pixels which 
%should be copied into a new image with the size 64x64
    l=1;
    for x=1:64
        for y=1:64
            point{l} = ceil(abs([x y 1]*Ainv));
            l=l+1;
        end
    end

    img = imread(char(strcat(files(n).name(1:end-4), '.jpg')));
    img = rgb2gray(img);
    imshow(img);
    impixelinfo;
    %output image 64x64. For each pixel out(i,j) it takes a pixel from original
    %image, coordinates of which are stored at point{k}.
    out = zeros(64,64);
    k=1;
    for i=1:64
        for j=1:64
            if (point{k}(1)>240)
                point{k}(1)=240;
            end
            out(j,i) = img(point{k}(2),point{k}(1));
            k=k+1;
        end
    end
    imshow(out,[]);

    %Save the new cropped picture
    out=out-min(out(:)); % shift data such that the smallest element of out image is 0
    out=out/max(out(:)); % normalize the shifted data to 1 
    path = 'C:\MATH\Cropped\';
    imwrite(out,[char(strcat(path, files(n).name(1:end-4), '.jpg'))]);
end




