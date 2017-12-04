
img = im2double(imread('source11.PNG'));
img_pt = load('source11.mat');
shape_pt = double(img_pt.shape);



imgB = im2double(imread('ref11.PNG'));
imgB = (imgB);
% imgB = imgB(:,:,3);
ref_pt =load('ref11.mat');
shapeB = double(ref_pt.shape);

imgA = im2double(imread('ref12.PNG'));
% imgA = im2double(imread(fullfile(NASpath,'/Dropbox_MIT/MERL_facial/Old_Proc_045-201/s045-041022-02/refl/blend_015.png')));
imgA = (imgA);
% imgA = imgA(:,:,3);
ref_pt =load('ref12.mat');
shapeA = double(ref_pt.shape);


%%
tic
results = relight( ...
        img, ...
        shape_pt, ...
        imgA, ...
        shapeA, ...
        imgB, ...
        shapeB ...
    );


toc

subplot(221);imshow(img,[]);
subplot(222);imshow(imgA,[]);
subplot(223);imshow(imgB,[]);
subplot(224);imshow(results.out_img,[]);