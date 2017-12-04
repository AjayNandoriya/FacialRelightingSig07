% Perform face relighting based on reference images
%
% Peers, Pieter, et al. "Post-production facial performance relighting 
% using reflectance transfer." ACM Transactions on Graphics (TOG)26.3 (2007)
%
% result = img*imgRefA/imgRefB
function results = relight(img, pt, imgRefA, ptRefA, imgRefB, ptRefB)
    results= struct();
    % morphing the reference images
    scaleA = max(size(img,1)/size(imgRefA,1),size(img,2)/size(imgRefA,2));
    imgRefA = imresize(imgRefA, scaleA);    ptRefA = ptRefA*scaleA;
    scaleB =  max(size(img,1)/size(imgRefB,1),size(img,2)/size(imgRefB,2));
    imgRefB = imresize(imgRefB,scaleB);     ptRefB = ptRefB*scaleB;
    
    imgRefA = morph(imgRefA, ptRefA, pt); imgRefA = imgRefA(1:size(img,1), 1:size(img,2),:);
    imgRefB = morph(imgRefB, ptRefB, pt); imgRefB = imgRefB(1:size(img,1), 1:size(img,2),:);
    
    % create the mask of convex hull of pt
    [X,Y] = meshgrid(1:size(img, 2), 1:size(img, 1));
    ch = convhulln(pt);
    mask = inpolygon(X,Y,pt(ch(:,1),1),pt(ch(:,1),2));
    margin = 5;
    xpro = sum(mask, 1); ypro = sum(mask, 2);
    left = max(find(xpro>0, 1 )-margin, 0); right = min(find(xpro>0, 1, 'last' )+margin, size(mask, 2));
    up = max(find(ypro>0, 1 )-margin, 0); down = min(find(ypro>0, 1, 'last' )+margin, size(mask, 1));
    rect = [left, up, right-left+1, down-up+1];
    
    results.mask= mask;
    results.rect = rect;
    mask = imcrop(mask, rect);
    mask = repmat(mask,[1 1 size(imgRefA,3)]);
    imgRefA = imcrop(imgRefA, rect).*mask; 
    imgRefB = imcrop(imgRefB, rect).*mask;
    
    hsv_image = rgb2hsv(imcrop(img, rect));
    hsv_image = hsv_image.*mask;
    img_crop = hsv2rgb(hsv_image);
    
    % calculate the ratio image and remove some of the spikes
    C = (imfilter(imgRefA,fspecial('average', win), 'same')+0.001)./(imfilter(imgRefB,fspecial('average', win), 'same')+0.001);
    C = C.*mask;
    
    % perform illumination transform using Ratio 
    I_ratio_filtered = sig07(C,imgRefA,imgRefB);
    I_out = I_ratio_filtered.*img_crop;
    
    results.out_img = zeros(size(img));
    results.out_img(rect(2)-1 +(1:size(I_out,1)),rect(1)-1+(1:size(I_out,2)),:)=I_out;
   
end