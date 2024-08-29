function std_error = get_std_error(x)

std_error = std(x, 'omitnan')/sqrt(sum(~isnan(x)));

end