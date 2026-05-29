%微信公众号搜索：淘个代码，获取更多免费代码
%禁止倒卖转售，违者必究！！！！！
%唯一官方店铺：https://mbd.pub/o/author-amqYmHBs/work，其他途径都是骗子！
%% Fuch混沌映射代码——————————来自公众号《淘个代码》
function result = Fuch( N, dim)
fuch =rand(N,dim);
for i=1:N
    for j=2:dim
        fuch(i,j)=abs(cos(1./fuch(i,j-1).^2));

    end
end
result = fuch;
end

%% 来自公众号《淘个代码》