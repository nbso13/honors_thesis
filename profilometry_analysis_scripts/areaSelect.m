function [mask] = areaSelect(resp, loc, aff_pop, index)
%areaSelect takes neurons for the given afferent class that are within the
%designated location (where the texture is in contact with the skin)

if index == 1
    logit = aff_pop.iPC;
elseif index == 2
    logit = aff_pop.iRA;
elseif index == 3
    logit = aff_pop.iSA1;
else
    error("index does not refer to known afferent type")
end

min_x = loc(1);
max_x = loc(2);
min_y = loc(3);
max_y = loc(4);

len_rates = length(resp.rate);
indices = 1:len_rates;
mask = zeros(1, len_rates);
affs = resp.affpop.afferents;

for i = indices %only take if 1) the right afferent 2) in x bounds and 3) in y bounds
    mask(i) = logit(i) && (min_x <= affs(i).location(1)) && ...
        (affs(i).location(1) < max_x) && ...  
        (min_y <= affs(i).location(2)) && ...
        (affs(i).location(2) < max_y) && ~(0 == resp.rate(i));
end
    
mask = logical(mask);
end

