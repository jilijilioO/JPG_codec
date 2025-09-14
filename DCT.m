
%%%%%%%%%%完成一个矩阵的编码和解码
%        
% array=[112,111,112,111,112,111,112,111;113,113,113,113,113,113,113,113;116,116,116,116,116,115,115,115;119,119,119,119,119,119,119,119;123,124,124,124,124,123,123,123;124,126,126,126,126,125,126,125;126,126,127,126,127,126,127,126;126,126,127,126,127,126,127,126];
% array=[182,191,171,196,103,39,65,58;182,178,193,185,159,76,54,57;185,172,197,177,198,135,48,57;188,180,180,181,192,184,70,54;189,184,175,184,181,197,125,51;187,179,189,183,187,188,178,68;185,178,192,183,181,184,195,116;185,184,181,186,162,191,186,162];
% n=quantify_func(array);
%         ac=ac_encode_func(n);
%         dc=dc_encoding_func(n(1,1),0);
%         code=char(strcat(dc,ac));
% 
%  mat=uint8(reconfig_picture(decode,0));
%  disp(class(mat));
 
% % 展示第一张图像
% subplot(1, 2, 1);  % 创建一个1x2的子图像表格，并选择第一个子图
% imshow(uint8(img_after));  % 展示第一张图像
% title('Image After Processing');  % 设置标题
% 
% % 展示第二张图像
% subplot(1, 2, 2);  % 选择第二个子图
% imshow(img_YCbCr);  % 展示第二张图像
% title('image');  % 设置标题
%%
%读取图片数据 包括 长宽 RGB值
img = imread('picture1.png');
%将RGB值转换为YCbCr
img_YCbCr=rgb2gray(img);
%对图像块进行划分，并对每个图像块执行二维DCT
disp(size(img_YCbCr));
size_img=size(img_YCbCr);
%图片大小
rows = size_img(1);
cols = size_img(2);
%depth = size_img(3);

%子矩阵大小
sub_rows = 8;
sub_cols = 8;
 
% 计算划分数量
num_submatrices = rows / sub_rows * cols / sub_cols;

% 初始化存储子矩阵的单元格数组
sub_matrices = cell(num_submatrices, 1);
encode_matrices=cell(num_submatrices, 1);
decode_matrices=cell(num_submatrices, 1);
count = 1;
img_after=zeros(rows, cols);
lenth_code=0;
for i = 1:sub_rows:rows
    for j = 1:sub_cols:cols
        % 提取子矩阵
        
        sub_matrix = img_YCbCr(i:i+sub_rows-1, j:j+sub_cols-1);
        % 存储子矩阵
        sub_matrices{count}= sub_matrix;
        %编码子矩阵
        %disp(sub_matrix);
        n=quantify_func(sub_matrix);
        ac=ac_encode_func(n);
        dc=dc_encoding_func(n(1,1),0);
        code=char(strcat(dc,ac));
        encode_matrices{count}= code;
        %解码矩阵
         disp(code);
         disp(numel(code));
         lenth_code=lenth_code+numel(code);
         decode=decode_code(code);
         mat=reconfig_picture(decode,0);
         decode_matrices{count}= mat;
         disp(sub_matrix);
         disp(code);
         img_after(i:i+sub_rows-1,j:j+sub_cols-1)=mat;
         
         
        % 更新计数器
        count = count + 1;
        disp('count');
        disp(count);
        
    end
     
end

 
% 展示第一张图像
subplot(1, 2, 1);  % 创建一个1x2的子图像表格，并选择第一个子图
imshow(uint8(img_after));  % 展示第一张图像
title('Image After Processing');  % 设置标题

% 展示第二张图像
subplot(1, 2, 2);  % 选择第二个子图
imshow(img_YCbCr);  % 展示第二张图像
title('image');  % 设置标题

%%
%反量化

function matrix=reconfig_picture(F,last_dc)

%zigzag扫描，放回到二维数组中

%last_dc=12;
matrix = zeros(8);

% 初始化扫描方向为向上
direction = 'up';

% 初始化起始位置
row = 1;
col = 1;

% 逐个遍历矩阵的元素
for i = 1:64
    if i>=numel(F)
        break
    end
     matrix(row,col)=F(1,i);
    
    % 根据当前扫描方向更新行和列的值
    if strcmp(direction, 'up')
        if col == 8
            row = row + 1;
            direction = 'down';
        elseif row == 1
            col = col + 1;
            direction = 'down';
        else
            row = row - 1;
            col = col + 1;
        end
    elseif strcmp(direction, 'down')
        if row == 8
            col = col + 1;
            direction = 'up';
        elseif col == 1
            row = row + 1;
            direction = 'up';
        else
            row = row + 1;
            col = col - 1;
        end
    end
end

matrix(1,1)=matrix(1,1)+last_dc;
disp(matrix);
q_light_array=[16 11 10 16 24 40 51 61;
    12 12 14 19 26 58 60 55;
    14 13 16 24 40 57 69 56;
    14 17 22 29 51 87 80 62;
    18 22 37 56 68 109 103 77;
    24 35 55 64 81 104 113 92;
    49 64 78 87 103 121 120 101;
    72 92 95 98 112 100 103 99];
matrix=matrix.*q_light_array;
disp(matrix);
matrix=idct2(matrix);

matrix=round(matrix+128);


end

%%
%解码
function F=decode_code(code)
encoding_table_dc=struct('diff1',{0,1,3,7,15,31,63,127,255,511,1023,2047},'diff2',{0,1,2,4,8,16,32,64,128,256,512,1024},'ssss',{0,1,2,3,4,5,6,7,8,9,10,11},'light_code',{'00','010','011','100','101','110','1110','11110','111110','1111110','11111110','111111110'});
opts = detectImportOptions('encoding_ac.txt');
opts.Delimiter = '\t';
opts.VariableNamesLine = 0;
opts.VariableTypes = {'char','double','char'};
encoding_table_ac=readtable('encoding_ac.txt', opts);
%code='0111111011010000000001110001010';
count=1;
location=1;
str=string([]);
% disp(numel(code));
%dc解码
for j=1:8
for i=1:12
   
    if string(code(location:location+count))==string(encoding_table_dc(i).light_code)
        s=encoding_table_dc(i).ssss;
        %location=location+s;
%         disp('s');
%         disp(code(location:location+count));
   
        if s~=0
       
        elseif s==0
            s=1;
        end
        dc=code(location+count+1:location+count+s);
        location=location+count+s;
      
        
         if dc(1)=='1'
             
             dc=bin2dec(dc);
         elseif dc(1)=='0'
             for m=1:numel(dc)
                  if dc(m)=='1'
                       dc(m)='0';
                  elseif  dc(m)=='0'
                       dc(m)='1';
                  end
             end
             dc=-bin2dec(dc);
         end
       
        break;
    end
    
end

if location~=1
    break;
end
count=count+1;
end
 
find=false;
 
ac=string([]);
% disp('location');
% disp(location);
while location<numel(code)
   count=1; 
for j=1:16
           
          
    for i=1:numel(encoding_table_ac.C)
           %disp([string(code(location+1:location+count)),string(encoding_table_ac.A(i)),string(encoding_table_ac.C(i))])
          if string(code(location+1:location+count))==string(encoding_table_ac.C(i))
              s=char(encoding_table_ac.A(i));
              find=true;
             
              len=str2double(s(3));
              %判断是不是有连续16个0.此次不存储后面的值
              if string(s)~='F/0'
              ac_value=code(location+count+1:location+count+len);
               
              %二进制数转回到十进制
              if isempty(ac_value)~=true
              if ac_value(1)=='1' 
                 ac_value=bin2dec(ac_value);
              elseif ac_value(1)=='0'
                 for m=1:numel(ac_value)
                    if ac_value(m)=='1'
                       ac_value(m)='0';
                    elseif  ac_value(m)=='0'
                       ac_value(m)='1';
                    end
                 end
                  ac_value=-bin2dec(ac_value);
              end
              end
              %code=
              m=str2double(s(1));
 
               %往矩阵中存储0
              while m>0
                  ac=[ac,0];
                  m=m-1;
              end
              
              ac=[ac,ac_value];
              
              elseif string(s)=='F/0'
                m=str2double(s(1));

              while m>0
                  ac=[ac,0];
                  m=m-1;
              end

              end
              
              location=location+count+str2double(s(3));
              break;
          end
           
    end
    
   %判断是否找到
   if find==true
       find=false;
       break

   end
   %字符串长度+1
   count=count+1;
end
 
 
end
F=[dc,ac];

end



%%
%量化

function F=quantify_func(array)

for i = 1:8
    for j = 1:8
        array(i,j)=array(i,j)-128;
        %disp(array(i, j)); % 打印当前位置的值
    end
end
%进行dct变换
array_dct=dct2(array);

%引入亮度量化矩阵
q_light_array=[16 11 10 16 24 40 51 61;
    12 12 14 19 26 58 60 55;
    14 13 16 24 40 57 69 56;
    14 17 22 29 51 87 80 62;
    18 22 37 56 68 109 103 77;
    24 35 55 64 81 104 113 92;
    49 64 78 87 103 121 120 101;
    72 92 95 98 112 100 103 99];
%量化
F=round(array_dct./q_light_array);
end

%% 


function ac_encode=ac_encode_func(F)
%AC编码
encoding_table_ac=struct('diff1',{0,1,3,7,15,31,63,127,255,511,1023},'diff2',{0,1,2,4,8,16,32,64,128,256,512},'ssss',{0,1,2,3,4,5,6,7,8,9,10});
%读取ac编码表
opts = detectImportOptions('encoding_ac.txt');
opts.Delimiter = '\t';
opts.VariableNamesLine = 0;
opts.VariableTypes = {'char','double','char'};
data = readtable('encoding_ac.txt', opts);

%zigzag扫描

% 初始化扫描方向为向上
direction = 'down';
% 初始化起始位置
row = 1;
col = 2;
a= zeros(1, 63);
% zigzag扫描逐个遍历矩阵的元素
count=0;
str=string([]);
m=1;
ac_encode=string([]);
for i = 1:63
   
   a(1,i)= F(row, col);
   
   if a(1,i)==0
       count=count+1;

   else 
       %查找
       %获取二进制数对应大小
       for j=1:numel(encoding_table_ac)
            if ((encoding_table_ac(j).diff2<=a(1,i))&&(a(1,i)<=encoding_table_ac(j).diff1))||((-encoding_table_ac(j).diff1<=a(1,i))&&(a(1,i)<=-encoding_table_ac(j).diff2))
                ac_prefix=encoding_table_ac(j).ssss;
            end
       end
       %判断两个值中间有几个0
       while count>=16
           %%%%%%连续15个以上的0 
           ac_encode=[ac_encode,data.C(152)];
           count=count-16;
       end

      value=data.A;
      %将数值转为2进制， 若为负数则取反
      if a(1,i)>0
          ac=dec2bin(a(1,i));
      elseif a(1,i)<0
          ac=dec2bin(-a(1,i));
      for j = 1:numel(ac)
        if ac(j)=='1'
          ac(j)='0';
        elseif  ac(j)=='0'
          ac(j)='1';
        end 
      end
      end
      str(m)=[dec2hex(count),'/',dec2hex(ac_prefix)];
      %查找码表 搜索并完成编码
      for k=1:numel(value)
          if value(k)==str(m)
                 ac_encode=[ac_encode,data.C(k),ac];
          end
          
      end
       
      count=0;
      m=m+1;
   end
   
    % zigzag根据当前扫描方向更新行和列的值
    if strcmp(direction, 'up')
        if col == 8
            row = row + 1;
            direction = 'down';
        elseif row == 1
            col = col + 1;
            direction = 'down';
        else
            row = row - 1;
            col = col + 1;
        end
    elseif strcmp(direction, 'down')
        if row == 8
            col = col + 1;
            direction = 'up';
        elseif col == 1
            row = row + 1;
            direction = 'up';
        else
            row = row + 1;
            col = col - 1;
        end
    end
end
    %在最后添加eob
   if a(1,63)==0
        str(m)=['0','/','0'];
        ac_encode=[ac_encode,data.C(1)];
   end
%完成字符串的连接
ac_encode = strjoin(ac_encode,'');
end



%%
function dc=dc_encoding_func(dc,last_dc)
%dc编码
%dc编码表
encoding_table=struct('diff1',{0,1,3,7,15,31,63,127,255,511,1023,2047},'diff2',{0,1,2,4,8,16,32,64,128,256,512,1024},'ssss',{0,1,2,3,4,5,6,7,8,9,10,11},'light_code',{'00','010','011','100','101','110','1110','11110','111110','1111110','11111110','111111110'});
%前一个子块dc与本子块dc的差值
dc=dc-last_dc;
%前缀编码
for i=1:numel(encoding_table)
    if ((encoding_table(i).diff2<=dc)&&(dc<=encoding_table(i).diff1))||((-encoding_table(i).diff1<=dc)&&(dc<=-encoding_table(i).diff2))
        dc_prefix=encoding_table(i).light_code;
    end
end
%后缀编码

if dc>=0
    dc_end = dec2bin(dc); % 将十进制数转换为二进制数
   
elseif dc<0
    dc_end=dec2bin(-dc);
     % 负数取反
    for j = 1:numel(dc_end)
        if dc_end(j)=='1'
          dc_end(j)='0';
        elseif  dc_end(j)=='0'
          dc_end(j)='1';
        end
    end
     
end

dc=[dc_prefix,dc_end];
 
end

