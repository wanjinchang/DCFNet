function simple_net = deploy_transition_DCFNet(net)
input = 'target';
output = 'x';
simple_net = [];
simple_net.layers = [];
simple_net.meta.normalization.imageSize = [125,125,3];
simple_net.meta.normalization.averageImage = reshape(single([123,117,104]),[1,1,3]);

while ~strcmp(input,output)
    for i = 1:numel(net.layers)
        if numel(net.layers(i).inputs) == 1 && strcmp(net.layers(i).inputs{1},input)
            input = net.layers(i).outputs{1};
            if strcmp(net.layers(i).type,'dagnn.Conv')
                simple_net.layers{end+1} = struct(...
                    'name', net.layers(i).name, ...
                    'type', 'conv', ...
                    'weights', {{net.params(net.getParamIndex(net.layers(i).params{1,1})).value,...
                    net.params(net.getParamIndex(net.layers(i).params{1,2})).value}}, ...
                    'pad', floor(size(net.params(net.getParamIndex(net.layers(i).params{1,1})).value,1)/2), ...
                    'stride', net.layers(i).block.stride,...
                    'dilate',net.layers(i).block.dilate) ;
            elseif strcmp(net.layers(i).type,'dagnn.ReLU')
                simple_net.layers{end+1} = struct(...
                    'name', deal(net.layers(i).name), ...
                    'type', 'relu') ;
            elseif strcmp(net.layers(i).type,'dagnn.LRN')
                simple_net.layers{end+1} = struct(...
                    'name', deal(net.layers(i).name), ...
                    'type', 'lrn',...
                    'param',net.layers(i).block.param) ;
            else
                error('No such layer!');
            end
            continue;
        end
    end
end
