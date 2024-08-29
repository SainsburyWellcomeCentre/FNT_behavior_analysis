function [pl, b] = plot_shaded_error_bar(x, y, err, c, faceAlpha)
    curve1 = y + err;
    curve2 = y - err;
    b = fill([x', fliplr(x')], [curve1', fliplr(curve2')], c, FaceAlpha=faceAlpha, EdgeColor="none");
    pl = plot(x, y, 'LineWidth', 2, 'Color', c);
end