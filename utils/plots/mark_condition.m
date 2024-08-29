function pl = mark_condition(x,y,condition,c,markerStyle,markerSize)

    % remove data points for which specified condition is not fulfilled
    y(~condition)=[];
    x(~condition)=[];
    
    % plot scattered markers for all data points for which condition is
    % fulfilled
    pl = scatter(x,y,'Marker',markerStyle, 'MarkerEdgeColor', [0.2 0.2 0.2], ...
        'MarkerFaceColor',c, 'SizeData',markerSize, 'LineWidth',0.3);

end
