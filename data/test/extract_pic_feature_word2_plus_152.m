clear;
netStruct = load('../data/res152_batch32_Rankloss_2:1:0.1_margin1_both_drop0.75_shift_hard_256_152x152/net-epoch-80.mat');
net = dagnn.DagNN.loadobj(netStruct.net);
clear netStruct;
net.mode = 'test' ;
net.move('gpu') ;
net.removeLayer('RankLoss');
net.conserveMemory = true;
im_mean = reshape(net.meta.normalization.averageImage,1,1,3);
load('../url_data.mat');
p = imdb.images.data(imdb.images.set==3);
ff = [];
%%------------------------------
for i = 1:1000
    disp(i);
    str = [ p{i}];
    %im = imread(['./Flickr30k/flickr30k-images-300/',str(34:end)]);
    im = imread(['.',str]);
    oim = im;   % or oim = im;
    f = getFeature2(net,oim,im_mean,'data','fc1_1bn');
    f = sum(sum(f,1),2);
    f2 = getFeature2(net,fliplr(oim),im_mean,'data','fc1_1bn');
    f2 = sum(sum(f2,1),2);
    f = f+f2;
    size4 = size(f,4);
    f = reshape(f,[],size4)';
    f = norm_zzd(f);
    ff = cat(1,ff,f);
end

save('../test/resnet_flikr30k_pool5_img.mat','ff','-v7.3');
%}

ff = [];
load('../Flickr30k/dense_feature_word2.1.mat');
test_set = find(imdb.images.set==3);

for i = 1:1000
    disp(i);
    for j=1:5
        index = 5*test_set(i)-5+j;
        %get vector
        content = wordcnn(:,index);
        len = sum(wordcnn(:,index)>0);
        txtinput = zeros(len,20074,'single');
        for k=1:len %32
            txtinput(k,content(k))=1;
        end
        %transfer it to different location       
        win = 33-len;
        input = zeros(32,20074,win,'single');
        for kk = 1:win
            input(kk:kk+len-1,:,kk) = txtinput;
        end
        
        input = reshape(input,1,32,20074,[]);
        f = getFeature2(net,input,[],'data2','fc6_2bn');
        f = sum(f,4);
        size4 = size(f,4);
        f = reshape(f,[],size4)';
        f = norm_zzd(f);
        ff = cat(1,ff,f);
    end
end
save('../test/resnet_flikr30k_pool5_txt.mat','ff','-v7.3');
%}
evaluate;